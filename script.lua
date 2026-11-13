
--==================================================
--              TOANA HUB 2.3
--     MOBILE + PC | KEYBINDS
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local Config = {
    Speed = 16,
    Jump = 50,
    Fly = false,
    Noclip = false,
    ESP = false,
    FlySpeed = 50,
    Theme = Color3.fromRGB(145,80,255)
}

local savedPosition
local highlights = {}
local collisionCache = {}
local keybinds = {}
local waitingForKey
local flyHeight = 0
local speedEnabled = false
local jumpEnabled = false
local infiniteJumpEnabled = false

local themes = {
    Color3.fromRGB(145,80,255),
    Color3.fromRGB(0,180,255),
    Color3.fromRGB(0,220,140),
    Color3.fromRGB(255,80,120),
    Color3.fromRGB(255,160,40)
}

local themeIndex = 1

--==================================================
-- CHARACTER
--==================================================

local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- GUI PARENT
--==================================================

local guiParent = player:WaitForChild("PlayerGui")

if typeof(gethui) == "function" then
    local success, result = pcall(gethui)
    if success and result then
        guiParent = result
    end
end

local old = guiParent:FindFirstChild("TOANA_HUB_21")
if old then old:Destroy() end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "TOANA_HUB_21"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = guiParent

--==================================================
-- TOANA HUB : WELCOME POPUP
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local SITE_URL = "https://toana.ct.ws"
local DISCORD_URL = "https://discord.gg/hqcuy33zTf"

local popupClosed = false

local popup = Instance.new("Frame")
popup.Name = "ToanaWelcomePopup"
popup.Size = UDim2.fromOffset(360, 245)
popup.Position = UDim2.new(0.5, -180, 0.5, -122)
popup.BackgroundColor3 = Color3.fromRGB(18, 13, 30)
popup.BorderSizePixel = 0
popup.ZIndex = 100
popup.Parent = gui

local popupCorner = Instance.new("UICorner")
popupCorner.CornerRadius = UDim.new(0, 14)
popupCorner.Parent = popup

local popupStroke = Instance.new("UIStroke")
popupStroke.Color = Color3.fromRGB(151, 71, 255)
popupStroke.Thickness = 2
popupStroke.Parent = popup

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 45)
title.Position = UDim2.fromOffset(15, 12)
title.BackgroundTransparency = 1
title.Text = "WELCOME TO TOANA"
title.TextColor3 = Color3.fromRGB(190, 130, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 21
title.ZIndex = 101
title.Parent = popup

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -30, 0, 35)
subtitle.Position = UDim2.fromOffset(15, 55)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Rejoins notre communauté !"
subtitle.TextColor3 = Color3.fromRGB(200, 190, 215)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.ZIndex = 101
subtitle.Parent = popup

local function createPopupButton(name, text, color, y, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -40, 0, 42)
    button.Position = UDim2.fromOffset(20, y)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.ZIndex = 102
    button.Parent = popup

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)

    return button
end

local function openLink(url)
    if typeof(setclipboard) == "function" then
        pcall(setclipboard, url)
    end

    if typeof(request) == "function" then
        pcall(function()
            request({
                Url = url,
                Method = "GET"
            })
        end)
    end
end

createPopupButton(
    "WebsiteButton",
    "🌐  COPIER LE LIEN DU SITE",
    Color3.fromRGB(125, 55, 220),
    105,
    function()
        openLink(SITE_URL)
    end
)

createPopupButton(
    "DiscordButton",
    "💬  COPIER INVITATION DISCORD",
    Color3.fromRGB(88, 101, 242),
    155,
    function()
        openLink(DISCORD_URL)
    end
)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.Position = UDim2.new(1, -38, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(55, 40, 70)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.ZIndex = 103
closeButton.Parent = popup

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local function closePopup()
    if popupClosed then return end
    popupClosed = true

    local tween = TweenService:Create(
        popup,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(320, 210)
        }
    )

    tween:Play()
    tween.Completed:Connect(function()
        popup:Destroy()
    end)
end

closeButton.MouseButton1Click:Connect(closePopup)

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,radius or 9)
    c.Parent = obj
end

local function makeButton(parent, name, callback, height)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-5,0,height or 40)
    b.BackgroundColor3 = Color3.fromRGB(36,36,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = name
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 13
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b,9)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function makeInput(parent, name, value)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-5,0,38)
    box.BackgroundColor3 = Color3.fromRGB(36,36,50)
    box.TextColor3 = Color3.new(1,1,1)
    box.PlaceholderText = name
    box.PlaceholderColor3 = Color3.fromRGB(160,160,170)
    box.Text = tostring(value or "")
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.Parent = parent
    corner(box,9)
    return box
