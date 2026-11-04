
-- 相对路径：请在仓库根目录（pixel-farm/）运行本脚本
local OUT = "demo/assets/char/"

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

-- 通用绘制: opts 控制头发/衣服/帽子/裙子/胡子/矮
local function drawAll(img, dy, lx, rx, o)
  local hair    = o.hair
  local hair_sh = o.hair_sh
  local shirt   = o.shirt
  local shirt_sh= o.shirt_sh
  local pants   = o.pants
  local pants_sh= o.pants_sh
  local boot    = o.boot
  local boot_sh = o.boot_sh
  local hat     = o.hat
  local hat_sh  = o.hat_sh
  local skin    = SKIN
  local skin_sh = SKIN_SH
  local child   = o.child or false
  local dress   = o.dress or false
  local beard   = o.beard or false
  local long_hair = o.long_hair or false
  local hat_style = o.hat_style or 'straw'  -- straw / round / hood / none

  -- 腿长: 小孩短 4px
  local legTop = child and 24 or 22
  local legBot = child and 27 or 27
  local footY  = child and 28 or 28

  -- ===== 腿 =====
  for y = legTop, legBot do
    px(img, 6 + lx, y + dy, pants_sh)
    px(img, 9 + rx, y + dy, pants)
  end
  for x = 5 + lx, 7 + lx do px(img, x, footY + dy, boot_sh) end
  for x = 8 + rx, 10 + rx do px(img, x, footY + dy, boot) end

  -- ===== 裙摆 (dress 模式) =====
  local bodyTop = child and 14 or 12
  local bodyBot = child and 20 or 21
  if dress then
    -- 裙子: 覆盖到大腿上半, 梯形
    for y = bodyTop, bodyBot + 1 do
      local wide = 1 + math.floor((y - bodyTop) / 3)
      for x = 4 - wide, 12 + wide do
        px(img, x, y + dy, shirt)
      end
    end
    for y = bodyTop, bodyBot + 1 do
      local wide = 1 + math.floor((y - bodyTop) / 3)
      px(img, 11 + wide, y + dy, shirt_sh)
    end
  else
    -- 普通上衣
    for y = bodyTop, bodyBot do
      for x = 5, 11 do
        px(img, x, y + dy, shirt)
      end
    end
    for y = bodyTop, bodyBot do
      px(img, 10, y + dy, shirt_sh)
      px(img, 11, y + dy, shirt_sh)
    end
    -- 腰带
    for x = 5, 11 do px(img, x, bodyBot + dy, BELT) end
  end

  -- ===== 手臂 =====
  px(img, 4, bodyTop + 1 + dy, shirt_sh)
  px(img, 4, bodyTop + 2 + dy, shirt_sh)
  px(img, 4, bodyTop + 3 + dy, shirt_sh)
  px(img, 4, bodyTop + 4 + dy, skin_sh)
  px(img, 12, bodyTop + 1 + dy, shirt)
  px(img, 12, bodyTop + 2 + dy, shirt)
  px(img, 12, bodyTop + 3 + dy, skin)

  -- ===== 头 =====
  local headCY = child and 8 or 7
  local headR  = child and 4.5 or 4
  -- 脸
  for y = headCY - 4, headCY + 4 do
    for x = 4, 12 do
      local dx, dy2 = x - 8, y - headCY
      if dx*dx + dy2*dy2 <= headR * headR then
        px(img, x, y + dy, skin)
      end
    end
  end
  -- 右下阴影
  for y = headCY, headCY + 4 do
    for x = 8, 12 do
      local dx, dy2 = x - 8, y - headCY
      if dx*dx + dy2*dy2 <= headR*headR and (x + y) > (16 + headCY) then
        px(img, x, y + dy, skin_sh)
      end
    end
  end
  -- 头发 (上部盖)
  for y = headCY - 4, headCY - 1 do
    for x = 4, 12 do
      local dx, dy2 = x - 8, y - headCY
      if dx*dx + dy2*dy2 <= headR * headR then
        px(img, x, y + dy, hair)
      end
    end
  end
  -- 后脑鬓角
  for y = headCY - 1, headCY + 3 do
    px(img, 4, y + dy, hair)
    px(img, 5, y + dy, hair)
  end
  px(img, 4, headCY + 2 + dy, hair_sh)
  px(img, 4, headCY + 3 + dy, hair_sh)
  -- 长发 (女孩)
  if long_hair then
    for y = headCY + 3, bodyTop + 1 do
      px(img, 4, y + dy, hair)
      px(img, 5, y + dy, hair_sh)
      px(img, 6, y + dy, hair)
    end
  end

  -- 眼睛 + 鼻 + 嘴
  px(img, 11, headCY + dy, EYE)
  px(img, 11, headCY + 1 + dy, EYE)
  px(img, 13, headCY + 1 + dy, skin)
  px(img, 13, headCY + 2 + dy, skin_sh)
  px(img, 11, headCY + 3 + dy, MOUTH)

  -- 胡子 (老人)
  if beard then
    for x = 8, 12 do px(img, x, headCY + 3 + dy, hair) end
    for x = 8, 11 do px(img, x, headCY + 4 + dy, hair) end
    px(img, 8, headCY + 2 + dy, hair)
    px(img, 9, headCY + 2 + dy, hair)
  end

  -- ===== 帽子 =====
  if hat_style == 'straw' then
    for x = 2, 14 do
      px(img, x, headCY - 5 + dy, hat)
      px(img, x, headCY - 4 + dy, hat_sh)
    end
    for x = 4, 12 do
      px(img, x, headCY - 7 + dy, hat)
      px(img, x, headCY - 6 + dy, hat_sh)
    end
  elseif hat_style == 'round' then
    -- 圆顶帽 (商人)
    for y = headCY - 7, headCY - 4 do
      for x = 5, 11 do
        local dx = x - 8
        if math.abs(dx) <= (y - (headCY - 7)) + 1 then
          px(img, x, y + dy, hat)
        end
      end
    end
    -- 帽檐
    for x = 3, 13 do
      px(img, x, headCY - 4 + dy, hat_sh)
    end
  elseif hat_style == 'hood' then
    -- 兜帽 (老人)
    for y = headCY - 5, headCY + 1 do
      for x = 3, 13 do
        local dx, dy2 = x - 8, y - headCY
        if dx*dx + dy2*dy2 <= (headR+1) * (headR+1) and y <= headCY - 1 then
          px(img, x, y + dy, hat)
        end
      end
    end
    for x = 4, 6 do
      px(img, x, headCY - 4 + dy, hat_sh)
    end
  end
