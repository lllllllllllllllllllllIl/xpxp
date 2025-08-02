-- LocalScript (put in StarterPlayerScripts)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Configurable teleport positions
local positions = {
    { name = "Spot 1", pos = Vector3.new(-13.31, 3.55, -352.51) },
    { name = "Spot 2", pos = Vector3.new(-13.90, 3.55, -488.12) },
}

-- UI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 150)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0, 0)
mainFrame.Parent = screenGui

local uiLayout = Instance.new("UIListLayout")
uiLayout.Padding = UDim.new(0, 4)
uiLayout.FillDirection = Enum.FillDirection.Vertical
uiLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiLayout.VerticalAlignment = Enum.VerticalAlignment.Top
uiLayout.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Teleport Positions"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = mainFrame

-- State
local selectedIndex = 1
local markersVisible = true

-- Toggle markers button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -10, 0, 25)
toggleBtn.Text = "Hide World Markers"
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
toggleBtn.Parent = mainFrame

-- Position buttons container
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, -10, 0, 60)
listFrame.BackgroundTransparency = 1
listFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = listFrame

-- Teleport button
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1, -10, 0, 30)
tpBtn.Text = "Teleport"
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 16
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Parent = mainFrame

-- Helpers
local function updateSelectionUI()
    for i, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then
            if i == selectedIndex then
                child.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            else
                child.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end
        end
    end
end

-- Create selection buttons
for i, data in ipairs(positions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Text = data.name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = listFrame

    btn.MouseButton1Click:Connect(function()
        selectedIndex = i
        updateSelectionUI()
    end)
end

updateSelectionUI()

-- Teleport function: exact position, preserve orientation
local function teleportTo(index)
    local char = player.Character
    if not char or not char.Parent then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local target = positions[index]
    if not target then return end

    local _, yRot, _ = hrp.CFrame:ToEulerAnglesYXZ()
    -- Preserve yaw (facing), reset pitch/roll
    hrp.CFrame = CFrame.new(target.pos) * CFrame.Angles(0, yRot, 0)
end

-- Button connections
tpBtn.MouseButton1Click:Connect(function()
    teleportTo(selectedIndex)
end)

toggleBtn.MouseButton1Click:Connect(function()
    markersVisible = not markersVisible
    toggleBtn.Text = markersVisible and "Hide World Markers" or "Show World Markers"
    local folder = workspace:FindFirstChild("TeleportMarkers")
    if folder then
        for _, anchor in ipairs(folder:GetChildren()) do
            local gui = anchor:FindFirstChild("BillboardGui")
            if gui then
                gui.Enabled = markersVisible
            end
        end
    end
end)

-- World markers
local markersFolder = workspace:FindFirstChild("TeleportMarkers")
if not markersFolder then
    markersFolder = Instance.new("Folder")
    markersFolder.Name = "TeleportMarkers"
    markersFolder.Parent = workspace
end

for i, data in ipairs(positions) do
    local anchor = Instance.new("Part")
    anchor.Name = "Marker_" .. data.name
    anchor.Size = Vector3.new(1,1,1)
    anchor.Transparency = 1
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CFrame = CFrame.new(data.pos)
    anchor.Parent = markersFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BillboardGui"
    billboard.Adornee = anchor
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 140, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = anchor

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bg.BorderSizePixel = 0
    bg.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = data.name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    nameLabel.Parent = bg

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(1, 0, 0, 25)
    selectBtn.Position = UDim2.new(0, 0, 0, 25)
    selectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    selectBtn.Text = "Select"
    selectBtn.Font = Enum.Font.Gotham
    selectBtn.TextSize = 12
    selectBtn.TextColor3 = Color3.fromRGB(255,255,255)
    selectBtn.Parent = bg

    selectBtn.MouseButton1Click:Connect(function()
        selectedIndex = i
        updateSelectionUI()
    end)
end

-- Ensure teleport still works after respawn
player.CharacterAdded:Connect(function()
    wait(1)
end)
