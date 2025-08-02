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

-- GUI Setup
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

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.Text = "Auto Shot: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 18

-- Toggle Button Logic
toggleButton.MouseButton1Click:Connect(function()
    if not fired then
        firingEnabled = not firingEnabled
        toggleButton.Text = firingEnabled and "Auto Shot: ON" or "Auto Shot: OFF"
        toggleButton.BackgroundColor3 = firingEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(0, 150, 255)
    end
end)

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
            print("Fired", shotMultiplier, "shots at power ≥ 65.")
        end
    end
end

-- Power Listener (One-Time)
local connection
connection = power:GetPropertyChangedSignal("Value"):Connect(function()
    if not fired and firingEnabled and power.Value >= powerThreshold then
        fired = true
        fireShot()
        
        -- Cleanup
        if connection then connection:Disconnect() end
        screenGui:Destroy()
        print("Shot fired. GUI and listener destroyed.")
    end
end)
