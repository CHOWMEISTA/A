--[[ 
ULTIMATE PLAYER ADMIN + ESP (ONE FILE)
Legitimate, no exploits, players only
]]

-----------------------
-- SERVICES
-----------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

-----------------------
-- REMOTE EVENT
-----------------------
local Remote = Instance.new("RemoteEvent")
Remote.Name = "AdminRemote"
Remote.Parent = ReplicatedStorage

------------------------------------------------
-- SERVER LOGIC (AUTHORITATIVE ACTIONS)
------------------------------------------------
Remote.OnServerEvent:Connect(function(plr, action, data)
	if not plr.Character then return end
	local target = (data.target and data.target ~= "" and Players:FindFirstChild(data.target)) or plr
	if not target or not target.Character then return end

	local char = target.Character
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	if action == "speed" then
		hum.WalkSpeed = data.v

	elseif action == "jump" then
		hum.JumpPower = data.v

	elseif action == "heal" then
		hum.Health = hum.MaxHealth

	elseif action == "kill" then
		hum.Health = 0

	elseif action == "god" then
		hum.MaxHealth = data.v and math.huge or 100
		hum.Health = hum.MaxHealth

	elseif action == "freeze" then
		root.Anchored = data.v

	elseif action == "noclip" then
		for _,p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = not data.v
			end
		end

	elseif action == "fly" then
		if data.v then
			local bv = Instance.new("BodyVelocity")
			bv.Name = "FlyForce"
			bv.MaxForce = Vector3.new(1e9,1e9,1e9)
			bv.Velocity = Vector3.new(0,60,0)
			bv.Parent = root
		else
			local f = root:FindFirstChild("FlyForce")
			if f then f:Destroy() end
		end

	elseif action == "tp_up" then
		root.CFrame *= CFrame.new(0,50,0)

	elseif action == "gravity" then
		workspace.Gravity = data.v

	elseif action == "time" then
		Lighting.ClockTime = data.v
	end
end)

------------------------------------------------
-- CLIENT SETUP (GUI + ESP)
------------------------------------------------
local function setupClient(player)
	player.CharacterAdded:Wait()

	---------------- GUI ROOT ----------------
	local gui = Instance.new("ScreenGui")
	gui.Name = "AdminGui"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.fromScale(0.55,0.6)
	main.Position = UDim2.fromScale(0.225,0.2)
	main.BackgroundColor3 = Color3.fromRGB(22,22,22)
	main.Active, main.Draggable = true, true

	---------------- SIDE PANEL ----------------
	local side = Instance.new("Frame", main)
	side.Size = UDim2.fromScale(0.25,1)
	side.BackgroundColor3 = Color3.fromRGB(30,30,30)

	local pages = Instance.new("Frame", main)
	pages.Position = UDim2.fromScale(0.25,0)
	pages.Size = UDim2.fromScale(0.75,1)
	pages.BackgroundTransparency = 1

	local function makePage(name)
		local f = Instance.new("Frame", pages)
		f.Size = UDim2.fromScale(1,1)
		f.Visible = false
		f.Name = name
		return f
	end

	local function switch(name)
		for _,p in ipairs(pages:GetChildren()) do
			p.Visible = p.Name == name
		end
	end

	local y = 0.05
	local function sideBtn(text,page)
		local b = Instance.new("TextButton", side)
		b.Size = UDim2.fromScale(1,0.08)
		b.Position = UDim2.fromScale(0,y)
		y += 0.085
		b.Text = text
		b.TextScaled = true
		b.BackgroundColor3 = Color3.fromRGB(45,45,45)
		b.TextColor3 = Color3.new(1,1,1)
		b.MouseButton1Click:Connect(function()
			switch(page)
		end)
	end

	---------------- PAGES ----------------
	local Movement = makePage("Movement")
	local PlayerCtl = makePage("Player")
	local Env = makePage("Env")
	local ESP = makePage("ESP")

	switch("Movement")

	sideBtn("Movement","Movement")
	sideBtn("Player","Player")
	sideBtn("Environment","Env")
	sideBtn("ESP","ESP")

	local targetBox = Instance.new("TextBox", main)
	targetBox.Size = UDim2.fromScale(0.3,0.06)
	targetBox.Position = UDim2.fromScale(0.35,0.02)
	targetBox.PlaceholderText = "Target (blank = self)"

	local function btn(parent,text,pos,cb)
		local b = Instance.new("TextButton", parent)
		b.Size = UDim2.fromScale(0.9,0.08)
		b.Position = UDim2.fromScale(0.05,pos)
		b.Text = text
		b.TextScaled = true
		b.MouseButton1Click:Connect(cb)
	end

	-- MOVEMENT
	btn(Movement,"Speed 80",0.1,function()
		Remote:FireServer("speed",{target=targetBox.Text,v=80})
	end)
	btn(Movement,"Jump 120",0.2,function()
		Remote:FireServer("jump",{target=targetBox.Text,v=120})
	end)

	local fly=false
	btn(Movement,"Fly Toggle",0.3,function()
		fly=not fly
		Remote:FireServer("fly",{target=targetBox.Text,v=fly})
	end)

	-- PLAYER
	btn(PlayerCtl,"Heal",0.1,function()
		Remote:FireServer("heal",{target=targetBox.Text})
	end)
	btn(PlayerCtl,"Kill",0.2,function()
		Remote:FireServer("kill",{target=targetBox.Text})
	end)

	local god=false
	btn(PlayerCtl,"Godmode",0.3,function()
		god=not god
		Remote:FireServer("god",{target=targetBox.Text,v=god})
	end)

	-- ENV
	btn(Env,"Low Gravity",0.1,function()
		Remote:FireServer("gravity",{v=50})
	end)
	btn(Env,"Reset Gravity",0.2,function()
		Remote:FireServer("gravity",{v=196.2})
	end)
	btn(Env,"Day",0.3,function()
		Remote:FireServer("time",{v=14})
	end)
	btn(Env,"Night",0.4,function()
		Remote:FireServer("time",{v=0})
	end)

	---------------- ESP (LEGIT) ----------------
	local espEnabled = false
	local adornments = {}

	local function clearESP()
		for _,v in pairs(adornments) do
			v:Destroy()
		end
		adornments = {}
	end

	local function applyESP()
		clearESP()
		for _,p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local box = Instance.new("SelectionBox")
				box.Adornee = p.Character
				box.Color3 = p.TeamColor.Color
				box.LineThickness = 0.05
				box.Parent = gui
				table.insert(adornments,box)
			end
		end
	end

	btn(ESP,"Toggle ESP",0.1,function()
		espEnabled = not espEnabled
		if espEnabled then applyESP() else clearESP() end
	end)

	Players.PlayerAdded:Connect(function()
		if espEnabled then applyESP() end
	end)

	---------------- GUI TOGGLE ----------------
	UIS.InputBegan:Connect(function(i,gp)
		if not gp and i.KeyCode == Enum.KeyCode.RightShift then
			main.Visible = not main.Visible
		end
	end)
end

Players.PlayerAdded:Connect(setupClient)
for _,p in ipairs(Players:GetPlayers()) do
	setupClient(p)
end
