-- 攻撃动作帧生成 (aseprite 批处理)
-- 相对路径: 请在仓库根目录 (pixel-farm/) 运行
-- 用法: aseprite -b --script tools/art/gen_attack.lua
-- 只写 <角色>/<方向>/attack/ 下的帧, 不覆盖已有 idle/walk
local OUT = "demo/assets/char/"

local function C(r,g,b) return Color{r=r,g=g,b=b} end
local SKIN    = C(242,201,160)
local SKIN_SH = C(217,168,124)
local EYE     = C(34,34,34)
local MOUTH   = C(180,100,100)
local BELT    = C(40,30,20)
-- 工具 (锄头/草叉): 木柄 + 铁头
local WOOD    = C(120,80,40)
local WOOD_SH = C(78,50,24)
local STEEL   = C(205,210,220)
local STEEL_SH= C(150,155,165)

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

local function drawBodyFront(img, p, yOff)
  local top = p.child and 13 or 12
  local bot = p.child and 20 or 21
  local legTop = 22
  local legBot = p.child and 26 or 27
  local footY = p.child and 27 or 28

  for y = legTop, legBot do
    px(img, 6, y + yOff, p.pants_sh)
    px(img, 9, y + yOff, p.pants)
  end
  for x = 5, 7 do px(img, x, footY + yOff, p.boot_sh) end
  for x = 8, 10 do px(img, x, footY + yOff, p.boot) end

  if p.dress then
    for y = top, bot + 1 do
      local w = 1 + math.floor((y - top) / 3)
      for x = 4 - w, 12 + w do px(img, x, y + yOff, p.shirt) end
      px(img, 11 + w, y + yOff, p.shirt_sh)
    end
  else
    for y = top, bot do
      for x = 5, 11 do px(img, x, y + yOff, p.shirt) end
    end
    for y = top, bot do px(img, 11, y + yOff, p.shirt_sh) end
    for x = 5, 11 do px(img, x, bot + yOff, BELT) end
  end
end

local function drawBodySide(img, p, yOff)
  local top = p.child and 13 or 12
  local bot = p.child and 20 or 21
  local footY = p.child and 27 or 28

  for y = 22, p.child and 26 or 27 do
    px(img, 6, y + yOff, p.pants_sh)
    px(img, 9, y + yOff, p.pants)
  end
  for x = 5, 7 do px(img, x, footY + yOff, p.boot_sh) end
  for x = 8, 10 do px(img, x, footY + yOff, p.boot) end

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
end

local function drawHeadDown(img, p, yOff)
  local hy = (p.child and 8 or 7) + yOff
  circ(img, 8, hy, 4, p.skin)
  for x = 5, 11 do px(img, x, hy + 4, p.skin_sh) end
  for x = 4, 12 do
    for y = hy - 4, hy - 1 do
      local dx,dy = x-8, y-hy
      if dx*dx+dy*dy <= 16 then px(img, x, y, p.hair) end
    end
  end
  for y = hy - 1, hy + 2 do
    px(img, 4, y, p.hair); px(img, 5, y, p.hair_sh)
    px(img, 11, y, p.hair); px(img, 12, y, p.hair)
  end
  if p.long_hair then
    for y = hy + 3, hy + 8 do
      px(img, 4, y, p.hair); px(img, 5, y, p.hair_sh)
      px(img, 11, y, p.hair); px(img, 12, y, p.hair)
    end
  end
  px(img, 6, hy + 1, EYE); px(img, 10, hy + 1, EYE)
  px(img, 8, hy + 2, p.skin_sh)
  px(img, 8, hy + 3, MOUTH)
  if p.beard then
    for x = 6, 10 do px(img, x, hy + 3, p.hair) end
    for x = 7, 9 do px(img, x, hy + 4, p.hair) end
  end
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
        if dx*dx+dy*dy <= 25 and y <= hy - 1 then px(img, x, y, p.hat) end
      end
    end
    for x = 4, 6 do px(img, x, hy - 4, p.hat_sh) end
  elseif p.hat_style == 'ears' then
    for x = 4, 6 do px(img, x, hy - 5, p.hat) end
    px(img, 5, hy - 6, p.hat); px(img, 5, hy - 5, p.hat_sh)
    for x = 10, 12 do px(img, x, hy - 5, p.hat) end
    px(img, 11, hy - 6, p.hat); px(img, 11, hy - 5, p.hat_sh)
  end
end

local function drawHeadUp(img, p, yOff)
  local hy = (p.child and 8 or 7) + yOff
  circ(img, 8, hy, 4, p.hair)
  for x = 4, 12 do for y = hy, hy + 3 do px(img, x, y, p.hair_sh) end end
  for x = 5, 11 do for y = hy - 2, hy + 3 do px(img, x, y, p.hair) end end
  if p.long_hair then
    for y = hy + 2, hy + 8 do for x = 4, 12 do px(img, x, y, p.hair) end end
  end
  px(img, 3, hy + 1, p.skin)
  px(img, 13, hy + 1, p.skin)
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
        if dx*dx+dy*dy <= 25 then px(img, x, y, p.hat) end
      end
    end
    for x = 4, 6 do px(img, x, hy - 4, p.hat_sh) end
  elseif p.hat_style == 'ears' then
    for x = 4, 6 do px(img, x, hy - 5, p.hat) end
    px(img, 5, hy - 6, p.hat_sh)
    for x = 10, 12 do px(img, x, hy - 5, p.hat) end
    px(img, 11, hy - 6, p.hat_sh)
  end
