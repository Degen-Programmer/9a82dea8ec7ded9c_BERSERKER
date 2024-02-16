local RunService = game:GetService("RunService")
local EdibleMesh_Library = {}

-----------------------------------------------------------------------------------
export type VertexClass = {
	Normal: Vector3,
	Alpha: number,
	Color: Color3,
	Position: Vector3,
	UVCoordinate: Vector2,
}
export type VerticesDataClass = {
	Vertices: {[number]: VertexClass},
	Triangles: {[number]: {number}},
	EditableMesh: EditableMesh,
	Mesh: MeshPart,
	TriangleReference: {[number]: number},
	Temp: {[any]: any}
}
-----------------------------------------------------------------------------------

function map(value, min, max, output_min, output_max, keepInRange)
	local difference = max - min
	local difference_output = output_max - output_min

	local coefficient = difference_output / difference

	local difference_value = value - min
	local output_value = output_min + difference_value * coefficient

	if keepInRange then
		
		output_value = math.clamp(output_value, math.min(output_max, output_min), math.max(output_max, output_min))
	end
	return output_value
end

local VERTEX_APPEAR_TIME = .1
local VERTEX_APPEAR_DISTANCE = 3
local DEFAULT_WAIT_TIME = 1 / 60

local Vertex_Class = {}
function Vertex_Class.New(EditableMesh: EditableMesh, VertexId: number)
	local self = {}
	self.Normal = EditableMesh:GetVertexNormal(VertexId)
	self.Alpha = EditableMesh:GetVertexColorAlpha(VertexId)
	self.Color = EditableMesh:GetVertexColor(VertexId)
	self.Position = EditableMesh:GetPosition(VertexId)
	self.UVCoordinate = EditableMesh:GetUV(VertexId)

	return self :: VertexClass
end


local VerticesData_Class = {}
VerticesData_Class.__index =  VerticesData_Class

function VerticesData_Class.CreateVerticesData(Mesh: MeshPart, EditableMesh: EditableMesh)
	local self = setmetatable({}, Vertex_Class)

	self.EditableMesh = EditableMesh
	self.Mesh = Mesh
	self.Vertices = {}
	self.Triangles = {}
	self.TriangleReference = {}
	self.Temp = {}
	local Vertices = EditableMesh:GetVertices()
	for _, vertex in Vertices do
		local _Vertex = Vertex_Class.New(EditableMesh, vertex)
		self.Vertices[vertex] = _Vertex
		self.TriangleReference[vertex] = {}
	end
	for _, triangle in EditableMesh:GetTriangles() do
		local v1, v2, v3 = EditableMesh:GetTriangleVertices(triangle)
		--saving the order of verices for triangles
		self.Triangles[triangle] = {[1] = v1, [2] = v2, [3] = v3}
		table.insert(self.TriangleReference[v1], triangle)
		table.insert(self.TriangleReference[v2], triangle)
		table.insert(self.TriangleReference[v3], triangle)
	end
	return self:: VerticesDataClass
end


function VerticesData_Class.DestroyMesh(self: VerticesDataClass)	
	local Triangles = self.EditableMesh:GetTriangles()
	for _, triangle in Triangles do
		self.EditableMesh:RemoveTriangle(triangle)
	end
	local Vertices = self.EditableMesh:GetVertices()
	for _, vertex in Vertices do
		self.EditableMesh:RemoveVertex(vertex)
	end
end

function VerticesData_Class.Reset(self: VerticesDataClass)
	VerticesData_Class.DestroyMesh(self)
	local VerticesNewIds = {}	
	for vertexId, vertex: VertexClass in self.Vertices do
		local NewVertexId = self.EditableMesh:AddVertex(vertex.Position)
		VerticesNewIds[vertexId] = NewVertexId
		self.EditableMesh:SetVertexNormal(NewVertexId, vertex.Normal)
		self.EditableMesh:SetVertexColor(NewVertexId, vertex.Color)
		self.EditableMesh:SetVertexColorAlpha(NewVertexId, vertex.Alpha)
		self.EditableMesh:SetUV(NewVertexId, vertex.UVCoordinate)
	end

	for triangleId, triangleData in self.Triangles do
		local Triangle = self.EditableMesh:AddTriangle(VerticesNewIds[triangleData[1]], VerticesNewIds[triangleData[2]], VerticesNewIds[triangleData[3]])		
	end
