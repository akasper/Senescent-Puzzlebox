class LargeFormatter
  attr_reader :puzzlebox, :per_layer
  def initialize(puzzlebox, debug=false)
    @puzzlebox = puzzlebox
    @debug = debug
    @per_layer = (puzzlebox.side**0.5).ceil
  end
  
  def format
    output = "goal: (#{puzzlebox.goal[0]}, #{puzzlebox.goal[1]}, #{puzzlebox.goal[2]})\n"
    (0...per_layer).each do |layer|
      output += z_axis_labels(layer)
      output += x_axis_labels(layer)
      (0...puzzlebox.side).each do |row|
        (0...per_layer).each do |stack|
          y = row
          z = stack + (per_layer * layer)
          output += rowify(y,z) if puzzlebox.real?(0, y, z)
        end
        output += "\n"
      end
      output += "\n"
    end
    output += "moves: #{puzzlebox.occupied.empty? ? 'none' : puzzlebox.occupied.collect {|p| "(#{p[0]}, #{p[1]}, #{p[2]})"}.join(', ')}\n"
    output += "\t***Solved!***\n" if puzzlebox.solved?
    output += "\t**Unlocked!**\n" if puzzlebox.partially_solved?
    output
  end
  
  def x_axis_labels(layer=0)
    output = ' |'
    0.upto(puzzlebox.side - 1) do |i|
      output += (i%10 == 0 && i > 0) ? "*|" : "#{i%10}|"
    end
    output += "\t"
    axis = ''
    (0...per_layer).each { |i| axis += output if puzzlebox.real?(0,0,layer*per_layer + i)}
    output = axis
    output += "\n"
  end
  
  def z_axis_labels(layer=0)
    output = ''
    (0...per_layer).each do |i|
      z = i + (layer * per_layer)
      if puzzlebox.real?(0,0,z)
        output += ' ' + (' ' * (puzzlebox.side)) + "z:#{i + layer*per_layer}" + (' ' * (puzzlebox.side)) + "\t"
      end
    end
    output += "\n"
  end
  
  def rowify(y,z)
    output = "#{(y%10 == 0 && y > 0) ? "*|" : "#{y%10}|"}"
    (0...puzzlebox.side).each { |x| output += "#{squarify(x,y,z)}|"}
    output += "\t"
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
