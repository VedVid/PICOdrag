pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- game loop

function _init()
 pi = 3.14
 fps = 30
 car = make_car()
 ui = create_ui(car)
end

function _update()
 handle_keys()
 car_update(car)
 gauges_update(ui, car)
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
  create_speedometer(0, 88, car)
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

function create_speedometer(x, y, car)
 local sprites = {}
 for i=1, (car.speed_max_for_gauge / car.speedometer_interval) - 1 do
  add(sprites, 1)
 end
 add(sprites, 2)
 add(sprites, 2)
 add(sprites, 2)
 return
  create_gauge(x, y, sprites)
end

function create_tachometer(x, y)
 local sprites = {}
 for i=1, (car.speed_max_for_gauge / 1000)  do
  add(sprites, 17)
 end
 add(sprites, 18)
 add(sprites, 18)
 return
  create_gauge(x, y, sprites)
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

function gauges_update(ui, car)
 -- speedometer
 -- 1 tile = gauge_interval
 -- 1 tile = 8 px
 -- 1 px = 20 km / 8 px
 local px = car.speedometer_interval / 8
 local pos = flr(
  ui.speedometer.x + (
  car.current_speed / px))
 ui.speedometer.indicator_x1 = pos
 ui.speedometer.indicator_x2 = pos + 1

 -- tachometer
 -- 1 tile = 1000 rpm
 -- 1 tile = 8 px
 -- 1 px = 1000 rpm / 8 px
 px = 1000 / 8
 pos = flr(
  ui.tachometer.x + (
  car.current_rpm / px))
 ui.tachometer.indicator_x1 = pos
 ui.tachometer.indicator_x2 = pos + 1
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
   car.current_gear = 1
  elseif cgear ==
   ui.gearbox.gears.two then
   ngear = ui.gearbox.gears.zero_left
   car.previous_gear = 2
   car.current_gear = 0
  elseif cgear ==
   ui.gearbox.gears.zero_middle then
   ngear = ui.gearbox.gears.three
   car.current_gear = 3
  elseif cgear ==
   ui.gearbox.gears.four then
   ngear = ui.gearbox.gears.zero_middle
   car.previous_gear = 4
   car.current_gear = 0
  elseif cgear ==
   ui.gearbox.gears.zero_right then
   ngear = ui.gearbox.gears.five
   car.current_gear = 5
  elseif cgear ==
   ui.gearbox.gears.reverse then
   ngear = ui.gearbox.gears.zero_right
   car.current_gear = 0
  end
 elseif btnp(3) then
  dir = {0,1}
  if cgear ==
   ui.gearbox.gears.one then
   ngear = ui.gearbox.gears.zero_left
   car.previous_gear = 1
   car.current_gear = 0
  elseif cgear ==
   ui.gearbox.gears.zero_left then
   ngear = ui.gearbox.gears.two
   car.current_gear = 2
  elseif cgear ==
   ui.gearbox.gears.three then
   ngear = ui.gearbox.gears.zero_middle
   car.previous_gear = 3
   car.current_gear = 0
  elseif cgear ==
   ui.gearbox.gears.zero_middle then
   ngear = ui.gearbox.gears.four
   car.current_gear = 4
  elseif cgear ==
   ui.gearbox.gears.five then
   ngear = ui.gearbox.gears.zero_right
   car.previous_gear = 5
   car.current_gear = 0
  elseif cgear ==
   ui.gearbox.gears.zero_right then
   ngear = ui.gearbox.gears.reverse
   car.current_gear = 0
  end
 end
 
 if ngear then
  ui.gearbox.current_gear = ngear
  ui.gearbox.handle.x += 8*dir[1]
  ui.gearbox.handle.y += 8*dir[2]
  car_calc_dropdown(car)
 end
end

-->8
-- cars and related math

function make_car()
 return make_abarth()
end

function make_honda()
 local car = {}
 car.brand = "honda"
 car.model = "civic"
 car.variant = "type r"
 car.engine = "2.0 vtec"
 car.year = 2020
 car.speedometer_interval = 30
 car.horsepower = 320
 car.rpm_max = 6500
 car.rpm_max_for_gauge = 6000
 car.speed_max_for_gauge = 260
 car.final_drive_ratio = 4.11
 car.wheel_ratio = 0.34
 -- {nm, rpm}
 car.torque_max = {400, 3500}
 car.gear_one_ratio = 3.63
 car.gear_one_vmax = 56
 car.gear_one_time = 2.2
 car.gear_one_dropdown = 1000
 car.gear_two_ratio = 2.12
 car.gear_two_vmax = 96
 car.gear_two_time = 4.4
 car.gear_two_dropdown = 2300 
 car.gear_three_ratio = 1.53
 car.gear_three_vmax = 132
 car.gear_three_time = 7.4
 car.gear_three_dropdown = 1600
 car.gear_four_ratio = 1.13
 car.gear_four_vmax = 179
 car.gear_four_time = 14.2
 car.gear_four_dropdown = 1600
 car.gear_five_ratio = 0.91
 car.gear_five_vmax = 223
 car.gear_five_time = 27.3
 car.gear_five_dropdown = 1200
 car.gear_six_ratio = 0.74
 car.gear_six_vmax = 272
 car.gear_six_time = 95.1
 car.gear_six_dropdown = 1250
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
   car.gear_five_dropdown},
  {car.gear_six_vmax,
   car.gear_six_time,
   car.gear_six_dropdown}}
 car.current_gear = 0
 car.previous_gear = 0
 car.current_rpm = 0
 car.current_speed = 0
 return car