end

local function makeFrame(path, dy, lx, rx, o)
  local s = Sprite(16, 32)
  local lay = s:newLayer()
  local img = s:newCel(lay, 1).image
  drawAll(img, dy, lx, rx, o)
  s:saveCopyAs(path)
end

local function genChar(name, o)
  local base = OUT .. name .. "/"
  os.execute('mkdir -p "' .. base .. 'idle" "' .. base .. 'walk" "' .. base .. 'jump"')
  -- idle
  makeFrame(base .. "idle/frame_0.png", 0, 0, 0, o)
  makeFrame(base .. "idle/frame_1.png", 1, 0, 0, o)
  -- walk
  makeFrame(base .. "walk/frame_0.png", 1, -1, 1, o)
  makeFrame(base .. "walk/frame_1.png", 0, 0, 0, o)
  makeFrame(base .. "walk/frame_2.png", 1, 1, -1, o)
  makeFrame(base .. "walk/frame_3.png", 0, 0, 0, o)
  -- jump
  makeFrame(base .. "jump/frame_0.png", 1, 0, 0, o)
  makeFrame(base .. "jump/frame_1.png", 0, -1, 1, o)
  makeFrame(base .. "jump/frame_2.png", 1, 0, 0, o)
  print("DONE: " .. name)
end

-- ===== 4 个新角色 =====

-- 1) 村姑: 长发 + 粉色连衣裙
genChar("girl", {
  hair = C(120,60,40), hair_sh = C(70,30,20),
  shirt = C(230,140,180), shirt_sh = C(180,90,130),
  pants = C(230,140,180), pants_sh = C(180,90,130),
  boot = C(120,70,50), boot_sh = C(70,35,20),
  hat = C(240,240,240), hat_sh = C(190,190,190),
  dress = true, long_hair = true, hat_style = 'none',
})

-- 2) 老人: 灰发 + 白胡子 + 棕袍 + 兜帽
genChar("elder", {
  hair = C(180,180,180), hair_sh = C(130,130,130),
  shirt = C(90,60,40), shirt_sh = C(60,35,20),
  pants = C(90,60,40), pants_sh = C(60,35,20),
  boot = C(50,30,20), boot_sh = C(25,12,8),
  hat = C(70,50,30), hat_sh = C(45,30,18),
  beard = true, hat_style = 'hood',
})

-- 3) 商人: 蓝衣 + 圆顶帽 + 小胡子
genChar("merchant", {
  hair = C(60,40,30), hair_sh = C(30,20,15),
  shirt = C(50,110,180), shirt_sh = C(30,75,130),
  pants = C(80,60,40), pants_sh = C(55,40,25),
  boot = C(50,30,20), boot_sh = C(25,12,8),
  hat = C(90,50,40), hat_sh = C(60,30,20),
  hat_style = 'round', beard = true,
})

-- 4) 小孩: 矮一截 + 橙色上衣
genChar("child", {
  hair = C(200,160,60), hair_sh = C(140,110,40),
  shirt = C(240,150,50), shirt_sh = C(180,100,30),
  pants = C(80,80,120), pants_sh = C(55,55,85),
  boot = C(70,45,30), boot_sh = C(35,20,12),
  hat = C(0,0,0), hat_sh = C(0,0,0),
  hat_style = 'none', child = true,
})

print("ALL DONE")
