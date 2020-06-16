-- OptimisticSide
-- https://github.com/Accutrix/RoService

local MAX_TIMEOUT_INTERVAL = 5

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = RunService:IsClient() and Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Network")
local Services = require(ReplicatedStorage:WaitForChild("Services"))

local DebugService = Services:GetService("DebugService")
local IdentificationService = Services:GetService("IdentificationService")

local LocalEnd = RunService:IsServer() and "Server" or "Client"
local CommuncationEnd = RunService:IsClient() and "Server" or "Client"

local Network = { }

Network.TrafficData = { }
Network.TrackingTraffic = false

Network.Remotes = {
	RemoteEvent = { };
	RemoteFunction = { };
}

Network.Callbacks = {
	RemoteEvent = { };
	RemoteFunction = { };
}


function Network:LogTraffic(Remote, From, To, ...)
	if Network.TrackingTraffic then
		table.insert(Network.TrafficData, tick(), {Remote.ClassName, Remote.Name, From, To, ...})
	end
end


function Network:Bind(RemoteType, RemoteName, ...)
	local Parameters = {...}
	local CallbackId = IdentificationService:GenerateId()
	local Callback = Parameters[#Parameters]
	
	table.remove(Parameters, #Parameters)
	if Network.Callbacks[RemoteType][RemoteName] then
		Network.Callbacks[RemoteType][RemoteName][CallbackId] = {
			Filters = Parameters;
			Function = Callback;
		}
	else
		DebugService:Log("Network", "Unable to bind to " .. RemoteType .. " '" .. RemoteName .. "' | Remote does not exist")
	end
end


function Network:ScanFilters(Parameters, Filters)
	for Index, Parameter in pairs(Filters or { }) do
		if Parameters[Index] ~= Parameter then
			return false
		end
	end
	return true
end


function Network:FindCallback(Remote, ...)
	local RemoteType = Remote.ClassName
	local RemoteName = Remote.Name
	local Parameters = {...}
	for CallbackId, Callback in pairs(Network.Callbacks[RemoteType][RemoteName] or { }) do
		if Network:ScanFilters(Parameters, Callback.Filters) then
			return Callback
		end
	end
end


function Network:ExecuteCallback(Callback, ...)
	local StartTime = tick()
	local Result = {pcall(Callback.Function, ...)}
	repeat wait() until Result or tick() - StartTime > MAX_TIMEOUT_INTERVAL
	
	local Success = Result[1]
	table.remove(Result, 1)
	if Success then
		return Success, Result
	end
end


function Network:HandleRemote(Remote, ...)
	local Callback = Network:FindCallback(Remote, ...)
	if Callback then
		local Success, Result = Network:ExecuteCallback(Callback, ...)
		if Success then
			return unpack(Result)
		end
	end
end


function Network:AddRemote(Remote)
	if typeof(Remote) ~= "Instance" or (not Remote:IsA("RemoteEvent") and not Remote:IsA("RemoteFunction")) then
		return
	end
	local ClassName = Remote.ClassName
	local RemoteName = Remote.Name
	
	Network.Remotes[ClassName][RemoteName] = Remote
	Network.Callbacks[ClassName][RemoteName] = { }
	
	if Remote:IsA("RemoteEvent") then
		Remote["On" .. LocalEnd .. "Event"]:Connect(function(...)
			return Network:HandleRemote(Remote, ...)
		end)
	elseif Remote:IsA("RemoteFunction") then
		Remote["On" .. LocalEnd .. "Invoke"] = function(...)
			return Network:HandleRemote(Remote, ...)
		end
	end
end


function Network:TrackTraffic(Duration)
	Network.TrafficData = { }
	Network.TrackingTraffic = true
	wait(Duration)
	
	Network.TrackingTraffic = false
	local TrafficData = Network.TrafficData
	Network.TrafficData = { }
	return TrafficData
end


function Network:Fire(RemoteName, ...)
	local Remote = Network.Remotes.RemoteEvent[RemoteName]
	if Remote then
		return Remote["Fire" .. CommuncationEnd](Remote, ...)
	end
end


function Network:Invoke(RemoteName, ...)
	local Remote = Network.Remotes.RemoteFunction[RemoteName]
	if Remote then
		return Remote["Invoke" .. CommuncationEnd](Remote, ...)
	end
end


function Network:Init()
	local function AddRemotes(Remotes)
		for _, Remote in pairs(Remotes) do
			if typeof(Remote) == "Instance" and (Remote:IsA("RemoteEvent") or Remote:IsA("RemoteFunction")) then
				Network:AddRemote(Remote)
			end
		end
	end
	AddRemotes(Remotes:GetDescendants())
end


function Network:BindToEvent(RemoteName, ...)
	return Network:Bind("RemoteEvent", RemoteName, ...)
end

function Network:BindToFunction(RemoteName, ...)
	return Network:Bind("RemoteFunction", RemoteName, ...)
end


function Network:FireServer(...)
	return Network:Fire(...)
end

function Network:FireClient(Client, Remote, ...)
	return Network:Fire(Remote, Client, ...)
end


function Network:InvokeServer(...)
	return Network:Invoke(...)
end

function Network:InvokeClient(Client, Remote, ...)
	return Network:Invoke(Remote, Client, ...)
end


function Network:FireClients(Clients, Remote, ...)
	for _, Client in pairs(Clients) do
		Network:FireClient(Client, Remote, ...)
	end
end

function Network:InvokeClients(Clients, Remote, ...)
	local Responses = { }
	for _, Client in pairs(Clients) do
		Responses[Client] = Network:InvokeClient(Client, Remote, ...)
	end
	return Responses
end


function Network:FireAllClients(Remote, ...)
	return Network:FireClients(Players:GetPlayers(), Remote, ...)
end

function Network:InvokeAllClients(Remote, ...)
	return Network:InvokeClients(Players:GetPlayers(), Remote, ...)
end


Network:Init()


return Network