end

function make_abarth()
 local car = {}
 car.brand = "abarth"
 car.model = "595"
 car.variant = ""
 car.engine = "1.4 t-jet"
 car.year = 2017
 car.speedometer_interval = 20
 car.horsepower = 160
 car.rpm_max = 5500
 car.rpm_max_for_gauge = 5000
 car.speed_max_for_gauge = 200
 car.final_drive_ratio = 3.36
 car.wheel_ratio = 0.30
 -- {nm, rpm}
 car.torque_max = {206, 3000}
 car.gear_one_ratio = 3.91
 car.gear_one_vmax = 47
 car.gear_one_time = 3.0
 car.gear_one_dropdown = 1000
 car.gear_two_ratio = 2.24
 car.gear_two_vmax = 82
 car.gear_two_time = 6.3
 car.gear_two_dropdown = 2000
 car.gear_three_ratio = 1.52
 car.gear_three_vmax = 121
 car.gear_three_time = 14.6
 car.gear_three_dropdown = 1500
 car.gear_four_ratio = 1.16
 car.gear_four_vmax = 160
 car.gear_four_time = 54.9
 car.gear_four_dropdown = 1200
 car.gear_five_ratio = 0.87
 car.gear_five_vmax = 212
 car.gear_five_time = 118.2
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
 car.previous_gear = 0
 car.current_rpm = 0
 car.current_speed = 0
 return car
end

function calculate_speed(car)
 if car.current_gear > 0 then
  return flr((car.current_rpm / car.rpm_max) *
   car.gears_data[car.current_gear][1])
 else
  if car.previous_gear > 0 then
   return flr((car.current_rpm / car.rpm_max) *
    car.gears_data[car.previous_gear][1])
  end
 end
 return 0
end 

function car_update(car)
 local rpm_plus = 30 -- safe fixed value
 if car.current_gear == 0 then
  car.current_rpm -= rpm_plus
 else
  rpm_plus = flr(
   car.rpm_max / car.gears_data[car.current_gear][2] / fps)
  car.current_rpm += rpm_plus
 end
 if car.current_rpm > car.rpm_max then
  car.current_rpm = car.rpm_max
 elseif car.current_rpm < 0 then
  car.current_rpm = 0
 end
 car.current_speed = calculate_speed(car)
 return true
end

function car_calc_dropdown(car)
 if car.previous_gear == 1 then
  if car.current_gear == 2 then
   car.current_rpm -= car.gear_two_dropdown
  elseif car.current_gear == 3 then
   car.current_rpm -= (car.gear_two_dropdown + car.gear_three_dropdown)
  elseif car.current_gear == 4 then
   car.current_rpm -= (car.gear_two_dropdown + car.gear_three_dropdown + car_gear_four_dropdown)
  elseif car.current_gear == 5 then
   car.current_rpm -= (car.gear_two_dropdown + car.gear_three_dropdown + car.gear_four_dropdown + car.gear_five_dropdown) 
  end
  
 elseif car.previous_gear == 2 then
  if car.current_gear == 1 then
   car.current_rpm += car.gear_two_dropdown
  elseif car.current_gear == 3 then
   car.current_rpm -= car.gear_three_dropdown
  elseif car.current_gear == 4 then
   car.current_rpm -= (car.gear_three_dropdown + car.gear_four_dropdown)
  elseif car.current_gear == 5 then
   car.current_rpm -= (car.gear_three_dropdown + car.gear_four_dropdwon + car.gear_five_dropdown)
  end
  
 elseif car.previous_gear == 3 then
  if car.current_gear == 1 then
   car.current_rpm += (car.gear_one_dropdown + car.gear_two_dropdown)
  elseif car.current_gear == 2 then
   car.current_rpm += car.gear_two_dropdown
  elseif car.current_gear == 4 then
   car.current_rpm -= car.gear_four_dropdown
  elseif car.current_gear == 5 then
   car.current_rpm -= (car.gear_four_dropdown + car.gear_five_dropdown)
  end

 elseif car.previous_gear == 4 then
  if car.current_gear == 1 then
   car.current_rpm += (car.gear_one_dropdown + car.gear_two_dropdown + car.gear_three_dropdown)
  elseif car.current_gear == 2 then
   car.current_rpm += (car.gear_two_dropdown + car.gear_three_dropdown)
  elseif car.current_gear == 3 then
   car.current_rpm += car.gear_three_dropdown
  elseif car.current_gear == 5 then
   car.current_rpm -= car.gear_five_dropdown
  end

 elseif car.previous_gear == 5 then
  if car.current_gear == 1 then
   car.current_rpm += (car.gear_one_dropdown + car.gear_two_dropdown + car.gear_three_dropdown + car.gear_four_dropdown)
  elseif car.current_gear == 2 then
   car.current_rpm += (car.gear_two_dropdown + car.gear_three_dropdown + car.gear_four_dropdown)
  elseif car.current_gear == 3 then
   car.current_rpm += (car.gear_three_dropdown + car.gear_four_dropdown)
  elseif car.current_gear == 4 then
   car.current_rpm += car.gear_four_dropdown
  end
 end
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
