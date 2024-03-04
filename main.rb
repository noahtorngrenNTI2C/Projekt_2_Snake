=begin
Noah Törngren
2024-02-28

Detta program ska vara spelet snake
Med piltangenterna ska man kunna styra ormen. Spelet tar slut när ormen har åkt in i en vägg eller ormen har åkt in i sig själv.
Med ruby2d kan ett fönster ritas ut

Programmet består av två klasser: Snake och Game. En update funktion som körs vid varje frame och en event hanterare 
som körs när en tangent är nedtryckt

=end
require 'ruby2d'

set background: 'black'
set fps_cap: 10
#grid size 20 pixels
SQUARE_SIZE = 20
#for default window size of 480px * 640px, width is 32 (640/20) and height is 24 (480/20) at grid size = 20 pixels
GRID_WIDTH = Window.width / SQUARE_SIZE
GRID_HEIGHT = Window.height / SQUARE_SIZE
#classen snake med alla metoder som handlar om ormen, har inga konstuktor parametrar
class Snake
  attr_writer :direction
#instance variables begin with @. uninitialized instance variables have the value nil
#first coordinate is x axis and second is y axis, starting from top left corner
  def initialize
    @positions = [[2, 0], [2, 1], [2, 2], [2 ,3]]
    @direction = 'down'
    @growing = false
  end

  #retunerar arrayen positions
  def positions
    return @positions
  end

  # ritar ut ormen
  def draw
    head_x, head_y = head_position
    
    case @direction
    when 'up' then Sprite.new('img/snake_head.png', x: head_x * SQUARE_SIZE, y: head_y * SQUARE_SIZE, width: SQUARE_SIZE, height: SQUARE_SIZE, rotate: 180)
    when 'down' then Sprite.new('img/snake_head.png', x: head_x * SQUARE_SIZE, y: head_y * SQUARE_SIZE, width: SQUARE_SIZE, height: SQUARE_SIZE, rotate: 0)
    when 'left' then Sprite.new('img/snake_head.png', x: head_x * SQUARE_SIZE, y: head_y * SQUARE_SIZE, width: SQUARE_SIZE, height: SQUARE_SIZE, rotate: 90)
    when 'right' then Sprite.new('img/snake_head.png', x: head_x * SQUARE_SIZE, y: head_y * SQUARE_SIZE, width: SQUARE_SIZE, height: SQUARE_SIZE, rotate: -90)
    end


    @positions[0..-2].each do |position|
      Square.new(x: position[0] * SQUARE_SIZE, y: position[1] * SQUARE_SIZE, size: SQUARE_SIZE - 1, color: 'olive')
    end
  end

  # låter ormen växa
  def grow
    @growing = true
  end
#.shift moves all elements down by one
# Denna metod flyttar på ormen. Inga parametrar och retunerar inget
  def move
    if !@growing
      @positions.shift
    end

    @positions.push(next_position)
    @growing = false
  end
#En metod som kollar vilken riktning som är möjlig. Parametrar string new_direction
  def can_change_direction_to?(new_direction)
#Ett case statement som gör så new_direction inte blir motsatten
    case @direction
    when 'up' then new_direction != 'down'
    when 'down' then new_direction != 'up'
    when 'left' then new_direction != 'right'
    when 'right' then new_direction != 'left'
    end
  end

  # x positionen av huvudet på ormen 
  def x
    head[0]
  end

  # y positionen av ormen
  def y
    head[1]
  end

  # nästa position på huvudet
  def next_position
    if @direction == 'down'
      new_coords(head[0], head[1] + 1)
    elsif @direction == 'up'
      new_coords(head[0], head[1] - 1)
    elsif @direction == 'left'
      new_coords(head[0] - 1, head[1])
    elsif @direction == 'right'
      new_coords(head[0] + 1, head[1])
    end
  end
#Om ormen har åkt in i sig själv
  def hit_itself?
    @positions.uniq.length != @positions.length
  end

  #kollar om ormen kör in i väggen
  def hit_wall?
    if @positions.last[0] > GRID_WIDTH || @positions.last[0] < 0
      return true
    end

    if @positions.last[1] > GRID_HEIGHT || @positions.last[1] < 0
      return true
    end
    return false
  end

  private
  # alla privata metoder som Snake klassen har

  # Denna metod var för att ormen skulle kunna köra igenom väggar. Har ändrats. Parametrar int x, x värdet på ormens huvud och int y y positionen på ormens huvud. Retunerar parametrarna
  def new_coords(x, y)
    #[x % GRID_WIDTH, y % GRID_HEIGHT] <-- om man ska kunna åka igenom väggen
    [x , y ]
  end
  # retunerar kordinaterna på huvudet på ormen vilket är en array
  def head
    @positions.last
  end

  # retunerar kordinaterna på huvudet på ormen
  def head_position
    head
  end

end
#Game classen som har avsvar för logiken i spelet, har inga konstuktor parametrar
class Game
  def initialize # initierar classens variabler
    @ball_x = 10
    @ball_y = 10
    @score = 0
    @finished = false
  end
  #Ritar äppet och texten 
  def draw
    Sprite.new('img/apple.png',x: @ball_x * SQUARE_SIZE, y: @ball_y * SQUARE_SIZE, width: SQUARE_SIZE, height: SQUARE_SIZE)
    Text.new(text_message, color: 'white', x: 10, y: 10, size: 25, z: 1)
  end
 #en metod som kollar om omen äter äpplet. Parametrar: int x, int y. x och y kordinaterna på ormens huvud
  def snake_hit_ball?(x, y)
    @ball_x == x && @ball_y == y
  end
#ny slumpad position för äpplet. Parametrar: positions en array med ormens delars positioner
  def random_position(positions)
    x = rand(Window.width / SQUARE_SIZE)
    y = rand(Window.height / SQUARE_SIZE)

    positions.each do |position|
      if x == position[0] && y == position[1]
        return random_position(positions)
      end
    end
    return x, y
  end
  
  # ändrar scoret och hämtar en ny position för äpplet. Parametrar: positions en array med ormens delars positioner
  def record_hit(positions)
    @score += 1
    x,y = random_position(positions)
    @ball_x = x
    @ball_y = y
  end

  # avslutar spelet
  def finish
    @finished = true
  end

  # kollar om spelet är klart. Retunerar boolean @finished
  def finished?
    @finished
  end

  private
  # alla privata metoder och variabler

  # vad som ska skrivas
  def text_message
    if finished?
      "Game over, Your Score was #{@score}. Press 'R' to restart. "
    else
      "Score: #{@score}"
    end
  end
end

snake = Snake.new
game = Game.new

# update loopen kör kontenueligt
update do
  clear

  unless game.finished?
    snake.move
  end

  snake.draw
  game.draw

  if game.snake_hit_ball?(snake.x, snake.y)
    game.record_hit(snake.positions)
    snake.grow
  end

  if snake.hit_wall? 
    game.finish
  end

  if snake.hit_itself?
    game.finish
  end
end
#game loop logic

#nuvarande tid
current_time = Time.now.to_f
#när en tangent ärn nedtryckt
on :key_down do |event|
  if Time.now.to_f - current_time >= 0.05 # Så att ormen inte kan svänga för fort 
    if ['up', 'down', 'left', 'right'].include?(event.key)
      if snake.can_change_direction_to?(event.key) # om svängen är möjlig
        snake.direction = event.key # ändrar riktningen
      end
    end
    current_time = Time.now.to_f # ändrar tiden till nuvarande tid
  end
  if game.finished? && event.key == 'r'
    snake = Snake.new
    game = Game.new
  end
end

show