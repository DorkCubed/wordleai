# load list of all wordle words
const in_file = open("./wordle-words/wordle.csv", "r")
const words = [String(strip(split(line, ",")[1])) for line in eachline(in_file)]
close(in_file)

# config
const min_letter_count = 19
const success_bailout_letter_count = 21

# results, 5-tuple of words and n different letters
const results = Dict{Set{String}, Int}()
const results_lock = Threads.ReentrantLock()

# temp file that holds the current results in case the script crashes
const results_file_name = "mine_5_guesses_temp.txt"
const results_file = open(results_file_name, "w")
println(results_file, "n_letters,word_1,word_2,word_3,word_4,word_5")

# shuffle sets to increase odds of hitting a high scoring pair early
import Random
const words_01 = Random.shuffle(words)
const words_02 = Random.shuffle(words_01)
const words_03 = Random.shuffle(words_02)
const words_04 = Random.shuffle(words_03)
const words_05 = Random.shuffle(words_04)

# number of runs completed for status updates, this script will take a long time
const seen_combinations = Set() # keep track of seen pairing, so work is not done twice
const seen_lock = Threads.ReentrantLock()

println("starting...")

function add!(set, word)
    for c in word 
        push!(set, word) 
    end
end

# run through all combinations
Threads.@threads for _01 in words_01
    for _02 in words_02
        if _02 == _01 break end
        for _03 in words_03
            if _03 == _02 break end
            for _04 in words_04
                if _04 == _03 break end
                for _05 in words_05
                    if _05 == _04 break end
                    local combination = Set([_01, _02, _03, _04, _05])
                    lock(seen_lock)
                    local already_processed = hash(combination) in seen_combinations
                    unlock(seen_lock)

                    if !already_processed
                        lock(seen_lock)
                        push!(seen_combinations, hash(combination))
                        print("\r processed: $(length(seen_combinations))")
                        unlock(seen_lock)

                        local set = Set()
                        add!(set, _01)
                        add!(set, _02)
                        add!(set, _03)
                        add!(set, _04)
                        add!(set, _05)

                        local n_letters = length(set)
                        if n_letters >= min_letter_count
                            lock(results_lock)
                            results[Set([_01, _02, _03, _04, _05])] = length(set)
                            println(results_file, length(set), ",", _01, ",", _02, ",", _03, ",", _04, ",", _05)
                            @info "found valid combination with $(n_letters) letters: $([_01, _02, _03, _04, _05])"
                            unlock(results_lock)
                        end

                        if n_letters >= success_bailout_letter_count # found a valid pair, bail out of all loops
                            @info "Thread #$(Threads.threadid()) found combination with $success_bailout_letter_count letters, bailing out..."  
                            return
                        end

                        @label skip
                    end
                end
            end
        end
    end
end
          
# done, print results
final_results = Vector{Pair{Int, Array{String}}}()
for set in keys(results) 
    push!(final_results, Pair(results[set], [set...]))
end

out_file = open("mine_5_guesses_output.txt", "w")
println(results_file, "n_different_letters,word_1,word_2,word_3,word_4,word_5")

for row in sort(final_results; lt = (a, b) -> (a.first > b.first))
    println(row.first, "\t", row.second)
    println(out_file, row.first, ",", row.second[1], ",", row.second[2], ",", row.second[3], ",", row.second[4], ",", row.second[5])
end
close(out_file)

# cleanup temp file
close(results_file)
rm(results_file_name)

exit(0)

