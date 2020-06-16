-- OptimisticSide
-- https://github.com/Accutrix/RoService

local Characters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
local Digits = {1, 2, 3, 4, 5, 6, 7, 8, 9, 0}

local Identification = { }


function Identification:GenerateId(Length)
	Length = Length or 20
	local Result = ""
	for I = 1, Length do
		local Character = math.random(1, 2) == 1 and Characters[math.random(1, #Characters)] or Digits[math.random(1, #Digits)]
		Character = math.random(1, 2) == 1 and string.upper(Character) or string.lower(Character)
		Result = Result .. Character
	end
	return Result
end


return Identification
