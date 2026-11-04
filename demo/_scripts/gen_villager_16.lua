
-- 相对路径：请在仓库根目录（pixel-farm/）运行本脚本
local out = "demo/assets/char/villager/"

local SKIN    = Color{r=242,g=201,b=160}
local SKIN_SH = Color{r=217,g=168,b=124}
local HAIR    = Color{r=122,g=74,b=40}
local HAIR_SH = Color{r=74,g=40,b=16}
local SHIRT   = Color{r=74,g=138,b=58}
local SHIRT_SH= Color{r=42,g=90,b=42}
local PANTS   = Color{r=74,g=74,b=106}
local PANTS_SH= Color{r=48,g=48,b=74}
local BOOT    = Color{r=58,g=32,b=16}
local BOOT_SH = Color{r=26,g=10,b=0}
local HAT     = Color{r=212,g=184,b=90}
local HAT_SH  = Color{r=168,g=138,b=58}
local EYE     = Color{r=34,g=34,b=34}
local MOUTH   = Color{r=180,g=100,b=100}

local function px(img, x, y, c)
  if x >= 0 and x < img.width and y >= 0 and y < img.height then
    img:drawPixel(x, y, c)
  end
end

-- 头: 16x32 画布, 头约 9x9, 面朝右
local function drawHead(img, dy)
  -- 脸圆
  for y = 3, 11 do
    for x = 4, 12 do
      local dx, dy2 = x - 8, y - 7
      if dx*dx + dy2*dy2 <= 16 then
        px(img, x, y + dy, SKIN)
      end
    end
  end
  -- 右下阴影
  for y = 7, 11 do
    for x = 8, 12 do
      local dx, dy2 = x - 8, y - 7
      if dx*dx + dy2*dy2 <= 16 and (x + y) > 15 then
        px(img, x, y + dy, SKIN_SH)
      end
    end
  end
  -- 头发盖上半
  for y = 3, 5 do
    for x = 4, 12 do
      local dx, dy2 = x - 8, y - 7
      if dx*dx + dy2*dy2 <= 16 then
        px(img, x, y + dy, HAIR)
      end
    end
  end
  -- 后脑鬓角
  for y = 5, 10 do
    for x = 4, 5 do
      local dx, dy2 = x - 8, y - 7
      if dx*dx + dy2*dy2 <= 16 then
        px(img, x, y + dy, HAIR)
      end
    end
  end
  px(img, 4, 8 + dy, HAIR_SH)
  px(img, 4, 9 + dy, HAIR_SH)
  -- 草帽
  for x = 2, 14 do
    px(img, x, 2 + dy, HAT)
    px(img, x, 3 + dy, HAT_SH)
  end
  for x = 4, 12 do
    px(img, x, 0 + dy, HAT)
    px(img, x, 1 + dy, HAT_SH)
  end
  -- 眼睛 (侧面单眼)
  px(img, 11, 7 + dy, EYE)
  px(img, 11, 8 + dy, EYE)
  -- 鼻头
  px(img, 13, 8 + dy, SKIN)
  px(img, 13, 9 + dy, SKIN_SH)
  -- 嘴
  px(img, 11, 10 + dy, MOUTH)
end

-- 身体: 衬衫 + 手臂
local function drawBody(img, dy)
  -- 躯干
  for y = 12, 21 do
    for x = 5, 11 do
      px(img, x, y + dy, SHIRT)
    end
  end
  -- 右侧阴影
  for y = 12, 21 do
    px(img, 10, y + dy, SHIRT_SH)
    px(img, 11, y + dy, SHIRT_SH)
  end
  -- 左臂 (后侧)
  px(img, 4, 13 + dy, SHIRT_SH)
  px(img, 4, 14 + dy, SHIRT_SH)
  px(img, 4, 15 + dy, SHIRT_SH)
  px(img, 4, 16 + dy, SKIN_SH)
  -- 右臂 (前侧)
  px(img, 12, 13 + dy, SHIRT)
  px(img, 12, 14 + dy, SHIRT)
  px(img, 12, 15 + dy, SKIN)
  -- 腰带
  for x = 5, 11 do
    px(img, x, 21 + dy, Color{r=40,g=30,b=20})
  end
end

-- 腿
local function drawLegs(img, dy, lx, rx)
  -- 左腿 (后)
  for y = 22, 27 do
    px(img, 6 + lx, y + dy, PANTS_SH)
  end
  for x = 5 + lx, 7 + lx do
    px(img, x, 28 + dy, BOOT_SH)
  end
  -- 右腿 (前)
  for y = 22, 27 do
    px(img, 9 + rx, y + dy, PANTS)
  end
  for x = 8 + rx, 10 + rx do
    px(img, x, 28 + dy, BOOT)
  end
end

local function makeFrame(path, dy, lx, rx)
  local s = Sprite(16, 32)
  local lay = s:newLayer()
  local img = s:newCel(lay, 1).image
  drawLegs(img, dy, lx, rx)
  drawBody(img, dy)
  drawHead(img, dy)
  s:saveCopyAs(path)
end

-- idle: 2 帧, 身体轻微上下
makeFrame(out .. "idle/frame_0.png", 0, 0, 0)
makeFrame(out .. "idle/frame_1.png", 1, 0, 0)

-- walk: 4 帧, 腿前后换
makeFrame(out .. "walk/frame_0.png", 1, -1, 1)
makeFrame(out .. "walk/frame_1.png", 0, 0, 0)
makeFrame(out .. "walk/frame_2.png", 1, 1, -1)
makeFrame(out .. "walk/frame_3.png", 0, 0, 0)

-- jump: 3 帧
makeFrame(out .. "jump/frame_0.png", 1, 0, 0)
makeFrame(out .. "jump/frame_1.png", 0, -1, 1)
makeFrame(out .. "jump/frame_2.png", 1, 0, 0)

print("DONE: 16x32, 9 frames")
