using ZXCalculus, YaoBlocks
using Test

qc = random_circuit(4, 20, 0.2, 0.2)
zxd = ZXDiagram(qc)
pt_zxd = phase_teleportation(zxd)
ex_zxd = clifford_simplification(zxd)
pt_qc = QCircuit(pt_zxd)
ex_qc = QCircuit(ex_zxd)
@test tcount(qc) >= tcount(pt_qc)

blks = toqbir(qc)
pt_blks = toqbir(pt_qc)
ex_blks = toqbir(ex_qc)

@test operator_fidelity(blks, pt_blks) ≈ 1
@test operator_fidelity(blks, ex_blks) ≈ 1
