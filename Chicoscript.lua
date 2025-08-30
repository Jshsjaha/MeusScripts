-- Advanced Floor Control - VERSÃO FINAL CORRIGIDA
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local floor, floorActive = nil, false
local floorHeight = 0
local floorSpeed = 0.3
local maxHeight = 85
local isPaused = false

-- Create the floor - CORRIGIDO: y-1
local function CreateFloor()
    if floor and floor.Parent then
        floor:Destroy()
    end
    
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    -- ✅ CORRIGIDO: y-1 (1 unidade abaixo do jogador)
    local startPosition = humanoidRootPart and Vector3.new(
        humanoidRootPart.Position.X, 
        humanoidRootPart.Position.Y - 1,  -- AQUI: y-1
        humanoidRootPart.Position.Z
    ) or Vector3.new(0, -1, 0)  -- E AQUI TAMBÉM
    
    floor = Instance.new("Part")
    floor.Name = "SolidGreenFloor"
    floor.Size = Vector3.new(500, 5, 500)
    floor.Position = startPosition
    floor.Anchored = true
    floor.CanCollide = true
    floor.Transparency = 0
    floor.BrickColor = BrickColor.new("Bright green")
    floor.Material = Enum.Material.SmoothPlastic
    floor.Reflectance = 0.1
    
    -- Tornar invisível para outros jogadores
    local localScript = Instance.new("LocalScript")
    localScript.Name = "LocalVisibility"
    localScript.Source = [[
        local player = game:GetService("Players").LocalPlayer
        
        game:GetService("RunService").RenderStepped:Connect(function()
            local allPlayers = game:GetService("Players"):GetPlayers()
            for _, otherPlayer in ipairs(allPlayers) do
                if otherPlayer ~= player then
                    script.Parent.Transparency = 1
                    script.Parent.CanCollide = false
                else
                    script.Parent.Transparency = 0
                    script.Parent.CanCollide = true
                end
            end
        end)
    ]]
    localScript.Parent = floor

    floor.Parent = workspace
    return floor
end

-- Move floor - SEM TELETRANSPORTE
local function MoveFloor()
    while true do
        if floor and floor.Parent then
            if not isPaused then
                local character = player.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart then
                    if floorActive then
                        floorHeight = math.min(floorHeight + floorSpeed, maxHeight)
                        
                        floor.Position = Vector3.new(
                            humanoidRootPart.Position.X,
                            floorHeight,
                            humanoidRootPart.Position.Z
                        )
                        
                    else
                        if floorHeight > 0 then
                            floorHeight = math.max(floorHeight - floorSpeed * 2, 0)
                            
                            floor.Position = Vector3.new(
                                humanoidRootPart.Position.X,
                                floorHeight,
                                humanoidRootPart.Position.Z
                            )
                        end
                    end
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end

