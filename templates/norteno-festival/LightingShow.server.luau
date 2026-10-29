-- Norteño Studio AI · server-authoritative concert lighting controller
-- Install in ServerScriptService as LightingShow.server.lua after building the festival.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local root: Model? = nil
for _, child in Workspace:GetChildren() do
  if child:IsA("Model") and child:GetAttribute("GeneratedByNortenoStudioAI") == true then
    root = child
    break
  end
end
if not root then
  warn("[Norteño Studio AI] No se encontró el modelo generado del festival.")
  return
end

local backstage = root:FindFirstChild("Backstage")
local rig = root:FindFirstChild("LightingRig")
local console = backstage and backstage:FindFirstChild("ShowControlConsole")
local prompt = console and console:FindFirstChild("ShowControlPrompt")
if not (rig and prompt and prompt:IsA("ProximityPrompt")) then
  warn("[Norteño Studio AI] Falta el control del show o el equipo de iluminación.")
  return
end

local looks = {
  { name = "Apertura cálida", color = Color3.fromRGB(255, 174, 77), brightness = 1.1 },
  { name = "Rojo y ámbar", color = Color3.fromRGB(230, 58, 55), brightness = 1.35 },
  { name = "Cian de festival", color = Color3.fromRGB(65, 215, 235), brightness = 1.15 },
  { name = "Final dorado", color = Color3.fromRGB(255, 224, 153), brightness = 1.5 },
}
local active = false
local revision = 0
local lastToggleAt = 0

local function updateConsole(text: string)
  local sign = backstage and backstage:FindFirstChild("ControlConsoleSign")
  if not sign then return end
  for _, descendant in sign:GetDescendants() do
    if descendant:IsA("TextLabel") then
      descendant.Text = text
      return
    end
  end
end

local function setLook(look)
  for _, descendant in rig:GetDescendants() do
    if descendant:IsA("SpotLight") or descendant:IsA("PointLight") then
      descendant.Color = look.color
      descendant.Brightness = look.brightness
      descendant.Enabled = true
    elseif descendant:IsA("BasePart") and descendant.Name == "FixtureLens" then
      descendant.Color = look.color
    end
  end
  -- Change the LED wall graphic at the same time as the fixtures.
  for _, descendant in root:GetDescendants() do
    if descendant:IsA("Frame") and descendant.Name == "LEDStripe" then
      descendant.BackgroundColor3 = look.color
      descendant.BackgroundTransparency = 0.08
    elseif descendant:IsA("TextLabel") and descendant.Name == "Label" then
      descendant.TextColor3 = look.color
    end
  end
end

local function stopShow()
  active = false
  revision += 1
  for _, descendant in rig:GetDescendants() do
    if descendant:IsA("SpotLight") then
      descendant.Color = Color3.fromRGB(255, 174, 77)
      descendant.Brightness = 0.8
      descendant.Enabled = false
    elseif descendant:IsA("PointLight") and descendant.Parent and descendant.Parent.Name == "FixtureLens" then
      descendant.Enabled = false
    elseif descendant:IsA("BasePart") and descendant.Name == "FixtureLens" then
      descendant.Color = Color3.fromRGB(83, 68, 54)
    end
  end
  for _, descendant in root:GetDescendants() do
    if descendant:IsA("Frame") and descendant.Name == "LEDStripe" then
      descendant.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
      descendant.BackgroundTransparency = 0.2
    end
  end
  prompt.ActionText = "Iniciar show"
  updateConsole("SHOW EN PAUSA")
end

local function startShow()
  active = true
  revision += 1
  local myRevision = revision
  prompt.ActionText = "Detener show"
  updateConsole("SHOW ACTIVO · LUCES")
  task.spawn(function()
    local index = 0
    while active and revision == myRevision do
      index = (index % #looks) + 1
      setLook(looks[index])
      task.wait(2.3)
    end
  end)
end

prompt.Triggered:Connect(function(player: Player)
  local now = os.clock()
  if now - lastToggleAt < 1 then return end
  lastToggleAt = now
  if active then
    stopShow()
  else
    startShow()
  end
end)

Players.PlayerRemoving:Connect(function(player)
  -- The show is venue-wide; leaving the server must not leave a dangling player state.
  if player:GetAttribute("RequestedShowControl") then
    player:SetAttribute("RequestedShowControl", nil)
  end
end)

stopShow()
print("[Norteño Studio AI] Control de iluminación instalado.")
