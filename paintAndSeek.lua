local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Prevent duplicate GUI
if CoreGui:FindFirstChild("EspPremiumGui") then
	CoreGui.EspPremiumGui:Destroy()
end

-- Script state & color constants
local scriptActive = true
local hiderEspEnabled = true
local seekerEspEnabled = true

local COLOR_HIDER = Color3.fromRGB(0, 255, 255)
local COLOR_SEEKER = Color3.fromRGB(255, 0, 0)

local LocalPlayer = Players.LocalPlayer

-- ==== ROOT HELPER ====
local function getCharacterRoot(char)
	if not char then return end
	-- try common root names, fallback to primary part
	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("Head")
		or char.PrimaryPart
end

local function teleportToPart(targetPart)
	if not targetPart then return end
	local char = LocalPlayer.Character
	if not char then return end
	local root = getCharacterRoot(char)
	if root and root:IsA("BasePart") then
		-- offset upward to avoid clipping
		root.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
	end
end

-- ==== GUI CREATION ====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EspPremiumGui"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 275)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  Premium Control Panel"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -60, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(1, 0)
MinCorner.Parent = MinBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -45)
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Helper to create consistent buttons
local function createButton(name, text, yPos, defaultColor)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.Position = UDim2.new(0, 0, 0, yPos)
	btn.BackgroundColor3 = defaultColor
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 13
	btn.Parent = ContentFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	return btn
end

local HiderBtn = createButton("HiderToggle", "Hider ESP: ON", 5, Color3.fromRGB(0, 140, 200))
local SeekerBtn = createButton("SeekerToggle", "Seeker ESP: ON", 42, Color3.fromRGB(180, 40, 40))

local TeleportHeader = Instance.new("TextLabel")
TeleportHeader.Size = UDim2.new(1, 0, 0, 25)
TeleportHeader.Position = UDim2.new(0, 0, 0, 82)
TeleportHeader.BackgroundTransparency = 1
TeleportHeader.Text = "—— Teleport Exploit Functions ——"
TeleportHeader.TextColor3 = Color3.fromRGB(140, 140, 140)
TeleportHeader.TextSize = 12
TeleportHeader.Font = Enum.Font.SourceSansBold
TeleportHeader.Parent = ContentFrame

local TPObbyBtn = createButton("ObbyTP", "Teleport to Obby Winner Pad", 112, Color3.fromRGB(45, 125, 45))
local TPCoinBtn = createButton("CoinTP", "Teleport to NEAREST Coin", 150, Color3.fromRGB(200, 140, 0))

-- ==== MINIMIZE / RESTORE (WITHOUT TWEEN.WAIT) ====
local isMinimized = false
local originalSize = MainFrame.Size
local tweenObject = nil

MinBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local targetSize
	if isMinimized then
		targetSize = UDim2.new(0, 35, 0, 35)
	else
		targetSize = originalSize
	end

	if tweenObject then tweenObject:Cancel() end
	tweenObject = TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = targetSize})
	tweenObject:Play()

	tweenObject.Completed:Once(function()
		if isMinimized then
			ContentFrame.Visible = false
			Title.Visible = false
			CloseBtn.Visible = false
			MinBtn.Position = UDim2.new(0, 5, 0, 5)
			MinBtn.Text = "+"
			MainCorner.CornerRadius = UDim.new(1, 0)
		else
			MainCorner.CornerRadius = UDim.new(0, 8)
			ContentFrame.Visible = true
			Title.Visible = true
			CloseBtn.Visible = true
			MinBtn.Position = UDim2.new(1, -60, 0, 5)
			MinBtn.Text = "-"
		end
	end)
end)

-- ==== BUTTON HANDLERS ====
HiderBtn.MouseButton1Click:Connect(function()
	hiderEspEnabled = not hiderEspEnabled
	HiderBtn.BackgroundColor3 = hiderEspEnabled and Color3.fromRGB(0, 140, 200) or Color3.fromRGB(60, 60, 60)
	HiderBtn.Text = hiderEspEnabled and "Hider ESP: ON" or "Hider ESP: OFF"
end)

SeekerBtn.MouseButton1Click:Connect(function()
	seekerEspEnabled = not seekerEspEnabled
	SeekerBtn.BackgroundColor3 = seekerEspEnabled and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(60, 60, 60)
	SeekerBtn.Text = seekerEspEnabled and "Seeker ESP: ON" or "Seeker ESP: OFF"
end)

CloseBtn.MouseButton1Click:Connect(function()
	scriptActive = false
	ScreenGui:Destroy()
end)

