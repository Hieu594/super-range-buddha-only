local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local FastAttackEnabled = false
local FastAttackRange = 2000
local TOGGLE_KEY = Enum.KeyCode.U

local Net = ReplicatedStorage.Modules.Net
local RegisterHit = Net["RE/RegisterHit"]
local RegisterAttack = Net["RE/RegisterAttack"]

local FastAttackConnection = nil
local ToggleButton = nil

local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FastAttackGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Frame = Instance.new("Frame")
    Frame.Name = "MainFrame"
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 0
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.Size = UDim2.new(0, 200, 0, 80)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Frame

    ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = Frame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    ToggleButton.Size = UDim2.new(0.8, 0, 0.6, 0)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "Fast Attack: OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    ToggleButton.TextWrapped = true

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ToggleButton

    local dragging = false
    local dragInput, dragStart, startPos

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    return ToggleButton
end

local function AttackMultipleTargets(targets)
    pcall(function()
        if not targets or #targets == 0 then return end

        local allTargets = {}

        for _, targetChar in pairs(targets) do
            local head = targetChar:FindFirstChild("Head")
            if head then
                table.insert(allTargets, { targetChar, head })
            end
        end

        if #allTargets == 0 then return end

        RegisterAttack:FireServer(0)

        local hitArgs = {
            allTargets[1][2],
            allTargets
        }

        RegisterHit:FireServer(unpack(hitArgs))
    end)
end

local function StartFastAttack()
    if FastAttackConnection then
        task.cancel(FastAttackConnection)
    end

    FastAttackConnection = task.spawn(function()
        while FastAttackEnabled do
            task.wait(0.01)

            local myChar = Players.LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end

            local targetsInRange = {}

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")

                    if humanoid and hrp and humanoid.Health > 0 then
                        local dist = (hrp.Position - myHRP.Position).Magnitude
                        if dist <= FastAttackRange then
                            table.insert(targetsInRange, player.Character)
                        end
                    end
                end
            end

            local enemiesFolder = workspace:FindFirstChild("Enemies")
            if enemiesFolder then
                for _, npc in pairs(enemiesFolder:GetChildren()) do
                    local humanoid = npc:FindFirstChild("Humanoid")
                    local hrp = npc:FindFirstChild("HumanoidRootPart")

                    if humanoid and hrp and humanoid.Health > 0 then
                        local dist = (hrp.Position - myHRP.Position).Magnitude
                        if dist <= FastAttackRange then
                            table.insert(targetsInRange, npc)
                        end
                    end
                end
            end

            if #targetsInRange > 0 then
                AttackMultipleTargets(targetsInRange)
            end
        end
    end)
end

local function StopFastAttack()
    if FastAttackConnection then
        task.cancel(FastAttackConnection)
        FastAttackConnection = nil
    end
end

local function ToggleFastAttack()
    FastAttackEnabled = not FastAttackEnabled

    if FastAttackEnabled then
        if ToggleButton then
            ToggleButton.Text = "Fast Attack: ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        end
        StartFastAttack()
    else
        if ToggleButton then
            ToggleButton.Text = "Fast Attack: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        end
        StopFastAttack()
    end
end

ToggleButton = CreateGUI()

ToggleButton.MouseButton1Click:Connect(function()
    ToggleFastAttack()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == TOGGLE_KEY then
        ToggleFastAttack()
    end
end)
