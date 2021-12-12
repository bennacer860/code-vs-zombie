require 'ruby2d'

BOARD_MAX_X = 16000
BOARD_MAX_Y = 9000
ZOMBIE_SPEED = 4
ASH_SPEED = 10
GUN_RADIUS = 2000

class Parent 
    attr_accessor :x,:y,:id
    def initialize x, y, id = nil
      @x, @y, @id = x, y, id
    end

    def distance_from_point(point_x,point_y)
        sum_of_squares = (point_x-@x)**2+(point_y-@y)**2
        Math.sqrt( sum_of_squares )
    end


    def move_towards_target(target)
      # Rotate us to face the player
      rotation = Math.atan2(target.y - @y, target.x - @x);

      # Move towards the player
      speed = 2
      @x += Math.cos(rotation) * speed;
      @y += Math.sin(rotation) * speed;
    end

    def to_s
        "#{@x}, #{@y}, :id #{@id}"
    end

    def draw(color)
      # Square.new(x: @x, y: @y, size: 5, color: color)
      Circle.new(x: @x, y: @y, radius: 10, color: color)
    end
end

class Human < Parent; end

class Zombie < Parent
    def move
        # for now it will move randomly
        next_move_x = [@x, @x+ZOMBIE_SPEED, @x-ZOMBIE_SPEED].reject{|value| value < 0 || value > BOARD_MAX_X}.sample
        next_move_y = [@y, @y+ZOMBIE_SPEED, @y-ZOMBIE_SPEED].reject{|value| value < 0 || value > BOARD_MAX_Y}.sample
        @x = next_move_x
        @y = next_move_y
        [@x, @y]
    end
end

class Ash < Parent
    def move
        # TODO: zombie should move towards human or ash
        # fow now it will move randomly
        next_move_x = [@x, @x+ASH_SPEED, @x-ASH_SPEED].reject{|value| value < 0 || value > BOARD_MAX_X}.sample  
        next_move_y = [@y, @y+ASH_SPEED, @y-ASH_SPEED].reject{|value| value < 0 || value > BOARD_MAX_Y}.sample
        @x = next_move_x
        @y = next_move_y
        # returning coordinate for the purpose of logging
        [@x, @y]
    end    
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
      @ash = Ash.new(0,0)
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

        # remove if humans are dead
        # aka same coordinate as a zombie
        zombies_coordinates = @zombies.map{|z| [z.x, z.y]}
        @humans.delete_if do |human|
            zombies_coordinates.include?([human.x, human.y])
        end

        # remove if zombies are dead
        # aka in the radius of Ash's gun
        @zombies.delete_if do |zombie|
            # A zombie is worth the number of humans still alive squared x10, not including Ash
            # TODO get a more accurate score calculation with the combos 
            if zombie.distance_from_point(@ash.x, @ash.y) <= GUN_RADIUS
                @score += @humans.count * 10
                debug "Ash shot zombie #{zombie}"
                true
            else
                false
            end
        end

        # check if the game is over
        if @zombies.count == 0 || @humans.count == 0
            @game_over = true
            # debug "game is over : zombies #{@zombies.count}, humans #{@humans.count}, score #{@score}"
        end


        ########## Move randomly ash and zombies #############
        @history << @ash.move
        debug "Ash #{@ash}"
        @zombies.each do |zombie|
            @zombie_history << zombie.move
            debug "Zombie #{zombie}"
        end
    end

    def debug(info, enabled=false)
        puts info if enabled
    end
end



game = Game.new

game.zombies << Zombie.new(500,100,1)
game.zombies << Zombie.new(500,500,2)
game.humans << Human.new(0,0,1)
game.ash = Ash.new(1000,800,1)

set title: "Simulation Code vs Zombie"
set background: 'white'
set width: 1600
set height: 900
set resizeable: true

update do
  clear
  game.ash.draw('blue')
  game.zombies.each {|z| z.draw('red')}
  game.humans.each {|h| h.draw('green')}

  game.ash.move_towards_target(game.humans.first)
  game.zombies.each {|z| z.move}
  # sleep(1)
end

show
