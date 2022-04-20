class Mastermind
    @@valid_colors = ['RED', 'GREEN', 'BLUE', 'YELLOW', 'BROWN', 'ORANGE']
    
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

    def valid_guess?(colors)
        if colors.length != 4
            puts "Must input 4 colors\n"
            return false
        end
        colors.each do |color|
            if !(@@valid_colors.include?(color))
                puts "Invalid Code\n"
                return false
            end
        end
        return true
    end
end

class CodeBreaker < Mastermind

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
        super
    end

    def check_guess(colors)
        super
    end
end

class CodeMaker < Mastermind
    def initialize(code)
        @code = code
    end

    private
    def check_guess(colors, code = @code)
        valid = valid_guess?(colors)
        if !valid
            return false
        end

        feedback = []
        code.each_with_index do |code_color, c|
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
        return feedback         
    end
    
    public
    def fill_solutions
        solutions = []
        for thousands in '1'..'6' do
            for hundreds in '1'..'6' do
                for tens in '1'..'6' do
                    for units in '1'..'6' do
                        solutions.push("#{thousands}#{hundreds}#{tens}#{units}")
                    end
                end
            end
        end
        solutions
    end
    
    def valid_guess?(colors)
        super
    end


    def guess_code(solutions, guess)
        guess = [@@valid_colors[guess[0].to_i - 1], @@valid_colors[guess[1].to_i - 1], @@valid_colors[guess[2].to_i - 1], @@valid_colors[guess[3].to_i - 1]]
        puts "\nGuessing Code:"
        p guess
    
        feedback = check_guess(guess)
        puts "Feedback:"
        p feedback
    
        solutions.select! do |num|
            num = [@@valid_colors[num[0].to_i - 1], @@valid_colors[num[1].to_i - 1], @@valid_colors[num[2].to_i - 1], @@valid_colors[num[3].to_i - 1]]
            check_guess(guess, num) == feedback
        end
        solutions
    end

	def convert_to_code(num)
		num = [@@valid_colors[num[0].to_i - 1], @@valid_colors[num[1].to_i - 1], @@valid_colors[num[2].to_i - 1], @@valid_colors[num[3].to_i - 1]]
		num
	end
end

puts "Welcome to Mastermind!
The goal of the game is to guess the 4 color code that the code maker has created.
There are 8 valid colors to guess from: red, green, blue, yellow, brown, orange.
After every guess, the code maker will give you (the code breaker) feedback based on your choices and his code.
Red means that one of the colors is in the code and the correct spot,
white means one of the colors is in the code but in the wrong spot,
and black means one of the colors is not in the code.
Let's start!\n\n"


puts "Would like to play as the code maker or code breaker?"
while true do
    player = gets.downcase.gsub(/\s+/, "")
    if player == "codebreaker" || player == "codemaker"
        break
    end
    puts "Invalid choice, try again: "
end

if player == "codemaker"
    
    valid_code = false
    until valid_code do
        print "\nEnter code (4 colors seperated by spaces): "
        code = gets.split.map {|color| color.upcase.strip}
        game = CodeMaker.new(code)
        valid_code = game.valid_guess?(code) 
        if valid_code
            count = code.reduce(0) do |tot, color|
                tot += code.count(color) == 1 ? 1 : 0
                tot
            end
            valid_code = count == 4
            if !valid_code
                puts "The code cannot contain more than 1 of the same color"
            end
        end
    end
    
    tries = 12
    solutions = game.fill_solutions
    until solutions.length == 1 do
        if tries == 12
            guess = "1122"
        else
            guess = solutions[0]
        end

        solutions = game.guess_code(solutions, guess)
        if solutions.length == 1
			solution = game.convert_to_code(solutions[0])
            puts "\nYou lost!"
			puts "Deciphered code: #{solution}"
            puts "Computer deciphered code in #{12 - tries + 1} tries"
        else
            tries -= 1
            if tries == 0
                puts "Congrats! You won!"
                puts "Computer was not able to deciphered code in 12 tries"
                break
            end
            puts "Tries left: #{tries}"
        end
		sleep(1)
	end
else
    game = CodeBreaker.new
    tries = 12
    won = false
    
    until won do
        valid_code = false
        until valid_code do
            print "\nEnter code (4 colors seperated by spaces): "
            guess = gets.split.map {|color| color.upcase.strip}
            valid_code = game.valid_guess?(guess)
        end
    
        if game.check_guess(guess)
            puts "\nCongrats! You won in #{12 - tries + 1} tries!"
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
end
