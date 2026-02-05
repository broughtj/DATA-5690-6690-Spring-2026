# The computer guesses my number

function print_header()
    println("\tWelcome to 'Guess My Number'!")
    println("\tPlease think of a number between 1 and 100.")
    println("\tI will try to guess it. Give me hints with 'higher' and 'lower'.")
    println("\tOnce my guess is right, type 'correct'.")
    println("\tLet's see if I can guess it in as few attempts as possible!\n")
end

function print_footer(guess, tries)
    println("You guessed it!  The number was ", guess)
    println("And it only took ", tries, " tries!\n")
    println("\n\nPress the enter key to exit.")
end

# New helper function for robust input
function get_user_hint()
    while true
        print("Is it 'higher', 'lower', or 'correct'? ")
        answer = lowercase(strip(readline())) # Convert to lowercase and trim whitespace

        if answer == "higher" || answer == "lower" || answer == "correct"
            return answer
        else
            println("Sorry, I don't understand. Please enter 'higher', 'lower', or 'correct'.")
        end
    end
end

function main()  # code goes here!
    # print the header
    print_header()

    # set the inital values
    lo = 1
    hi = 100
    tries = 0
    answer = ""
    guess = 0

    # the loop
    while answer != "correct"
        # It's possible for lo to become greater than high if the user is inconsistent.
        if lo > hi
            println("I think you might have made a mistake with your hints! Please restart and be consistent.")
            return
        end

        guess = (hi + lo) ÷ 2
        print("My guess is $guess. ")
        tries += 1 # Only increment tries for valid guesses

        answer = get_user_hint() # Use the new helper function

        if answer == "higher"
           lo  = guess + 1
        elseif answer == "lower"
            hi = guess - 1
        # No else for "correct" because the loop condition will handle it.
        end
    end

    print_footer(guess, tries)
end
