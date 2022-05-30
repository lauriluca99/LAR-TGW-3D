
Lar = LinearAlgebraicRepresentation


"""
    function frag_face_channel(
            in_chan, 
            out_chan, 
            V::Points, 
            EV::ChainOp, 
            FE::ChainOp, 
            sp_idx::Vector{Int64})

Funziona che parallelizza, con l'utilizzo dei canali, la frammentazione delle facce in `FE` rispetto le facce in `sp_idx`.
"""
function frag_face_channel(in_chan, out_chan, V::Points, EV, FE, sp_idx)
    run_loop = true
    while run_loop
        sigma = take!(in_chan)
        if sigma != -1
            put!(out_chan, frag_face(V, EV, FE, sp_idx, sigma))
        else
            run_loop = false
        end
    end
end


"""
    function frag_face(
            V::Points, 
            EV::ChainOp, 
            FE::ChainOp, 
	        sp_idx::Vector{Int64}, 
            sigma::Int64)

Prende la faccia `sigma` e la trasforma in 2D per poter calcolare le intersezioni con le facce in `sp_idx[sigma]`
ed ottenere la disposizione 2D della faccia `sigma`.
"""
function frag_face(V, EV, FE, sp_idx, sigma)

    vs_num = size(V, 1)

	# 2D transformation of sigma face
    sigmavs = (abs.(FE[sigma:sigma,:]) * abs.(EV))[1,:].nzind
    sV = V[sigmavs, :]
    sEV = EV[FE[sigma, :].nzind, sigmavs]
    M = Lar.Arrangement.submanifold_mapping(sV)
    tV = ([V ones(vs_num)]*M)[:, 1:3]  # folle convertire *tutti* i vertici
    sV = tV[sigmavs, :]
    # sigma face intersection with faces in sp_idx[sigma]
    for i in sp_idx[sigma]
        tmpV, tmpEV = Lar.Arrangement.face_int(tV, EV, FE[i, :])
		sV, sEV
        sV, sEV = Lar.skel_merge(sV, sEV, tmpV, tmpEV)
    end

    # computation of 2D arrangement of sigma face
    sV = sV[:, 1:2]
    nV, nEV, nFE = planar_arrangement(sV, sEV, sparsevec(ones(Int8, length(sigmavs))))
    if nV === nothing ## not possible !! ... (each original face maps to its decomposition)
        return [], spzeros(Int8, 0,0), spzeros(Int8, 0,0)
    end
    nvsize = size(nV, 1)
    nV = [nV zeros(nvsize) ones(nvsize)]*inv(M)[:, 1:3] ## ????

    return nV, nEV, nFE
end


"""
    function merge_vertices(
            V::Points, 
            EV::ChainOp, 
            FE::ChainOp, 
            [err=1e-4])
	
Rimuove i vertici congruenti ad un singolo rappresentatante, traduce i lati per tener 
conto della congruenza ed otteniene nuove facce congruenti.

#### Argomenti addizionali:
- `err`: Limite di errore massimo che si vuole utilizzare. Di Defaults a `1e-4`.
"""
function merge_vertices(V::Points, EV::ChainOp, FE::ChainOp, err=1e-4)
   vertsnum = size(V, 1)
   edgenum = size(EV, 1)
   facenum = size(FE, 1)
   newverts = zeros(Int, vertsnum)
   # KDTree constructor needs an explicit array of Float64
   V = Array{Float64,2}(V)
   W = convert(Points, LinearAlgebra.transpose(V))
   kdtree = KDTree(W)
