using Flux, CUDA, Random, DataFrames, CSV
using Flux:train!
include("wordle.jl")
include("indexing.jl")

wordler = Chain(
    Conv((2, 1), 5 => 25, relu),
    x -> reshape(x, (5, 25, 1, size(x, 4))),
    Conv((1, 25), 1 => 1, relu),
    x -> reshape(x, :, size(x, 4)),
    Dense(5, 5, relu)
    )

df = DataFrame(CSV.File("valid-words.csv"))
idf = indexify(df)

function gettingdata(vec, sz = 5, batchsize = 1, wotd = "hello")
    data = Array{Int64}(undef, 2, 5, sz, batchsize)

    for batch in 1:batchsize
        random_indices = rand(1:size(vec)[1], sz)
        random_batch = vec[random_indices, 1]
        results = Array{Int64}(undef, 5, sz)

        for i in 1:sz
            places = wordle(wotd, random_batch[i])
            places = parse.(Int64, places)
            results[i, :] = places
        end

        random_batch = indexify(random_batch)

        data[1, :, :, batch] = random_batch[2:end, :]'
        data[2, :, :, batch] = results'
    end

    return data
end

function loss(model, x, y)
    moy = model(x)
    sco = (size(moy)[1]) * 5
    for i in 1:size(moy)[1]
        for j in 1:size(moy)[2]
            
            if round(moy[i, j]) in y[i, :]
                sco = sco - 0.25
            end

            if round(moy[i, j]) == y[i, j]
                sco = sco - 0.5
            end

            if (j > 1) && (abs(moy[i, j] - moy[i, j-1]) < 0.5)
                sco = sco + 0.5
            end

        end
    end

    if sco < 27
        println(sco)
    end

    return sco
end

function training(idf, df, wordler, epochs)

    opt = Flux.setup(AdamW(0.25), wordler)

    for epoch in 1:epochs
        randomindex = rand(1:size(df)[1])
        randomword = df[randomindex, 1]
        solu = idf[randomindex, :]
        solu = solu'
        solu = vcat(solu, solu, solu, solu, solu)

        tradata = [(gettingdata(df, 5, 5, randomword), solu)]
        train!(loss, wordler, tradata, opt)
    end
end

training(idf, df, wordler, 100)
a = gettingdata(df, 5, 1, "abcde")
display(a)
b = wordler(a)
b = round.(b)
b = unindexify(b)
display(b)