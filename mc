local PathfindingService = game:GetService("PathfindingService")
local targetPos = Vector3.new(167.63, 2.11, -184.24)

-- Move/Walk player to target (instead of teleport)
local function movePlayerToTarget()
    if not (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart")) then
        return
    end

    local humanoid = player.Character:FindFirstChild("Humanoid")
    local root = player.Character.HumanoidRootPart
    local startPos = root.Position
    local destination = targetPos + Vector3.new(0, -5, 0) -- slight offset above ground

    -- Create and compute path
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(startPos, destination)

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            -- Move to each waypoint; this makes the character walk naturally
            humanoid:MoveTo(waypoint.Position)
            local reached = humanoid.MoveToFinished:Wait()
            if not reached then
                -- if fails at a waypoint, try continuing or break
                break
            end
        end
        -- Final adjustment in case of slight offset
        humanoid:MoveTo(destination)
    else
        -- fallback: direct MoveTo
        humanoid:MoveTo(destination)
    end

    print("Started movement toward", targetPos)
end
