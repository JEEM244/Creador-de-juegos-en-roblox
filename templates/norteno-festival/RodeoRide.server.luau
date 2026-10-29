-- Norteño Studio AI · safe arcade ride score loop
-- Install in ServerScriptService as RodeoRide.server.lua after building the festival.
-- The attraction is an optional timed arcade challenge; it does not depict injury.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

local arena = root:FindFirstChild("RodeoArena")
local ride = arena and arena:FindFirstChild("MechanicalRide")
local body = ride and ride:FindFirstChild("RideBody")
local prompt = body and body:FindFirstChild("RidePrompt")
local board = arena and arena:FindFirstChild("RideScoreboard")
if not (arena and ride and ride:IsA("Model") and body and prompt and prompt:IsA("ProximityPrompt")) then
  warn("[Norteño Studio AI] Falta la atracción arcade o su ProximityPrompt.")
  return
end

local basePivot = ride:GetPivot()
local activeRun = nil
local runId = 0
local defaultPromptText = "Probar atracción"

local function setBoard(text: string)
  if not board then return end
  for _, item in board:GetDescendants() do
    if item:IsA("TextLabel") then
      item.Text = text
      return
    end
  end
end

local function getBestScore(player: Player): IntValue
  local leaderstats = player:FindFirstChild("leaderstats")
  if not leaderstats then
    leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
  end
  local best = leaderstats:FindFirstChild("RodeoBest")
  if not best then
    best = Instance.new("IntValue")
    best.Name = "RodeoBest"
    best.Value = 0
    best.Parent = leaderstats
  end
  return best :: IntValue
end

local function finishRun(run)
  if activeRun ~= run then return end
  activeRun = nil
  ride:PivotTo(basePivot)
  prompt.ActionText = defaultPromptText
  prompt.ObjectText = "Jaripeo arcade"
  local best = getBestScore(run.player)
  if run.score > best.Value then best.Value = run.score end
  setBoard(string.format("RETO TERMINADO  ·  %s  ·  PUNTOS: %d", run.player.DisplayName, run.score))
  run.player:SetAttribute("LastRodeoScore", run.score)
  run.player:SetAttribute("RodeoRideActive", false)
end

local function beginRun(player: Player)
  runId += 1
  local run = {
    id = runId,
    player = player,
    score = 0,
    startedAt = os.clock(),
    lastTapAt = 0,
  }
  activeRun = run
  player:SetAttribute("RodeoRideActive", true)
  player:SetAttribute("LastRodeoScore", 0)
  prompt.ActionText = "¡Presiona E para mantener el equilibrio!"
  prompt.ObjectText = "Reto activo · vuelve a pulsar"
  setBoard("RETO ACTIVO  ·  " .. player.DisplayName .. "  ·  PULSA E")
  task.spawn(function()
    while activeRun == run and os.clock() - run.startedAt < 12 do
      local elapsed = os.clock() - run.startedAt
      local tilt = math.sin(elapsed * 3.2) * math.rad(7)
      local roll = math.cos(elapsed * 2.7) * math.rad(5)
      local yaw = math.sin(elapsed * 1.8) * math.rad(3)
      ride:PivotTo(basePivot * CFrame.Angles(tilt, yaw, roll))
      setBoard(string.format("%s  ·  PUNTOS: %d  ·  %ds",
        string.upper(player.DisplayName), run.score, math.max(0, 12 - math.floor(elapsed))))
      task.wait(0.08)
    end
    finishRun(run)
  end)
end

prompt.Triggered:Connect(function(player: Player)
  if not player or not player:IsDescendantOf(Players) then return end
  if not activeRun then
    beginRun(player)
    return
  end
  if activeRun.player ~= player then return end
  local now = os.clock()
  if now - activeRun.lastTapAt < 0.35 then return end
  activeRun.lastTapAt = now
  activeRun.score += 1
  player:SetAttribute("LastRodeoScore", activeRun.score)
end)

Players.PlayerRemoving:Connect(function(player)
  if activeRun and activeRun.player == player then
    finishRun(activeRun)
  end
end)

setBoard("RETO DE MONTA  ·  ACÉRCATE Y PULSA E")
print("[Norteño Studio AI] Minijuego arcade de jaripeo instalado.")
