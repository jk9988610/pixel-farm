
local OUT = "E:/tools/pixijs-dev/demo/assets/char/"

local function C(r,g,b) return Color{r=r,g=g,b=b} end
local SKIN    = C(242,201,160)
local SKIN_SH = C(217,168,124)
local EYE     = C(34,34,34)
local MOUTH   = C(180,100,100)
local BELT    = C(40,30,20)

local function px(img, x, y, c)
  if x >= 0 and x < img.width and y >= 0 and y < img.height then
    img:drawPixel(x, y, c)
  end
end
local function rect(img, x0,y0,x1,y1,c)
  for y=y0,y1 do for x=x0,x1 do px(img,x,y,c) end end
end
local function circ(img, cx, cy, r, c)
  for y=cy-r,cy+r do for x=cx-r,cx+r do
    local dx,dy = x-cx,y-cy
    if dx*dx+dy*dy<=r*r then px(img,x,y,c) end
  end end
end

-- 调色板
local function makePalette(o)
  return {
    hair=o.hair, hair_sh=o.hair_sh,
    shirt=o.shirt, shirt_sh=o.shirt_sh,
    pants=o.pants, pants_sh=o.pants_sh,
    boot=o.boot, boot_sh=o.boot_sh,
    hat=o.hat, hat_sh=o.hat_sh,
    skin=SKIN, skin_sh=SKIN_SH,
    dress=o.dress, long_hair=o.long_hair,
    beard=o.beard, child=o.child,
    hat_style=o.hat_style,
  }
end

-- 正面上半身 (身体+腿), 复用
local function drawBodyFront(img, p, yOff, legPhase)
  local top = p.child and 13 or 12
  local bot = p.child and 20 or 21
  local legTop = p.child and 22 or 22
  local legBot = p.child and 26 or 27
  local footY  = p.child and 27 or 28

  -- 腿 (正面两条)
  local lOff = 0; local rOff = 0
  if legPhase == 0 then lOff = -1; rOff = 1
  elseif legPhase == 1 then lOff = 0; rOff = 0
  elseif legPhase == 2 then lOff = 1; rOff = -1
  end
  for y = legTop, legBot do
    px(img, 6 + lOff, y + yOff, p.pants_sh)
    px(img, 9 + rOff, y + yOff, p.pants)
  end
  for x = 5 + lOff, 7 + lOff do px(img, x, footY + yOff, p.boot_sh) end
  for x = 8 + rOff, 10 + rOff do px(img, x, footY + yOff, p.boot) end

  -- 裙摆 (dress)
  if p.dress then
    for y = top, bot + 1 do
      local w = 1 + math.floor((y - top) / 3)
      for x = 4 - w, 12 + w do px(img, x, y + yOff, p.shirt) end
      px(img, 11 + w, y + yOff, p.shirt_sh)
    end
  else
    -- 躯干
    for y = top, bot do
      for x = 5, 11 do px(img, x, y + yOff, p.shirt) end
    end
    for y = top, bot do
      px(img, 11, y + yOff, p.shirt_sh)
    end
    for x = 5, 11 do px(img, x, bot + yOff, BELT) end
  end

  -- 手臂 (正面两只对称)
  for y = top + 1, top + 4 do
    px(img, 4, y + yOff, p.shirt_sh)
    px(img, 12, y + yOff, p.shirt)
  end
  px(img, 4, top + 5 + yOff, p.skin_sh)
  px(img, 12, top + 5 + yOff, p.skin)
end

