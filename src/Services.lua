-- OptimisticSide
-- https://github.com/Accutrix/RoService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local SharedServices = ReplicatedStorage:WaitForChild("SharedServices")

local Services = { }


function Services:FindService(ServiceFolder, ServiceName)
	for _, SubFolder in ipairs(ServiceFolder:GetChildren()) do
		for _, Service in ipairs(SubFolder:GetChildren()) do
			if ServiceName == Service.Name or ServiceName == Service.Name .. "Service" then
				if Service:IsA("IntValue") or Service:IsA("NumberValue") or Service:IsA("StringValue") or Service:IsA("ObjectValue") then
					if typeof(Service.Value) == "string" and not tonumber(Service.Value) then
						local RequirePath = string.split(Service.Value, ".")
						
						local Parent = RequirePath[1] == "script" and Service or game
						for _, Child in ipairs({select(2, unpack(RequirePath))}) do
							Parent = Parent:WaitForChild(Child)
						end
						if Parent:IsA("ModuleScript") then
							return Parent
						end
					else
						return tonumber(Service.Value) or Service.Value
					end
				end
				return Service
			end
		end
	end
end


function Services:GetService(ServiceName, ShouldntRequire)
	local Service
	if RunService:IsServer() then
		local FromServer = Services:FindService(ServerStorage:WaitForChild("ServerServices"), ServiceName)
		if FromServer then
			Service = FromServer
		end
	end
	if not Service then
		local FromShared = Services:FindService(SharedServices, ServiceName)
		if FromShared then
			Service = FromShared
		end
	end
	if Service then
		if not ShouldntRequire then
			local Success, Result = pcall(require, Service)
			repeat wait() until Success or Result
			if Success then
				Service = Result
			else
				warn("Services - Unable to load service '" .. Service.Name .. "' | " .. Result)
			end
		end
	else
		local Success, GameService = pcall(function()
			return game:GetService(ServiceName)
		end)
		if Success then
			Service = GameService
		end
	end
	return Service
end


return setmetatable({ }, {
	__index = function(self, Index)
		local FromServices = rawget(Services, Index)
		if FromServices then
			return FromServices
		else
			local Service = Services:GetService(Index)
			if Service then
				return Service
			end
		end
	end;
})
