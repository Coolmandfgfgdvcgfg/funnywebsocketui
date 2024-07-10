local Client = game.Players.LocalPlayer
local SMethod = (WebSocket and WebSocket.connect)

if not SMethod then return Client:Kick("Executor is too shitty.") end

local Main = function()
	local ws = WebSocket.connect("ws://localhost:9000")
    	local Closed = false
	pcall(function()
	ws:Send(game:GetService("HttpService"):JSONEncode({
		Method = "Authorization",
		Name = Client.Name
	}))
	end)
	ws.OnMessage:Connect(function(Unparsed)
		print(Unparsed)
		local Parsed = game:GetService("HttpService"):JSONDecode(Unparsed)
		print(Parsed)
		print(Parsed.Method)
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

	pcall(function()
		while Closed == false do
			ws:Send(game:GetService("HttpService"):JSONEncode({
            		Method = "Ping",
            		Timestamp = tick()  -- Include a timestamp if needed
        		}))
			task.wait(2)
		end
	end)		
    repeat
        wait()  
    until Closed
end

while wait(1) do
	local Success, Error = pcall(Main)
	if not Success then print(Error) end
end
