using flux, CUDA, wordle
using flux:train!

model = Chain(
    multiheadattention()
) |> gpu