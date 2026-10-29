--!strict
-- Norteño Studio AI · Festival Norteño procedural scene builder
-- Intended for Roblox Studio's EDIT context through a trusted MCP execution tool.
-- It creates only a dedicated Workspace model and never replaces an unmarked user model.
-- Review the generated result before saving or publishing the place.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local GENERATED_ATTRIBUTE = "GeneratedByNortenoStudioAI"
local ROOT_NAME = "NortenoFestival"
local VERSION = "1.0.0"

local palette = {
  charcoal = Color3.fromRGB(24, 25, 28),
  steel = Color3.fromRGB(48, 52, 58),
  black = Color3.fromRGB(10, 11, 14),
  gold = Color3.fromRGB(228, 174, 75),
  brass = Color3.fromRGB(162, 114, 42),
  red = Color3.fromRGB(157, 38, 45),
  cream = Color3.fromRGB(245, 225, 183),
  amber = Color3.fromRGB(255, 169, 61),
  cyan = Color3.fromRGB(55, 211, 230),
  magenta = Color3.fromRGB(223, 65, 175),
  dirt = Color3.fromRGB(105, 75, 48),
  concrete = Color3.fromRGB(59, 59, 58),
  crowdA = Color3.fromRGB(37, 37, 41),
  crowdB = Color3.fromRGB(62, 34, 37),
  crowdC = Color3.fromRGB(35, 48, 52),
}

local function findRoot(): Model
  -- Never replace existing content automatically. A rerun stops safely if our
  -- generated scene is already present, so it cannot create a duplicate.
  for _, child in Workspace:GetChildren() do
    if child:IsA("Model") and child:GetAttribute(GENERATED_ATTRIBUTE) == true then
      error("Ya existe una escena generada por Norteño Studio AI; revisa o renombra esa escena antes de volver a ejecutar el constructor.")
    end
  end

  local existing = Workspace:FindFirstChild(ROOT_NAME)
  local name = ROOT_NAME
  if existing then
    local suffix = 2
    repeat
      name = ROOT_NAME .. "_Generated_" .. tostring(suffix)
      suffix += 1
    until Workspace:FindFirstChild(name) == nil
  end

  local root = Instance.new("Model")
  root.Name = name
  root:SetAttribute(GENERATED_ATTRIBUTE, true)
  root:SetAttribute("BuilderVersion", VERSION)
  root.Parent = Workspace
  return root
end

local root = findRoot()

local function folder(name: string, parent: Instance?): Folder
  local result = Instance.new("Folder")
  result.Name = name
  result.Parent = parent or root
  return result
end

local function makePart(
  parent: Instance,
  name: string,
  size: Vector3,
  cf: CFrame,
  color: Color3,
  material: Enum.Material?,
  shape: Enum.PartType?,
  transparency: number?
): Part
  local item = Instance.new("Part")
  item.Name = name
  item.Size = size
  item.CFrame = cf
  item.Color = color
  item.Material = material or Enum.Material.SmoothPlastic
  item.Anchored = true
  item.CanCollide = true
  item.TopSurface = Enum.SurfaceType.Smooth
  item.BottomSurface = Enum.SurfaceType.Smooth
  if shape then item.Shape = shape end
  if transparency then item.Transparency = transparency end
  item.CastShadow = true
  item.Parent = parent
  return item
end

local function addTextSurface(board: BasePart, text: string, accent: Color3, face: Enum.NormalId?)
  local gui = Instance.new("SurfaceGui")
  gui.Name = "FestivalSign"
  gui.Face = face or Enum.NormalId.Back
  gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
  gui.PixelsPerStud = 36
  gui.LightInfluence = 0
  gui.Parent = board

  local background = Instance.new("Frame")
  background.Name = "Background"
  background.Size = UDim2.fromScale(1, 1)
  background.BackgroundColor3 = palette.black
  background.BorderSizePixel = 0
  background.Parent = gui

  local stripe = Instance.new("Frame")
  stripe.Name = "AccentStripe"
  stripe.Size = UDim2.new(1, 0, 0.055, 0)
  stripe.Position = UDim2.fromScale(0, 0.93)
  stripe.BackgroundColor3 = accent
  stripe.BorderSizePixel = 0
  stripe.Parent = background

  local label = Instance.new("TextLabel")
  label.Name = "Label"
  label.Size = UDim2.new(0.94, 0, 0.82, 0)
  label.Position = UDim2.fromScale(0.03, 0.06)
  label.BackgroundTransparency = 1
  label.Text = text
  label.TextColor3 = palette.cream
  label.TextStrokeTransparency = 0.65
  label.Font = Enum.Font.GothamBlack
  label.TextScaled = true
  label.TextWrapped = true
  label.Parent = background
  return gui
