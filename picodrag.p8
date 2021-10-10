pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- game loop

function _init()
 pi = 3.14
 fps = 30
 ui = create_ui()
 car = make_car()
end

function _update()
 handle_keys()
 car_update(car)
 if btnp(5) then
  car.current_gear += 1
  car.current_rpm -= car.gears_data[car.current_gear][3]
 end
end

function _draw()
 cls()
 draw_ui(ui)
 if ui.gearbox.current_gear then
  print(ui.gearbox.current_gear[1]..":"..ui.gearbox.current_gear[2])
 else
  print("no gearbox info")
 end
 if (car.current_rpm) or (car.current_speed) then
  print(car.current_rpm.."rpm, "..car.current_speed.."kmph")
 else
  print("no rpm and speed info")
 end
end

-->8
-- creation of ui elements

function create_ui()
 local ui = {}
 ui.speedometer =
  create_speedometer(0, 88)
 ui.tachometer =
  create_tachometer(0, 104)
 ui.gearbox =
  create_gearbox(80, 108)
 return ui
end

function create_gauge(x, y, sprites)
 local gauge = {}
 gauge.x = x
 gauge.y = y
 gauge.sprites = sprites
 gauge.indicator_x1 = x
 gauge.indicator_x2 = x+1
 gauge.indicator_y1 = y-1
 gauge.indicator_y2 = y+8
 return gauge
end

function create_speedometer(x, y)
 return
  create_gauge(x, y,
   {1,1,1,1,1,1,1,1,1,1,1,2,2})
end

function create_tachometer(x, y)
 return
  create_gauge(x, y,
   {17,17,17,17,17,17,18,18})
end

function create_gearbox(x, y)
 local gearbox = {}
 -- the center of the gearbox
 gearbox.x = x
 gearbox.y = y

 gearbox.back = {}
 gearbox.back.sprites = {
  5,6,7,21,22,23,37,38,39}

 gearbox.handle = {}
 gearbox.handle.x = gearbox.x
 gearbox.handle.y = gearbox.y
 gearbox.handle.sprite = 9

 gearbox.gears = {}
 gearbox.gears.zero_middle =
  {0,0}
 gearbox.gears.zero_left =
  {-1,0}
 gearbox.gears.zero_right =
  {1,0}
 gearbox.gears.one = {-1,-1}
 gearbox.gears.two = {-1,1}
 gearbox.gears.three = {0,-1}
 gearbox.gears.four = {0,1}
 gearbox.gears.five = {1,-1}
 gearbox.gears.reverse = {1,1}

 gearbox.current_gear =
  gearbox.gears.zero_middle
 return gearbox
end
-->8
-- drawing functions

function draw_ui(ui)
 draw_gauges()
 draw_gearbox()
end

function draw_gauges()
 local xoff = 0

 for k, v in pairs(ui.speedometer.sprites) do
  local x = ui.speedometer.x + (xoff * 8)
  local y = ui.speedometer.y
  spr(v, x, y)
  xoff += 1
 end
 
 rectfill(
  ui.speedometer.indicator_x1,
  ui.speedometer.indicator_y1,
  ui.speedometer.indicator_x2,
  ui.speedometer.indicator_y2,
  10)

 xoff = 0
 for k, v in pairs(ui.tachometer.sprites) do
  local x = ui.tachometer.x + (xoff * 8)
  local y = ui.tachometer.y
  spr(v, x, y)
  xoff += 1
 end

 rectfill(
  ui.tachometer.indicator_x1,
  ui.tachometer.indicator_y1,
  ui.tachometer.indicator_x2,
  ui.tachometer.indicator_y2,
  10)
end

