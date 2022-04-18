class CodeMaker
    @@valid_colors = ['RED', 'GREEN', 'BLUE', 'YELLOW', 'BROWN', 'ORANGE', 'BLACK', 'WHITE']

    attr_reader :code
    def initialize
        @code = generate_code()
    end

    private
    def generate_code
        code = []
        until code.length == 4 do
            color = @@valid_colors.sample
            if !(code.include?(color))
                code.push(color)
            end
        end
        code
    end

    public
    def valid_guess?(colors)
        if colors.length != 4
            puts "Must input 4 colors\n"
            return false
        end
        colors.each do |color|
            if !(@@valid_colors.include?(color))
                puts "Invalid Guess\n"
                return false
            end
        end
        return true
    end

    def check_guess(colors)
        valid = valid_guess?(colors)
        if !valid
            return false
        end

        feedback = []
        @code.each_with_index do |code_color, c|
            whites = false
            reds = false
            colors.each_with_index do |guess_color, g|
                if guess_color == code_color
                    if c == g
                        feedback.unshift("RED")
                        reds = true
                        break
                    else
                        whites = true
                    end
                end
            end
            if whites && !reds
                feedback.push("WHITE")
            end
        end
        (4 - feedback.length).times {feedback.push("BLACK")}  # add feedback for colors that weren't in code

        correct = 0
        feedback.each {|peg| correct += 1 if peg == "RED"}
        if correct == 4
            return true
        else
            puts "Feedback:"
            p feedback
            return false
        end          
    end
end

game = CodeMaker.new
puts "Welcome to Mastermind!
The goal of the game is to guess the 4 color code that the code maker has created.
There are 8 valid colors to guess from: red, green, blue, yellow, brown, orange, black, white.
After every guess, the code maker will give you feedback based on your choices and his code.
Red means that one of the colors is in the code and the correct spot,
white means one of the colors is in the code but in the wrong spot,
and black means one of the colors is not in the code.
Let's start!\n"

tries = 12
won = false

until won do
    valid_guess = false
    until valid_guess do
        print "\nEnter code (4 colors seperated by spaces): "
        guess = gets.split.map {|color| color.upcase}
        valid_guess = game.valid_guess?(guess)
    end

    if game.check_guess(guess)
        puts "Congrats! You won!"
        won = true
    else
        tries -= 1
        if tries == 0
            puts "You lost!"
            puts "The code was #{game.code}"
            break  # break out of game
        end
        puts "Tries left: #{tries}"
    end
end