-- 侧面身体 (已有逻辑)
local function drawBodySide(img, p, yOff, legPhase)
  local top = p.child and 13 or 12
  local bot = p.child and 20 or 21
  local legTop = 22
  local legBot = p.child and 26 or 27
  local footY  = p.child and 27 or 28

  local lOff = 0; local rOff = 0
  if legPhase == 0 then lOff = -1; rOff = 1
  elseif legPhase == 2 then lOff = 1; rOff = -1
  end
  for y = legTop, legBot do
    px(img, 6 + lOff, y + yOff, p.pants_sh)
    px(img, 9 + rOff, y + yOff, p.pants)
  end
  for x = 5 + lOff, 7 + lOff do px(img, x, footY + yOff, p.boot_sh) end
  for x = 8 + rOff, 10 + rOff do px(img, x, footY + yOff, p.boot) end

  if p.dress then
    for y = top, bot + 1 do
      local w = 1 + math.floor((y - top) / 3)
      for x = 4 - w, 12 + w do px(img, x, y + yOff, p.shirt) end
      px(img, 11 + w, y + yOff, p.shirt_sh)
    end
  else
    for y = top, bot do for x = 5, 11 do px(img, x, y + yOff, p.shirt) end end
    for y = top, bot do px(img, 11, y + yOff, p.shirt_sh) end
    for x = 5, 11 do px(img, x, bot + yOff, BELT) end
  end

  -- 侧面手臂: 后侧 + 前侧
  for y = top + 1, top + 4 do
    px(img, 4, y + yOff, p.shirt_sh)
  end
  px(img, 4, top + 5 + yOff, p.skin_sh)
  for y = top + 1, top + 3 do
    px(img, 12, y + yOff, p.shirt)
  end
  px(img, 12, top + 4 + yOff, p.skin)
end

-- 正面头 (朝下, 能看到两只眼)
local function drawHeadDown(img, p, yOff)
  local hy = (p.child and 8 or 7) + yOff

  -- 脸
  circ(img, 8, hy, 4, p.skin)
  -- 下巴阴影
  for x = 5, 11 do px(img, x, hy + 4, p.skin_sh) end
  -- 头发 (额前刘海 + 两侧)
  for x = 4, 12 do
    for y = hy - 4, hy - 1 do
      local dx,dy = x-8, y-hy
      if dx*dx+dy*dy <= 16 then px(img, x, y, p.hair) end
    end
  end
  -- 两侧鬓角
  for y = hy - 1, hy + 2 do
    px(img, 4, y, p.hair)
    px(img, 5, y, p.hair_sh)
    px(img, 11, y, p.hair)
    px(img, 12, y, p.hair)
  end
  -- 长发披到肩
  if p.long_hair then
    for y = hy + 3, hy + 8 do
      px(img, 4, y, p.hair)
      px(img, 5, y, p.hair_sh)
      px(img, 11, y, p.hair)
      px(img, 12, y, p.hair)
    end
  end
  -- 两只眼
  px(img, 6, hy + 1, EYE)
  px(img, 10, hy + 1, EYE)
  -- 鼻子
  px(img, 8, hy + 2, p.skin_sh)
  -- 嘴
  px(img, 8, hy + 3, MOUTH)
  -- 胡子
  if p.beard then
    for x = 6, 10 do px(img, x, hy + 3, p.hair) end
    for x = 7, 9 do px(img, x, hy + 4, p.hair) end
  end

  -- 帽子 (草帽: 帽檐大椭圆, 帽顶小)
  if p.hat_style == 'straw' then
    for x = 1, 15 do px(img, x, hy - 5, p.hat) end
    for x = 1, 15 do px(img, x, hy - 4, p.hat_sh) end
    for x = 4, 12 do px(img, x, hy - 7, p.hat) end
    for x = 4, 12 do px(img, x, hy - 6, p.hat_sh) end
  elseif p.hat_style == 'round' then
    circ(img, 8, hy - 5, 3, p.hat)
    for x = 3, 13 do px(img, x, hy - 3, p.hat_sh) end
  elseif p.hat_style == 'hood' then
    for x = 3, 13 do
      for y = hy - 5, hy + 2 do
        local dx,dy = x-8, y-hy
        if dx*dx+dy*dy <= 25 and y <= hy - 1 then
          px(img, x, y, p.hat)
        end
      end
    end
    for x = 4, 6 do px(img, x, hy - 4, p.hat_sh) end
  end
end

