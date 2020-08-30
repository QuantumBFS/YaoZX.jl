using YaoZX
using Test

@testset "push gate" begin
    include("push_gate.jl")
end

@testset "to qbir" begin
    include("toqbir.jl")
end
