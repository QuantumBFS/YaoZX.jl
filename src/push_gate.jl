# patch
push_gate!(zxd::ZXDiagram, ::Val{:CNOT}, args...) = push_ctrl_gate!(zxd, Val(:CNOT), args...)
push_gate!(zxd::ZXDiagram, ::Val{:CZ}, args...) = push_ctrl_gate!(zxd, Val(:CZ), args...)

function push_gate!(zxd::ZXDiagram, c::AbstractBlock)
	push_gate!(zxd, decompose_zx(c))
end

# rotation blocks
function push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	push_gate!(zxd, Val(:X), c.locs[1], c.content.theta/π)
end
function push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta/π)
end

function push_gate!(zxd::ZXDiagram, c::ChainBlock{N}) where {N}
	push_gate!.(Ref(zxd), subblocks(c))
	zxd
end

# constant block
function push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,HGate}) where {N}
	push_gate!(zxd, Val(:H), c.locs[1])
end

# control blocks
function push_gate!(zxd::ZXDiagram, c::ControlBlock{N,XGate,1}) where {N}
	cloc = c.ctrl_locs[1]
	if c.ctrl_config[1] == 1
		push_gate!(zxd, Val(:CNOT), cloc, c.locs[1])
	else
		push_gate!(zxd, Val(:X), cloc, 1//1)
		push_gate!(zxd, Val(:CNOT), cloc, c.locs[1])
		push_gate!(zxd, Val(:X), cloc, 1//1)
	end
end
function push_gate!(zxd::ZXDiagram, c::ControlBlock{N,ZGate,1}) where {N}
	cloc = c.ctrl_locs[1]
	if c.ctrl_config[1] == 1
		push_gate!(zxd, Val(:CZ), cloc, c.locs[1])
	else
		push_gate!(zxd, Val(:X), cloc, 1//1)
		push_gate!(zxd, Val(:CZ), cloc, c.locs[1])
		push_gate!(zxd, Val(:X), cloc, 1//1)
	end
end

function push_gate!(zxd::ZXDiagram, c::PutBlock{N,2,SWAPGate}) where {N}
	a, b = c.locs
	push_gate!(zxd, Val(:SWAP), [a, b])
end

# ref: https://qiskit.org/textbook/ch-gates/more-circuit-identities.html
function decompose_zx(c::ControlBlock{N,XGate,2}) where N
	a, b = getclocs(c)
	loc = c.locs[1]
	chain(N,
		put(loc=>H),
		cnot(b, loc),
		put(loc=>ConstGate.Tdag),
		cnot(a, loc),
		put(loc=>ConstGate.T),
		cnot(b, loc),
		put(loc=>ConstGate.Tdag),
		cnot(a, loc),
		put(loc=>ConstGate.T),
		put(b=>ConstGate.T),
		put(loc=>H),
		cnot(a, b),
		put(a=>ConstGate.T),
		put(b=>ConstGate.Tdag),
		cnot(a, b),
	)
end

function decompose_zx(c::ControlBlock{N,YGate,1}) where {N}
	a = getclocs(c)[1]
	loc = c.locs[1]
	chain(N, put(loc=>ConstGate.Sdag), cnot(a, loc), put(loc=>ConstGate.S))
end

function decompose_zx(c::ControlBlock{N,ShiftGate{T},1}) where {N,T}
	a = getclocs(c)[1]
	loc = c.locs[1]
	θ = c.content.theta
	chain(N, put(a=>ShiftGate(θ/2)), put(loc=>Rz(θ/2)), cnot(a,loc), put(loc=>Rz(-θ/2)), cnot(a,loc))
end

function decompose_zx(c::ControlBlock{N,RotationGate{1,T,YGate},1}) where {N,T}
	a = getclocs(c)[1]
	loc = c.locs[1]
	θ = c.content.theta
	chain(N, put(loc=>Ry(θ/2)), cnot(a,loc), put(loc=>Ry(-θ/2)), cnot(a,loc))
end

function decompose_zx(c::ControlBlock{N,RotationGate{1,T,XGate},1}) where {N,T}
	a = getclocs(c)[1]
	loc = c.locs[1]
	θ = c.content.theta
	chain(N, put(loc=>Rx(θ/2)), cz(a,loc), put(loc=>Rx(-θ/2)), cz(a,loc))
end

function decompose_zx(c::ControlBlock{N,RotationGate{1,T,ZGate},1}) where {N,T}
	a = getclocs(c)[1]
	loc = c.locs[1]
	θ = c.content.theta
	chain(N, put(loc=>Rz(θ/2)), cnot(a,loc), put(loc=>Rz(-θ/2)), cnot(a,loc))
end

# constant block
function decompose_zx(c::PutBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	put(N, c.locs[1]=>Rx(π))
end
function decompose_zx(c::PutBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	put(N, c.locs[1]=>Rz(π))
end
function decompose_zx(c::PutBlock{N,1,ConstGate.SGate}) where {N}
	put(N, c.locs[1]=>Rz(π/2))
end
function decompose_zx(c::PutBlock{N,1,ConstGate.TGate}) where {N}
	put(N, c.locs[1]=>Rz(π/4))
end
function decompose_zx(c::PutBlock{N,1,ConstGate.SdagGate}) where {N}
	put(N, c.locs[1]=>Rz(-π/2))
end
function decompose_zx(c::PutBlock{N,1,ConstGate.TdagGate}) where {N}
	put(N, c.locs[1]=>Rz(-π/4))
end
function decompose_zx(c::PutBlock{N,1,ShiftGate{T}}) where {N,T}
	put(N, c.locs[1]=>Rz(c.content.theta))
end

function getclocs(c::ControlBlock)
	(2 .* c.ctrl_config .- 1) .* c.ctrl_locs
end
