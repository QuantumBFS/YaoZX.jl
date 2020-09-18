using YaoBlocks
using ZXCalculus
import YaoBlocks: mat

function toqbir(qc::QCircuit)
    n = ZXCalculus.nqubits(qc)
    c = chain(n)
    for g in gates(qc)
        gg = parse_block(g)
        gg !== nothing && push!(c, gg)
    end
    return c
end

function toqbir(zxd::ZXDiagram)
    return toqbir(QCircuit(zxd))
end

function parse_block(g::QGate)
    if g.name == :X
        put(g.loc => X)
    elseif g.name == :H
        put(g.loc => H)
    elseif g.name == :Z
        put(g.loc => Z)
    elseif g.name == :S
        put(g.loc => ConstGate.S)
    elseif g.name == :Sdag
        put(g.loc => ConstGate.Sdag)
    elseif g.name == :T
        put(g.loc => T)
    elseif g.name == :Tdag
        put(g.loc => ConstGate.Tdag)
    elseif g.name == :Rx
        put(g.loc => Rx(g.param))
    elseif g.name == :Rz
        put(g.loc => Rz(g.param))
    elseif g.name == :shift
        put(g.loc => shift(g.param))
    elseif g.name == :CNOT
        control(g.ctrl, g.loc => X)
    elseif g.name == :CZ
        control(g.ctrl, g.loc => Z)
    end
end

mat(qc::QCircuit) = mat(toqbir(qc))
mat(zxd::ZXDiagram) = mat(QCircuit(zxd))