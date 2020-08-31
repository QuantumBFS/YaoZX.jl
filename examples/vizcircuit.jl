using Viznet, YaoBlocks

using YaoExtensions

struct CircuitCanvas
    frontier::Vector{Int}
end

nline(c::CircuitCanvas) = length(c)

function CircuitCanvas(nqubit::Int, depth::Int)
    CircuitCanvas(nqubit, depth)
end

function frontier(c::CircuitCanvas, start, stop)
    maximum(i->frontier[i], start:stop)
end

function Base.:>>(b::AbstractBlock, c::CircuitCanvas)
    error("block type $(typeof(b)) does not support visualization.")
end

function Base.:>>(p::PutBlock{N,1}, c::CircuitCanvas)
    i = frontier(c)
    for j in p.locs
        CircuitCanvas.lattice[i, j]
        tb >>
    end
end

function Base.:>>(cb::ControlBlock, c::CircuitCanvas)
    i = frontier(c)
end