end

local function addSign(parent: Instance, name: string, text: string, size: Vector3, cf: CFrame, accent: Color3)
  local board = makePart(parent, name, size, cf, palette.black, Enum.Material.Metal)
  addTextSurface(board, text, accent)
  local trim = makePart(parent, name .. "_TopTrim", Vector3.new(size.X, 0.22, size.Z + 0.18),
    cf * CFrame.new(0, size.Y / 2 + 0.16, 0), accent, Enum.Material.Metal)
  trim.CanCollide = false
  return board
end

local function addGlow(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, brightness: number)
  local neon = makePart(parent, name, size, cf, color, Enum.Material.Neon)
  neon.CanCollide = false
  neon.CastShadow = false
  local light = Instance.new("PointLight")
  light.Name = "Glow"
  light.Color = color
  light.Brightness = brightness
  light.Range = math.max(12, size.X * 1.3)
  light.Shadows = false
  light.Parent = neon
  return neon
end

local function addTruss(parent: Instance, a: Vector3, b: Vector3, thickness: number, color: Color3)
  local delta = b - a
  local beam = makePart(parent, "TrussMember", Vector3.new(thickness, thickness, delta.Magnitude),
    CFrame.lookAt((a + b) / 2, b),
    color, Enum.Material.Metal)
  beam.CanCollide = false
  return beam
end

local grounds = folder("Grounds")
local stage = folder("MainStage")
local rig = folder("LightingRig")
local crowd = folder("Crowd")
local concessions = folder("Concessions")
local rodeo = folder("RodeoArena")
local backstage = folder("Backstage")
local wayfinding = folder("Wayfinding")

-- Global lighting: cinematic but readable, without a large post-processing stack.
Lighting.ClockTime = 20.3
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(74, 68, 66)
Lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 42)
Lighting.EnvironmentDiffuseScale = 0.35
Lighting.EnvironmentSpecularScale = 0.35
Lighting.FogColor = Color3.fromRGB(29, 25, 31)
Lighting.FogStart = 260
Lighting.FogEnd = 760

local atmosphereCandidate = Lighting:FindFirstChild("NortenoAtmosphere")
local atmosphere: Atmosphere
if atmosphereCandidate and atmosphereCandidate:IsA("Atmosphere")
  and atmosphereCandidate:GetAttribute(GENERATED_ATTRIBUTE) == true then
  atmosphere = atmosphereCandidate
else
  local atmosphereName = atmosphereCandidate and "NortenoAtmosphere_Generated" or "NortenoAtmosphere"
  local suffix = 2
  local candidate = Lighting:FindFirstChild(atmosphereName)
  while candidate and not (candidate:IsA("Atmosphere") and candidate:GetAttribute(GENERATED_ATTRIBUTE) == true) do
    atmosphereName = "NortenoAtmosphere_Generated_" .. tostring(suffix)
    suffix += 1
    candidate = Lighting:FindFirstChild(atmosphereName)
  end
  if candidate and candidate:IsA("Atmosphere") then
    atmosphere = candidate
  else
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Name = atmosphereName
    atmosphere:SetAttribute(GENERATED_ATTRIBUTE, true)
    atmosphere.Parent = Lighting
  end
end
atmosphere.Density = 0.22
atmosphere.Offset = 0.08
atmosphere.Color = Color3.fromRGB(179, 155, 142)
atmosphere.Decay = Color3.fromRGB(75, 55, 61)
atmosphere.Glare = 0.18
atmosphere.Haze = 1.3