end

local function drawHeadSide(img, p, yOff)
  local hy = (p.child and 8 or 7) + yOff
  circ(img, 8, hy, 4, p.skin)
  for y = hy, hy+4 do
    for x = 8, 12 do
      local dx,dy = x-8, y-hy
      if dx*dx+dy*dy<=16 and (x+y)>(16+hy) then px(img, x, y, p.skin_sh) end
    end
  end
  for y = hy-4, hy-1 do
    for x = 4, 12 do
      local dx,dy = x-8, y-hy
      if dx*dx+dy*dy<=16 then px(img, x, y, p.hair) end
    end
  end
  for y = hy-1, hy+3 do px(img, 4, y, p.hair); px(img, 5, y, p.hair) end
  px(img, 4, hy+2, p.hair_sh); px(img, 4, hy+3, p.hair_sh)
  if p.long_hair then
    for y = hy+3, hy+8 do px(img, 4, y, p.hair); px(img, 5, y, p.hair_sh) end
  end
  px(img, 11, hy, EYE); px(img, 11, hy+1, EYE)
  px(img, 13, hy+1, p.skin); px(img, 13, hy+2, p.skin_sh)
  px(img, 11, hy+3, MOUTH)
  if p.beard then
    for x = 8, 12 do px(img, x, hy+3, p.hair) end
    for x = 8, 11 do px(img, x, hy+4, p.hair) end
  end
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
        if dx*dx+dy*dy <= 25 and y <= hy-1 then px(img, x, y, p.hat) end
      end
    end
    for x = 4, 6 do px(img, x, hy-4, p.hat_sh) end
  elseif p.hat_style == 'ears' then
    px(img, 6, hy - 6, p.hat); px(img, 7, hy - 6, p.hat); px(img, 7, hy - 5, p.hat_sh)
  end
end

-- 举起的工具: 木柄 + 铁头, phase 0 蓄力 (竖直), 1 挥出 (前伸)
local function drawTool(img, p, dir, phase)
  local top = p.child and 13 or 12
  if dir == 'down' then
    if phase == 0 then
      -- 蓄力: 柄竖在右侧, 铁头在上
      for y = top - 3, top + 5 do px(img, 14, y, WOOD) end
      px(img, 14, top - 4, STEEL); px(img, 13, top - 4, STEEL_SH); px(img, 15, top - 4, STEEL_SH)
      px(img, 13, top + 6, SKIN); px(img, 14, top + 6, SKIN)
    else
      -- 挥出: 前臂下压, 铁头朝前下方
      for x = 12, 15 do px(img, x, top + 2, WOOD) end
      px(img, 13, top + 3, STEEL); px(img, 14, top + 3, STEEL); px(img, 12, top + 3, STEEL_SH)
      px(img, 11, top + 1, SKIN); px(img, 12, top + 1, SKIN)
      -- 挥击残影
      px(img, 12, top + 5, STEEL_SH); px(img, 14, top + 5, STEEL_SH)
    end
  elseif dir == 'up' then
    if phase == 0 then
      for y = 1, top + 2 do px(img, 14, y, WOOD) end
      px(img, 14, 0, STEEL); px(img, 13, 0, STEEL_SH); px(img, 15, 0, STEEL_SH)
      px(img, 13, top + 3, SKIN); px(img, 14, top + 3, SKIN)
    else
      for y = 0, top - 1 do px(img, 15, y, WOOD) end
      px(img, 15, 0, STEEL); px(img, 14, 0, STEEL_SH); px(img, 15, 1, STEEL_SH)
      px(img, 14, top, SKIN); px(img, 15, top, SKIN)
      px(img, 13, 1, STEEL_SH)
    end
  else
    if phase == 0 then
      -- 侧面蓄力: 柄斜向后
      for y = top - 2, top + 4 do px(img, 12, y, WOOD) end
      px(img, 12, top - 3, STEEL); px(img, 11, top - 3, STEEL_SH)
      px(img, 11, top + 5, SKIN); px(img, 12, top + 5, SKIN)
    else
      -- 侧面挥出: 柄水平前伸
      for x = 12, 15 do px(img, x, top + 1, WOOD) end
      px(img, 15, top, STEEL); px(img, 15, top + 2, STEEL_SH); px(img, 14, top, STEEL)
      px(img, 11, top + 1, SKIN); px(img, 12, top + 1, SKIN)
      px(img, 15, top + 3, STEEL_SH)
    end
  end
