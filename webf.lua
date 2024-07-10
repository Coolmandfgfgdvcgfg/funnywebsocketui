local Services = setmetatable({}, { __index = function(Self, Key) return game.GetService(game, Key) end })
local Client = Services.Players.LocalPlayer

local Main = function()
	local Success, ws = pcall(WebSocket.connect, "ws://localhost:9000/")
    	local Closed = false

	if not Success then return end

	ws:Send(Services.HttpService:JSONEncode({
		Method = "Authorization",
		Name = Client.Name
	}))
	ws.OnMessage:Connect(function(Unparsed)
		local Parsed = Services.HttpService:JSONDecode(Unparsed)
		
		if (Parsed.Method == "Execute") then
			local Function, Error 	= loadstring(Parsed.Data)

			
			Function()
			if Error then
				error(Error)
			end
		end
	end)

	-- WebSocket.OnClose:Wait()
	ws.OnClose:Connect(function()
        	Closed = true
    	end)

    repeat
        ws:Send(Services.HttpService:JSONEncode({
            		Method = "Ping",
            		Timestamp = tick()  -- Include a timestamp if needed
        }))
	wait(2)
    until Closed
end

while wait(1) do
	local Success, Error 				= pcall(Main)
	if not Success then print(Error) end
end