-- 背面头 (朝上, 只能看到帽子+后脑勺)
local function drawHeadUp(img, p, yOff)
  local hy = (p.child and 8 or 7) + yOff

  -- 后脑勺 (一大片头发)
  circ(img, 8, hy, 4, p.hair)
  for x = 4, 12 do
    for y = hy, hy + 3 do
      px(img, x, y, p.hair_sh)
    end
  end
  -- 后脑勺整体暗
  for x = 5, 11 do
    for y = hy - 2, hy + 3 do
      px(img, x, y, p.hair)
    end
  end
  -- 长发
  if p.long_hair then
    for y = hy + 2, hy + 8 do
      for x = 4, 12 do px(img, x, y, p.hair) end
    end
  end
  -- 耳朵
  px(img, 3, hy + 1, p.skin)
  px(img, 13, hy + 1, p.skin)

  -- 帽子 (背面看: 帽顶+帽檐)
  if p.hat_style == 'straw' then
    for x = 1, 15 do px(img, x, hy - 5, p.hat) end
    for x = 1, 15 do px(img, x, hy - 4, p.hat_sh) end
    for x = 4, 12 do px(img, x, hy - 7, p.hat) end
    for x = 4, 12 do px(img, x, hy - 6, p.hat_sh) end
  elseif p.hat_style == 'round' then
    circ(img, 8, hy - 5, 3, p.hat)
    for x = 3, 13 do px(img, x, hy - 3, p.hat_sh) end
  elseif p.hat_style == 'hood' then
    for x = 3, 13 do
      for y = hy - 5, hy + 3 do
        local dx,dy = x-8, y-hy
        if dx*dx+dy*dy <= 25 then
          px(img, x, y, p.hat)
        end
      end
    end
    for x = 4, 6 do px(img, x, hy - 4, p.hat_sh) end
  end
end

-- 侧面头 (朝右, 复用之前的逻辑)
local function drawHeadSide(img, p, yOff)
  local hy = (p.child and 8 or 7) + yOff
  local r  = p.child and 4 or 4

  circ(img, 8, hy, r, p.skin)
  for y = hy, hy+4 do
    for x = 8, 12 do
      local dx,dy = x-8, y-hy
      if dx*dx+dy*dy<=r*r and (x+y)>(16+hy) then
        px(img, x, y, p.skin_sh)
      end
    end
  end
  -- 后脑头发
  for y = hy-4, hy-1 do
    for x = 4, 12 do
      local dx,dy = x-8, y-hy
      if dx*dx+dy*dy<=r*r then px(img, x, y, p.hair) end
    end
  end
  for y = hy-1, hy+3 do
    px(img, 4, y, p.hair)
    px(img, 5, y, p.hair)
  end
  px(img, 4, hy+2, p.hair_sh)
  px(img, 4, hy+3, p.hair_sh)
  if p.long_hair then
    for y = hy+3, hy+8 do
      px(img, 4, y, p.hair)
      px(img, 5, y, p.hair_sh)
    end
  end
  -- 单眼
  px(img, 11, hy, EYE)
  px(img, 11, hy+1, EYE)
  -- 鼻子突出
  px(img, 13, hy+1, p.skin)
  px(img, 13, hy+2, p.skin_sh)
  -- 嘴
  px(img, 11, hy+3, MOUTH)
  -- 胡子侧面
  if p.beard then
    for x = 8, 12 do px(img, x, hy+3, p.hair) end
    for x = 8, 11 do px(img, x, hy+4, p.hair) end
  end

  -- 帽子
  if p.hat_style == 'straw' then
    for x = 2, 14 do px(img, x, hy-5, p.hat) end
    for x = 2, 14 do px(img, x, hy-4, p.hat_sh) end
    for x = 4, 12 do px(img, x, hy-7, p.hat) end
    for x = 4, 12 do px(img, x, hy-6, p.hat_sh) end
  elseif p.hat_style == 'round' then
    circ(img, 8, hy-5, 3, p.hat)
    for x = 3, 13 do px(img, x, hy-3, p.hat_sh) end
  elseif p.hat_style == 'hood' then
    for x = 3, 13 do
      for y = hy-5, hy+1 do
        local dx,dy = x-8, y-hy
        if dx*dx+dy*dy <= 25 and y <= hy-1 then
          px(img, x, y, p.hat)
        end
      end
    end
    for x = 4, 6 do px(img, x, hy-4, p.hat_sh) end
  end
