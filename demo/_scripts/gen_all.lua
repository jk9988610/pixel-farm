
local out_dir = "E:/tools/pixijs-dev/demo/assets/sv/"

local SKIN     = Color{r=242,g=201,b=160}
local SKIN_SH  = Color{r=217,g=168,b=124}
local HAIR     = Color{r=122,g=74,b=40}
local HAIR_SH  = Color{r=74,g=40,b=16}
local SHIRT    = Color{r=58,g=110,b=165}
local SHIRT_SH = Color{r=42,g=74,b=117}
local PANTS_L  = Color{r=90,g=90,b=126}
local PANTS_R  = Color{r=58,g=58,b=90}
local PANTS_SH = Color{r=30,g=30,b=60}
local BOOT     = Color{r=58,g=32,b=16}
local BOOT_SH  = Color{r=26,g=10,b=0}
local HAT      = Color{r=212,g=184,b=90}
local HAT_SH   = Color{r=168,g=138,b=58}
local EYE      = Color{r=34,g=34,b=34}
local MOUTH    = Color{r=180,g=100,b=100}
local BELT     = Color{r=58,g=32,b=16}

local FAR     = Color{r=120,g=145,b=165}
local FAR_SH  = Color{r=95,g=120,b=140}
local MID     = Color{r=55,g=95,b=75}
local MID_SH  = Color{r=40,g=75,b=60}
local GRASS   = Color{r=126,g=200,b=96}
local GRASS_SH= Color{r=105,g=178,b=80}
local GRASS_DK= Color{r=88,g=155,b=68}
local CLOUD   = Color{r=245,g=245,b=250,a=235}
local CLOUD_SH= Color{r=210,g=220,b=235,a=235}

local FLOWER_R= Color{r=230,g=80,b=80}
local FLOWER_Y= Color{r=240,g=210,b=70}
local FLOWER_B= Color{r=90,g=140,b=230}
local FLOWER_P= Color{r=230,g=130,b=190}
local FLOWER_C= Color{r=250,g=245,b=190}
local STEM    = Color{r=60,g=130,b=60}

local function makeSprite(w, h)
  local s = Sprite(w, h)
  local lay = s:newLayer()
  return s, s:newCel(lay, 1).image
end
local function save(s, name) s:saveCopyAs(out_dir .. name) end
local function rect(img, x0, y0, x1, y1, c)
  for y = y0, y1 do
    for x = x0, x1 do
      if x >= 0 and x < img.width and y >= 0 and y < img.height then
        img:drawPixel(x, y, c)
      end
    end
  end
end
local function circle(img, cx, cy, r, c)
  for y = math.floor(cy - r), math.ceil(cy + r) do
    for x = math.floor(cx - r), math.ceil(cx + r) do
      local dx, dy = x - cx, y - cy
      if dx*dx + dy*dy <= r*r and x >= 0 and x < img.width and y >= 0 and y < img.height then
        img:drawPixel(x, y, c)
      end
    end
  end
end

math.randomseed(12345)

