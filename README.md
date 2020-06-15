<h1 align="center">RoService</h1>

<div align="center">
	A framework to improve game development on the ROBLOX platform.
</div>

## About
RoService is a service-driven framework intended to improve module organization and productivity. It was developed by Accutrix Labs in 2020, and is free to use!  RoService makes code more portable and easily accessible throughout your project. 

## Usage
Using RoService is very easy. It uses 2 folders: one in ReplicatedStorage, and the other in ServerStorage. The one in ReplicatedStorage is to store shared services (this will be called `SharedServices`), and the one in ServerStorage is to store server modules (which will be called `ServerServices`). There will also be a ModuleScript in ReplicatedStorage, which will house methods to get services, and this will be called `Services`

Here's an example of using RoService. We will have an example service in the shared services, called `LogService`
```lua
local LogService = { }

function LogService:Log(...)
    print(...)
end

return LogService
```
Then, we'll have a script in ServerScriptService that will use our LogService.
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)

local LogService = Services:GetService("LogService")

LogService:Log("Hello world!")
```

## Installation
To install RoService, simply paste the following code into your command bar in ROBLOX studio.

```lua
local h = game:GetService("HttpService") loadstring(h:GetAsync("https://raw.githubusercontent.com/Accutrix/RoService/master/install.lua"))(h.HttpEnabled)
```
