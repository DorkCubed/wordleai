import Random

"""
find 5-tupels of five letter words that have the largest set of pairwise different letters
"""
function run(min_letter_count::Integer, success_bailout_letter_count::Integer)
    # load list of all wordle words
    in_file = open("./wordle-words/wordle.csv", "r")
    words = [String(strip(split(line, ",")[1])) for line in eachline(in_file)]
    close(in_file)

    # results, 5-tuple of words and n different letters
    results = Dict{Set{String}, Int}()
    results_lock = Threads.ReentrantLock()

    # temp file that holds the current results in case the script crashes
    results_file_name = "mine_5_guesses_temp.txt"
    results_file = open(results_file_name, "w")

    csv_header = "n_letters,word_1,word_2,word_3,word_4,word_5"
    println(results_file, csv_header)

    # shuffle sets to increase odds of hitting a high scoring pair early
    words_01 = Random.shuffle(words)
    words_02 = Random.shuffle(words_01)
    words_03 = Random.shuffle(words_02)
    words_04 = Random.shuffle(words_03)
    words_05 = Random.shuffle(words_04)
    n_words = length(words)

    # number of runs completed for status updates, this script will take a long time
    seen_combinations = Set() # keep track of seen pairing, so work is not done twice
    seen_lock = Threads.ReentrantLock()

    println("starting...")

    # run through all combinations
    Threads.@threads for i_01 in 1:n_words
        for i_02 in 1:n_words
            if i_02 == i_01 break end
            for i_03 in 1:n_words
                if i_03 == i_02 || i_03 == i_01 break end
                for i_04 in 1:n_words
                    if i_04 == i_03 || i_04 == i_02 || i_04 == i_01 break end
                    for i_05 in 1:n_words
                        if i_05 == i_04 || i_05 == i_03 || i_05 == i_02 || i_05 == i_01 break end
                        local combination = hash(Set([i_01, i_02, i_03, i_04, i_05]))
                        
                        lock(seen_lock)
                        local already_processed = combination in seen_combinations
                        if !already_processed 
                            push!(seen_combinations, combination)
                            unlock(seen_lock)
                            print("\r# processed: $(length(seen_combinations))")
                        else
                            unlock(seen_lock)
                            @goto skip
                        end

                        local set = Set()
                        for c in words_01[i_01] push!(set, c) end
                        for c in words_02[i_02] push!(set, c) end
                        for c in words_03[i_03] push!(set, c) end
                        for c in words_04[i_04] push!(set, c) end
                        for c in words_05[i_05] push!(set, c) end

                        local n_letters = length(set)
                        if n_letters >= min_letter_count
                            _01 = words_01[i_01]
                            _02 = words_02[i_02]
                            _03 = words_03[i_03]
                            _04 = words_04[i_04]
                            _05 = words_05[i_05]

                            lock(results_lock)
                            results[Set([_01, _02, _03, _04, _05])] = n_letters
                            println(results_file, n_letters, ",", _01, ",", _02, ",", _03, ",", _04, ",", _05)
                            @info "found valid combination with $(n_letters) letters: $([_01, _02, _03, _04, _05])"
                            unlock(results_lock)
                        else
                            @goto skip
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
            
    # done, print results
    final_results = Vector{Pair{Int, Array{String}}}()
    for set in keys(results) 
        push!(final_results, Pair(results[set], [set...]))
    end

    out_file = open("mine_5_guesses_output.txt", "w")
    println(results_file, csv_header)

    for row in sort(final_results; lt = (a, b) -> (a.first > b.first))
        println(row.first, "\t", row.second)
        println(out_file, row.first, ",", row.second[1], ",", row.second[2], ",", row.second[3], ",", row.second[4], ",", row.second[5])
    end
    close(out_file)

    # cleanup temp file
    close(results_file)
    rm(results_file_name)
end

run(20, 25)
exit(0)

