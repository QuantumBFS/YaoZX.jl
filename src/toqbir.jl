using ZXCalculus: qubit_loc

function gate_sequence(circ::ZXDiagram{T, P}) where {T, P}
    lo = circ.layout
    spider_seq = ZXCalculus.spider_sequence(circ)
    vs = spiders(circ)
    locs = Dict()
    nqubit = lo.nbits
    frontier_v = ones(T, nqubit)

    seq = []
    while sum([frontier_v[i] <= length(spider_seq[i]) for i = 1:nqubit]) > 0
        for q = 1:nqubit
            if frontier_v[q] <= length(spider_seq[q])
                v = spider_seq[q][frontier_v[q]]
                nb = ZXCalculus.neighbors(circ, v)
                if length(nb) <= 2
                    θ = ZXCalculus.phase(circ, v)
                    if spider_type(circ, v) == ZXCalculus.SpiderType.Z
                        push!(seq, (:Z, q, θ))
                    elseif spider_type(circ, v) == ZXCalculus.SpiderType.X
                        push!(seq, (:X, q, θ))
                    elseif spider_type(circ, v) == ZXCalculus.SpiderType.H
                        push!(seq, (:H, q))
                    end
                    frontier_v[q] += 1
                elseif length(nb) == 3
                    v1 = nb[[qubit_loc(lo, u) != q for u in nb]][1]
                    if spider_type(circ, v1) == SpiderType.H
                        v1 = setdiff(ZXCalculus.neighbors(circ, v1), [v])[1]
                    end
                    if sum([findfirst(isequal(u), spider_seq[qubit_loc(lo, u)]) != frontier_v[qubit_loc(lo, u)] for u in [v, v1]]) == 0
                        for vv in [v, v1]
                            q = qubit_loc(lo, vv)
                            θ = ZXCalculus.phase(circ, vv)
                            if spider_type(circ, vv) == ZXCalculus.SpiderType.Z
                                push!(seq, (:Z, q, θ))
                            else
                                push!(seq, (:X, q, θ))
                            end
                        end
                        if spider_type(circ, v) == spider_type(circ, v1) == ZXCalculus.SpiderType.Z
                            push!(seq, (:CZ, qubit_loc(lo, v), qubit_loc(lo, v1)))
                        elseif spider_type(circ, v) == ZXCalculus.SpiderType.Z
                            push!(seq, (:CNOT, qubit_loc(lo, v1), qubit_loc(lo, v)))
                        elseif spider_type(circ, v) == ZXCalculus.SpiderType.X
                            push!(seq, (:CNOT, qubit_loc(lo, v), qubit_loc(lo, v1)))
                        end
                        for u in [v, v1]
                            frontier_v[qubit_loc(lo, u)] += 1
                        end
                    end
                end
            end
        end
    end
    return seq
end

function toqbir(zxd::ZXDiagram)
    n = length(zxd._inputs)
    c = chain(n)
    for g in gate_sequence(zxd)
        gg = parse_block(g)
        gg !== nothing && push!(c, gg)
    end
    c
end

function parse_block(g::Tuple)
    if g[1] == :X
        p = g[3]
        if p == 1
            put(g[2]=>X)
        elseif p != 0
            put(g[2]=>Rx(p*π))
        end
    elseif g[1] == :Z
        p = g[3]
        if p == 1
            put(g[2]=>Z)
        elseif p != 0
            put(g[2]=>Rz(g[3]*π))
        end
    elseif g[1] == :H
        put(g[2]=>H)
    elseif g[1] == :CZ
        control(g[2], g[3]=>Z)
    elseif g[1] == :CNOT
        control(g[2], g[3]=>X)
    elseif g[1] == :SWAP
        control(g[2], g[3]=>X)
    end
end
