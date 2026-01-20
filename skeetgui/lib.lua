local SkeetLib = {
    Themes = {
        Accent = Color3.fromRGB(162, 203, 63), -- Стандартний зелений Skeet
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18)
    },
    Config = {},
    ActiveTab = nil
}

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local LP = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- // 1. ВАТЕРМАРКА (Динамічна)
local function CreateWatermark()
    local WaterGui = Instance.new("ScreenGui", LP.PlayerGui)
    WaterGui.Name = "SkeetWatermark"
    
    local Holder = Instance.new("Frame", WaterGui)
    Holder.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    Holder.BorderSizePixel = 1
    Holder.BorderColor3 = Color3.fromRGB(45, 45, 45)
    Holder.Position = UDim2.new(0, 20, 0, 20)
    
    local Line = Instance.new("Frame", Holder)
    Line.Size = UDim2.new(1, 0, 0, 2)
    Line.BackgroundColor3 = SkeetLib.Themes.Accent
    Line.BorderSizePixel = 0
    
    local Text = Instance.new("TextLabel", Holder)
    Text.BackgroundTransparency = 1
    Text.Font = Enum.Font.Code
    Text.TextColor3 = Color3.new(1, 1, 1)
    Text.TextSize = 13
    
    task.spawn(function()
        while task.wait(0.5) do
            local fps = math.floor(1 / task.wait())
            local str = string.format(" nahbro.lua | %s | fps: %d ", LP.Name, fps)
            Text.Text = str
            local size = game:GetService("TextService"):GetTextSize(str, 13, Enum.Font.Code, Vector2.new(1000, 1000))
            Holder.Size = UDim2.new(0, size.X + 10, 0, 26)
            Text.Size = UDim2.new(1, 0, 1, 0)
        end
    end)
end

-- // 2. СИСТЕМА КОНФІГІВ
function SkeetLib:SaveConfig(name)
    local data = HttpService:JSONEncode(self.Config)
    writefile("nahbro_"..name..".json", data)
end

function SkeetLib:LoadConfig(name)
    if isfile("nahbro_"..name..".json") then
        local data = HttpService:JSONDecode(readfile("nahbro_"..name..".json"))
        self.Config = data
        -- Тут можна додати логіку оновлення візуальних кнопок
    end
end

-- // 3. INTRO
local function PlayIntro(title)
    local IntroGui = Instance.new("ScreenGui", LP.PlayerGui)
    local Line = Instance.new("Frame", IntroGui)
    Line.Size = UDim2.new(0, 0, 0, 2)
    Line.Position = UDim2.new(0.5, 0, 0.5, 0)
    Line.BackgroundColor3 = SkeetLib.Themes.Accent
    Line.BorderSizePixel = 0
    
    TS:Create(Line, TweenInfo.new(0.6), {Size = UDim2.new(0, 300, 0, 2), Position = UDim2.new(0.5, -150, 0.5, 0)}):Play()
    task.wait(0.7)
    TS:Create(Line, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    IntroGui:Destroy()
end

-- // 4. ГОЛОВНЕ ВІКНО
function SkeetLib:CreateWindow(cfg)
    if cfg.Intro then PlayIntro(cfg.Title) end
    if cfg.Watermark then CreateWatermark() end
    
    local ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
    ScreenGui.Name = "SkeetMain"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 99
    
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 500, 0, 380)
    Main.Position = UDim2.new(0.5, -250, 0.5, -190)
    Main.BackgroundColor3 = SkeetLib.Themes.Background
    Main.BorderSizePixel = 1
    Main.BorderColor3 = Color3.fromRGB(45, 45, 45)
    Main.Visible = false
    
    -- Акцентна лінія
    local TopLine = Instance.new("Frame", Main)
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.BackgroundColor3 = SkeetLib.Themes.Accent
    TopLine.BorderSizePixel = 0

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 100, 1, -2)
    Sidebar.Position = UDim2.new(0, 0, 0, 2)
    Sidebar.BackgroundColor3 = SkeetLib.Themes.Sidebar
    Sidebar.BorderSizePixel = 0
    
    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -110, 1, -10)
    Container.Position = UDim2.new(0, 110, 0, 10)
    Container.BackgroundTransparency = 1

    -- Toggle G
    UIS.InputBegan:Connect(function(i, chat)
        if chat then return end
        if i.KeyCode == Enum.KeyCode.G then
            Main.Visible = not Main.Visible
            UIS.MouseIconEnabled = Main.Visible
        end
    end)

    local lib = {}
    local tabs = 0

    function lib:CreateTab(name)
        tabs = tabs + 1
        local TabPage = Instance.new("ScrollingFrame", Container)
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = (tabs == 1)
        TabPage.ScrollBarThickness = 0
        local UIList = Instance.new("UIListLayout", TabPage)
        UIList.Padding = UDim.new(0, 5)

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 40)
        TabBtn.Position = UDim2.new(0, 0, 0, (tabs-1)*40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.Code
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = TabPage.Visible and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Container:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            TabPage.Visible = true
            TabBtn.TextColor3 = Color3.new(1,1,1)
        end)

        local tab_ops = {}
        function tab_ops:CreateToggle(text, id, callback)
            local f = Instance.new("Frame", TabPage)
            f.Size = UDim2.new(1, 0, 0, 25)
            f.BackgroundTransparency = 1
            
            local box = Instance.new("TextButton", f)
            box.Size = UDim2.new(0, 14, 0, 14)
            box.Position = UDim2.new(0, 5, 0, 5)
            box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            box.Text = ""
            
            local lbl = Instance.new("TextLabel", f)
            lbl.Text = text
            lbl.Position = UDim2.new(0, 25, 0, 0)
            lbl.Size = UDim2.new(0, 100, 1, 0)
            lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            lbl.Font = Enum.Font.Code
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = "Left"

            box.MouseButton1Click:Connect(function()
                SkeetLib.Config[id] = not SkeetLib.Config[id]
                box.BackgroundColor3 = SkeetLib.Config[id] and SkeetLib.Themes.Accent or Color3.fromRGB(40, 40, 40)
                callback(SkeetLib.Config[id])
            end)
        end
        return tab_ops
    end
    return lib
end

-- // ПРИКЛАД ВИКОРИСТАННЯ
local Window = SkeetLib:CreateWindow({
    Title = "nahbro.lua",
    Intro = true,
    Watermark = true
})

local Rage = Window:CreateTab("Rage")
local Settings = Window:CreateTab("Settings")

Rage:CreateToggle("Silent Aim", "silent_aim", function(v)
    print("Silent Aim: ", v)
end)

Settings:CreateToggle("Custom Theme (Blue)", "blue_theme", function(v)
    if v then
        SkeetLib.Themes.Accent = Color3.fromRGB(55, 177, 218)
    else
        SkeetLib.Themes.Accent = Color3.fromRGB(162, 203, 63)
    end
end)