-- Teleport to Obby Winner Pad (cached once found)
local obbyPad = nil
local function getObbyPad()
	if obbyPad and obbyPad:IsDescendantOf(Workspace) then return obbyPad end
	local lobby = Workspace:FindFirstChild("LobbyInteractives")
	if lobby then
		obbyPad = lobby:FindFirstChild("ObbyWinnerPad")
	else
		obbyPad = nil
	end
	return obbyPad
end

TPObbyBtn.MouseButton1Click:Connect(function()
	local pad = getObbyPad()
	if pad then
		teleportToPart(pad)
	else
		warn("ObbyWinnerPad not found.")
	end
end)

-- True nearest coin search
TPCoinBtn.MouseButton1Click:Connect(function()
	local coinsFolder = Workspace:FindFirstChild("SpawnedCoins")
	if not coinsFolder then
		warn("SpawnedCoins folder missing.")
		return
	end

	local char = LocalPlayer.Character
	if not char then
		warn("You have no character.")
		return
	end
	local root = getCharacterRoot(char)
	if not root then
		warn("No root part found on character.")
		return
	end
	local rootPos = root.Position

	local nearestCoin = nil
	local nearestDist = math.huge

	for _, coin in ipairs(coinsFolder:GetChildren()) do
		if coin:IsA("BasePart") then
			local dist = (coin.Position - rootPos).Magnitude
			if dist < nearestDist then
				nearestDist = dist
				nearestCoin = coin
			end
		end
	end

	if nearestCoin then
		teleportToPart(nearestCoin)
	else
		warn("No coins available to teleport to.")
	end
end)

-- ==== ESP SYSTEM (EVENT-DRIVEN CHARACTER LIST) ====
local activeBoxes = {}  -- [Player] = BoxHandleAdornment
local trackedPlayers = {} -- [Player] = true (only used for cleanup, optional)

-- Efficient player character tracking via events
local function onCharacterAdded(character)
	local player = Players:GetPlayerFromCharacter(character)
	if not player or player == LocalPlayer then return end
	-- Clean up old box if any
	if activeBoxes[player] then
		activeBoxes[player]:Destroy()
		activeBoxes[player] = nil
	end
	-- We do not create box yet; it will be created on next ESP update.
end

local function onPlayerAdded(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(onCharacterAdded)
	-- In case character already exists
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

local function onPlayerRemoving(player)
	if activeBoxes[player] then
		activeBoxes[player]:Destroy()
		activeBoxes[player] = nil
	end
end

-- Connect to all existing players
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Main ESP update (runs every frame via RenderStepped)
local function updateEsp()
	-- Gather all active characters
	local characters = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			if char then
				characters[player] = char
			end
		end
	end

	-- Process each tracked character
	for player, char in pairs(characters) do
		local head = char:FindFirstChild("Head")
		if not head or not head:IsA("BasePart") then
			-- If character exists but head is missing (e.g., dead), hide box
			if activeBoxes[player] then
				activeBoxes[player]:Destroy()
				activeBoxes[player] = nil
			end
			continue
		end

		local isHider = (head.Transparency >= 0.9)
		local isSeeker = (head.Transparency < 0.5)
		local showBox = (isHider and hiderEspEnabled) or (isSeeker and seekerEspEnabled)

		if showBox then
			local box = activeBoxes[player]
			if not box or box.Parent ~= CoreGui then
				-- Create new box if missing
				box = Instance.new("BoxHandleAdornment")
				box.Name = "EspBox"
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Adornee = head
				box.Size = Vector3.new(4, 5, 4)
				box.CFrame = CFrame.new(0, -1, 0)  -- relative offset
				box.Parent = CoreGui
				activeBoxes[player] = box
			end
			-- Update color
			box.Color3 = isHider and COLOR_HIDER or COLOR_SEEKER
			box.Transparency = 0.6
			-- Ensure Adornee is up to date (in case head changed)
			if box.Adornee ~= head then
				box.Adornee = head
			end
		else
			-- Hide / remove box
			if activeBoxes[player] then
				activeBoxes[player]:Destroy()
				activeBoxes[player] = nil
			end
		end
	end

	-- Remove boxes for players no longer in the game
	for player, box in pairs(activeBoxes) do
		if not characters[player] then
			box:Destroy()
			activeBoxes[player] = nil
		end
	end
end

-- Continuous ESP loop using RenderStepped (smooth & efficient)
RunService.RenderStepped:Connect(function()
	if not scriptActive then return end
	pcall(updateEsp)  -- safety wrapper
end)

-- Cleanup on GUI destruction
ScreenGui.Destroying:Connect(function()
	scriptActive = false
	for _, box in pairs(activeBoxes) do
		box:Destroy()
	end
	table.clear(activeBoxes)
	-- Disconnect player events if needed (optional)
end)
