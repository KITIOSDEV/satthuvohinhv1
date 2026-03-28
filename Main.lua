-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
-- SETTINGS
_G.Settings = {
    ESP = false,
    Hitbox = false,
    HitboxSize = 1000
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

-- ===== OUTER
local Outer = Instance.new("Frame")
Outer.Parent = ScreenGui
Outer.Size = UDim2.new(0, 400, 0, 100)
Outer.Position = UDim2.new(-1, 0, 0.1, 0)
Outer.BackgroundColor3 = Color3.fromRGB(25,25,25)
Outer.BackgroundTransparency = 0.2
Outer.Active = true
Outer.Draggable = true
Instance.new("UICorner", Outer).CornerRadius = UDim.new(0,15)

local stroke = Instance.new("UIStroke", Outer)
stroke.Color = Color3.fromRGB(80,80,80)

-- ===== MAIN
local Main = Instance.new("Frame")
Main.Parent = Outer
Main.Size = UDim2.new(1,-10,1,-10)
Main.Position = UDim2.new(0,5,0,5)
Main.BackgroundColor3 = Color3.fromRGB(40,40,40)
Main.BackgroundTransparency = 0.3
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

-- ===== TITLE
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "Delta Invis ESP"
Title.BackgroundColor3 = Color3.fromRGB(50,50,50)
Title.BackgroundTransparency = 0.2
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Instance.new("UICorner", Title)

-- ===== HOLDER
local Holder = Instance.new("Frame", Main)
Holder.Size = UDim2.new(1,0,1,-30)
Holder.Position = UDim2.new(0,0,0,30)
Holder.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Holder)
UIList.FillDirection = Enum.FillDirection.Horizontal
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.Padding = UDim.new(0,10)

-- ===== BUTTON
local function createButton(text)
    local btn = Instance.new("TextButton")
    btn.Parent = Holder
    btn.Size = UDim2.new(0,120,0,50)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.BackgroundTransparency = 0.25
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 16
    btn.Text = text
    Instance.new("UICorner", btn)
    return btn
end

-- ===== ESP GOD
local ESPBtn = createButton("ESP: OFF")
local ESPObjects = {}

local function createESP(plr)
    if plr == LocalPlayer then return end
    if ESPObjects[plr] then return end

    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255,0,0)
    box.Thickness = 1
    box.Filled = false

    local text = Drawing.new("Text")
    text.Size = 16
    text.Center = true
    text.Outline = true

    ESPObjects[plr] = {Box = box, Text = text}
end

local function removeESP()
    for _, v in pairs(ESPObjects) do
        for _, obj in pairs(v) do
            obj:Remove()
        end
    end
    ESPObjects = {}
end

ESPBtn.MouseButton1Click:Connect(function()
    _G.Settings.ESP = not _G.Settings.ESP
    ESPBtn.Text = "ESP: " .. (_G.Settings.ESP and "ON" or "OFF")

    if not _G.Settings.ESP then
        removeESP()
    end
end)

-- UPDATE ESP REALTIME
RunService.RenderStepped:Connect(function()
    if not _G.Settings.ESP then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                createESP(plr)

                local hrp = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                local esp = ESPObjects[plr]

                if onScreen then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude

                    local size = math.clamp(2000 / distance, 20, 200)

                    esp.Box.Size = Vector2.new(size, size)
                    esp.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                    esp.Box.Visible = true

                    esp.Text.Text = plr.Name .. " [" .. math.floor(distance) .. "m]"
                    esp.Text.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                    esp.Text.Visible = true
                else
                    esp.Box.Visible = false
                    esp.Text.Visible = false
                end
            end
        end
    end
end)
-- ===== HITBOX
local HitboxBtn = createButton("Hitbox: OFF")

HitboxBtn.MouseButton1Click:Connect(function()
    _G.Settings.Hitbox = not _G.Settings.Hitbox
    HitboxBtn.Text = "Hitbox: " .. (_G.Settings.Hitbox and "ON" or "OFF")
end)

RunService.RenderStepped:Connect(function()
    if _G.Settings.Hitbox then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(1000,1000,1000)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end
            end
        end
    end
end)

-- ===== TOGGLE
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,60,0,60)
ToggleBtn.Position = UDim2.new(0,10,0.5,-30)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.Image = "rbxassetid://7072718362"
ToggleBtn.Draggable = true

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

-- ===== ANIMATION
local openPos = UDim2.new(0.5,-200,0.1,0)
local closePos = UDim2.new(-1,0,0.1,0)

local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local visible = false

ToggleBtn.MouseButton1Click:Connect(function()
    visible = not visible
    TweenService:Create(Outer, tweenInfo, {
        Position = visible and openPos or closePos
    }):Play()
end)
