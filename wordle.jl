wotd = "divya"

function wordle(wotd, guess)
    wotd = lowercase(wotd)
    guess = lowercase(guess)
    ret = Array{Char}(undef, length(wotd))

    if length(guess) != length(wotd)
        return "Invalid!"
    end
    for i in 1:lastindex(guess)
        if guess[i] == wotd[i]
            ret[i] = '🟩'
            chg = guess[i]
            wotd = replace(wotd, chg => '0' , count = 1)
        else
            ret[i] = '⬜'
        end
    end
    for i in 1:lastindex(guess)
        if guess[i] in wotd
            ret[i] = '🟨'
            chg = guess[i]
            wotd = replace(wotd, chg => '0' , count = 1)
        end
    end

    ret = join(ret)
    return ret
end

function play()
    won = "0"
    n = 0
    while n < 6
        if won != "🟩🟩🟩🟩🟩" && won != "Invalid!"
            print("Enter your guess: ")
            guess = readline()
            won = wordle(wotd, guess)
            println(won)
            n = n + 1

        elseif won == "Invalid!"            
            print("Enter your guess: ")
            guess = readline()
            won = wordle(wotd, guess)
            println(won)
            
        else
            println("You won!")
            break
        end
    end
end

play()