end

local function makeFrame(path, dir, p, bob, legPhase)
  local s = Sprite(16, 32)
  local lay = s:newLayer()
  local img = s:newCel(lay, 1).image
  local yOff = bob
  if dir == 'down' then
    drawBodyFront(img, p, yOff, legPhase)
    drawHeadDown(img, p, yOff)
  elseif dir == 'up' then
    drawBodyFront(img, p, yOff, legPhase)
    drawHeadUp(img, p, yOff)
  else
    drawBodySide(img, p, yOff, legPhase)
    drawHeadSide(img, p, yOff)
  end
  s:saveCopyAs(path)
end

local function genChar(name, o)
  local p = makePalette(o)
  os.execute('mkdir -p "' .. OUT .. name .. '/down/idle" "' .. OUT .. name .. '/down/walk"')
  os.execute('mkdir -p "' .. OUT .. name .. '/up/idle"   "' .. OUT .. name .. '/up/walk"')
  os.execute('mkdir -p "' .. OUT .. name .. '/side/idle" "' .. OUT .. name .. '/side/walk"')

  for _, dir in ipairs({'down','up','side'}) do
    local base = OUT .. name .. '/' .. dir .. '/'
    -- idle: 2 帧 bob
    makeFrame(base .. 'idle/frame_0.png', dir, p, 0, 1)
    makeFrame(base .. 'idle/frame_1.png', dir, p, 1, 1)
    -- walk: 4 帧
    makeFrame(base .. 'walk/frame_0.png', dir, p, 1, 0)
    makeFrame(base .. 'walk/frame_1.png', dir, p, 0, 1)
    makeFrame(base .. 'walk/frame_2.png', dir, p, 1, 2)
    makeFrame(base .. 'walk/frame_3.png', dir, p, 0, 1)
  end
  print("DONE: " .. name)
end

-- ===== 5 个角色 =====

genChar("villager", {
  hair = C(122,74,40), hair_sh = C(74,40,16),
  shirt = C(74,138,58), shirt_sh = C(42,90,42),
  pants = C(74,74,106), pants_sh = C(48,48,74),
  boot = C(58,32,16), boot_sh = C(26,10,0),
  hat = C(212,184,90), hat_sh = C(168,138,58),
  hat_style = 'straw',
})

genChar("girl", {
  hair = C(120,60,40), hair_sh = C(70,30,20),
  shirt = C(230,140,180), shirt_sh = C(180,90,130),
  pants = C(230,140,180), pants_sh = C(180,90,130),
  boot = C(120,70,50), boot_sh = C(70,35,20),
  hat = C(240,240,240), hat_sh = C(190,190,190),
  dress = true, long_hair = true, hat_style = 'none',
})

genChar("elder", {
  hair = C(180,180,180), hair_sh = C(130,130,130),
  shirt = C(90,60,40), shirt_sh = C(60,35,20),
  pants = C(90,60,40), pants_sh = C(60,35,20),
  boot = C(50,30,20), boot_sh = C(25,12,8),
  hat = C(70,50,30), hat_sh = C(45,30,18),
  beard = true, hat_style = 'hood',
})

genChar("merchant", {
  hair = C(60,40,30), hair_sh = C(30,20,15),
  shirt = C(50,110,180), shirt_sh = C(30,75,130),
  pants = C(80,60,40), pants_sh = C(55,40,25),
  boot = C(50,30,20), boot_sh = C(25,12,8),
  hat = C(90,50,40), hat_sh = C(60,30,20),
  hat_style = 'round', beard = true,
})

genChar("child", {
  hair = C(200,160,60), hair_sh = C(140,110,40),
  shirt = C(240,150,50), shirt_sh = C(180,100,30),
  pants = C(80,80,120), pants_sh = C(55,55,85),
  boot = C(70,45,30), boot_sh = C(35,20,12),
  hat = C(0,0,0), hat_sh = C(0,0,0),
  hat_style = 'none', child = true,
})

print("ALL DONE: 5 chars x 3 dirs x 6 frames = 90 png")
