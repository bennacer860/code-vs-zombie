require 'byebug'
require 'ruby2d'

BOARD_MAX_X = 1600
BOARD_MAX_Y = 900
ZOMBIE_SPEED = 4
ASH_SPEED = 4
GUN_RADIUS = 20

class Parent
    attr_accessor :x, :y, :id, :game, :target
    def initialize x, y, id, speed, game
      @x, @y, @id, @speed, @game = x, y, id, speed, game
      @target = nil
    end

    def distance_from_point(point_x,point_y)
      sum_of_squares = (point_x-@x)**2+(point_y-@y)**2
      Math.sqrt( sum_of_squares )
    end

    def move_towards_coordinates(x,y)
      # Rotate us to face the player
      rotation = Math.atan2(y - @y, x - @x);

      # Move towards the player
      @x += Math.cos(rotation) * @speed;
      @y += Math.sin(rotation) * @speed;
    end

    # if there is no target, get a random one and move towards it
    def move_towards_target(targets)
      if @target.nil?
        @target = get_new_target(targets)
      end

      move_towards_coordinates(@target.x, @target.y)
      [@x, @y]
    end

    # get a random target
    def get_new_target(targets)
      # byebug
      # puts "get_new_target #{targets.each(&:id)}"
      targets.sample
    end

    def to_s
      "#{@x}, #{@y}, :id #{@id}"
    end

    def draw(color)
      # Square.new(x: @x, y: @y, size: 5, color: color)
      Circle.new(x: @x, y: @y, radius: 10, color: color)
      Text.new("#{@id}", x: @x-5, y: @y-5, color: 'black', size: 10) if @id
    end

    def move
      # for now it will move randomly
      next_move_x = [@x, @x+@speed, @x-@speed].reject{|value| value < 0 || value > BOARD_MAX_X}.sample
      next_move_y = [@y, @y+@speed, @y-@speed].reject{|value| value < 0 || value > BOARD_MAX_Y}.sample
      @x = next_move_x
      @y = next_move_y
      [@x, @y]
    end

    def has_target?
      @target.nil?
    end

    def check_if_target_is_in_radius(target_x, target_y, blast_radius)
      self.distance_from_point(target_x, target_y) <= blast_radius
    end
end

class Human < Parent; end

class Zombie < Parent

  # get a random target
  def get_new_target(targets)
    # pick the closest target
    targets.sort_by do |target|
      self.distance_from_point(target.x, target.y)
    end.first
  end
end

class Ash < Parent
end

class Game
  attr_accessor :ash,
    :humans,
    :zombies,
    :current_state,
    :game_over,
    :score,
    :history,
    :number_of_turns

  def initialize
    @humans  = []
    @zombies = []
    @ash = Ash.new(0,0,0,4,nil)
    @game_over = false
    @score = 0
    @history = []
    @zombie_history = []
    @number_of_turns = 0
  end

  # play next move
  def next_sate
    # count the number of turns before we end the game
    # possibly use it when deciding best next move
    @number_of_turns += 1

    # do not calculate next state actions if game is over
    return if @game_over

    # if a zombie if targeting a human that has been eaten already
    # select new target
    @zombies.each do |zombie|
      if !@humans.include?(zombie.target)
        zombie.target = nil
      end
    end

    # remove if humans are dead
    # aka same coordinate as a zombie
    zombies_coordinates = @zombies.map{|z| [z.x, z.y]}
    @humans.delete_if do |human|
        @zombies.any? do |zombie|
          if human.check_if_target_is_in_radius(zombie.x, zombie.y, ZOMBIE_SPEED)
            debug "Human #{human} has been eaten by a zombie #{zombie}"
            zombie.target = nil
            true
          else
            false
          end
        end
    end

    # remove if zombies are dead
    # aka in the radius of Ash's gun
    @zombies.delete_if do |zombie|
        # A zombie is worth the number of humans still alive squared x10, not including Ash
        # TODO get a more accurate score calculation with the combos
        # if zombie.distance_from_point(@ash.x, @ash.y) <= GUN_RADIUS
        if zombie.check_if_target_is_in_radius(@ash.x, @ash.y, ASH_SPEED)
            @score += @humans.count * 10
            debug "Ash shot zombie #{zombie}"
            # target shot, allow ash to change target
            @ash.target = nil
            true
        else
            false
        end
    end

    # check if the game is over
    if @zombies.count == 0 || @humans.count == 0
      @game_over = true
      debug "game is over : zombies #{@zombies.count}, humans #{@humans.count}, score #{@score}"
    end

    ########## Move randomly ash and zombies #############

    # @history << @ash.move_towards_target(@zombies)
    if !@game_over
      @ash.move_towards_target(@zombies)
      @history << [@ash.x, @ash.y]
      debug "Ash #{@ash}"
      @zombies.each do |zombie|
        @zombie_history << zombie.move
        zombie.move_towards_target(@humans + [@ash])
        debug "Zombie #{zombie}"
      end
    end
  end

  def debug(info, enabled= true)
    puts info if enabled
  end
