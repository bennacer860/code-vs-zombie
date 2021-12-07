BOARD_MAX_X = 16000
BOARD_MAX_Y = 9000
ZOMBIE_SPEED = 400
ASH_SPEED = 1000
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

    def to_s
        "#{@x}, #{@y}, :id #{@id}"
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

# for statistics
score_distribution = [] 
winner_game_turns = []


# the coordinate of the best next move
# conditions:
#   highest_score
#   lowest number of turns if there is equality in games
best_next_move = []
best_score = 0
best_number_of_turns = 0
10000.times do 
    game = Game.new

    game.zombies << Zombie.new(8600,8600,1)
    game.zombies << Zombie.new(9600,8600,2)
    game.humans << Human.new(9000,9000,1)

    30.times do
        break if game.game_over
        game.next_sate
    end

    if game.score > best_score
        puts game.score
        best_next_move = game.history.first
        best_score = game.score
    end
 
    # pick the fasts solution if the scores are the same
    if game.score == best_score && game.number_of_turns < best_number_of_turns
        best_next_move = game.history.first
    end

    # stats
    score_distribution << game.score
    winner_game_turns << game.number_of_turns if game.score > 0
end

def tally( array )
    array.each_with_object(Hash.new(0)){|key,hash| hash[key] += 1}
end

puts tally(score_distribution)
puts tally(winner_game_turns)
puts "best move #{best_next_move}"