end

local function makeLabel(parent, name)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-5,0,27)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Config.Theme
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

--==================================================
-- FLOATING BUTTON
--==================================================

local floating = Instance.new("TextButton")
floating.Name = "TOANA_FLOAT"
floating.Size = UDim2.fromOffset(58,58)
floating.Position = UDim2.new(0,18,0.45,0)
floating.BackgroundColor3 = Config.Theme
floating.Text = "T"
floating.TextColor3 = Color3.new(1,1,1)
floating.TextSize = 25
floating.Font = Enum.Font.GothamBold
floating.Active = true
floating.Parent = gui
corner(floating,30)

local floatingStroke = Instance.new("UIStroke")
floatingStroke.Color = Color3.new(1,1,1)
floatingStroke.Thickness = 1.5
floatingStroke.Parent = floating

--==================================================
-- MAIN MENU
--==================================================

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0,340,0,510)
main.Position = UDim2.new(0.5,-170,0.5,-255)
main.BackgroundColor3 = Color3.fromRGB(18,18,27)
main.BorderSizePixel = 0
main.Active = true
main.Visible = false
main.Parent = gui
corner(main,15)

--==================================================
-- WHITE DRAG HANDLE
--==================================================

local dragBar = Instance.new("TextButton")
dragBar.Name = "WhiteDragBar"
dragBar.Size = UDim2.new(0, 9, 1, 0)
dragBar.Position = UDim2.new(0, -15, 0, 0)
dragBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
dragBar.BorderSizePixel = 0
dragBar.Text = ""
dragBar.AutoButtonColor = false
dragBar.Active = true
dragBar.ZIndex = 10
dragBar.Parent = main

corner(dragBar, 5)

local dragBarStroke = Instance.new("UIStroke")
dragBarStroke.Color = Config.Theme
dragBarStroke.Thickness = 1
dragBarStroke.Parent = dragBar

local draggingMain = false
local mainDragStart
local mainStartPosition

dragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingMain = true
        mainDragStart = input.Position
        mainStartPosition = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not draggingMain then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - mainDragStart

        main.Position = UDim2.new(
            mainStartPosition.X.Scale,
            mainStartPosition.X.Offset + delta.X,
            mainStartPosition.Y.Scale,
            mainStartPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingMain = false
    end
end)
local outline = Instance.new("UIStroke")
outline.Color = Config.Theme
outline.Thickness = 2
outline.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-55,0,45)
title.Position = UDim2.fromOffset(12,0)
title.BackgroundTransparency = 1
title.Text = "TOANA HUB 2.3"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 21
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35,35)
close.Position = UDim2.new(1,-43,0,5)
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(180,50,70)
close.Font = Enum.Font.GothamBold
close.Parent = main
corner(close,8)

local function toggleMenu()
    main.Visible = not main.Visible
end

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,1,-60)
scroll.Position = UDim2.fromOffset(10,50)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

--==================================================
-- ACTION ROWS + KEYBINDS
--==================================================

local actions = {}
local displayNames = {}
local keyButtons = {}

local function makeActionRow(parent, feature, label, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-5,0,40)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local actionButton = Instance.new("TextButton")
    actionButton.Size = UDim2.new(0.61,-4,1,0)
    actionButton.BackgroundColor3 = Color3.fromRGB(36,36,50)
    actionButton.TextColor3 = Color3.new(1,1,1)
    actionButton.Text = label
    actionButton.Font = Enum.Font.GothamSemibold
    actionButton.TextSize = 12
    actionButton.Parent = row
    corner(actionButton,8)

    local bindButton = Instance.new("TextButton")
    bindButton.Size = UDim2.new(0.39,0,1,0)
    bindButton.Position = UDim2.new(0.61,0,0,0)
    bindButton.BackgroundColor3 = Color3.fromRGB(75,55,115)
    bindButton.TextColor3 = Color3.new(1,1,1)
    bindButton.Text = "DEFINIR"
    bindButton.Font = Enum.Font.GothamSemibold
    bindButton.TextSize = 11
    bindButton.Parent = row
    corner(bindButton,8)

    actionButton.MouseButton1Click:Connect(callback)

    bindButton.MouseButton1Click:Connect(function()
        waitingForKey = feature
        bindButton.Text = "APPUYER..."
        bindButton.BackgroundColor3 = Color3.fromRGB(180,110,40)
    end)

    actions[feature] = callback
    displayNames[feature] = label
    keyButtons[feature] = bindButton

    return actionButton
