using flux, CUDA
using flux:train!
include("wordle.jl")

model = Chain(
    RNN()
) |> gpu

function loss(x, y)
    moy = model(x)
end