
-- 相对路径：请在仓库根目录（pixel-farm/）运行本脚本
local out = "demo/assets/sv/"

local function C(r,g,b) return Color{r=r,g=g,b=b,a=255} end
local TRUNK    = C(90,55,30)
local TRUNK_SH = C(60,35,18)
local LEAF1    = C(60,140,60)
local LEAF1_SH = C(40,105,45)
local LEAF1_HL = C(90,175,85)
local LEAF2    = C(48,120,52)
local ROCK     = C(140,140,150)
local ROCK_SH  = C(95,95,105)
local ROCK_HL  = C(175,175,185)
local DIRT     = C(110,80,50)
local DIRT_SH  = C(80,55,35)
local FLOWER_R = C(230,80,80)
local STEM     = C(60,130,60)

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
    local dx,dy = x-cx, y-cy
    if dx*dx+dy*dy <= r*r then px(img,x,y,c) end
  end end
end

-- tree: 32x48, 锚点底部中心 (16, 48)
do
  local s = Sprite(32, 48)
  local lay = s:newLayer()
  local img = s:newCel(lay, 1).image

  -- 影子
  for y = 44, 47 do
    for x = 4, 27 do
      local dx, dy = x - 16, (y - 46) * 2
      if dx*dx + dy*dy <= 144 then
        img:drawPixel(x, y, Color{r=30,g=40,b=30,a=90})
      end
    end
  end

  -- 树干
  rect(img, 13, 28, 18, 45, TRUNK)
  rect(img, 17, 28, 18, 45, TRUNK_SH)
  px(img, 13, 45, TRUNK_SH)
  px(img, 18, 45, TRUNK_SH)

  -- 树冠 (三层圆形堆叠)
  circ(img, 16, 18, 13, LEAF1_SH)
  circ(img, 16, 16, 12, LEAF1)
  circ(img, 12, 14, 6, LEAF1_HL)
  circ(img, 22, 20, 7, LEAF1_SH)
  circ(img, 16, 10, 6, LEAF1)
  circ(img, 13, 9, 3, LEAF1_HL)

  s:saveCopyAs(out .. "tree.png")
end

-- bush: 24x16, 锚点底部中心
do
  local s = Sprite(24, 16)
  local lay = s:newLayer()
  local img = s:newCel(lay, 1).image
  for y = 13, 15 do
    for x = 2, 21 do
      local dx, dy = x - 12, (y - 14) * 3
      if dx*dx + dy*dy <= 100 then
        img:drawPixel(x, y, Color{r=30,g=40,b=30,a=80})
      end
    end
  end
  circ(img, 12, 9, 7, LEAF1_SH)
  circ(img, 12, 8, 6, LEAF1)
  circ(img, 8, 6, 3, LEAF1_HL)
  circ(img, 16, 9, 3, LEAF1_HL)
  px(img, 10, 8, FLOWER_R)
  px(img, 14, 6, FLOWER_R)
  s:saveCopyAs(out .. "bush.png")
end

-- rock: 16x12, 锚点底部中心
do
  local s = Sprite(16, 12)
  local lay = s:newLayer()
  local img = s:newCel(lay, 1).image
  for y = 9, 11 do
    for x = 1, 14 do
      local dx, dy = x - 8, (y - 10) * 3
      if dx*dx + dy*dy <= 49 then
        img:drawPixel(x, y, Color{r=30,g=30,b=30,a=80})
      end
    end
  end
  for y = 3, 9 do
    for x = 2, 13 do
      local dx, dy = x - 8, y - 6
      if dx*dx*1.5 + dy*dy <= 20 then
        img:drawPixel(x, y, ROCK)
      end
    end
  end
  for y = 5, 9 do
    for x = 9, 13 do
      local dx, dy = x - 8, y - 6
      if dx*dx*1.5 + dy*dy <= 20 then
        img:drawPixel(x, y, ROCK_SH)
      end
    end
  end
  px(img, 6, 4, ROCK_HL)
  px(img, 7, 4, ROCK_HL)
  px(img, 6, 5, ROCK_HL)
  s:saveCopyAs(out .. "rock.png")
end

-- flowerbed: 32x20, 锚点底部中心
do
  local s = Sprite(32, 20)
  local lay = s:newLayer()
  local img = s:newCel(lay, 1).image
  -- 土
  for y = 12, 19 do
    for x = 2, 29 do
      img:drawPixel(x, y, DIRT)
    end
  end
  for x = 2, 29 do
    img:drawPixel(x, 19, DIRT_SH)
  end
  -- 草沿
  for x = 2, 29 do
    img:drawPixel(x, 11, LEAF1)
  end
  -- 花
  for i = 0, 5 do
    local cx = 5 + i * 4
    rect(img, cx, 7, cx, 10, STEM)
    px(img, cx, 6, FLOWER_R)
    px(img, cx-1, 6, FLOWER_R)
    px(img, cx+1, 6, FLOWER_R)
    px(img, cx, 5, C(250,220,80))
  end
  s:saveCopyAs(out .. "flowerbed.png")
end

print("DONE: tree/bush/rock/flowerbed")