end

function VerticesData_Class.CloneVertex(self: VerticesDataClass, vertexId: number, vertexPosition: Vector3?)
	local vertex = self.Vertices[vertexId]

	local NewVertexId = self.EditableMesh:AddVertex(vertexPosition or vertex.Position)
	self.EditableMesh:SetVertexNormal(NewVertexId, vertex.Normal)
	self.EditableMesh:SetVertexColor(NewVertexId, vertex.Color)
	self.EditableMesh:SetVertexColorAlpha(NewVertexId, vertex.Alpha)
	self.EditableMesh:SetUV(NewVertexId, vertex.UVCoordinate)

	return NewVertexId
end

function VerticesData_Class.ReplicateVertices(self: VerticesDataClass)
	local NewVertices = {}

	for originalVertexId, vertex in self.Vertices do
		local NewVertex = VerticesData_Class.CloneVertex(self, originalVertexId)
		NewVertices[originalVertexId] = NewVertex
	end

	return NewVertices
end

function VerticesData_Class.SortVerticesByDistanceFromPoint(self: VerticesDataClass, Point: Vector3)
	local RelativePosition = self.Mesh.CFrame:ToObjectSpace(CFrame.new(Point)).Position
	local ClosestVertex = nil
	local minimalDistance = bit32.bnot(0)
	for vertexId, vertex in self.Vertices do
		local Distance = (vertex.Position - RelativePosition).Magnitude 
		if Distance >= minimalDistance then
			continue
		end
		ClosestVertex = vertexId
		minimalDistance = Distance
	end

	local VertexDistances = {}
	for vertexId, vertex in self.Vertices do
		local Distance = (vertex.Position - self.Vertices[ClosestVertex].Position).Magnitude
		table.insert(VertexDistances, {vertexId, Distance})
	end

	table.sort(VertexDistances, function(a0: {number}, a1: {number}): boolean return a0[2] < a1[2] end)
	return VertexDistances
end

function VerticesData_Class.TweenVertexToPosition(self: VerticesDataClass, VertexId: number, StartPosition: Vector3, TargetPosition: Vector3, Time: number)
	--Uses only existing vertices in mesh (NOT SAVED)
	task.spawn(function()
		local TotalDt = 0
		local StartPosition = StartPosition
		while TotalDt < Time do
			TotalDt += task.wait()
			local X = map(TotalDt, 0, Time, StartPosition.X, TargetPosition.X, true)
			local Y = map(TotalDt, 0, Time, StartPosition.Y, TargetPosition.Y, true)
			local Z = map(TotalDt, 0, Time, StartPosition.Z, TargetPosition.Z, true)
			self.EditableMesh:SetPosition(VertexId, Vector3.new(X, Y, Z))
		end
	end)
end

