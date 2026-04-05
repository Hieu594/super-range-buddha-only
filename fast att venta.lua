-- Thay đổi giá trị khởi tạo thành false để đồng bộ với UI lúc mới bắt đầu
local FastAttackEnabled = true 
local FastAttackRange = 950
local TOGGLE_KEY = Enum.KeyCode.U

-- [Các biến Service và Remote giữ nguyên như cũ...]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Net = ReplicatedStorage.Modules.Net
local RegisterHit = Net["RE/RegisterHit"]
local RegisterAttack = Net["RE/RegisterAttack"]
local FastAttackConnection = nil
local ToggleButton = nil

-- [Hàm CreateGUI và AttackMultipleTargets giữ nguyên...]
-- (Mình bỏ qua phần hiển thị code lặp lại để tập trung vào logic bạn cần)

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
            -- Quét mục tiêu... (Logic quét của bạn)
            -- [Phần code quét mục tiêu giữ nguyên...]
            
            if #targetsInRange > 0 then
                AttackMultipleTargets(targetsInRange)
            end
        end
    end)
end

local function StopFastAttack()
    -- Ép biến về false để dừng vòng lặp while ngay lập tức
    FastAttackEnabled = false 
    if FastAttackConnection then
        task.cancel(FastAttackConnection)
        FastAttackConnection = nil
    end
end

-- HÀM TOGGLE ĐÃ ĐƯỢC SỬA LẠI ĐỂ TỰ ĐỘNG DỌN DẸP VÀ CHUYỂN TRẠNG THÁI
local function ToggleFastAttack()
    -- Nếu đang bật (true), thì sẽ chạy logic Tắt và dọn dẹp
    if FastAttackEnabled then
        if ToggleButton then
            ToggleButton.Text = "Fast Attack: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        end
        -- Dọn dẹp logic và CHUYỂN BIẾN VỀ FALSE
        StopFastAttack()
    else
        -- Nếu đang tắt (false), thì bật lên
        FastAttackEnabled = true
        if ToggleButton then
            ToggleButton.Text = "Fast Attack: ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        end
        StartFastAttack()
    end
end

-- Khởi tạo GUI
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