function draw_gearbox()
 spr(ui.gearbox.back.sprites[1],
  ui.gearbox.x-8,
  ui.gearbox.y-8)
 spr(ui.gearbox.back.sprites[2],
  ui.gearbox.x,
  ui.gearbox.y-8)
 spr(ui.gearbox.back.sprites[3],
  ui.gearbox.x+8,
  ui.gearbox.y-8)
 spr(ui.gearbox.back.sprites[4],
  ui.gearbox.x-8,
  ui.gearbox.y)
 spr(ui.gearbox.back.sprites[5],
  ui.gearbox.x,
  ui.gearbox.y)
 spr(ui.gearbox.back.sprites[6],
  ui.gearbox.x+8,
  ui.gearbox.y)
 spr(ui.gearbox.back.sprites[7],
  ui.gearbox.x-8,
  ui.gearbox.y+8)
 spr(ui.gearbox.back.sprites[8],
  ui.gearbox.x,
  ui.gearbox.y+8)
 spr(ui.gearbox.back.sprites[9],
  ui.gearbox.x+8,
  ui.gearbox.y+8)
 spr(ui.gearbox.handle.sprite,
  ui.gearbox.handle.x,
  ui.gearbox.handle.y)
end

-->8
-- handling keys

function handle_keys()
 -- left:  0
 -- right: 1
 -- up:    2
 -- down:  3
 -- 🅾️:    4
 -- ❎:    5
 local cgear = ui.gearbox.current_gear
 local ngear = nil
 local dir = {0,0}

 if btnp(0) then
  dir = {-1,0}
  if cgear ==
   ui.gearbox.gears.zero_middle then
   ngear = ui.gearbox.gears.zero_left
  elseif cgear ==
   ui.gearbox.gears.zero_right then
   ngear = ui.gearbox.gears.zero_middle
  end
 elseif btnp(1) then
  dir = {1,0}
  if cgear ==
   ui.gearbox.gears.zero_left then
   ngear = ui.gearbox.gears.zero_middle
  elseif cgear ==
   ui.gearbox.gears.zero_middle then
   ngear = ui.gearbox.gears.zero_right
  end 
 elseif btnp(2) then
  dir = {0,-1}
  if cgear ==
   ui.gearbox.gears.zero_left then
   ngear = ui.gearbox.gears.one
  elseif cgear ==
   ui.gearbox.gears.two then
   ngear = ui.gearbox.gears.zero_left
  elseif cgear ==
   ui.gearbox.gears.zero_middle then
   ngear = ui.gearbox.gears.three
  elseif cgear ==
   ui.gearbox.gears.four then
   ngear = ui.gearbox.gears.zero_middle
  elseif cgear ==
   ui.gearbox.gears.zero_right then
   ngear = ui.gearbox.gears.five
  elseif cgear ==
   ui.gearbox.gears.reverse then
   ngear = ui.gearbox.gears.zero_right
  end
 elseif btnp(3) then
  dir = {0,1}
  if cgear ==
   ui.gearbox.gears.one then
   ngear = ui.gearbox.gears.zero_left
  elseif cgear ==
   ui.gearbox.gears.zero_left then
   ngear = ui.gearbox.gears.two
  elseif cgear ==
   ui.gearbox.gears.three then
   ngear = ui.gearbox.gears.zero_middle
  elseif cgear ==
   ui.gearbox.gears.zero_middle then
   ngear = ui.gearbox.gears.four
  elseif cgear ==
   ui.gearbox.gears.five then
   ngear = ui.gearbox.gears.zero_right
  elseif cgear ==
   ui.gearbox.gears.zero_right then
   ngear = ui.gearbox.gears.reverse
  end
 end
 
 if ngear then
  ui.gearbox.current_gear = ngear
  ui.gearbox.handle.x += 8*dir[1]
  ui.gearbox.handle.y += 8*dir[2]
 end
end

-->8
-- cars and related math