-- head 24x24 (侧面朝右)
do
  local s, img = makeSprite(24, 24)
  circle(img, 12, 14, 8, SKIN)
  for y = 12, 21 do
    for x = 12, 19 do
      local dx, dy = x - 12, y - 14
      if dx*dx + dy*dy <= 8*8 and (x + y) > 26 then
        img:drawPixel(x, y, SKIN_SH)
      end
    end
  end
  -- 后脑头发
  for y = 5, 18 do
    for x = 3, 11 do
      local dx, dy = x - 12, y - 14
      if dx*dx + dy*dy <= 8*8 then img:drawPixel(x, y, HAIR) end
    end
  end
  for y = 5, 9 do
    for x = 4, 19 do
      local dx, dy = x - 12, y - 14
      if dx*dx + dy*dy <= 8*8 then img:drawPixel(x, y, HAIR) end
    end
  end
  for y = 10, 17 do
    for x = 3, 7 do
      local dx, dy = x - 12, y - 14
      if dx*dx + dy*dy <= 8*8 then img:drawPixel(x, y, HAIR_SH) end
    end
  end
  -- 鼻子突出
  img:drawPixel(20, 15, SKIN)
  img:drawPixel(20, 16, SKIN_SH)
  img:drawPixel(21, 16, SKIN)
  -- 草帽
  rect(img, 1, 7, 22, 8, HAT)
  rect(img, 1, 9, 22, 9, HAT_SH)
  rect(img, 5, 2, 18, 6, HAT)
  rect(img, 5, 6, 18, 6, HAT_SH)
  -- 眼嘴
  rect(img, 16, 13, 16, 14, EYE)
  img:drawPixel(17, 18, SKIN_SH)
  img:drawPixel(18, 19, MOUTH)
  save(s, "head.png")
end

-- neck 6x4
do
  local s, img = makeSprite(6, 4)
  rect(img, 0, 0, 5, 3, SKIN)
  rect(img, 0, 3, 5, 3, SKIN_SH)
  save(s, "neck.png")
end

-- chest 18x22
do
  local s, img = makeSprite(18, 22)
  rect(img, 0, 0, 17, 15, SHIRT)
  rect(img, 0, 16, 17, 21, PANTS_L)
  rect(img, 0, 15, 17, 16, BELT)
  rect(img, 4, 0, 5, 14, SHIRT_SH)
  rect(img, 12, 0, 13, 14, SHIRT_SH)
  rect(img, 15, 0, 17, 14, SHIRT_SH)
  rect(img, 15, 16, 17, 21, PANTS_R)
  save(s, "chest.png")
end

local function part2(name, w, h, main, sh, sx, sy)
  local s, img = makeSprite(w, h)
  rect(img, 0, 0, w-1, h-1, main)
  if sh and (sx or sy) then
    rect(img, w-(sx or 2), 0, w-1, h-1, sh)
  end
  save(s, name)
end

part2("thighL.png", 8, 6, PANTS_L, PANTS_R, 2, 0)
part2("thighR.png", 8, 6, PANTS_L, PANTS_R, 2, 0)
part2("thigh1L.png", 8, 4, PANTS_L, PANTS_R, 2, 0)
part2("thigh1R.png", 8, 4, PANTS_L, PANTS_R, 2, 0)

-- calf 8x12 (上裤下靴)
local function calf(name)
  local s, img = makeSprite(8, 12)
  rect(img, 0, 0, 7, 9, PANTS_L)
  rect(img, 6, 0, 7, 9, PANTS_R)
  rect(img, 0, 10, 7, 11, BOOT)
  rect(img, 6, 10, 7, 11, BOOT_SH)
  save(s, name)
end
calf("calfL.png")
calf("calfR.png")

-- foot 12x4
local function foot(name)
  local s, img = makeSprite(12, 4)
  rect(img, 2, 0, 11, 2, BOOT)
  rect(img, 2, 3, 11, 3, BOOT_SH)
  save(s, name)
end
foot("footL.png")
foot("footR.png")

-- upperarm 6x12
local function upperarm(name)
  local s, img = makeSprite(6, 12)
  rect(img, 0, 0, 5, 11, SHIRT)
  rect(img, 4, 0, 5, 11, SHIRT_SH)
  save(s, name)
end
upperarm("upperarmL.png")
upperarm("upperarmR.png")

-- forearm 5x10 (上袖下肤)
local function forearm(name)
  local s, img = makeSprite(5, 10)
  rect(img, 0, 0, 4, 4, SHIRT)
  rect(img, 3, 0, 4, 4, SHIRT_SH)
  rect(img, 0, 5, 4, 9, SKIN)
  rect(img, 3, 5, 4, 9, SKIN_SH)
  save(s, name)
