-- Norteño Studio AI · lightweight local crowd animation
-- Install as a LocalScript in StarterPlayerScripts after the festival scene is built.
-- It animates a limited number of anchored silhouette arms locally to keep the server light.

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local function findGeneratedRoot(): Model?
  for _, child in Workspace:GetChildren() do
    if child:IsA("Model") and child:GetAttribute("GeneratedByNortenoStudioAI") == true then
      return child
    end
  end
  return nil
end

local root: Model? = findGeneratedRoot()
if not root then
  root = Workspace:WaitForChild("NortenoFestival", 30) :: Model?
  if root and not root:IsA("Model") then
    root = nil
  end
end
if not root then
  warn("[Norteño Studio AI] No se encontró el festival para animar el público.")
  return
end

local crowd = root:FindFirstChild("Crowd")
if not crowd then
  warn("[Norteño Studio AI] Falta la carpeta Crowd.")
  return
end

local rng = Random.new(714)
local animatedArms = 0
local MAX_ANIMATED_ARMS = 42
local activeTweens = {}

for _, person in crowd:GetChildren() do
  if animatedArms >= MAX_ANIMATED_ARMS then
    break
  end
  if not person:IsA("Model") or person.Name ~= "AudienceSilhouette" then
    continue
  end

  local arms = {}
  for _, item in person:GetChildren() do
    if item:IsA("BasePart") and item.Name == "Arm" then
      table.insert(arms, item)
    end
  end

  for index, arm in arms do
    if animatedArms >= MAX_ANIMATED_ARMS then
      break
    end
    local baseCFrame = arm.CFrame
    local direction = if index % 2 == 0 then -1 else 1
    local angle = math.rad(rng:NextInteger(12, 24) * direction)
    local target = baseCFrame * CFrame.Angles(0, 0, angle)
    local info = TweenInfo.new(
      rng:NextNumber(0.8, 1.35),
      Enum.EasingStyle.Sine,
      Enum.EasingDirection.InOut,
      -1,
      true,
      rng:NextNumber(0, 1.2)
    )
    local tween = TweenService:Create(arm, info, { CFrame = target })
    table.insert(activeTweens, tween)
    tween:Play()
    animatedArms += 1
  end
end

print(string.format("[Norteño Studio AI] Animación local ligera: %d brazos.", animatedArms))