end

--==================================================
-- SPEED
--==================================================

makeLabel(scroll,"MOUVEMENT")

local speedInput = makeInput(scroll,"Vitesse (0-100)",16)
local speedButton

local function applySpeed()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = Config.Speed
    end
end

local function toggleSpeed()
    speedEnabled = not speedEnabled
    Config.Speed = speedEnabled
        and math.clamp(tonumber(speedInput.Text) or 32,0,100)
        or 16

    applySpeed()
    speedButton.Text = "SPEED : "..(speedEnabled and "ON" or "OFF")
end

makeButton(scroll,"APPLIQUER VITESSE",function()
    Config.Speed = math.clamp(tonumber(speedInput.Text) or 16,0,100)
    applySpeed()
end)

speedButton = makeActionRow(scroll,"Speed","SPEED : OFF",toggleSpeed)

--==================================================
-- JUMP
--==================================================

local jumpInput = makeInput(scroll,"Puissance du saut (0-150)",50)
local jumpButton

local function applyJump()
    local hum = getHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = Config.Jump
    end
end

local function toggleJump()
    jumpEnabled = not jumpEnabled
    Config.Jump = jumpEnabled
        and math.clamp(tonumber(jumpInput.Text) or 75,0,150)
        or 50

    applyJump()
    jumpButton.Text = "JUMP : "..(jumpEnabled and "ON" or "OFF")
end

makeButton(scroll,"APPLIQUER SAUT",function()
    Config.Jump = math.clamp(tonumber(jumpInput.Text) or 50,0,150)
    applyJump()
end)

jumpButton = makeActionRow(scroll,"Jump","JUMP : OFF",toggleJump)

--==================================================
-- INFINITE JUMP
--==================================================

local infiniteJumpButton

local function toggleInfiniteJump()
    infiniteJumpEnabled = not infiniteJumpEnabled

    infiniteJumpButton.Text =
        "INFINITE JUMP : " ..
        (infiniteJumpEnabled and "ON" or "OFF")
end

infiniteJumpButton = makeActionRow(
    scroll,
    "InfiniteJump",
    "INFINITE JUMP : OFF",
    toggleInfiniteJump
)

