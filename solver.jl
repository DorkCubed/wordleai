using Flux, CUDA, Random, DataFrames, CSV
using Flux:train!
include("wordle.jl")
include("indexing.jl")

wordler = Conv((3, 3), 4 => 1, relu) |> gpu
df = DataFrame(CSV.File("valid-words.csv"))

function gettingdata(vec, sz, wotd = "hello")
    random_indices = rand(1:size(vec)[1], sz)
    random_batch = vec[random_indices, 1]
    results = Array{Char}(undef, 5, sz)

    for i in 1:sz
        results[i, :] = collect(wordle(wotd, random_batch[i]))
    end

    random_batch = indexify(random_batch)

    data = Array{Any}(undef, 5, sz, 2, 1)
    data[:, :, 1, 1] = random_batch[2:end, :]
    data[:, :, 2, 1] = results
    return data
end

function loss(x, y, model)
    moy = model(x)

    moy = round.(moy)
    moy = wordle(y, moy)
    moy = assignscore(moy)
    return moy
end

gettingdata(df, 5)