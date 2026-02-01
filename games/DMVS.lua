-- mativilasanti_ pro player script - DMVS (Murderers VS Sheriffs) versión ultra rápida

getgenv().AutoGun = false
getgenv().PullGun = false
getgenv().AutoKnife = false
getgenv().HitBox = false
getgenv().PlayerESP = false
getgenv().GunSound = false
getgenv().Triggerbot = false
getgenv().AutoSlash = false
getgenv().EquipKnife = false
getgenv().AutoTPe = false
getgenv().AutoBuy = false

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Locals
local eu = Players.LocalPlayer
local Settings = {
  Triggerbot = {
    Cooldown = 0.05,  -- ultra rápido
    Waiting = false
  },
  Teleport = {
    Mode = "Everytime",
    CFrame = CFrame.new(-337, 76, 19)
  },
  Slash = {
    Cooldown = 0.01  -- knife slash casi instantáneo
  },
  Boxes = {
    Selected = "Knife Box #1",
    Price = 500
  },
  SFX = false,
  SpamSoundCooldown = 0.05,
  Cache = {
    Knife = nil,
    Gun = nil
  }
}
local HitSize = 5
local CorInocente = Color3.new(1, 0.5, 0)

-- Funciones base (sin cambios mayores)
local function GetClassOf(class)
  local Objects = { Allies = {}, Enemies = {} }
  for _, p in pairs(Players:GetPlayers()) do
    if p ~= eu and p:GetAttribute("Game") == eu:GetAttribute("Game") then
      if (class == "Enemies" or class == "Everyone") and p:GetAttribute("Team") ~= eu:GetAttribute("Team") then
        Objects.Enemies[#Objects.Enemies+1] = p
      elseif (class == "Allies" or class == "Everyone") and p:GetAttribute("Team") == eu:GetAttribute("Team") then
        Objects.Allies[#Objects.Allies+1] = p
      end
    end
  end
  if class == "Everyone" then return Objects elseif class == "Allies" then return Objects.Allies elseif class == "Enemies" then return Objects.Enemies end
end

local function ReturnItem(class, where)
  if not eu.Character or not eu:GetAttribute("Game") then return end
  local function SearchIn(parent)
    for _, item in pairs(eu[parent]:GetChildren()) do
      if item:IsA("Tool") and ((class == "Gun" and item:FindFirstChild("fire") and item:FindFirstChild("showBeam") and item:FindFirstChild("kill")) or (class == "Knife" and item:FindFirstChild("Slash"))) then
        Settings.Cache[class] = item
        return item
      end
    end
  end
  local item = Settings.Cache[class]
  if item and item.Parent and (where and item.Parent == eu[where] or not where and (item.Parent == eu.Backpack or item.Parent == eu.Character)) then
    if not where or item.Parent == eu[where] then return item end
  end
  return where and SearchIn(where) or SearchIn("Character") or SearchIn("Backpack")
end

local function PlaySound(id)
  task.spawn(function()
    local s = Instance.new("Sound")
    s.Parent = workspace.CurrentCamera
    s.Volume = 1
    s.Looped = false
    s.SoundId = "rbxassetid://" .. id
    s:Play()
    s.Ended:Wait()
    s:Destroy()
  end)
end

local function ScanEnemies(from)
  local EnemiesInSight = {}
  if not workspace.CurrentCamera then return EnemiesInSight end
  local function GetAlliesChar(allies)
    local Allies = {}
    for _, ally in pairs(allies) do if ally.Character then table.insert(Allies, ally.Character) end end
    return Allies
  end
  local Teams = GetClassOf("Everyone")
  for _, enemy in pairs(Teams.Enemies) do
    local char = enemy.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then continue end
    local CamPos = workspace.CurrentCamera.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {eu.Character, unpack(GetAlliesChar(Teams.Allies))}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local camResult = workspace:Raycast(CamPos, root.Position - CamPos, rayParams)
    if not (camResult and camResult.Instance:IsDescendantOf(char)) then continue end
    local hitResult = workspace:Raycast(from, root.Position - from, rayParams)
    if not (hitResult and hitResult.Instance:IsDescendantOf(char)) then continue end
    EnemiesInSight[enemy.Name] = { Enemy = enemy, Character = char, HitPosition = hitResult.Position }
  end
  return EnemiesInSight
end

local function Trigger()
  local Triggerbot = Settings.Triggerbot
  if not Triggerbot.Waiting then
    pcall(function()
      local Gun = ReturnItem("Gun", "Character")
      if not Gun then return end
      local gunPos = Gun.Handle.Position
      local EnemiesInSight = ScanEnemies(gunPos)
      for _, info in pairs(EnemiesInSight) do
        local hitPos = info.HitPosition
        local enemyObj = info.Enemy
        Gun.fire:FireServer()
        Gun.showBeam:FireServer(hitPos, gunPos, Gun.Handle)
        Gun.kill:FireServer(enemyObj, Vector3.new(hitPos))
        if Settings.SFX then PlaySound(8561500387) end
        ReplicatedStorage.LocalBeam:Fire(Gun.Handle, hitPos)
        Triggerbot.Waiting = true
        task.delay(Triggerbot.Cooldown, function() Triggerbot.Waiting = false end)
        break
      end
    end)
  end
end

local function KillGun()
  pcall(function()
    local Gun = ReturnItem("Gun", "Character")
    for _, enemy in pairs(GetClassOf("Enemies")) do
      pcall(function()
        if Gun and enemy.Character then
          repeat
            Gun.kill:FireServer(enemy, Vector3.new(enemy.Character.Head.Position))
            task.wait(0.01)  -- ultra rápido
          until not Gun or Gun.Parent ~= eu.Character or not enemy.Character
        end
      end)
    end
  end)
end

local function PlayerESP()
  while getgenv().PlayerESP and task.wait(0.05) do  -- más rápido que 0.33
    pcall(function()
      for _, players in pairs(GetClassOf("Enemies")) do
        local player = players.Character
        if player and player.Parent then
          if player:FindFirstChild("Highlight") then
            if not player.Highlight.Enabled then player.Highlight.Enabled = true end
            if player.Highlight.FillColor ~= CorInocente or player.Highlight.OutlineColor ~= CorInocente then
              player.Highlight.FillColor = CorInocente
              player.Highlight.OutlineColor = CorInocente
            end
          else
            local highlight = Instance.new("Highlight")
            highlight.FillColor = CorInocente
            highlight.OutlineColor = CorInocente
            highlight.FillTransparency = 0.6
            highlight.Adornee = player
            highlight.Parent = player
          end
        end
      end
    end)
  end
  if not getgenv().PlayerESP then
    for _, players in pairs(GetClassOf("Enemies")) do
      local player = players.Character
      if player and player:FindFirstChild("Highlight") then player.Highlight.Enabled = false end
    end
  end
end

local function KillKnife()
  local Enemies = GetClassOf("Enemies")
  if #Enemies < 1 then return false end
  for _, enemy in pairs(Enemies) do
    ReplicatedStorage.KnifeKill:FireServer(enemy, enemy)
  end
  return true
end

-- ... (el resto de funciones como MouseTP, GetTP, DelTP, BuyBox se mantienen iguales)

-- Load keybinds y Gokka (cambiado a tu repo si querés, pero por ahora original)
task.spawn(function()
  Settings.Keybinds = {
    { Title = "Manual Trigger", Bind = "ButtonX", Callback = Trigger },
    { Title = "Kill All", Bind = "ButtonY", Callback = function() if KillKnife() and Settings.SFX then PlaySound(18694762392) end end },
    { Title = "Player ESP", Bind = "J", Callback = function() getgenv().PlayerESP = not getgenv().PlayerESP PlayerESP() end },
    { Title = "Teleport", Bind = "ButtonB", Callback = MouseTP }
  }
  
  local Gokka = loadstring(game:HttpGet("https://raw.githubusercontent.com/Moligrafi001/Triangulare/main/extra/Gokka.lua"))()
  Gokka:DisconnectAll()
  Gokka:Connect({
    Name = "Keybinds",
    Signal = UserInputService.InputBegan,
    Callback = function(input, gp)
      if gp then return end
      for _, slot in pairs(Settings.Keybinds) do
        local bind = Enum.KeyCode[slot.Bind]
        if bind and input.KeyCode == bind then return slot.Callback() end
      end
    end
  })
end)

-- Tabs y UI (cambiado título)
local Tabs = {
  Menu = Window:Tab({ Title = "Main", Icon = "leaf"}),
  Gun = Window:Tab({ Title = "Gun", Icon = "skull"}),
  Knife = Window:Tab({ Title = "Knife", Icon = "sword"}),
  Boxes = Window:Tab({ Title = "Boxes", Icon = "box"}),
  Teleport = Window:Tab({ Title = "Teleport", Icon = "shell"}),
  Keybinds = Window:Tab({ Title = "Keybinds", Icon = "keyboard"}),
}
Window:SelectTab(1)

-- (El resto de las secciones de UI: Menu, Gun, Knife, Boxes, Teleport, Keybinds se mantienen iguales al original que tenías, pero con los toggles y loops ya modificados arriba para velocidad)

-- Agrega tu cartel al final
WindUI:Notify({
  Title = "Sigueme en Instagram",
  Content = "@mativilasanti_",
  Duration = 12
})

print("mativilasanti_ pro player script - DMVS cargado | Autokill knife ultra rápido")
