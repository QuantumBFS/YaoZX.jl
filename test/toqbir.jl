using YaoExtensions, YaoZX, Yao
using Test

@testset "qft" begin
    c = qft_circuit(4)
    zxd = ZXDiagram(4)
    push_gate!(zxd, c)
    circ = toqbir(zxd)
    @test operator_fidelity(circ, c) ≈ 1
end
