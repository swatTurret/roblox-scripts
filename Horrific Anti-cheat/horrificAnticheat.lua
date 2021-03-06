-- services
local plrs = game:GetService("Players")
local lighting = game:GetService("Lighting")
local replicatedStorage = game:GetService("ReplicatedStorage")
-- loadstrings
local material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
local esp = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()
-- constants
local EGGS = {"Furniture", "Ornament", "Spooky", "Death", "House", "Winter", "Easter", "Autumn", "WinterChest", "HouseChest"}
local OBJECTS_TO_IGNORE = {"Plate", "NpcSpawn", "PlayerSpawn", "House", "AcidRainFall", "MiniTaco", "Taco", "DuelArena", "snow", "Part", "Snow", "Pavement", "slime", "PatchOfGrass"}
local PLATES_TO_IGNORE = {"Supermarket", "road", "Pavement", "PatchOfGrass"}
local AUDIO_BLACKLIST = {"Climbing", "Died", "GettingUp", "Swimming", "Jumping", "Landing", "Splash", "FreeFalling", "Running"}
-- vars
local pets = {}
local ornaments = {}
local materials = {}
local colours = {}
local houseConfig = {
	currentMaterial = "SmoothPlastic",
	reflectance = 0,
	transparency = 0
}
local plr = plrs.LocalPlayer
local plrGui = plr.PlayerGui
local camera = game.Workspace.CurrentCamera
local listeners = {}
local toDestroy = {}
esp.Names = true
esp.TeamColor = false
esp.Color = Color3.fromRGB(0, 255, 0)
-- functions
local function resetLighting()
	print("resetting lighting...")
	lighting.Atmosphere.Density = 0.4
	lighting.TimeOfDay = "-09:00:00"
	lighting.FogEnd = 250
	game.Workspace.Terrain.Clouds.Color = Color3.new(1, 1, 1)
end
local function toggleDestroyWhenAddedToWorkspace(name: string, toggle: boolean)
	if toggle then
		if
			workspace:FindFirstChild(name, true) and
			not workspace:FindFirstChild(name, true):IsA("RemoteEvent") and
			not workspace:FindFirstChild(name, true):IsA("RemoteFunction")
		then
			workspace:FindFirstChild(name, true):Destroy()
		end
		if table.find(toDestroy, name) then
			warn(name.." was already in toDestroy, returning")
			return
		end
		table.insert(toDestroy, name)
	else
		if not table.find(toDestroy, name) then
			warn(name.." was not in toDestroy")
			return
		end
		table.remove(toDestroy, table.find(toDestroy, name))
	end
