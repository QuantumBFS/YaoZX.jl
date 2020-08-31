using Yao, YaoExtensions
using YaoZX
using Test

@testset "decompose gates" begin
	@test YaoZX.getclocs(cnot(2,-2,1)) == (-2,)
	@test YaoZX.getclocs(control(4, (-2, 3), 1=>X)) == (-2, 3)
	for g in [control(5, (2, 1), 4=>X),
		 	put(5, 3=>ConstGate.T), put(5, 2=>ConstGate.Sdag),
			put(5, 4=>ConstGate.Tdag), put(5, 2=>ConstGate.S),
			control(5, 4, 3=>Y), put(5, 3=>shift(0.4)),
			control(5, 2, 3=>Ry(0.5)),
			control(5, 2, 3=>Rz(0.5)),
			control(5, 2, 3=>Rx(0.5)),
			control(5, -2, 3=>Rx(0.5)),
			cphase(5, 2, 4, 0.5)
			]
		@test operator_fidelity(decompose_zx(g), g) ≈ 1
	end
end
