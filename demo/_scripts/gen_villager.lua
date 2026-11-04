
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

local function rect(img, x0, y0, x1, y1, c)
  for y = y0, y1 do
    for x = x0, x1 do
      if x >= 0 and x < img.width and y >= 0 and y < img.height then
        img:drawPixel(x, y, c)
      end
    end
  end
end

local function drawHead(img, yo)
  for y = 6, 16 do
    for x = 11, 21 do
      local dx, dy = x - 16, y - 11
      if dx*dx + dy*dy <= 25 then
        img:drawPixel(x, y + yo, SKIN)
      end
    end
  end
  for y = 12, 16 do
    for x = 14, 21 do
      local dx, dy = x - 16, y - 11
      if dx*dx + dy*dy <= 25 and (x + y) > 29 then
        img:drawPixel(x, y + yo, SKIN_SH)
      end
    end
  end
  for y = 6, 9 do
    for x = 11, 21 do
      local dx, dy = x - 16, y - 11
      if dx*dx + dy*dy <= 25 then
        img:drawPixel(x, y + yo, HAIR)
      end
    end
  end
  for y = 9, 15 do
    for x = 11, 13 do
      local dx, dy = x - 16, y - 11
      if dx*dx + dy*dy <= 25 then
        img:drawPixel(x, y + yo, HAIR)
      end
    end
  end
  for y = 9, 15 do
    for x = 11, 12 do
      local dx, dy = x - 16, y - 11
      if dx*dx + dy*dy <= 25 then
        img:drawPixel(x, y + yo, HAIR_SH)
      end
    end
  end
  rect(img, 8, 5 + yo, 24, 5 + yo, HAT)
  rect(img, 8, 6 + yo, 24, 6 + yo, HAT_SH)
  rect(img, 11, 2 + yo, 21, 4 + yo, HAT)
  rect(img, 11, 4 + yo, 21, 4 + yo, HAT_SH)
  img:drawPixel(19, 11 + yo, EYE)
  img:drawPixel(19, 12 + yo, EYE)
  img:drawPixel(21, 12 + yo, SKIN_SH)
  img:drawPixel(22, 12 + yo, SKIN)
  img:drawPixel(22, 13 + yo, SKIN_SH)
  img:drawPixel(19, 14 + yo, MOUTH)
end

local function drawBody(img, yo)
  rect(img, 12, 16 + yo, 20, 23 + yo, SHIRT)
  rect(img, 19, 16 + yo, 20, 23 + yo, SHIRT_SH)
  rect(img, 15, 16 + yo, 17, 16 + yo, SKIN_SH)
  rect(img, 10, 17 + yo, 11, 21 + yo, SHIRT_SH)
  rect(img, 10, 22 + yo, 11, 22 + yo, SKIN_SH)
  rect(img, 21, 17 + yo, 22, 21 + yo, SHIRT)
  rect(img, 21, 22 + yo, 22, 22 + yo, SKIN)
end

local function drawLegs(img, yo, lx, rx)
  rect(img, 13 + lx, 24 + yo, 14 + lx, 28 + yo, PANTS_SH)
  rect(img, 12 + lx, 28 + yo, 15 + lx, 30 + yo, BOOT_SH)
  rect(img, 17 + rx, 24 + yo, 18 + rx, 28 + yo, PANTS)
  rect(img, 16 + rx, 28 + yo, 19 + rx, 30 + yo, BOOT)
end

local function makeFrame(path, yo, lx, rx)
  local s = Sprite(32, 32)
  local lay = s:newLayer()
  local img = s:newCel(lay, 1).image
  drawLegs(img, yo, lx, rx)
  drawBody(img, yo)
  drawHead(img, yo)
  s:saveCopyAs(path)
end

makeFrame(out .. "idle/frame_0.png", 0, 0, 0)
makeFrame(out .. "idle/frame_1.png", 1, 0, 0)
makeFrame(out .. "walk/frame_0.png", 1, -2, 2)
makeFrame(out .. "walk/frame_1.png", 0, 0, 0)
makeFrame(out .. "walk/frame_2.png", 1, 2, -2)
makeFrame(out .. "walk/frame_3.png", 0, 0, 0)
makeFrame(out .. "jump/frame_0.png", 2, 0, 0)
makeFrame(out .. "jump/frame_1.png", -1, -1, 1)
makeFrame(out .. "jump/frame_2.png", 0, 0, 0)

print("DONE: 9 frames")
