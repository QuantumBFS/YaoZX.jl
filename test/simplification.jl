using ZXCalculus, YaoBlocks
using Test

qc = random_circuit(4, 20, 0.2, 0.2)
zxd = ZXDiagram(qc)
pt_zxd = phase_teleportation(zxd)
ex_zxd = clifford_simplification(zxd)
ex_zxd2 = full_reduction(zxd)
pt_qc = QCircuit(pt_zxd)
ex_qc = QCircuit(ex_zxd)
ex_qc2 = QCircuit(ex_zxd2)
@test tcount(qc) >= tcount(pt_qc)

blks = toqbir(qc)
pt_blks = toqbir(pt_qc)
ex_blks = toqbir(ex_qc)
ex_blks2 = toqbir(ex_qc2)

@test operator_fidelity(blks, pt_blks) ≈ 1
@test operator_fidelity(blks, ex_blks) ≈ 1
@test operator_fidelity(blks, ex_blks2) ≈ 1
@test operator_fidelity(ex_blks, ex_blks2) ≈ 1