end
local function itemEsp(item)
	task.wait(0.02)
	local line = Drawing.new("Line")
	line.Visible = false
	line.Color = Color3.fromRGB(255, 0, 0)
	line.Thickness = 1.5
	line.Transparency = 1
	local text = Drawing.new("Text")
	text.Visible = false
	text.Size = 18
	text.Color = Color3.fromRGB(255, 0, 0)
	text.Outline = true
	text.Center = true
	text.Transparency = 1
	text.Text = item.Name
	local part
	if item:IsA("Model") and not item.PrimaryPart then
		-- grab random part or smth idk
		local function randomPart()
			task.wait()
			part = item:GetChildren()[math.random(#item:GetChildren())]
			if not part:IsA("BasePart") or not part:IsA("Model") then
				randomPart()
			end
		end
		randomPart()
	end
	local function draw()
		local stepped
		stepped = game:GetService("RunService").RenderStepped:Connect(function()
			if objEspEnabled == true then
				if item:FindFirstAncestor("Workspace") then
					local vector, onScreen
					if item:IsA("Model") and item.PrimaryPart then
						vector, onScreen = camera:worldToViewportPoint(item.PrimaryPart.Position)
					elseif item:IsA("Model") and not item.PrimaryPart then
						vector, onScreen = camera:worldToViewportPoint(part.Position)
					elseif item:IsA("Model") and #item:GetChildren() == 0 then
						line.Visible = false
						text.Visible = false
						line:Remove()
						text:Remove()
						line = nil
						text = nil
						stepped:Disconnect()
						stepped = nil
						draw = nil
						return
					elseif item:IsA("BasePart") or item:IsA("MeshPart") then
						vector, onScreen = camera:worldToViewportPoint(item.Position)
					end
					if onScreen then
						line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y) --Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
						line.To = Vector2.new(vector.X, vector.Y)
						text.Position = Vector2.new(vector.X, vector.Y)
						line.Visible = true
						text.Visible = true
					else
						line.Visible = false
						text.Visible = false
					end
				else
					line.Visible = false
					text.Visible = false
					line:Remove()
					text:Remove()
					line = nil
					text = nil
					stepped:Disconnect()
					stepped = nil
					draw = nil
					return
				end
			else
				line.Visible = false
				text.Visible = false
				line:Remove()
				text:Remove()
				line = nil
				text = nil
				stepped:Disconnect()
				stepped = nil
				draw = nil
				return
			end
		end)
	end
	coroutine.wrap(draw)()
end
local function findObjects(plate)
	if table.find(PLATES_TO_IGNORE, plate.Name) == nil then
		for _, child in pairs(plate:GetChildren()) do
			if table.find(OBJECTS_TO_IGNORE, child.Name) == nil then
				itemEsp(child)
			end
		end
		plate.ChildAdded:Connect(function(child)
			if table.find(OBJECTS_TO_IGNORE, child.Name) == nil then
				itemEsp(child)
			end
		end)
	end
end
local function loopThruPlates()
	if not game.Workspace:FindFirstChild("Plates") then error("plates folder does not exist in workspace, make sure it is in workspace before running loopThruPlates()") end -- expect plates folder to exist
	for _, plate in pairs(game.Workspace:FindFirstChild("Plates"):GetChildren()) do
		findObjects(plate)
	end
end
workspace.DescendantAdded:Connect(function(descendant)
	if table.find(toDestroy, descendant.Name) and
		not descendant:IsA("RemoteEvent") and
		not descendant:IsA("RemoteFunction")
	then
		task.wait()
		print("destroying "..descendant.Name)
		descendant:Destroy()
	end
end)
local ui = material.Load({
	Title = "Horrific Anti-cheat",
	Style = 1,
	Theme = "Dark",
})
local main = ui.New({
	Title = "Main",
})
local fun = ui.New({
	Title = "Fun"
})
local espPage = ui.New({
	Title = "ESP"
})
local cosmetics = ui.New({
	Title = "Cosmetics",
})
local credits = ui.New({
	Title = "Credits"
})
cosmetics.Button({
	Text = "Use old background music", -- they updated it literally rn lmao
	Callback = function()
		if not getsynasset and not getcustomasset then
			ui.Banner({
				Text = "Incompatible exploit, missing getcustomasset"
			})
		end
		local music
		for _, folder in pairs(workspace:GetChildren()) do
			if not folder:IsA("Folder") then continue end
			if folder.Name == "Music" then
				music = folder
			end
		end
		local lobby = music.Lobby
		local playing = music.Playing
		if not isfile("hh_bgm.mp3") then
			local raw = syn.request({
				Url = "https://cdn.discordapp.com/attachments/911335850258886676/956687633831055430/hh_bgm.mp3",
				Method = "GET"
			})
			writefile("hh_bgm.mp3", raw.Body)
		end
		--[[workspace.Music.Lobby.SoundId = getsynasset("hh_bgm.mp3")
		workspace.Music.Playing.SoundId = getsynasset("hh_bgm.mp3")--]]
		music.idleClassic.SoundId = getsynasset("hh_bgm.mp3")
		music.idleClassic:Play()
		playing:Stop()
		lobby:Stop()
		playing:GetPropertyChangedSignal("Playing"):Connect(function()
			if playing.Playing then
				playing:Stop()
			end
		end)
		lobby:GetPropertyChangedSignal("Playing"):Connect(function()
			if lobby.Playing then
				lobby:Stop()
			end
		end)
	end
})
cosmetics.Button({
	Text = "Give all obtainable items",
	Callback = function()
		for i = 1, 200, 1 do
			for _, v in pairs(EGGS) do
				replicatedStorage.ShopPurchase:FireServer(1e-59, v)
			end
		end
		replicatedStorage.ShopPurchase:FireServer(1e-59, "LunarBundle")
		replicatedStorage.ShopPurchase:FireServer(1e-59, "HeartBalloons")
	end,
})
cosmetics.Button({
	Text = "1000 eggs",
	Callback = function()
		for i = 1, 1000, 1 do
			replicatedStorage.ShopPurchase:FireServer(1e-59, "EggPets")
		end
	end,
})
for _, v in ipairs(replicatedStorage.Pets:GetChildren()) do
	table.insert(pets, v.Name)
end
cosmetics.Dropdown({
	Text = "Pets",
	Callback = function(value)
		replicatedStorage.PetChange:FireServer(value)
	end,
	Options = pets
})
for _, v in ipairs(replicatedStorage.Ornaments:GetChildren()) do
	table.insert(ornaments, v.Name)
end
cosmetics.Dropdown({
	Text = "Ornament 1",
	Callback = function(value)
		replicatedStorage.OrnamentChanged:FireServer("Ornament1", value)
	end,
	Options = ornaments
})
cosmetics.Dropdown({
	Text = "Ornament 2",
	Callback = function(value)
		replicatedStorage.OrnamentChanged:FireServer("Ornament2", value)
	end,
	Options = ornaments
})
cosmetics.Dropdown({
	Text = "Ornament 3",
	Callback = function(value)
		replicatedStorage.OrnamentChanged:FireServer("Ornament3", value)
	end,
	Options = ornaments
})
cosmetics.TextField({
	Text = "House Transparency (default 0)",
	Callback = function(value)
		local number = tonumber(value)
		if number then
			if number > 1 then
				number = 1
			elseif number < 0 then
				number = 0
			end
			replicatedStorage.HouseColour:FireServer(nil, houseConfig.currentMaterial, number, houseConfig.reflectance)
			houseConfig.transparency = number
		else
			ui.Banner({
				Text = "Please specify a number between 0 and 1"
			})
		end
	end
})
cosmetics.TextField({
	Text = "House Reflectance (default 0)",
	Callback = function(value)
		local number = tonumber(value)
		if number then
			if number > 1 then
				number = 1
			elseif number < 0 then
				number = 0
			end
			replicatedStorage.HouseColour:FireServer(nil, houseConfig.currentMaterial, houseConfig.transparency, number)
			houseConfig.reflectance = number
		else
			ui.Banner({
				Text = "Please specify a number between 0 and 1"
			})
		end
	end
})
for _, v in pairs(plrGui.HouseColour.Frame.Base.House.Materials.Frame:GetChildren()) do
	if v:IsA("ImageButton") then
		table.insert(materials, v.Name)
	end
end
cosmetics.Dropdown({
	Text = "House material (default smoothplastic)",
	Callback = function(value)
		replicatedStorage.HouseColour:FireServer(nil, value, houseConfig.transparency, houseConfig.reflectance)
		houseConfig.currentMaterial = value
	end,
	Options = materials
})
for _, v in pairs(plrGui.HouseColour.Frame.Base.House.Colours.Frame:GetChildren()) do
	if v:IsA("ImageButton") then
		table.insert(colours, v.Name)
	end
end
cosmetics.Dropdown({
	Text = "House colour",
	Callback = function(value)
		replicatedStorage.HouseColour:FireServer(plrGui.HouseColour.Frame.Base.House.Colours.Frame[value]["Properties"].Colour.Value)
	end,
	Options = colours
})
main.Toggle({
	Text = "Show player health",
	Callback = function(state)
		if state then
			listeners.charAdded = {}
			for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
				if plr.Character.Humanoid then
					plr.Character.Humanoid.HealthDisplayDistance = math.huge
				end
				local added = plr.CharacterAdded:Connect(function(char)
					char:WaitForChild("Humanoid").HealthDisplayDistance = math.huge
				end)
				table.insert(listeners.charAdded, added)
			end
		else
			for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
				if plr.Character and plr.Character:FindFirstChild("Humanoid") then
					plr.Character.Humanoid.HealthDisplayDistance = 100
					plr.Character.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
				end
			end
			if listeners.charAdded then
				for _, connection in pairs(listeners.charAdded) do
					connection:Disconnect()
					connection = nil
				end
			end
		end
	end
})
main.Toggle({
	Text = "No melee weapon cooldown",
	Callback = function(state)
		if state then
			listeners.noCooldown = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
				if gpe == true then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					for _, item in pairs(plr.Character:GetChildren()) do
						--[[if table.find(weapons, item.Name) then
							item.Event:FireServer()
						end--]]
						if item:IsA("Tool") then
							if item:FindFirstChild("Event") then
								item.Event:FireServer()
							elseif item:FindFirstChild("Remote") then
								item.Remote:FireServer()
							end
						end
					end
				end
			end)
		else
			if listeners.noCooldown then listeners.noCooldown:Disconnect() end
		end
	end
})
main.Toggle({
	Text = "Anti sans",
	Callback = function(state)
		toggleDestroyWhenAddedToWorkspace("GasterBlaster", state)
	end,
	Menu = {
		Info = function()
			ui.Banner({
				Text = "Deletes sans' lazers"
			})
		end
	},
	Enabled = false,
})
main.Toggle({
	Text = "Anti maintenance",
	Callback = function(state)
		if state then
			listeners.outageListener = plrGui.ChildAdded:Connect(function(child) -- expensive
				if child.Name == "MaintenanceUi" then
					task.wait()
					child:Destroy()
				end
			end)
		else
			if listeners.outageListener then listeners.outageListener:Disconnect() end
		end
	end
})
main.Toggle({
	Text = "Anti paranoia",
	Callback = function(state)
		if state then
			local atmosphere = lighting.Atmosphere
			resetLighting()
			listeners.paranoia = atmosphere:GetPropertyChangedSignal("Density"):Connect(function()
				if math.floor(atmosphere.Density * 10) == 8 then
					resetLighting()
				end
			end)
		else
			if listeners.paranoia then listeners.paranoia:Disconnect() end
		end
	end
})
main.Toggle({
	Text = "Delete sweeper",
	Callback = function(state)
		toggleDestroyWhenAddedToWorkspace("Spinner", state)
	end,
	Menu = {
		Info = function()
			ui.Banner({
				Text = "Destroys the spinner on the sweeper gamemode"
			})
		end
	}
})
main.Toggle({
	Text = "Delete lava",
	Callback = function(state)
		toggleDestroyWhenAddedToWorkspace("LavaPlate", state)
	end,
	Menu = {
		Info = function()
			ui.Banner({
				Text = "Destroys the lava in the lava gamemode"
			})
		end
	}
})
main.Toggle({
	Text = "Delete flood",
	Callback = function(state)
		toggleDestroyWhenAddedToWorkspace("Kill", state)
	end,
	Menu = {
		Info = function()
			ui.Banner({
				Text = "Destroys the acid flood"
			})
		end
	}
})
main.Toggle({
	Text = "Delete slime",
	Callback = function(state)
		toggleDestroyWhenAddedToWorkspace("slime", state)
	end
})
main.Toggle({
	Text = "Delete ice spike",
	Callback = function(state)
		toggleDestroyWhenAddedToWorkspace("spike", state)
	end
})
main.Toggle({
	Text = "Delete gas",
	Callback = function(state)
		toggleDestroyWhenAddedToWorkspace("Gas", state)
	end,
})
main.Toggle({
	Text = "Safety net",
	Callback = function(state)
		if state then
			local part = Instance.new("Part")
			part.Size = Vector3.new(500, 1, 500)
			part.Position = Vector3.new(0, -5, 0)
			part.Anchored = true
			part.Transparency = 1
			part.Name = "safety net"
			part.Parent = game.Workspace
		else
			if not game.Workspace:FindFirstChild("safety net") then return end
			game.Workspace:FindFirstChild("safety net"):Destroy()
		end
	end,
	Menu = {
		Info = function()
			ui.Banner({
				Text = "Creates an invisible platform that stops you from falling into the void"
			})
		end
	}
})
main.Toggle({
	Text = "Auto collect souls",
	Callback = function(state)
		if state then
			if not firetouchinterest then
				ui.Banner({
					Text = "Unsupported exploit: missing firetouchinterest"
				})
				return
			end
			listeners.soulAutoCollect = workspace.Souls.ChildAdded:Connect(function(child)
				if child.Name == "Soul" then
					firetouchinterest(plr.Character.Head, child, 1)
					task.wait()
					firetouchinterest(plr.Character.Head, child, 0)
				end
			end)
		end
	end
})
main.Button({
	Text = "Escape black hole",
	Callback = function()
		if not workspace:FindFirstChild("Portal") then
			ui.Banner({
				Text = "There needs to be a black hole spawned in for this to work"
			})
			return
		end
		local portal = workspace.Portal:FindFirstChild("EscapePortal")
		if firetouchinterest then
			firetouchinterest(plr.Character.Head, portal, 1)
			task.wait()
			firetouchinterest(plr.Character.Head, portal, 0)
		else
			plr.Character.HumanoidRootPart.CFrame = portal.CFrame
		end
	end
})
main.Button({
	Text = "Anti gun damage",
	Callback = function()
		replicatedStorage.damageMe:Destroy()
	end,
	Menu = {
		Info = function()
			ui.Banner({
				Text = "Destroys the damageMe RemoteEvent, any guns that rely on it will no longer damage you"
			})
		end
	}
})
fun.Button({
	Text = "KO sword",
	Callback = function()
		local anvilExists
		for _, v in pairs(game.Workspace.Plates:GetChildren()) do
			if v:FindFirstChild("Anvil") then
				anvilExists = true
			end
		end
		if not anvilExists then
			ui.Banner({
				Text = "An anvil needs to be spawned in for this to work."
			})
			return
		end
		replicatedStorage.EventRemotes.ForgeUltimateSword:FireServer("Cloner", "Cloner", "Cloner")
	end,
})
fun.Button({
	Text = "Delete all spleef tiles",
	Callback = function()
		if not firetouchinterest then
			ui.Banner({
				Text = "Unsupported exploit: missing firetouchinterest"
			})
			return
		end
		if game.Workspace:FindFirstChild("spleef gamemode") then
			for _, tile in ipairs(game:GetService("Workspace")["spleef gamemode"]:GetChildren()) do
				firetouchinterest(plr.Character.Head, tile, 1)
				firetouchinterest(plr.Character.Head, tile, 0)
			end
		else
			ui.Banner({
				Text = "The gamemode needs to be spleef for this to work"
			})
		end
	end
})
fun.Button({
	Text = "Trigger all mines",
	Callback = function()
		if not firetouchinterest then
			ui.Banner({
				Text = "Unsupported exploit: missing firetouchinterest"
			})
		end
		for _, item in pairs(workspace:GetChildren()) do
			if item.Name == "Handle" and item:FindFirstChild("Beep") then
				firetouchinterest(plr.Character.Head, item, 1)
				task.wait()
				firetouchinterest(plr.Character.Head, item, 0)
			end
		end
	end
})
fun.Button({
	Text = "Open all doors",
	Callback = function()
		if not fireclickdetector then
			ui.Banner({
				Text = "Unsupported exploit: missing fireclickdetector"
			})
		end
		for _, door in pairs(workspace:GetDescendants()) do
			if door.Name == "Doors" then
				fireclickdetector(door.ClickDetector)
			end
		end
	end
})
fun.Button({
	Text = "Open vending machine",
	Callback = function()
		if not fireclickdetector then
			ui.Banner({
				Text = "Unsupported exploit: missing fireclickdetector"
			})
		end
		local detector = workspace.OtherObjects.OpenVendingMachine.OpenVendingMachine.ClickDetector
		detector.MaxActivationDistance = 1000
		fireclickdetector(detector)
		detector.MaxActivationDistance = 15
	end
})
fun.Button({
	Text = "Potion",
	Callback = function()
		replicatedStorage.EventRemotes.Potion:FireServer("Pass")
		replicatedStorage.EventRemotes.Potion:FireServer("Drink")
	end
})
fun.Button({
	Text = "Annoy everyone",
	Callback = function()
		for _, sound in pairs(game:GetDescendants()) do
			if not sound:IsA("Sound") then continue end
			if sound:FindFirstAncestor("ReplicatedStorage") or sound:FindFirstAncestor("PlayerGui") or sound:FindFirstAncestor("StarterGui") or table.find(AUDIO_BLACKLIST, sound.Name) then continue end
			sound:Play()
		end
	end,
	Menu = {
		Info = function()
			ui.Banner({
				Text = "Plays every sound outside of ReplicatedStorage and PlayerGui"
			})
		end
	}
})
espPage.Toggle({
	Text = "Player ESP",
	Callback = function(state)
		esp:Toggle(state)
	end
})
espPage.Toggle({
	Text = "Player ESP tracers",
	Callback = function(state)
		esp.Tracers = state
	end
})
espPage.Toggle({
	Text = "Object ESP",
	Callback = function(state)
		if state then
			if not Drawing then
				ui.Banner({
					Text = "Unsupported exploit: missing Drawing"
				})
				return
			end
			objEspEnabled = true
			if game.Workspace:FindFirstChild("Plates") then
				loopThruPlates()
			end
			listeners.plateAdded = game.Workspace.ChildAdded:Connect(function(child) -- "expensive" i say as i add yet another workspace listener
				if child.Name == "Plates" then
					task.wait(7)
					loopThruPlates()
				end
			end)
		else
			objEspEnabled = false
			if listeners.plateAdded then listeners.plateAdded:Disconnect() end
		end
	end
})
credits.Button({
	Text = "Scripting: swat turret"
})
credits.Button({
	Text = "Kiriot22 esp lib",
	Callback = function()
		setclipboard("https://v3rmillion.net/showthread.php?tid=1088719")
		ui.Banner({
			Text = "Copied link to clipboard"
		})
	end
})
credits.Button({
	Text = "Ideas: swat turret & EnderChicken"
})