-- Festival footprint and access paths.
makePart(grounds, "FestivalGround", Vector3.new(440, 3, 390), CFrame.new(0, -1.5, 5),
  palette.concrete, Enum.Material.Asphalt)
makePart(grounds, "AudienceFloor", Vector3.new(118, 0.5, 105), CFrame.new(0, 0.2, -2),
  Color3.fromRGB(45, 43, 42), Enum.Material.Concrete)
makePart(grounds, "MainWalkway", Vector3.new(24, 0.35, 76), CFrame.new(0, 0.35, 98),
  Color3.fromRGB(83, 76, 64), Enum.Material.Concrete)
for side = -1, 1, 2 do
  for index = 1, 9 do
    local z = -35 + index * 14
    local x = side * 14
    local stripe = makePart(grounds, "WalkwayEdgeLight", Vector3.new(0.28, 0.16, 4.5),
      CFrame.new(x, 0.55, z), palette.amber, Enum.Material.Neon)
    stripe.CanCollide = false
    stripe.CastShadow = false
  end
end

-- Main stage: layered deck, access stairs, trim and front safety barriers.
makePart(stage, "StageDeck_Base", Vector3.new(104, 4, 40), CFrame.new(0, 3, -65),
  palette.charcoal, Enum.Material.Metal)
makePart(stage, "StageDeck_Top", Vector3.new(100, 0.8, 37), CFrame.new(0, 5.4, -65),
  Color3.fromRGB(31, 30, 29), Enum.Material.WoodPlanks)
makePart(stage, "StageFrontFascia", Vector3.new(100, 2.4, 1.1), CFrame.new(0, 4.2, -44.55),
  palette.black, Enum.Material.Metal)
makePart(stage, "GoldStagePinstripe", Vector3.new(99, 0.18, 0.18), CFrame.new(0, 5.05, -43.95),
  palette.gold, Enum.Material.Neon).CanCollide = false
for side = -1, 1, 2 do
  local x = side * 43
  for step = 1, 4 do
    makePart(stage, "AccessStair", Vector3.new(12, 0.55, 2.7),
      CFrame.new(x, 1.1 + step * 0.55, -43.5 - step * 2.5),
      palette.steel, Enum.Material.Metal)
  end
  makePart(stage, "StageSideTower", Vector3.new(4, 15, 5), CFrame.new(side * 52, 9.5, -64),
    palette.black, Enum.Material.Metal)
  for level = 1, 5 do
    local trim = makePart(stage, "TowerTrim", Vector3.new(4.2, 0.22, 5.2),
      CFrame.new(side * 52, 3.5 + level * 2.2, -64),
      if level % 2 == 0 then palette.gold else palette.red, Enum.Material.Neon)
    trim.CanCollide = false
  end
end
for x = -42, 42, 14 do
  local monitor = makePart(stage, "StageMonitor", Vector3.new(5, 1.3, 2.4),
    CFrame.new(x, 6.25, -47.5) * CFrame.Angles(math.rad(-12), 0, 0),
    palette.steel, Enum.Material.Metal)
  makePart(stage, "MonitorGrille", Vector3.new(4.3, 0.07, 1.85),
    monitor.CFrame * CFrame.new(0, 0.7, 0), palette.black, Enum.Material.DiamondPlate).CanCollide = false
end