end



game = Game.new
5.times do |n|
  x = rand(BOARD_MAX_X)
  y = rand(BOARD_MAX_Y)
  game.zombies << Zombie.new(x, y, n, ZOMBIE_SPEED, game)
end

35.times do |n|
  x = rand(BOARD_MAX_X)
  y = rand(BOARD_MAX_Y)
  game.humans << Human.new(x, y, n, 0, game)
end
game.zombies << Zombie.new(500, 300, 1, ZOMBIE_SPEED, game)
game.zombies << Zombie.new(400, 400, 1, ZOMBIE_SPEED, game)
game.zombies << Zombie.new(500, 500, 2, ZOMBIE_SPEED, game)
game.humans << Human.new(400, 50, 1, 0, game)
game.humans << Human.new(400, 50, 1, 0, game)
game.humans << Human.new(400, 50, 1, 0, game)
game.humans << Human.new(400, 50, 1, 0, game)
game.humans << Human.new(50, 50, 1, 0, game)
game.humans << Human.new(550, 140, 1, 0, game)
game.ash = Ash.new(600, 600, 1, ASH_SPEED, game)

set title: "Simulation Code vs Zombie"
set background: 'white'
set width: BOARD_MAX_X
set height: BOARD_MAX_Y
set resizeable: true

tick = 0
update do
  # clear board
  clear

  game.next_sate

  # timer
  Text.new("Timer : #{tick}", x: 10, y: 10, color: 'blue', size: 10)

  # Ash
  ash = game.ash
  ash.draw('blue')
  Text.new("x #{ash.x}, y: #{ash.y}", x: ash.x+10, y: ash.y+10, color: 'blue', size: 10)
  if ash.target
    Line.new(
      x1: ash.x, y1: ash.y,
      x2: ash&.target&.x, y2: ash&.target&.y,
      width: 1,
      color: 'blue',
      z: 20
    )
  end

  # Zombies
  game.zombies.each do |z|
    z.draw('red')
    Text.new("x #{z.x}, y: #{z.y}", x: z.x+10, y: z.y+10, color: 'red', size: 10)
    Text.new("target #{z.target&.id}", x: z.x+10, y: z.y+20, color: 'red', size: 10)
    if z.target
      Line.new(
        x1: z.x, y1: z.y,
        x2: z&.target&.x, y2: z&.target&.y,
        width: 1,
        color: 'green',
        z: 50
      )
    end
  end

  # Humans
  game.humans.each {|h| h.draw('green')}


  if game.game_over
    Text.new("Game Over zombies #{game.zombies.count}, humans #{game.humans.count}, score #{game.score}", x: BOARD_MAX_X/2, y: BOARD_MAX_Y/2, color: 'red', size: 30)
  end

  tick += 1 unless game.game_over
end

show