-- Create draggable circle interface
local function CreateCircleGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    if playerGui:FindFirstChild("CircleGUI") then
        playerGui.CircleGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CircleGUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local circleButton = Instance.new("ImageButton")
    circleButton.Name = "CircleMenuButton"
    circleButton.Size = UDim2.new(0, 60, 0, 60)
    circleButton.Position = UDim2.new(0, 20, 0.5, -30)
    circleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    circleButton.Image = "rbxassetid://6764432408"
    circleButton.ImageColor3 = Color3.fromRGB(0, 255, 0)
    circleButton.Parent = screenGui
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circleButton
    
    local circleStroke = Instance.new("UIStroke")
    circleStroke.Color = Color3.fromRGB(0, 255, 0)
    circleStroke.Thickness = 2
    circleStroke.Parent = circleButton

    local menuFrame = Instance.new("Frame")
    menuFrame.Name = "CircleMenu"
    menuFrame.Size = UDim2.new(0, 200, 0, 200)
    menuFrame.Position = UDim2.new(0, 90, 0.5, -100)
    menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    menuFrame.BackgroundTransparency = 0.1
    menuFrame.Visible = false
    menuFrame.Parent = screenGui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(1, 0)
    menuCorner.Parent = menuFrame
    
    local menuStroke = Instance.new("UIStroke")
    menuStroke.Color = Color3.fromRGB(0, 150, 0)
    menuStroke.Thickness = 2
    menuStroke.Parent = menuFrame

    local buttonPositions = {
        [1] = UDim2.new(0.5, -25, 0.2, -25),
        [2] = UDim2.new(0.2, -25, 0.5, -25),
        [3] = UDim2.new(0.8, -25, 0.5, -25),
    }

    local activateBtn = Instance.new("TextButton")
    activateBtn.Size = UDim2.new(0, 50, 0, 50)
    activateBtn.Position = buttonPositions[1]
    activateBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.Text = "⬆️"
    activateBtn.Font = Enum.Font.SourceSansBold
    activateBtn.TextSize = 16
    activateBtn.Visible = false
    activateBtn.Parent = menuFrame
    
    local btnCorner1 = Instance.new("UICorner")
    btnCorner1.CornerRadius = UDim.new(1, 0)
    btnCorner1.Parent = activateBtn

    local pauseBtn = Instance.new("TextButton")
    pauseBtn.Size = UDim2.new(0, 50, 0, 50)
    pauseBtn.Position = buttonPositions[2]
    pauseBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
    pauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    pauseBtn.Text = "⏸️"
    pauseBtn.Font = Enum.Font.SourceSansBold
    pauseBtn.TextSize = 16
    pauseBtn.Visible = false
    pauseBtn.Parent = menuFrame
    
    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.CornerRadius = UDim.new(1, 0)
    btnCorner2.Parent = pauseBtn

    local deactivateBtn = Instance.new("TextButton")
    deactivateBtn.Size = UDim2.new(0, 50, 0, 50)
    deactivateBtn.Position = buttonPositions[3]
    deactivateBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    deactivateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    deactivateBtn.Text = "⬇️"
    deactivateBtn.Font = Enum.Font.SourceSansBold
    deactivateBtn.TextSize = 16
    deactivateBtn.Visible = false
    deactivateBtn.Parent = menuFrame
    
    local btnCorner3 = Instance.new("UICorner")
    btnCorner3.CornerRadius = UDim.new(1, 0)
    btnCorner3.Parent = deactivateBtn

    local dragging = false
    local dragStart, startPos

    circleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = circleButton.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            circleButton.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            menuFrame.Position = UDim2.new(
                0, 
                circleButton.Position.X.Offset + 70,
                circleButton.Position.Y.Scale,
                circleButton.Position.Y.Offset - 30
            )
        end
    end)

    circleButton.MouseButton1Click:Connect(function()
        local visible = not menuFrame.Visible
        menuFrame.Visible = visible
        activateBtn.Visible = visible
        pauseBtn.Visible = visible
        deactivateBtn.Visible = visible
    end)

    activateBtn.MouseButton1Click:Connect(function()
        floorActive = true
        isPaused = false
        if not floor or not floor.Parent then
            CreateFloor()
        end
    end)

    pauseBtn.MouseButton1Click:Connect(function()
        isPaused = not isPaused
        pauseBtn.BackgroundColor3 = isPaused and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(200, 200, 0)
        pauseBtn.Text = isPaused and "▶️" or "⏸️"
    end)

    deactivateBtn.MouseButton1Click:Connect(function()
        floorActive = false
        isPaused = false
    end)

    return screenGui
end

local function HandleRespawn()
    player.CharacterAdded:Connect(function(character)
        wait(2)
        CreateCircleGUI()
        
        if floor and floor.Parent then
            floor:Destroy()
        end
        floorActive = false
        floorHeight = 0
        isPaused = false
    end)
end

if not player.Character then
    player.CharacterAdded:Wait()
end

CreateCircleGUI()
CreateFloor()
HandleRespawn()

spawn(MoveFloor)

print("✅ CHÃO CORRIGIDO: y-1")
print("✅ AGORA NASCE ABAIXO DO JOGADOR!")