-- Rear wall and two side LED panels. UI content is stylized, not a claim of live video.
local function ledPanel(parent: Instance, name: string, width: number, height: number, cf: CFrame, accent: Color3)
  local frame = makePart(parent, name .. "_Frame", Vector3.new(width + 1.5, height + 1.5, 1.8), cf,
    palette.steel, Enum.Material.Metal)
  local screen = makePart(parent, name .. "_Screen", Vector3.new(width, height, 0.25),
    cf * CFrame.new(0, 0, 0.98), Color3.fromRGB(9, 11, 16), Enum.Material.SmoothPlastic)
  screen.CanCollide = false
  local gui = Instance.new("SurfaceGui")
  gui.Name = "LEDVisual"
  gui.Face = Enum.NormalId.Back
  gui.LightInfluence = 0
  gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
  gui.PixelsPerStud = 20
  gui.Parent = screen
  local bg = Instance.new("Frame")
  bg.Size = UDim2.fromScale(1, 1)
  bg.BackgroundColor3 = Color3.fromRGB(9, 11, 16)
  bg.BorderSizePixel = 0
  bg.Parent = gui
  for i = 1, 12 do
    local stripe = Instance.new("Frame")
    stripe.Name = "LEDStripe"
    stripe.Size = UDim2.new(0.055, 0, 1, 0)
    stripe.Position = UDim2.new((i - 1) / 12, 0, 0, 0)
    stripe.BackgroundColor3 = if i % 3 == 0 then accent else palette.charcoal
    stripe.BackgroundTransparency = if i % 3 == 0 then 0.12 else 0.2
    stripe.BorderSizePixel = 0
    stripe.Parent = bg
  end
  local title = Instance.new("TextLabel")
  title.Size = UDim2.new(0.92, 0, 0.45, 0)
  title.Position = UDim2.fromScale(0.04, 0.17)
  title.BackgroundTransparency = 1
  title.Text = "FESTIVAL NORTEÑO"
  title.Font = Enum.Font.GothamBlack
  title.TextColor3 = palette.cream
  title.TextScaled = true
  title.TextStrokeTransparency = 0.45
  title.Parent = bg
  local subtitle = Instance.new("TextLabel")
  subtitle.Size = UDim2.new(0.82, 0, 0.16, 0)
  subtitle.Position = UDim2.fromScale(0.09, 0.64)
  subtitle.BackgroundTransparency = 1
  subtitle.Text = "MÚSICA · LUCES · TRADICIÓN"
  subtitle.Font = Enum.Font.GothamBold
  subtitle.TextColor3 = accent
  subtitle.TextScaled = true
  subtitle.Parent = bg
  return frame, screen
end
ledPanel(stage, "MainLEDWall", 62, 24, CFrame.new(0, 22, -84), palette.gold)
ledPanel(stage, "LeftLEDWall", 18, 12, CFrame.new(-39, 17, -82), palette.red)
ledPanel(stage, "RightLEDWall", 18, 12, CFrame.new(39, 17, -82), palette.cyan)
addSign(stage, "MainFestivalSign", "FESTIVAL NORTEÑO", Vector3.new(56, 6, 1.2), CFrame.new(0, 35, -83),
  palette.gold)

-- Truss towers and roof. All members are anchored for predictable performance.
for side = -1, 1, 2 do
  for z = -89, -43, 46 do
    local x = side * 51
    makePart(rig, "TrussTower", Vector3.new(2.1, 34, 2.1), CFrame.new(x, 18, z),
      palette.steel, Enum.Material.Metal)
    makePart(rig, "TowerFoot", Vector3.new(4.8, 1.2, 4.8), CFrame.new(x, 0.6, z),
      palette.black, Enum.Material.Metal)
    for y = 5, 31, 5 do
      addTruss(rig, Vector3.new(x, y, z - 2), Vector3.new(x, y + 5, z + 2), 0.32, palette.gold)
      addTruss(rig, Vector3.new(x, y + 5, z - 2), Vector3.new(x, y, z + 2), 0.32, palette.steel)
    end
  end
end
makePart(rig, "RoofTrussFront", Vector3.new(106, 2.3, 2.3), CFrame.new(0, 35, -43),
  palette.steel, Enum.Material.Metal)
makePart(rig, "RoofTrussRear", Vector3.new(106, 2.3, 2.3), CFrame.new(0, 35, -90),
  palette.steel, Enum.Material.Metal)
makePart(rig, "RoofBeamLeft", Vector3.new(2.3, 2.3, 47), CFrame.new(-51, 35, -66.5),
  palette.steel, Enum.Material.Metal)
