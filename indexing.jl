using DataFrames

function indexify(df)
    key = Array{Int64}(undef, 1, size(collect(df[1, 1]))[1])
    ndf = DataFrame()
    for i in 1:size(df)[1]
        fill!(key, 0)
        word = df[i, 1]
        word = lowercase(word)
        word = collect(word)
        for j in 1:(lastindex(word))
            c = Int8(word[j]) - 96
            key[j] = c 
        end
        ndf = vcat(ndf, key)
    end
    return ndf
end