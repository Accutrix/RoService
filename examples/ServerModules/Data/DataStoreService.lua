-- OptimisticSide
-- https://github.com/Accutrix/RoService

local DataStore = { }

DataStore.__index = DataStore


do
	local DataStoreService = game:GetService("DataStoreService")

	function DataStore:Get(Key)
		return self.InternalDataStore:GetAsync(Key) or self.DefaultValue
	end
	
	function DataStore:Set(Key, Value, Override)
		local Success, Result = pcall(self.InternalDataStore.UpdateAsync, self.InternalDataStore, Key, function(OldValue)
			if typeof(Value) == "function" then
				Value = pcall(Value, OldValue)
			end
			return Value or (Override and Value or OldValue)
		end)
		self.InternalUpdateBindable:Fire()
		return Success, Result
	end
	
	function DataStore:Increment(Key, Delta)
		return self:Set(Key, self:Get(Key) + Delta)
	end
	
	function DataStore:Remove(Key)
		return self:Set(Key, nil, true)
	end
	
	function DataStore.new(Name)
		local self = setmetatable({ }, DataStore)
		self.InternalDataStore = DataStoreService:GetDataStore(Name)
		self.InternalUpdateBindable = Instance.new("BindableEvent")
		self.Updated = self.InternalUpdateBindable.Event
		return self
	end
end

local DataStoreService = { }


function DataStoreService:GetDataStore(...)
	return DataStore.new(...)
end


return setmetatable(DataStoreService, {
	__index = function(self, Index)
		if DataStore[Index] then
			return DataStore[Index]
		else
			return game:GetService("DataStoreService")[Index]
		end
	end
})