makePart(rig, "RoofBeamRight", Vector3.new(2.3, 2.3, 47), CFrame.new(51, 35, -66.5),
  palette.steel, Enum.Material.Metal)
for x = -42, 42, 14 do
  addTruss(rig, Vector3.new(x, 34, -44), Vector3.new(x + 7, 34, -89), 0.3, palette.steel)
  local bar = makePart(rig, "LightingBar", Vector3.new(2.2, 0.6, 42),
    CFrame.new(x, 32.5, -66.5), palette.black, Enum.Material.Metal)
  bar.CanCollide = false
  local fixture = makePart(rig, "MovingHeadFixture", Vector3.new(2.1, 1.2, 1.7),
    CFrame.new(x, 31.4, -50) * CFrame.Angles(0, math.rad(180), 0),
    palette.charcoal, Enum.Material.Metal)
  fixture.CanCollide = false
  local lens = addGlow(rig, "FixtureLens", Vector3.new(0.9, 0.45, 0.2),
    fixture.CFrame * CFrame.new(0, 0, -0.9), palette.amber, 0.65)
  local spot = Instance.new("SpotLight")
  spot.Name = "StageBeam"
  spot.Face = Enum.NormalId.Front
  spot.Angle = 62
  spot.Range = 95
  spot.Brightness = 1.2
  spot.Color = palette.amber
  spot.Shadows = false
  spot.Parent = fixture
end

-- Front-of-house towers and restrained audience-facing fill lighting.
for side = -1, 1, 2 do
  local x = side * 58
  makePart(rig, "FOHTower", Vector3.new(2, 18, 2), CFrame.new(x, 9, -8), palette.steel, Enum.Material.Metal)
  for y = 10, 14, 4 do
    local lamp = makePart(rig, "FOHFixture", Vector3.new(1.5, 1, 1.5),
      CFrame.new(x, y, -8) * CFrame.Angles(0, math.rad(180), 0), palette.black, Enum.Material.Metal)
    local light = Instance.new("SpotLight")
    light.Face = Enum.NormalId.Front
    light.Angle = 72
    light.Range = 75
    light.Brightness = 1
    light.Color = palette.cream
    light.Shadows = false
    light.Parent = lamp
  end
end

-- Speaker arrays and sub stacks.
for side = -1, 1, 2 do
  local x = side * 46
  for row = 1, 6 do
    local y = 21 - row * 2.2
    local cabinet = makePart(stage, "LineArrayCabinet", Vector3.new(5.5, 2, 2.2),
      CFrame.new(x, y, -49), palette.black, Enum.Material.Metal)
    makePart(stage, "SpeakerGrille", Vector3.new(4.6, 1.5, 0.12),
      cabinet.CFrame * CFrame.new(0, 0, 1.16), palette.steel, Enum.Material.DiamondPlate).CanCollide = false
    for z = -0.55, 0.55, 1.1 do
      local cone = makePart(stage, "SpeakerConeDetail", Vector3.new(0.68, 0.68, 0.16),
        cabinet.CFrame * CFrame.new(-1.4, z, 1.28), palette.charcoal, Enum.Material.Metal, Enum.PartType.Cylinder)
      cone.CanCollide = false
    end
  end
  for stack = 0, 1 do
    for level = 0, 1 do
      local sub = makePart(stage, "Subwoofer", Vector3.new(5.5, 3, 3.5),
        CFrame.new(x, 1.5 + level * 3.05, -48 + stack * 3.8), palette.black, Enum.Material.Metal)
      makePart(stage, "SubwooferGrille", Vector3.new(4.5, 2.2, 0.15),
        sub.CFrame * CFrame.new(0, 0, 1.86), palette.steel, Enum.Material.DiamondPlate).CanCollide = false
    end
  end
end

-- Crowd pen, barriers and elevated seating with clear aisles.
for side = -1, 1, 2 do
  makePart(crowd, "FrontCrowdBarrier", Vector3.new(2, 3.5, 56), CFrame.new(side * 57, 1.75, -24),
    palette.black, Enum.Material.Metal)
  for segment = 1, 7 do
    makePart(crowd, "BarrierGoldInlay", Vector3.new(0.12, 0.12, 5.4),
      CFrame.new(side * 55.9, 2.7, -50 + segment * 7), palette.gold, Enum.Material.Neon).CanCollide = false
  end