# remove vertices congruent to a single representative
   todelete = []
   i = 1
   for vi in 1:vertsnum
       if !(vi in todelete)
           nearvs = Lar.inrange(kdtree, V[vi, :], err)
           newverts[nearvs] .= i
           nearvs = setdiff(nearvs, vi)
           todelete = union(todelete, nearvs)
           i = i + 1
       end
   end
   nV = V[setdiff(collect(1:vertsnum), todelete), :]
   # V[30,:] = V[26,:] #<<<<<<<<<<<<<<<<<< TEST

   # translate edges to take congruence into account
   edges = Array{Tuple{Int, Int}, 1}(undef, edgenum)
   oedges = Array{Tuple{Int, Int}, 1}(undef, edgenum)
   for ei in 1:edgenum
       v1, v2 = EV[ei, :].nzind
       edges[ei] = Tuple{Int, Int}(sort([newverts[v1], newverts[v2]]))
       oedges[ei] = Tuple{Int, Int}(sort([v1, v2]))
   end
   nedges = union(edges)
   # remove edges of zero length
   nedges = filter(t->t[1]!=t[2], nedges)
   nedgenum = length(nedges)
   nEV = spzeros(Int8, nedgenum, size(nV, 1))

   etuple2idx = Dict{Tuple{Int, Int}, Int}()
   for ei in 1:nedgenum
   	begin
       	nEV[ei, collect(nedges[ei])] .= 1
       	nEV
       end
       etuple2idx[nedges[ei]] = ei
   end
   for e in 1:nedgenum
   	v1,v2 = findnz(nEV[e,:])[1]
   	nEV[e,v1] = -1; nEV[e,v2] = 1
   end

   # compute new faces to take congruence into account
   faces = [[
       map(x->newverts[x], FE[fi, ei] > 0 ? oedges[ei] : reverse(oedges[ei]))
       for ei in FE[fi, :].nzind
   ] for fi in 1:facenum]


   visited = []
   function filter_fn(face)

       verts = []
       map(e->verts = union(verts, collect(e)), face)
       verts = Set(verts)

       if !(verts in visited)
           push!(visited, verts)
           return true
       end
       return false
   end

   nfaces = filter(filter_fn, faces)

   nfacenum = length(nfaces)
   nFE = spzeros(Int8, nfacenum, size(nEV, 1))

   for fi in 1:nfacenum
       for edge in nfaces[fi]
           ei = etuple2idx[Tuple{Int, Int}(sort(collect(edge)))]
           nFE[fi, ei] = sign(edge[2] - edge[1])
       end
   end

   return Lar.Points(nV), nEV, nFE
end



