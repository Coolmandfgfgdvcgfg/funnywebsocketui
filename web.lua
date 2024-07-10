local Services = setmetatable({}, { __index = function(Self, Key) return game.GetService(game, Key) end })
local Client = Services.Players.LocalPlayer
local SMethod = (WebSocket and WebSocket.connect)

if not SMethod then return Client:Kick("Executor is too shitty.") end

local Main = function()
	local Success, WebSocket = pcall(SMethod, "ws://localhost:9000/")
    	local Closed = false

	if not Success then return end

	WebSocket:Send(Services.HttpService:JSONEncode({
		Method = "Authorization",
		Name = Client.Name
	}))
	task.spawn(function()
		while Closed == false do
			WebSocket:Send(Services.HttpService:JSONEncode({
            		Method = "Ping",
            		Timestamp = tick()  -- Include a timestamp if needed
        		}))
			task.wait(2)
		end
	end)
	WebSocket.OnMessage:Connect(function(Unparsed)
		local Parsed 				= Services.HttpService:JSONDecode(Unparsed)
		
		if (Parsed.Method == "Execute") then
			local Function, Error 	= loadstring(Parsed.Data)

			if Error then return WebSocket:Send(Services.HttpService:JSONEncode({
				Method = "Error",
				Message	= Error
			}))	end
			
			Function()
		end
	end)

	-- WebSocket.OnClose:Wait()
	WebSocket.OnClose:Connect(function()
        	Closed = true
    	end)

    repeat
        wait()  
    until Closed
end

while wait(1) do
	local Success, Error 				= pcall(Main)
	if not Success then print(Error) end
end