UIS.JumpRequest:Connect(function()
    if not infiniteJumpEnabled then
        return
    end

    local hum = getHumanoid()

    if hum and hum.Health > 0 then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--==================================================
-- FLY
--==================================================

local flyInput = makeInput(scroll,"Vitesse du vol (10-100)",50)

flyInput.FocusLost:Connect(function()
    Config.FlySpeed = math.clamp(tonumber(flyInput.Text) or 50,10,100)
end)

local flyButton

local function toggleFly()
    Config.Fly = not Config.Fly
    flyButton.Text = "FLY : "..(Config.Fly and "ON" or "OFF")
    flyHeight = 0
end

flyButton = makeActionRow(scroll,"Fly","FLY : OFF",toggleFly)

makeButton(scroll,"MONTER",function()
    if Config.Fly then flyHeight = 1 end
end)

makeButton(scroll,"DESCENDRE",function()
    if Config.Fly then flyHeight = -1 end
end)

--==================================================
-- NOCLIP
--==================================================

local noclipButton

local function toggleNoclip()
    Config.Noclip = not Config.Noclip

    if not Config.Noclip then
        for part,original in pairs(collisionCache) do
            if part and part.Parent then
                part.CanCollide = original
            end
        end
        table.clear(collisionCache)
    end

    noclipButton.Text = "NOCLIP : "..(Config.Noclip and "ON" or "OFF")
end

noclipButton = makeActionRow(scroll,"Noclip","NOCLIP : OFF",toggleNoclip)

--==================================================
-- ESP
--==================================================

local function clearESP()
    for _,h in pairs(highlights) do
        if h and h.Parent then h:Destroy() end
    end
    table.clear(highlights)
end

local function refreshESP()
    clearESP()
    if not Config.ESP then return end

    for _,target in ipairs(Players:GetPlayers()) do
        if target ~= player and target.Character then
            local h = Instance.new("Highlight")
            h.Name = "ToanaESP"
            h.FillColor = Config.Theme
            h.OutlineColor = Color3.new(1,1,1)
            h.FillTransparency = 0.65
            h.Adornee = target.Character
            h.Parent = gui
            highlights[target] = h
        end
    end
end

local espButton

local function toggleESP()
    Config.ESP = not Config.ESP
    refreshESP()
    espButton.Text = "ESP : "..(Config.ESP and "ON" or "OFF")
end

espButton = makeActionRow(scroll,"ESP","ESP : OFF",toggleESP)

--==================================================
-- TELEPORT PLAYER
--==================================================

makeLabel(scroll,"TP")

local targetInput = makeInput(scroll,"Nom du joueur","")

local function teleportToPlayer()
    local target = Players:FindFirstChild(targetInput.Text)
    local root = getRoot()
    local targetRoot = target and target.Character
        and target.Character:FindFirstChild("HumanoidRootPart")

    if root and targetRoot and target ~= player then
        local char = getCharacter()
        if char then
            char:PivotTo(targetRoot.CFrame * CFrame.new(0,0,-4))
        end
    end
end

makeActionRow(scroll,"TeleportPlayer","TP VERS JOUEUR",teleportToPlayer)

--==================================================
-- SAVE / RETURN POSITION
--==================================================

local function savePosition()
    local root = getRoot()
    if root then
        savedPosition = root.CFrame
        print("TOANA : Position enregistrée")
    end
end

local function returnPosition()
    local char = getCharacter()
    local root = getRoot()

    if char and root and savedPosition then
        char:PivotTo(savedPosition)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

makeActionRow(scroll,"SavePosition","SAUVEGARDER POSITION",savePosition)
makeActionRow(scroll,"ReturnPosition","RETOUR POSITION",returnPosition)

makeButton(scroll,"EFFACER MA POSITION",function()
    savedPosition = nil
end)

--==================================================
-- THEMES
--==================================================

makeLabel(scroll,"PERSONNALISATION")

makeButton(scroll,"CHANGER COULEUR",function()
    themeIndex = themeIndex % #themes + 1
    Config.Theme = themes[themeIndex]

    outline.Color = Config.Theme
    floating.BackgroundColor3 = Config.Theme
    refreshESP()

    for _,obj in ipairs(scroll:GetChildren()) do
        if obj:IsA("TextLabel") then
            obj.TextColor3 = Config.Theme
        end
    end
end)

--==================================================
-- KEYBOARD
--==================================================

UIS.InputBegan:Connect(function(input,processed)

    if waitingForKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local feature = waitingForKey

            if input.KeyCode == Enum.KeyCode.Escape then
                keyButtons[feature].Text =
                    keybinds[feature] and keybinds[feature].Name or "DÉFINIR"

                keyButtons[feature].BackgroundColor3 =
                    Color3.fromRGB(75,55,115)

                waitingForKey = nil
                return
            end

            keybinds[feature] = input.KeyCode
            keyButtons[feature].Text = input.KeyCode.Name
            keyButtons[feature].BackgroundColor3 =
                Color3.fromRGB(40,125,80)

            waitingForKey = nil
        end
        return
    end

    if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightControl then
        toggleMenu()
        return
    end

    for feature,key in pairs(keybinds) do
        if input.KeyCode == key and actions[feature] then
            actions[feature]()
        end
    end
end)

--==================================================
-- FLOATING BUTTON DRAG + CLICK
--==================================================

local dragging = false
local moved = false
local dragStart
local startPos

floating.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        moved = false
        dragStart = input.Position
        startPos = floating.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        if delta.Magnitude > 8 then
            moved = true
        end

        floating.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        if not moved then
            toggleMenu()
        end

        dragging = false
    end
end)

--==================================================
-- FLY + NOCLIP UPDATE
--==================================================

RunService.Heartbeat:Connect(function()
    local char = getCharacter()
    local root = getRoot()
    local hum = getHumanoid()

    if not char or not root or not hum then return end

    if Config.Noclip then
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if collisionCache[part] == nil then
                    collisionCache[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end

    if Config.Fly then
        local camera = workspace.CurrentCamera
        local direction = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end

        direction += Vector3.yAxis * flyHeight

        root.AssemblyLinearVelocity =
            direction.Magnitude > 0
            and direction.Unit * Config.FlySpeed
            or Vector3.zero

        flyHeight = 0
    end
end)

--==================================================
-- PLAYER EVENTS
--==================================================

Players.PlayerAdded:Connect(function(target)
    target.CharacterAdded:Connect(function()
        task.wait(1)
        refreshESP()
    end)
end)

Players.PlayerRemoving:Connect(function(target)
    if highlights[target] then
        highlights[target]:Destroy()
        highlights[target] = nil
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
    applyJump()
    table.clear(collisionCache)
    refreshESP()
end)

print("================================")
print("        TOANA HUB 2.3")
print("        LOADED SUCCESSFULLY")
print("================================")
