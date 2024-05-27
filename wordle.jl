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
            ret[i] = '2'
            chg = guess[i]
            wotd = replace(wotd, chg => '0' , count = 1)
        else
            ret[i] = '0'
        end
    end
    for i in 1:lastindex(guess)
        if guess[i] in wotd
            ret[i] = '1'
            chg = guess[i]
            wotd = replace(wotd, chg => '0' , count = 1)
        end
    end

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
            won = replace(won, '0' => '⬜')
            won = replace(won, '1' => '🟨')
            won = replace(won, '2' => '🟩')
            won = join(won)
            println(won)
            n = n + 1

        elseif won == "Invalid!"            
            print("Enter your guess: ")
            guess = readline()
            won = wordle(wotd, guess)
            won = join(won)
            println(won)
            
        else
            println("You won!")
            break
        end
    end
end

function assignscore(ret)
    score = 0
    for i in 1:lastindex(ret)
        if ret[i] == '0'
            score = score + 15
        elseif ret[i] == '1'
            score = score + 5
        end
    end
    return score
end