function VerticesData_Class.AppearFromPoint(self: VerticesDataClass, Point: Vector3, Time: number, Offset: number?)
	VerticesData_Class.DestroyMesh(self)

	local SortedPoints = VerticesData_Class.SortVerticesByDistanceFromPoint(self, Point)
	local UsedPoints = {}

	local WaitTime = (Time - VERTEX_APPEAR_TIME) / #self.Vertices
	local Coeficient = WaitTime / DEFAULT_WAIT_TIME 
	local WaitFloat = 0

	for _, vertexTable in SortedPoints do

		WaitFloat += Coeficient
		local TimesToWait, Float = math.modf(WaitFloat)
		WaitFloat = Float
		for i = 1, TimesToWait do
			task.wait()
		end

		local startTime = os.clock()
		local currentVertexId = vertexTable[1]
		local VertexPosition = self.Vertices[currentVertexId].Position
		local CloneVertexPosition = VertexPosition + VertexPosition.Unit * (Offset or VERTEX_APPEAR_DISTANCE)
		local CloneVertex = VerticesData_Class.CloneVertex(self, currentVertexId,CloneVertexPosition )

		VerticesData_Class.TweenVertexToPosition(self, CloneVertex, CloneVertexPosition, VertexPosition, VERTEX_APPEAR_TIME)

		UsedPoints[currentVertexId] = CloneVertex

		local TrianglesId = self.TriangleReference[currentVertexId]

		for _, triangleId in TrianglesId do
			local RequiredVertices = self.Triangles[triangleId]

			local RequiredVerticesExist = true

			for _, requiredVertexId in RequiredVertices do
				if UsedPoints[requiredVertexId] == nil then
					RequiredVerticesExist = false
					break
				end
			end

			if not RequiredVerticesExist then
				continue
			end
			
			local v1 = UsedPoints[RequiredVertices[1]]
			local v2 = UsedPoints[RequiredVertices[2]]
			local v3 = UsedPoints[RequiredVertices[3]]

			self.EditableMesh:AddTriangle(v1, v2, v3)
		end

		local endTime = os.clock()
		--Measuring time loss with startTime and endTime
		local TimeLoss = endTime - startTime
		local TimeLossCoeficient = TimeLoss / DEFAULT_WAIT_TIME
		WaitFloat -= TimeLossCoeficient
		WaitFloat = math.max(0, WaitFloat)
	end
	task.wait(VERTEX_APPEAR_TIME + .1)
end

--VerticesData_Class.

function VerticesData_Class.Appear(self: VerticesDataClass, Time: number)
	local Vertices = {}
	for _, triangleData in self.Triangles do
		local v1 = VerticesData_Class.CloneVertex(self, triangleData[1])
		local v2 = VerticesData_Class.CloneVertex(self, triangleData[2])
		local v3 = VerticesData_Class.CloneVertex(self, triangleData[3])

		local v1Position = self.Vertices[triangleData[1]].Position +  self.Vertices[triangleData[1]].Position.Unit * Random.new():NextNumber(1, 2) * 50
		local v2Position = self.Vertices[triangleData[2]].Position +  self.Vertices[triangleData[2]].Position.Unit * Random.new():NextNumber(1, 2) * 50
		local v3Position = self.Vertices[triangleData[3]].Position +  self.Vertices[triangleData[3]].Position.Unit * Random.new():NextNumber(1, 2) * 50

		self.EditableMesh:SetPosition(v1, v1Position) 
		self.EditableMesh:SetPosition(v2, v2Position) 
		self.EditableMesh:SetPosition(v3, v3Position)

		local Triangle = self.EditableMesh:AddTriangle(v1, v2, v3)

		table.insert(Vertices, {[1] = v1, [2] = v1Position, [3] = triangleData[1]})
		table.insert(Vertices, {[1] = v2, [2] = v2Position, [3] = triangleData[2]})
		table.insert(Vertices, {[1] = v3, [2] = v3Position, [3] = triangleData[3]})
	end

	local totalDt = 0
	while totalDt < Time do
		totalDt += task.wait()
		--task.wait(1)
		for originVertexId, vertexTable in Vertices do
			local VertexId = vertexTable[1]
			local TargetId = vertexTable[3]
			local FirstPosition = vertexTable[2]
			local TargetPosition = self.Vertices[TargetId].Position

			local X = map(totalDt, 0, Time, FirstPosition.X, TargetPosition.X, true)
			local Y = map(totalDt, 0, Time, FirstPosition.Y, TargetPosition.Y, true)
			local Z = map(totalDt, 0, Time, FirstPosition.Z, TargetPosition.Z, true)
			self.EditableMesh:SetPosition(VertexId, Vector3.new(X, Y, Z))			
		end
	end
end


EdibleMesh_Library.VerticesData_Class = VerticesData_Class

return EdibleMesh_Library
