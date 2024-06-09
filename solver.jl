using Flux, CUDA, Random, DataFrames, CSV
using Flux:train!
include("wordle.jl")
include("indexing.jl")

wordler = Chain(
    Conv((2, 1), 5 => 1, relu),
    x -> reshape(x, :, size(x, 4)),
    Dense(5, 5, relu)
    )

df = DataFrame(CSV.File("valid-words.csv"))
idf = indexify(df)

function gettingdata(vec, sz, wotd = "hello")
    random_indices = rand(1:size(vec)[1], sz)
    random_batch = vec[random_indices, 1]
    results = Array{Int64}(undef, 5, sz)

    for i in 1:sz
        places = wordle(wotd, random_batch[i])
        places = parse.(Int64, places)
        results[i, :] = places
    end

    random_batch = indexify(random_batch)

    data = Array{Int64}(undef, 2, 5, sz, 1)
    data[1, :, :, 1] = random_batch[2:end, :]'
    data[2, :, :, 1] = results'
    return data
end

function loss(model, x, y)
    moy = model(x)
    sco = sum(abs2.(moy .- y))
    #println(sco)
    return sco
end

function training(idf, df, wordler, epochs)

    opt = Flux.setup(Adam(0.01), wordler)

    for epoch in 1:epochs
        randomindex = rand(1:size(df)[1])
        randomword = df[randomindex, 1]
        solu = idf[randomindex, :]
        #display(randomword)
        #display(solu)

        tradata = [(gettingdata(df, 5, randomword), solu)]
        train!(loss, wordler, tradata, opt)
    end
end


training(idf, df, wordler, 250)
a = gettingdata(df, 5)
display(a)
b = wordler(a)
b = round.(b)
b = unindexify(b)
display(b)