end
forearm("forearmL.png")
forearm("forearmR.png")

-- hand 5x5
local function hand(name)
  local s, img = makeSprite(5, 5)
  rect(img, 0, 0, 4, 4, SKIN)
  rect(img, 3, 0, 4, 4, SKIN_SH)
  save(s, name)
end
hand("handL.png")
hand("handR.png")

-- hills_far 512x160
do
  local s, img = makeSprite(512, 160)
  local pts = {{0, 80}}
  local x = 64
  while x < 512 do
    table.insert(pts, {x, 60 + math.random(-15, 25)})
    x = x + 64 + math.random(0, 32)
  end
  table.insert(pts, {512, 80})
  for px = 0, 511 do
    local h = 160
    for i = 1, #pts - 1 do
      local x1, y1 = pts[i][1], pts[i][2]
      local x2, y2 = pts[i+1][1], pts[i+1][2]
      if px >= x1 and px <= x2 then
        local t = (px - x1) / (x2 - x1)
        h = math.floor(y1 + (y2 - y1) * t)
        break
      end
    end
    for y = h, 159 do
      img:drawPixel(px, y, FAR)
    end
    if h < 160 then img:drawPixel(px, h, FAR_SH) end
  end
  save(s, "hills_far.png")
end

-- hills_mid 512x160
do
  local s, img = makeSprite(512, 160)
  local pts = {{0, 90}}
  local x = 48
  while x < 512 do
    table.insert(pts, {x, 80 + math.random(-10, 20)})
    x = x + 48 + math.random(0, 24)
  end
  table.insert(pts, {512, 90})
  for px = 0, 511 do
    local h = 160
    for i = 1, #pts - 1 do
      local x1, y1 = pts[i][1], pts[i][2]
      local x2, y2 = pts[i+1][1], pts[i+1][2]
      if px >= x1 and px <= x2 then
        local t = (px - x1) / (x2 - x1)
        h = math.floor(y1 + (y2 - y1) * t)
        break
      end
    end
    for y = h, 159 do
      img:drawPixel(px, y, MID)
    end
    if h < 160 then img:drawPixel(px, h, MID_SH) end
  end
  save(s, "hills_mid.png")
end

-- ground_tile 32x32 (纯草 + 随机点)
do
  local s, img = makeSprite(32, 32)
  rect(img, 0, 0, 31, 31, GRASS)
  for i = 1, 200 do
    local x = math.random(0, 31)
    local y = math.random(0, 31)
    local c = GRASS_SH
    if math.random(1, 10) == 1 then c = GRASS_DK end
    img:drawPixel(x, y, c)
  end
  save(s, "ground_tile.png")
end

-- cloud 32x16
do
  local s, img = makeSprite(32, 16)
  rect(img, 4, 8, 26, 12, CLOUD)
  rect(img, 8, 5, 22, 7, CLOUD)
  rect(img, 12, 3, 18, 4, CLOUD)
  rect(img, 4, 12, 26, 12, CLOUD_SH)
  rect(img, 8, 7, 22, 7, CLOUD_SH)
  save(s, "cloud.png")
end

-- 4 色花 8x8
local function flower(name, petal)
  local s, img = makeSprite(8, 8)
  rect(img, 3, 6, 4, 7, STEM)
  img:drawPixel(3, 2, petal)
  img:drawPixel(4, 2, petal)
  img:drawPixel(2, 3, petal)
  img:drawPixel(5, 3, petal)
  img:drawPixel(3, 4, petal)
  img:drawPixel(4, 4, petal)
  img:drawPixel(3, 3, FLOWER_C)
  img:drawPixel(4, 3, FLOWER_C)
  save(s, name)
end
flower("flower_red.png", FLOWER_R)
flower("flower_yellow.png", FLOWER_Y)
flower("flower_blue.png", FLOWER_B)
flower("flower_pink.png", FLOWER_P)

print("DONE")
