require File.join(File.dirname(__FILE__), 'puzzle_box')

$box = PuzzleBox.new

def move(x,y,z)
  if $box.occupy(x,y,z)
    $box  
  else
    "Illegal move (#{x}, #{y}, #{z})"
  end
end

def undo
  $box.undo
  $box
end

def restart
  $box.reset!
  $box
end

def create(x,y,z,side=8)
  PuzzleBox.new(x,y,z,side)
end

def box; $box; end

