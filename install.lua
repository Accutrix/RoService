-- OptimisticSide
-- https://github.com/Accutrix/RoService

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")


function Install(HttpEnabled)
	if not HttpEnabled then
		warn("RoService - HTTP is not enabled; Enabling...")
		HttpService.HttpEnabled = true
	end
	
	local Success, Fail = pcall(function()
		local ServicesModule = Instance.new("ModuleScript", ReplicatedStorage)
		ServicesModule.Name = "Services"
		
		local Success, Result = pcall(function()
			return HttpService:GetAsync("https://raw.githubusercontent.com/Accutrix/RoService/master/src/Services.lua")
		end)
		
		if Success then
			ServicesModule.Source = Result
		else
			warn("RoService - Unable to get source of Services module")
		end
		
		local SharedServices = Instance.new("Folder", ReplicatedStorage)
		local ServerServices = Instance.new("Folder", ServerStorage)
		
		SharedServices.Name = "SharedServices"
		ServerServices.Name = "ServerServices"
	end)
	
	if Success then
		warn("RoService - Installation successful")
	else
		warn("RoService - Could not install properly | " .. Fail)
	end
end

Install(...)
