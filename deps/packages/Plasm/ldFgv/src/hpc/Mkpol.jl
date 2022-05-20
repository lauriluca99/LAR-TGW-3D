using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using QHull

function GLLar(points::Array{Float64,2}, cells::Array{Array{Int64, 1}, 1})

	points = convert(Array{Float64,2}, points')
	vertices=Vector{Float32}()
	normals =Vector{Float32}()
	for cell in cells

		ch = QHull.chull(points[cell,:])
		verts = ch.vertices
		vdict = Dict(zip(verts, 1:length(verts)))
		hfaces = [[vdict[u],vdict[v],vdict[w]] for (u,v,w) in ch.simplices]
		hdict = Dict(zip(1:length(cell), cell))
		trias = [[hdict[t1],hdict[t2],hdict[t3]] for (t1,t2,t3) in hfaces]
		pts = points[verts,:]

		for tria in trias
			p3,p2,p1 = points[tria[1],:],points[tria[2],:],points[tria[3],:]
			p1 = convert(Point3d, p1)
			p2 = convert(Point3d, p2)
			p3 = convert(Point3d, p3)
			n=0.5*computeNormal(p1::Point3d,p2::Point3d,p3::Point3d)

			append!(vertices,p1); append!(normals,n)
			append!(vertices,p2); append!(normals,n)
			append!(vertices,p3); append!(normals,n)
		end
	end

	ret=GLMesh(GL_TRIANGLES)
	ret.vertices = GLVertexBuffer(vertices)
	ret.normals  = GLVertexBuffer(normals)
	return ret
end

V,CV = Lar.cuboidGrid([20,10,1])
VIEW([
      #GLCuboid(Box3d(Point3d(0,0,0),Point3d(1,1,1)))
      GLLar(V,CV)
      GLAxis(Point3d(0,0,0),Point3d(1,1,1))
])
