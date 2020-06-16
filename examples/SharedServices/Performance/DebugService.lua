-- OptimisticSide
-- https://github.com/Accutrix/RoService

local RunService = game:GetService("RunService")
local TextService = game:GetService("TestService")

local Debug = { }

Debug.LogSeperator = "-"


function Debug:GetEnd()
	if RunService:IsServer() then
		return "Server"
	else
		return "Client"
	end
end


function Debug:Log(...)
	local LogData = {Debug:GetEnd(), ...}
	local Seperator = " " .. Debug.LogSeperator .. " "
	warn(table.concat(LogData, Seperator))
end


return Debug