"""
    function spatial_arrangement_1(
            V::Points,
            copEV::ChainOp,
            copFE::ChainOp, 
            [multiproc::Bool=false])
			
Si occupa del processo di frammentazione delle facce per l'utilizzo del planar arrangement.	
Richiama le funzioni `frag_face` e `merge_vertices' per ritornare i nuovi vertici, lati e facce.

#### Argomenti addizionali:
- `multiproc::Bool`: Esegue la computazione in modalità parallela. Di Defaults a `false`.
"""
function spatial_arrangement_1(
		V::Points,
		copEV::ChainOp,
		copFE::ChainOp, multiproc::Bool=false)

	# spaceindex computation
	FV = Lar.compute_FV( copEV, copFE )
	model = (convert(Points,V'), FV)
	sp_idx = Lar.spaceindex(model) # OK!!  tested symmetry of computed relation

	# initializations
	fs_num = size(copFE, 1)
    rV = Array{Float64,2}(undef,0,3)
    rEV = SparseArrays.spzeros(Int8,0,0)
    rFE = SparseArrays.spzeros(Int8,0,0)

	# multiprocessing of face fragmentation
    if (multiproc == true)
        in_chan = Distributed.RemoteChannel(()->Channel{Int64}(0))
        out_chan = Distributed.RemoteChannel(()->Channel{Tuple}(0))
        @async begin
            for sigma in 1:fs_num
                put!(in_chan, sigma)
            end
            for p in Distributed.workers()
                put!(in_chan, -1)
            end
        end
        for p in Distributed.workers()
            @async Base.remote_do(
                frag_face_channel, p, in_chan, out_chan, V, EV, FE, sp_idx)
        end
        for sigma in 1:fs_num
            rV, rEV, rFE = Lar.skel_merge(rV, rEV, rFE, take!(out_chan)...)
        end
    else
	# sequential (iterative) processing of face fragmentation
        for sigma in 1:fs_num
            println("\n",sigma, "/", fs_num)
            nV, nEV, nFE = Lar.Arrangement.frag_face(V, copEV, copFE, sp_idx, sigma)
# 			v = size(nV,1); e = nEV.m; f = nFE.m
# @show v-e+f
# 			if v-e+f > 1
# 				g = v-e+f - 1	# number of inner loops
# 				nFE = removeinnerloops(g, nFE)
# @show nV;
# @show SparseArrays.nzind(nEV)
# @show SparseArrays.nzind(nFE)
# 			end
			#nV, nEV, nFE = Lar.fragface(V, copEV, copFE, sp_idx, sigma)
			nV = convert(Points, nV)
            a,b,c = Lar.skel_merge( rV,rEV,rFE,  nV,nEV,nFE )
            rV=a;  rEV=b;  rFE=c
        end
    end
	# merging of close vertices, edges and faces (3D congruence)
	rV, rEV, rFE = merge_vertices(rV, rEV, rFE, err=1e-3)
    return rV, rEV, rFE
end

"""
	function removeinnerloops(
            g::Int64, 
            nFE::ChainOp)

Rimuove le facce all'interno dei cicli interni dalla matrice sparsa nFE.
Il valore restituito ha `g` righe in meno rispetto all'input `nFE`.

"""
function removeinnerloops(g, nFE)
	# optimized solution (to check): remove the last `g` rows
	FE = Lar.cop2lar(nFE)
	nFE = Lar.lar2cop(FE[1:end-g])
end

"""
    function spatial_arrangement_2(
            rV::Points, 
            rcopEV::ChainOp, 
            rcopFE::ChainOp, 
            [multiproc::Bool=false])
			
Effettua la ricostruzione delle facce permettendo il wrapping spaziale 3D.

#### Argomenti addizionali:
- `multiproc::Bool`: Esegue la computazione in modalità parallela. Di Defaults a `false`.
		
"""
function spatial_arrangement_2(
		rV::Points,
		rcopEV::ChainOp,
		rcopFE::ChainOp, 
        multiproc::Bool=false)

	rcopCF = Lar.build_copFC(rV, rcopEV, rcopFE)  ######
	#rcopCF = Lar.Arrangement.minimal_3cycles(rV, rcopEV, rcopFE)
    return rV, rcopEV, rcopFE, rcopCF
end


"""
    function spatial_arrangement(
            V::Points, 
            copEV::ChainOp, 
            copFE::ChainOp; 
            [multiproc::Bool])

Calcola la disposizione sulle cellule complesse 2-skeleton date	in 3D.
														
Un complesso cellulare è disposto quando l'intersezione di ogni coppia di celle
del complesso è vuota e l'unione di tutte le celle rappresenta l'intero spazio Euclideo.
La funzione ritorna la piena disposizione complessa come una lista di vertici V e una catena di lati EV, FE, CF.

#### Argomenti addizionali:
- `multiproc::Bool`: Esegue la computazione in modalità parallela. Di Defaults a `false`.
"""
function spatial_arrangement(
		V::Points, # by rows
		copEV::ChainOp,
		copFE::ChainOp, 
        multiproc::Bool=false)

	# face subdivision
	rV, rcopEV, rcopFE = spatial_arrangement_1( V,copEV,copFE,multiproc )

	bicon_comps = Lar.Arrangement.biconnected_components(rcopEV)
	#W,bicon_comps = Lar.biconnectedComponent((W,EV))
	#@error "comps# = $(length(bicon_comps))"
	# 3-complex and containment graph

	rV, rEV, rFE, rCF = spatial_arrangement_2(rV, rcopEV, rcopFE)
end

export frag_face