end
for tier = 1, 5 do
  local z = 24 + tier * 7
  local y = 1.3 + tier * 1.15
  makePart(crowd, "BleacherTier", Vector3.new(100, 1.2, 6.3), CFrame.new(0, y, z),
    palette.steel, Enum.Material.Metal)
  makePart(crowd, "BleacherSeatPad", Vector3.new(96, 0.25, 4.6), CFrame.new(0, y + 0.7, z + 0.3),
    palette.red, Enum.Material.SmoothPlastic)
  for side = -1, 1, 2 do
    makePart(crowd, "BleacherHandrail", Vector3.new(0.22, 3.5, 0.22),
      CFrame.new(side * 49, y + 1.6, z + 2), palette.gold, Enum.Material.Metal)
  end
end

math.randomseed(24681)
local crowdColors = { palette.crowdA, palette.crowdB, palette.crowdC, palette.steel }
for row = 1, 5 do
  local z = -13 + row * 6.2
  local startX = -48
  local count = 13
  for index = 1, count do
    local x = startX + (index - 1) * 7.8 + (row % 2) * 1.5
    local base = Vector3.new(x, 0, z)
    local person = Instance.new("Model")
    person.Name = "AudienceSilhouette"
    person.Parent = crowd
    local torsoHeight = 2.4 + math.random() * 0.25
    local shirtColor = crowdColors[math.random(1, #crowdColors)]
    local torso = makePart(person, "Torso", Vector3.new(1.25, torsoHeight, 0.65),
      CFrame.new(base + Vector3.new(0, 2.2, 0)), shirtColor, Enum.Material.SmoothPlastic)
    torso.CanCollide = false
    torso.CanQuery = false
    local head = makePart(person, "Head", Vector3.new(0.88, 0.88, 0.88),
      CFrame.new(base + Vector3.new(0, 3.9, 0)), Color3.fromRGB(168, 128, 95), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    head.CanCollide = false
    head.CanQuery = false
    for legSide = -1, 1, 2 do
      local leg = makePart(person, "Leg", Vector3.new(0.4, 1.15, 0.46),
        CFrame.new(base + Vector3.new(legSide * 0.33, 0.55, 0)),
        Color3.fromRGB(22, 22, 24), Enum.Material.SmoothPlastic)
      leg.CanCollide = false
      leg.CanQuery = false
    end
    for armSide = -1, 1, 2 do
      local raised = math.random() > 0.72
      local angle = if raised then math.rad(38 * armSide) else math.rad(-6)
      local arm = makePart(person, "Arm", Vector3.new(0.36, raised and 1.85 or 1.55, 0.38),
        CFrame.new(base + Vector3.new(armSide * 0.88, raised and 2.75 or 2.15, 0))
          * CFrame.Angles(0, 0, angle), shirtColor, Enum.Material.SmoothPlastic)
      arm.CanCollide = false
      arm.CanQuery = false
    end
  end
end

-- Entrance, tickets, stalls, road cases, and overhead festival strings.
addSign(wayfinding, "EntranceArch", "BIENVENIDOS AL FESTIVAL", Vector3.new(38, 7, 1.2),
  CFrame.new(0, 15, 135), palette.gold)
for side = -1, 1, 2 do
  makePart(wayfinding, "EntrancePost", Vector3.new(2.2, 15, 2.2), CFrame.new(side * 20, 7.5, 135),
    palette.steel, Enum.Material.Metal)
  makePart(wayfinding, "EntrancePostCap", Vector3.new(3, 0.45, 3), CFrame.new(side * 20, 15.2, 135),
    palette.gold, Enum.Material.Metal)
end
local function makeStall(x: number, z: number, title: string, accent: Color3)
  local booth = makePart(concessions, "FestivalStall", Vector3.new(18, 8, 12), CFrame.new(x, 4, z),
    palette.charcoal, Enum.Material.WoodPlanks)
  makePart(concessions, "StallCounter", Vector3.new(18, 1.4, 3), CFrame.new(x, 1.4, z + 7),
    palette.brass, Enum.Material.WoodPlanks)
  makePart(concessions, "StallRoof", Vector3.new(20, 0.8, 14), CFrame.new(x, 8.6, z),
    palette.black, Enum.Material.Metal)
  for stripe = -1, 1, 2 do
    makePart(concessions, "StallCanopyStripe", Vector3.new(9.5, 0.18, 14.2),
      CFrame.new(x + stripe * 5, 8.15, z), accent, Enum.Material.Neon).CanCollide = false
  end
  addSign(concessions, title .. "_Sign", title, Vector3.new(15, 2.4, 0.6),
    CFrame.new(x, 6.8, z + 6.35), accent)
  return booth
end
makeStall(-83, 28, "COMIDA", palette.amber)
makeStall(83, 28, "BEBIDAS", palette.cyan)
makeStall(-83, 60, "ARTESANÍAS", palette.gold)
makeStall(83, 60, "TAQUILLA", palette.red)

for strand = 1, 3 do
  local z = 40 + strand * 22
  local a = Vector3.new(-65, 18, z)
  local b = Vector3.new(65, 18, z + 5)
  addTruss(grounds, a, b, 0.12, palette.steel)
  for lamp = 0, 10 do
    local t = lamp / 10
    local pos = a:Lerp(b, t) - Vector3.new(0, 2 + math.sin(t * math.pi) * 2, 0)
    addGlow(grounds, "StringLight", Vector3.new(0.55, 0.55, 0.55), CFrame.new(pos),
      if lamp % 3 == 0 then palette.amber else palette.cream, 0.35)
  end
end

-- Backstage dressing and a show-control console. The prompt is connected by the companion script.
makePart(backstage, "BackstageFloor", Vector3.new(70, 0.5, 22), CFrame.new(0, 0.4, -105),
  palette.black, Enum.Material.Metal)
for index = 1, 8 do
  local x = -30 + index * 8
  local case = makePart(backstage, "RoadCase", Vector3.new(4.2, 4, 4.2), CFrame.new(x, 2.4, -105),
    palette.steel, Enum.Material.Metal)
  for y = 1, 3 do
    makePart(backstage, "RoadCaseTrim", Vector3.new(4.25, 0.12, 4.25),
      case.CFrame * CFrame.new(0, -1.65 + y * 1.1, 0), palette.gold, Enum.Material.Metal).CanCollide = false
  end
end
local console = makePart(backstage, "ShowControlConsole", Vector3.new(5, 3, 3), CFrame.new(20, 2, -96),
  palette.charcoal, Enum.Material.Metal)
local prompt = Instance.new("ProximityPrompt")
prompt.Name = "ShowControlPrompt"
prompt.ActionText = "Iniciar / detener show"
prompt.ObjectText = "Control de iluminación"
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.HoldDuration = 0.6
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = console
addSign(backstage, "ControlConsoleSign", "CONTROL DEL SHOW", Vector3.new(8, 2, 0.6),
  CFrame.new(20, 4.6, -94.4), palette.gold)

-- Optional arcade-style mechanical ride area, spatially separated from the concert.
makePart(rodeo, "ArenaDirt", Vector3.new(78, 1.1, 78), CFrame.new(154, 0.2, -25),
  palette.dirt, Enum.Material.Ground)
makePart(rodeo, "ArenaCenterPad", Vector3.new(48, 0.2, 48), CFrame.new(154, 0.9, -25),
  Color3.fromRGB(124, 91, 57), Enum.Material.Sand)
for side = -1, 1, 2 do
  for edge = 0, 1 do
    makePart(rodeo, "ArenaFenceRail", Vector3.new(78, 0.55, 0.55),
      CFrame.new(154, 2.1 + edge * 2.1, -25 + side * 39), palette.cream, Enum.Material.Wood)
    makePart(rodeo, "ArenaFenceRail", Vector3.new(0.55, 0.55, 78),
      CFrame.new(154 + side * 39, 2.1 + edge * 2.1, -25), palette.cream, Enum.Material.Wood)
  end
end
for side = -1, 1, 2 do
  local x = 154 + side * 48
  for tier = 1, 4 do
    makePart(rodeo, "ArenaBleacherTier", Vector3.new(18, 1.1, 72),
      CFrame.new(x, tier * 1.15, -25), palette.steel, Enum.Material.Metal)
  end
end
addSign(rodeo, "ArenaSign", "JARIPEO ARCADE", Vector3.new(28, 5, 1),
  CFrame.new(154, 12, -66), palette.red)

local ride = Instance.new("Model")
ride.Name = "MechanicalRide"
ride.Parent = rodeo
makePart(ride, "RideBase", Vector3.new(18, 2, 18), CFrame.new(154, 2.2, -25),
  palette.black, Enum.Material.Metal)
local platform = makePart(ride, "RidePlatform", Vector3.new(11, 1.2, 11), CFrame.new(154, 3.8, -25),
  palette.brass, Enum.Material.Metal, Enum.PartType.Cylinder)
platform.CanCollide = true
local body = makePart(ride, "RideBody", Vector3.new(7.5, 3.2, 3), CFrame.new(154, 6, -25),
  Color3.fromRGB(60, 45, 37), Enum.Material.SmoothPlastic)
local head = makePart(ride, "RideHead", Vector3.new(2.6, 2.5, 2.8), CFrame.new(154, 7.7, -22.5),
  Color3.fromRGB(82, 62, 45), Enum.Material.SmoothPlastic)
for side = -1, 1, 2 do
  makePart(ride, "RideHorn", Vector3.new(0.45, 2.5, 0.45),
    CFrame.new(154 + side * 1.45, 9, -22.5) * CFrame.Angles(0, 0, math.rad(side * 28)),
    palette.cream, Enum.Material.SmoothPlastic)
  makePart(ride, "RideLeg", Vector3.new(0.8, 2.1, 0.8), CFrame.new(154 + side * 2.3, 4.7, -25),
    Color3.fromRGB(69, 51, 40), Enum.Material.SmoothPlastic)
end
local ridePrompt = Instance.new("ProximityPrompt")
ridePrompt.Name = "RidePrompt"
ridePrompt.ActionText = "Probar atracción"
ridePrompt.ObjectText = "Jaripeo arcade"
ridePrompt.KeyboardKeyCode = Enum.KeyCode.E
ridePrompt.HoldDuration = 0.7
ridePrompt.MaxActivationDistance = 10
ridePrompt.RequiresLineOfSight = false
ridePrompt.Parent = body
addSign(rodeo, "RideScoreboard", "RETO DE MONTA · ACÉRCATE PARA JUGAR",
  Vector3.new(22, 5, 0.9), CFrame.new(154, 10, 16), palette.gold)

-- Simple emergency/help point and neutral wayfinding; keep it visible, not cluttered.
addSign(wayfinding, "HelpPoint", "AYUDA / PRIMEROS AUXILIOS", Vector3.new(17, 3.2, 0.8),
  CFrame.new(-110, 6, 90), palette.cyan)
addSign(wayfinding, "ExitSign", "SALIDA", Vector3.new(12, 3, 0.8),
  CFrame.new(0, 8, 155), palette.gold)

-- Spawn on the entrance walkway, facing the stage.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "FestivalSpawn"
spawn.Size = Vector3.new(7, 1, 7)
spawn.CFrame = CFrame.new(0, 1.1, 116)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Transparency = 0.2
spawn.Color = palette.gold
spawn.Material = Enum.Material.Metal
spawn.Parent = wayfinding

root:SetAttribute("SceneBuildComplete", true)
print(string.format("[Norteño Studio AI] Festival construido: %s · builder %s", root:GetFullName(), VERSION))
print("[Norteño Studio AI] Siguiente paso: instalar LightingShow.server.luau y RodeoRide.server.luau; revisar desde la entrada y el centro del público.")
