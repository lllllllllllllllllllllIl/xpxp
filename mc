local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local backpack = player:WaitForChild("Backpack")
local actionValues = backpack:WaitForChild("ActionValues")
local power = actionValues:WaitForChild("Power")

local powerThreshold = 54
local shotMultiplier = 600
local firingEnabled = false
local fired = false

-- Target position
local targetPos = Vector3.new(167.63, 2.11, -184.24)

-- Keep track of last power to detect increases
local lastPower = power.Value

-- === World-space toggle above the position ===
local togglePart = Instance.new("Part")
togglePart.Name = "ToggleAnchor"
togglePart.Size = Vector3.new(1,1,1)
togglePart.Transparency = 1
togglePart.Anchored = true
togglePart.CanCollide = false
togglePart.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0)) -- slightly above
togglePart.Parent = workspace

local billboard = Instance.new("BillboardGui")
billboard.Name = "ToggleBillboard"
billboard.Adornee = togglePart
billboard.Size = UDim2.new(0, 120, 0, 40)
billboard.StudsOffset = Vector3.new(0, 0, 0)
billboard.AlwaysOnTop = true
billboard.Parent = togglePart

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- red = off
toggleButton.Text = "Auto Shot: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 14
toggleButton.Parent = billboard

-- Optional: also keep the original screen GUI for fallback / visibility
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "ShotToggleGUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 50)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local screenToggle = Instance.new("TextButton", frame)
screenToggle.Size = UDim2.new(1, 0, 1, 0)
screenToggle.Text = "Auto Shot: OFF"
screenToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
screenToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
screenToggle.Font = Enum.Font.SourceSansBold
screenToggle.TextSize = 18

-- Shared toggle update function
local function updateToggleUI()
    local on = firingEnabled
    local text = on and "Auto Shot: ON" or "Auto Shot: OFF"
    local color = on and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0) -- green when on, red when off

    toggleButton.Text = text
    toggleButton.BackgroundColor3 = color

    screenToggle.Text = text
    screenToggle.BackgroundColor3 = color
end

-- Toggle logic (both GUIs)
local function toggle()
    if not fired then
        firingEnabled = not firingEnabled
        updateToggleUI()
    end
end

toggleButton.MouseButton1Click:Connect(toggle)
screenToggle.MouseButton1Click:Connect(toggle)

-- Fire Shot Function
local function fireShot()
    local args = {
        [1] = false,
        [2] = "Shooting",
        [3] = "Standing Shot"
    }

    local playerEvents = backpack:FindFirstChild("PlayerEvents") or ReplicatedStorage:FindFirstChild("PlayerEvents")
    if playerEvents then
        local shootingEvent = playerEvents:FindFirstChild("Shooting")
        if shootingEvent then
            for i = 1, shotMultiplier do
                shootingEvent:FireServer(unpack(args))
            end
            print("Fired", shotMultiplier, "shots at power ≥ " .. powerThreshold .. ".")
        end
    end
end

-- Teleport function
local function teleportToTarget()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0)) -- slightly above ground
        print("Teleported player to", targetPos)
    end
end

-- Power Listener (for both increase and threshold-shot)
local connection
connection = power:GetPropertyChangedSignal("Value"):Connect(function()
    local current = power.Value

    -- Detect increase (any increase)
    if current > lastPower then
        teleportToTarget()
    end
    lastPower = current

    -- Fire shot when threshold met and toggle on
    if not fired and firingEnabled and current >= powerThreshold then
        fired = true
        fireShot()

        -- Cleanup
        if connection then connection:Disconnect() end
        if screenGui then screenGui:Destroy() end
        if togglePart then togglePart:Destroy() end
        print("Shot fired. GUI and listener destroyed.")
    end
end)