end

local function makeAttack(path, dir, p, phase)
  local s = Sprite(16, 32)
  local lay = s:newLayer()
  local img = s:newCel(lay, 1).image
  if dir == 'down' then
    drawBodyFront(img, p, 0)
    drawHeadDown(img, p, 0)
  elseif dir == 'up' then
    drawBodyFront(img, p, 0)
    drawHeadUp(img, p, 0)
  else
    drawBodySide(img, p, 0)
    drawHeadSide(img, p, 0)
  end
  drawTool(img, p, dir, phase)
  s:saveCopyAs(path)
end

local function genAttack(name, o)
  local p = makePalette(o)
  for _, dir in ipairs({'down','up','side'}) do
    local d = OUT .. name .. '/' .. dir .. '/attack'
    os.execute('mkdir -p "' .. d .. '"')
    makeAttack(d .. '/frame_0.png', dir, p, 0)
    makeAttack(d .. '/frame_1.png', dir, p, 1)
  end
  print("ATTACK DONE: " .. name)
end

-- 5 个已有角色 (调色板必须与 gen_chars_4dir.lua 保持一致)
genAttack("villager", {
  hair = C(122,74,40), hair_sh = C(74,40,16),
  shirt = C(74,138,58), shirt_sh = C(42,90,42),
  pants = C(74,74,106), pants_sh = C(48,48,74),
  boot = C(58,32,16), boot_sh = C(26,10,0),
  hat = C(212,184,90), hat_sh = C(168,138,58),
  hat_style = 'straw',
})

genAttack("girl", {
  hair = C(120,60,40), hair_sh = C(70,30,20),
  shirt = C(230,140,180), shirt_sh = C(180,90,130),
  pants = C(230,140,180), pants_sh = C(180,90,130),
  boot = C(120,70,50), boot_sh = C(70,35,20),
  hat = C(240,240,240), hat_sh = C(190,190,190),
  dress = true, long_hair = true, hat_style = 'none',
})

genAttack("elder", {
  hair = C(180,180,180), hair_sh = C(130,130,130),
  shirt = C(90,60,40), shirt_sh = C(60,35,20),
  pants = C(90,60,40), pants_sh = C(60,35,20),
  boot = C(50,30,20), boot_sh = C(25,12,8),
  hat = C(70,50,30), hat_sh = C(45,30,18),
  beard = true, hat_style = 'hood',
})

genAttack("merchant", {
  hair = C(60,40,30), hair_sh = C(30,20,15),
  shirt = C(50,110,180), shirt_sh = C(30,75,130),
  pants = C(80,60,40), pants_sh = C(55,40,25),
  boot = C(50,30,20), boot_sh = C(25,12,8),
  hat = C(90,50,40), hat_sh = C(60,30,20),
  hat_style = 'round', beard = true,
})

genAttack("child", {
  hair = C(200,160,60), hair_sh = C(140,110,40),
  shirt = C(240,150,50), shirt_sh = C(180,100,30),
  pants = C(80,80,120), pants_sh = C(55,55,85),
  boot = C(70,45,30), boot_sh = C(35,20,12),
  hat = C(0,0,0), hat_sh = C(0,0,0),
  hat_style = 'none', child = true,
})

-- 4 个新增角色
genAttack("fisherman", {
  hair = C(80,55,35), hair_sh = C(50,32,18),
  shirt = C(60,120,150), shirt_sh = C(38,86,110),
  pants = C(60,80,90), pants_sh = C(40,55,62),
  boot = C(45,35,25), boot_sh = C(22,16,10),
  hat = C(212,184,90), hat_sh = C(168,138,58),
  beard = true, hat_style = 'straw',
})

genAttack("smith", {
  hair = C(50,40,35), hair_sh = C(28,22,18),
  shirt = C(70,62,55), shirt_sh = C(45,40,35),
  pants = C(60,45,35), pants_sh = C(38,28,22),
  boot = C(40,28,18), boot_sh = C(20,12,8),
  hat = C(55,55,60), hat_sh = C(35,35,40),
  beard = true, hat_style = 'round',
})

genAttack("hunter", {
  hair = C(90,60,30), hair_sh = C(55,35,16),
  shirt = C(70,110,60), shirt_sh = C(45,75,38),
  pants = C(80,70,40), pants_sh = C(52,45,25),
  boot = C(50,32,16), boot_sh = C(25,14,6),
  hat = C(60,90,50), hat_sh = C(38,60,32),
  hat_style = 'hood',
})

genAttack("cat", {
  hair = C(230,160,70), hair_sh = C(190,120,45),
  shirt = C(235,170,80), shirt_sh = C(190,130,50),
  pants = C(200,140,70), pants_sh = C(160,105,45),
  boot = C(120,80,50), boot_sh = C(70,45,25),
  hat = C(230,160,70), hat_sh = C(190,120,45),
  hat_style = 'ears', child = true,
})

print("ALL DONE: 9 chars x 3 dirs x 2 frames = 54 png")
