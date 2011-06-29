class Formatter
  attr_reader :puzzlebox
  attr_accessor :debug
  
  def initialize(puzzlebox, debug=false)
    @puzzlebox = puzzlebox
    @debug = debug
  end
  
  def format
    output = "goal: (#{puzzlebox.goal[0]}, #{puzzlebox.goal[1]}, #{puzzlebox.goal[2]})\n"
    puzzlebox.points.each_with_index do |layer, i|
      output += x_axis_label + "\n"
      layer.each_with_index { |row, j| output += (rowify(row,i,j) + "\n") }
      output += "\n"
    end
    
    output += "moves: #{puzzlebox.occupied.empty? ? 'none' : puzzlebox.occupied.collect {|p| "(#{p[0]}, #{p[1]}, #{p[2]})"}.join(', ')}\n"
    output += "\t***Solved!***\n" if puzzlebox.solved?
    output += "\t**Unlocked!**\n" if puzzlebox.partially_solved?
    output
  end
  
  def x_axis_label
    axis = '|'
    0.upto(puzzlebox.side - 1) do |i|
      axis += (i%10 == 0 && i > 0) ? "*|" : "#{i%10}|"
    end
    axis
  end
  
  def rowify(row, i, j)
    output = (' ' * (j - (j.to_s.length - 1))) + "#{j}\\"
    row.each_with_index {|space, k| output += "#{squarify(k, j, i)}\\"}
    output += " [#{i}]" if (puzzlebox.side/2 == j)
    output
  end
  
  def squarify(x, y, z)
    if puzzlebox.goal?(x, y, z)
      return 'g'
    elsif puzzlebox.occupied?(x, y, z)
      return 'o'
    elsif @debug
      squarify_debug(x,y,z)
    else
      return ' '
    end
  end
  
  def squarify_debug(x,y,z)
    if puzzlebox.threatened_by_goal?(x,y,z)
      return puzzlebox.points[x][y][z] ? 'X' : '*'
    else
      return puzzlebox.points[x][y][z] ? 'X' : ' '
    end
  end
end