function make_car()
 local car = {}
 car.brand = "abarth"
 car.model = "595"
 car.variant = ""
 car.engine = "1.4 t-jet"
 car.year = 2017
 car.horsepower = 160
 car.rpm_max = 5500
 -- {nm, rpm}
 car.torque_max = {206, 3000}
 car.gear_one_vmax = 47
 car.gear_one_time = 3.01
 car.gear_one_dropdown = 0
 car.gear_two_vmax = 82
 car.gear_two_time = 6.34
 car.gear_two_dropdown = 2000
 car.gear_three_vmax = 121
 car.gear_three_time = 14.63
 car.gear_three_dropdown = 1500
 car.gear_four_vmax = 160
 car.gear_four_time = 54.96
 car.gear_four_dropdown = 1200
 car.gear_five_vmax = 212
 car.gear_five_time = 118.20
 car.gear_five_dropdown = 1100
 car.gears_data = {
  {car.gear_one_vmax,
   car.gear_one_time,
   car.gear_one_dropdown},
  {car.gear_two_vmax,
   car.gear_two_time,
   car.gear_two_dropdown},
  {car.gear_three_vmax,
   car.gear_three_time,
   car.gear_three_dropdown},
  {car.gear_four_vmax,
   car.gear_four_time,
   car.gear_four_dropdown},
  {car.gear_five_vmax,
   car.gear_five_time,
   car.gear_five_dropdown}}
 car.current_gear = 0
 car.current_rpm = 0
 car.current_speed = 0
 return car
end

function calculate_speed(car)
 local speed = flr((car.current_rpm / car.rpm_max) *
  car.gears_data[car.current_gear][1])
 return speed
end 

function car_update(car)
 if car.current_gear == 0 then
  return false
 end
 local rpm_plus = 70 -- safe fixed value
 rpm_plus = flr(
  car.rpm_max / car.gears_data[car.current_gear][2] / fps)
 car.current_rpm += rpm_plus
 if car.current_rpm > car.rpm_max then
  car.current_rpm = car.rpm_max
 elseif car.current_rpm < 0 then
  car.current_rpm = 0
 end
 car.current_speed = calculate_speed(car)
 return true
end

-- useful links:
-- calculator: https://x-engineer.org/automotive-engineering/chassis/vehicle-dynamics/calculate-wheel-vehicle-speed-engine-speed/
-- formula: v = (3.6 * rpm * pi * wheel_ratio) /
--              (30 * gear_ratio * final_ratio)

__gfx__
00000000666666666666666600000000000000005566555555666555556665550000000000000000000000000000000000000000000000000000000000000000
00000000666666666666666600000000000000005556555555556555556555550000000000111100000000000000000000000000000000000000000000000000
007007006666666666666666000000000000000055565555555665555566655500000000011dd110000000000000000000000000000000000000000000000000
00077000666666666666666600000000000000005556555555556555555565550000000001dddd10000000000000000000000000000000000000000000000000
00077000666666666666666600000000000000005566655555666555556665550000000001dddd10000000000000000000000000000000000000000000000000
007007006666666666666668000000000000000055500555555005555550055500000000011dd110000000000000000000000000000000000000000000000000
000000006666666d6666666800000000000000005550055555500555555005550000000000111100000000000000000000000000000000000000000000000000
000000006666666d6666666800000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffff00000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffff00000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffff00000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffff00000000000000005550000000000000000005550000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffff00000000000000005550000000000000000005550000000000000000000000000000000000000000000000000000000000000000
00000000fffffffffffffff800000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000fffffff4fffffff800000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000fffffff4fffffff800000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005550055555500555555005550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005566655555656555556665550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005555655555656555556565550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005566655555666555556655550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005565555555556555556565550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005566655555556555556565550000000000000000000000000000000000000000000000000000000000000000
__map__
1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1a1a1a1a1a1a1a1a1a1a1a1a1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1a1a1a1a1a1a1a1a1a191a1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1a1a1a1a1a1a1a1a1a1a1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1a1b1b1a1a1a1a1a1a1a1a1a1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1a1b1b1b1a1a1a1a1a1a1a1a1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1a1b1b1b1b1b1b1a1b1b1a1a1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
