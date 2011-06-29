require File.join(File.dirname(__FILE__), 'formatter')
require File.join(File.dirname(__FILE__), 'large_formatter')

class PuzzleBox
  attr_accessor :points
  attr_reader   :goal, :side, :occupied
  
  def initialize(x=0,y=0,z=0,side=8)
    @goal = [x,y,z]
    @side = side
    reset!
    $box = self
  end
  
  #all points except the goal are threatened or occupied
  def solved?
    solved = true
    0.upto(@side-1) do |x|
      0.upto(@side-1) do |y|
        0.upto(@side-1) do |z|
          solved &&= points[x][y][z] || occupied.include?([x,y,z]) || goal == [x,y,z]
        end
      end
    end
    solved
  end
  
  #all points surrounding the goal point are threatened
  def partially_solved?
    !points[goal[0]][goal[1]][goal[2]] && goal_adjacencies.all? { |adjacency| points[adjacency[0]][adjacency[1]][adjacency[2]] } 
  end
  
  # def mostly_solved?
  #   #all points that the goal point threatens are set
  # end
  
  def occupy(x, y, z)
    set = pointset(x, y, z)
    if all_settable?(set)
      occupied << [x, y, z]
      set_all(set)
      true
    else
      false
    end
  end
  
  def occupied?(x, y, z)
    occupied.include?([x,y,z])
  end
  
  def threatened_by_goal?(x, y, z)
    threatened_by_goal.include?([x,y,z])
  end
  
  def threatened_by_goal
    @threatened_by_goal ||= in_every_direction(goal[0], goal[1], goal[2], @side)
  end
  
  def undo
    @occupied.pop
    temp = @occupied.dup
    reset!
    temp.each {|p| occupy(p[0], p[1], p[2])}
  end
  
  def settable?(x, y, z)
    !occupied?(x, y, z) && !goal?(x, y, z)
  end
  
  def all_settable?(set=[])
    set.all? {|p| settable?(p[0], p[1], p[2])}
  end
  
  def goal?(x, y, z)
    [x, y, z] == goal
  end
  
  def occupied?(x, y, z)
    occupied.include?([x, y, z])
  end
  
  def set!(x, y, z)
    points[x][y][z] = true
  end
  
  def set_all(set)
    set.each {|p| set!(p[0], p[1], p[2])}
  end
  
  def goal_adjacencies
    in_every_direction(goal[0], goal[1], goal[2], 1)
  end
  
  def pointset(x, y, z)
    in_every_direction(x, y, z, @side)
  end
  
  def in_every_direction(x, y, z, distance=1)
    set = []
    0.upto(distance) do |d|
      set += DIRECTIONS.collect { |vector| [x + vector[0]*d, y + vector[1]*d, z + vector[2]*d] if real?(x + vector[0]*d, y + vector[1]*d, z + vector[2]*d)}
    end
    set.reject! &:nil?
    set.uniq!
    set.sort! {|a,b| a.inspect <=> b.inspect}
    set
  end
  
  def real?(x, y, z)
    x >= 0 && x < @side && y >= 0 && y < @side && z >= 0 && z < @side
  end
  
  def formatter
    @formatter ||= @side > 7 ? LargeFormatter.new(self) : Formatter.new(self)
  end

  def to_s
    "#{formatter.format}"
  end
  
  def reset!
    @points = @side.times.inject([]) do |rows|
      rows << @side.times.inject([]) do |aisles|
        aisles << @side.times.inject([]) do |columns|
          columns << false
        end
      end
    end
    @formatter = nil
    @threatened_by_goal = nil
    @occupied = []    
    self
  end
  
private
  def self.vectors
    return @vectors if @vectors
    @vectors = []
    (-1..1).each do |x|
      (-1..1).each do |y|
        (-1..1).each do |z|
          @vectors << [x, y, z] unless x == 0 && y == 0 && z == 0
        end
      end
    end
    @vectors
  end
  
public
  DIRECTIONS = self.vectors unless defined? DIRECTIONS  
end
