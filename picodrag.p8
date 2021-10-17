pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- game loop

function _init()
 pi = 3.14
 fps = 30
 km_ratio = 0.1
 track = make_track()
 player = make_player(track)
 car = make_car()
 ui = create_ui(car)
end

function _update()
 handle_keys()
 player_update(player, car, track)
 car_update(car)
 gauges_update(ui, car)
end

function _draw()
 cls()
 draw_ui(ui, car)
 draw_track(track)
 draw_player(player)
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
 if (player) then
  print("player "..player.x.." "..player.y.." "..player.cell.." "..player.sprite)
 else
  print("no player found")
 end
end

-->8
-- creation of ui elements

function create_ui(car)
 local ui = {}
 ui.speedometer =
  create_speedometer(0, 88, car)
 ui.tachometer =
  create_tachometer(0, 104)
 ui.gearbox =
  create_gearbox(80, 108, car)
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
 for i=1, (car.rpm_max_for_gauge / 1000) - 1  do
  add(sprites, 17)
 end
 add(sprites, 18)
 add(sprites, 19)
 add(sprites, 20)
 return
  create_gauge(x, y, sprites)
end

function create_gearbox(x, y, car)
 local gearbox = {}
 -- the center of the gearbox
 gearbox.x = x
 gearbox.y = y

 gearbox.back = {}
 if car.gears_data[6] then
  gearbox.back.sprites = {
   {5,6,7,4},
   {21,22,22,24},
   {37,38,39,40}}
 else
  gearbox.back.sprites = {
   {5,6,7},
   {21,22,23},
   {37,38,40}}
 end

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
 if car.gears_data[6] then
  gearbox.gears.six = {1,1}
  gearbox.gears.zero_right_right =
   {2,0}
  gearbox.gears.reverse = {2,1}
 else
  gearbox.gears.reverse = {1,1}
 end

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

function draw_player(player)
 spr(player.sprite, player.x, player.y)
end

function draw_ui(ui, car)
 draw_gauges()
 draw_gearbox(car)
end

function draw_track(track)
 for k, v in pairs(track.cells) do
  spr(v[3],
  track.x+(v[1]*8),
  track.y+(v[2]*8))
 end
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

function draw_gearbox(car)
 local offx = -8
 local offy = -8
 
 for k, v in pairs(ui.gearbox.back.sprites) do
  for k2, v2 in pairs(v) do
   spr(v2, ui.gearbox.x + offx,
    ui.gearbox.y + offy)
   offx += 8
  end
  offx = -8
  offy += 8
 end

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
  elseif (car.gears_data[6] and
   cgear == ui.gearbox.gears.zero_right_right) then
   ngear = ui.gearbox.gears.zero_right
  end
 elseif btnp(1) then
  dir = {1,0}
  if cgear ==
   ui.gearbox.gears.zero_left then
   ngear = ui.gearbox.gears.zero_middle
  elseif cgear ==
   ui.gearbox.gears.zero_middle then
   ngear = ui.gearbox.gears.zero_right
  elseif (cgear ==
   ui.gearbox.gears.zero_right and
   car.gears_data[6]) then
   ngear = ui.gearbox.gears.zero_right_right
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
  elseif (cgear ==
   ui.gearbox.gears.reverse and
   not car.gears_data[6]) then
   ngear = ui.gearbox.gears.zero_right
   car.current_gear = 0
  elseif (cgear ==
   ui.gearbox.gears.six and
   car.gears_data[6]) then
   ngear = ui.gearbox.gears.zero_right
   car.previous_gear = 6
   car.current_gear = 0
  elseif (cgear ==
   ui.gearbox.gears.reverse and
   car.gears_data[6]) then
   ngear = ui.gearbox.gears.zero_right_right
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
  elseif (cgear ==
   ui.gearbox.gears.zero_right and
   not car.gears_data[6]) then
   ngear = ui.gearbox.gears.reverse
   car.current_gear = 0
  elseif (cgear ==
   ui.gearbox.gears.zero_right and
   car.gears_data[6]) then
   ngear = ui.gearbox.gears.six
   car.current_gear = 6
  elseif (cgear ==
   ui.gearbox.gears.zero_right_right and
   car.gears_data[6]) then
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
-- player and cars

function make_player(track)
 local player = {}
 player.x = track.start_x
 player.x_dec = 0
 player.y = track.start_y
 player.y_dec = 0
 player.sprite = 48
 player.cell = 1
 return player
end

function player_update(player, car, track)
 local move_x = 0
 local move_y = 0
 local cell = nil
 if track.cells[player.cell] then
  cell = track.cells[player.cell][3]
 else
  player.cell = 1
  cell = track.cells[player.cell][3]
 end
 local ncell = nil
 if track.cells[player.cell+1] then
  ncell = track.cells[player.cell+1][3]
 else
  ncell = track.cells[1][3]
 end
 if cell == 10 or
  cell == 42 then
  move_x = car.current_speed * km_ratio 
 elseif cell == 26 then
  move_x = (-1) * car.current_speed * km_ratio 
 elseif cell == 11 or
  cell == 43 then
  move_y = car.current_speed * km_ratio
 elseif cell == 27 then
  move_y = (-1) * car.current_speed * km_ratio
 elseif cell == 12 then
  move_x = car.current_speed * km_ratio
 elseif cell == 13 then
  move_y = car.current_speed * km_ratio
 elseif cell == 29 then
  move_x = (-1) * car.current_speed * km_ratio
 elseif cell == 28 then
  move_y = (-1) * car.current_speed * km_ratio
 elseif cell == 14 then
  move_y = car.current_speed * km_ratio
 elseif cell == 30 then
  move_x = car.current_speed * km_ratio
 elseif cell == 31 then
  move_y = (-1) * car.current_speed * km_ratio
 elseif cell == 15 then
  move_x = (-1) * car.current_speed * km_ratio
 end
 player.x_dec += move_x
 player.y_dec += move_y
 local cont = true
 while cont do
  if player.x_dec >= 10 then
   player.x += 1
   player.x_dec -= 10
   if player.x % 8 == 0 then
    player.cell += 1
	   player.x_dec = 0
   end
  elseif player.x_dec <= -10 then
   player.x -= 1
   player.x_dec += 10
   if player.x % 8 == 0 then
    player.cell += 1
	   player.x_dec = 0
   end
  elseif player.y_dec >= 10 then
   player.y += 1
   player.y_dec -= 10
   if player.y % 8 == 0 then
    player.cell += 1
	   player.y_dec = 0
   end
  elseif player.y_dec <= -10 then
   player.y -= 1
   player.y_dec += 10
   if player.y % 8 == 0 then
    player.cell += 1
	   player.y_dec = 0
   end
  else
   cont = false
  end
 end
 if ncell == 10 or
  ncell == 42 then
  player.sprite = 48
 elseif ncell == 26 then
  player.sprite = 52
 elseif ncell == 11 or
  ncell == 43 then
  player.sprite = 54
 elseif ncell == 27 then
  player.sprite = 50
 elseif ncell == 12 then
  player.sprite = 49
 elseif ncell == 13 then
  player.sprite = 55
 elseif ncell == 29 then
  player.sprite = 53
 elseif ncell == 28 then
  player.sprite = 51
 elseif ncell == 14 then
  player.sprite = 53
 elseif ncell == 30 then
  player.sprite = 55
 elseif ncell == 31 then
  player.sprite = 49
 elseif ncell == 15 then
  player.sprite = 51
 end
end

function make_car()
 return make_honda()
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
 -- dropdown ratio is % of dropdown of rpm_max
 car.gear_one_dropdown_ratio =
  0.15
 car.gear_two_ratio = 2.12
 car.gear_two_vmax = 96
 car.gear_two_time = 4.4
 car.gear_two_dropdown = 2300
 car.gear_two_dropdown_ratio =
  0.35
 car.gear_three_ratio = 1.53
 car.gear_three_vmax = 132
 car.gear_three_time = 7.4
 car.gear_three_dropdown = 1600
 car.gear_three_dropdown_ratio =
  0.25
 car.gear_four_ratio = 1.13
 car.gear_four_vmax = 179
 car.gear_four_time = 14.2
 car.gear_four_dropdown = 1600
 car.gear_four_dropdown_ratio =
  0.25
 car.gear_five_ratio = 0.91
 car.gear_five_vmax = 223
 car.gear_five_time = 27.3
 car.gear_five_dropdown = 1200
 car.gear_five_dropdown_ratio =
  0.18
 car.gear_six_ratio = 0.74
 car.gear_six_vmax = 272
 car.gear_six_time = 95.1
 car.gear_six_dropdown = 1250
 car.gear_six_dropdown_ratio =
  0.19
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
 -- dropdown ratio is % of dropdown of rpm_max
 car.gear_one_dropdown_ratio =
  0.18
 car.gear_two_ratio = 2.24
 car.gear_two_vmax = 82
 car.gear_two_time = 6.3
 car.gear_two_dropdown = 2000
 car.gear_two_dropdown_ratio =
  0.36
 car.gear_three_ratio = 1.52
 car.gear_three_vmax = 121
 car.gear_three_time = 14.6
 car.gear_three_dropdown = 1500
 car.gear_three_dropdown_ratio =
  0.27
 car.gear_four_ratio = 1.16
 car.gear_four_vmax = 160
 car.gear_four_time = 54.9
 car.gear_four_dropdown = 1200
 car.gear_four_dropdown_ratio =
  0.22
 car.gear_five_ratio = 0.87
 car.gear_five_vmax = 212
 car.gear_five_time = 118.2
 car.gear_five_dropdown = 1100
 car.gear_five_dropdown_ratio =
  0.20
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
   car.current_rpm -= car.current_rpm * car.gear_two_dropdown_ratio
  elseif car.current_gear == 3 then
   car.current_rpm -= car.current_rpm * (car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio)
  elseif car.current_gear == 4 then
   car.current_rpm -= car.current_rpm * (car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio)
  elseif car.current_gear == 5 then
   car.current_rpm -= car.current_rpm * (car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio)
  elseif car.current_gear == 6 then
   car.current_rpm -= car.current_rpm * (car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio + car.gear_six_dropdown_ratio)
  end
  
 elseif car.previous_gear == 2 then
  if car.current_gear == 1 then
   car.current_rpm += car.current_rpm * car.gear_two_dropdown_ratio
  elseif car.current_gear == 3 then
   car.current_rpm -= car.current_rpm * car.gear_three_dropdown_ratio
  elseif car.current_gear == 4 then
   car.current_rpm -= car.current_rpm * (car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio)
  elseif car.current_gear == 5 then
   car.current_rpm -= car.current_rpm * (car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio)
  elseif car.current_gear == 6 then
   car.current_rpm -= car.current_rpm * (car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio + car.gear_six_dropdown_ratio)
  end
  
 elseif car.previous_gear == 3 then
  if car.current_gear == 1 then
   car.current_rpm += car.current_rpm * (car.gear_one_dropdown_ratio + car.gear_two_dropdown_ratio)
  elseif car.current_gear == 2 then
   car.current_rpm += car.current_rpm * car.gear_two_dropdown_ratio
  elseif car.current_gear == 4 then
   car.current_rpm -= car.current_rpm * car.gear_four_dropdown_ratio
  elseif car.current_gear == 5 then
   car.current_rpm -= car.current_rpm * (car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio)
  elseif car.current_gear == 6 then
   car.current_rpm -= car.current_rpm * (car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio + car.gear_six_dropdown_ratio)
  end

 elseif car.previous_gear == 4 then
  if car.current_gear == 1 then
   car.current_rpm += car.current_rpm * (car.gear_one_dropdown_ratio + car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio)
  elseif car.current_gear == 2 then
   car.current_rpm += car.current_rpm * (car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio)
  elseif car.current_gear == 3 then
   car.current_rpm += car.current_rpm * car.gear_three_dropdown_ratio
  elseif car.current_gear == 5 then
   car.current_rpm -= car.current_rpm * car.gear_five_dropdown_ratio
  elseif car.current_gear == 6 then
   car.current_rpm -= car.current_rpm * (car.gear_five_dropdown_ratio + car.gear_six_dropdown_ratio)
  end

 elseif car.previous_gear == 5 then
  if car.current_gear == 1 then
   car.current_rpm += car.current_rpm * (car.gear_one_dropdown_ratio + car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio)
  elseif car.current_gear == 2 then
   car.current_rpm += car.current_rpm * (car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio)
  elseif car.current_gear == 3 then
   car.current_rpm += car.current_rpm * (car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio)
  elseif car.current_gear == 4 then
   car.current_rpm += car.current_rpm * car.gear_four_dropdown_ratio
  elseif car.current_gear == 6 then
   car.current_rpm -= car.current_rpm * car.gear_six_dropdown_ratio
  end

 elseif car.previous_gear == 6 then
  if car.current_gear == 1 then
   car.current_rpm += car.current_rpm * (car.gear_one_dropdown_ratio + car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio)
  elseif car.current_gear == 2 then
   car.current_rpm += car.current_rpm * (car.gear_two_dropdown_ratio + car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio)
  elseif car.current_gear == 3 then
   car.current_rpm += car.current_rpm * (car.gear_three_dropdown_ratio + car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio)
  elseif car.current_gear == 4 then
   car.current_rpm += car.current_rpm * (car.gear_four_dropdown_ratio + car.gear_five_dropdown_ratio)
  elseif car.current_gear == 5 then
   car.current_rpm += car.current_rpm * car.gear_five_dropdown_ratio
  end
 end

 car.current_rpm = flr(car.current_rpm)
end

-- useful links:
-- calculator: https://x-engineer.org/automotive-engineering/chassis/vehicle-dynamics/calculate-wheel-vehicle-speed-engine-speed/
-- formula: v = (3.6 * rpm * pi * wheel_ratio) /
--              (30 * gear_ratio * final_ratio)

-->8
-- tracks

function make_track()
 local track = {}
 track.x = 0
 track.y = 16
 track.cells = {}
 --position, sprite
 add(track.cells, {4,5,42})
 add(track.cells, {5,5,10})
 add(track.cells, {6,5,10})
 add(track.cells, {7,5,13})
 add(track.cells, {7,6,11})
 add(track.cells, {7,7,30})
 add(track.cells, {8,7,10})
 add(track.cells, {9,7,10})
 add(track.cells, {10,7,10})
 add(track.cells, {11,7,10})
 add(track.cells, {12,7,10})
 add(track.cells, {13,7,10})
 add(track.cells, {14,7,31})
 add(track.cells, {14,6,27})
 add(track.cells, {14,5,27})
 add(track.cells, {14,4,27})
 add(track.cells, {14,3,27})
 add(track.cells, {14,2,15})
 add(track.cells, {13,2,26})
 add(track.cells, {12,2,26})
 add(track.cells, {11,2,26})
 add(track.cells, {10,2,26})
 add(track.cells, {9,2,26})
 add(track.cells, {8,2,28})
 add(track.cells, {8,1,15})
 add(track.cells, {7,1,26})
 add(track.cells, {6,1,26})
 add(track.cells, {5,1,26})
 add(track.cells, {4,1,26})
 add(track.cells, {3,1,14})
 add(track.cells, {3,2,30})
 add(track.cells, {4,2,10})
 add(track.cells, {5,2,10})
 add(track.cells, {6,2,13})
 add(track.cells, {6,3,11})
 add(track.cells, {6,4,29})
 add(track.cells, {5,4,26})
 add(track.cells, {4,4,26})
 add(track.cells, {3,4,26})
 add(track.cells, {2,4,26})
 add(track.cells, {1,4,14})
 add(track.cells, {1,5,11})
 add(track.cells, {1,6,11})
 add(track.cells, {1,7,30})
 add(track.cells, {2,7,10})
 add(track.cells, {3,7,31})
 add(track.cells, {3,6,27})
 add(track.cells, {3,5,12})
 track.start_x = 
  track.x+(8*track.cells[1][1])
 track.start_y =
  track.y+(8*track.cells[1][2])
 return track
end
__gfx__
00000000666666666666666600000000555555555566555555666555556665550000000000000000888888888666666800888888888888000088888888888800
00000000666666666666666600000000555555555556555555556555556555550000000000111100666656668665666808666666656668800866665666666880
007007006666666666666666000000005555555555565555555665555566655500000000011dd110666665668665666886666666665666888666656666666688
00077000666666666666666600000000555555555556555555556555555565550000000001dddd10665556568565656886666666556566688666565566666668
00077000666666666666666600000000555555555566655555666555556665550000000001dddd10666665668656566886665666665666688666656666656668
007007006666666666666668000000005555555555500555555005555550055500000000011dd110666656668665666886656566656666688666665666565668
000000006666666d6666666800000000555555555550055555500555555005550000000000111100666666668666666886565656666666688666666665656568
000000006666666d6666666800000000555555555550055555500555555005550000000000000000888888888666666886665668866666688666666886656668
00000000fffffffff9f9f9f9f8f8f8f8f8f888885550055555500555555005555555555500000000888888888666666886666668866656688665666886666668
00000000fffffffff9f9f9f9f8f8f8f8f8f888885550055555500555555005555555555500000000666656668665666886666656665656588565656666666668
00000000fffffffff9f9f9f9f8f8f8f8f8f888885550055555500555555005555555555500000000666566668656566886666566666565688656566665666668
00000000fffffffff9f9f9f9f8f8f8f8f8f888885550000000000000000005550000055500000000665655568565656886665655666656688665666666566668
00000000fffffffff9f9f9f9f8f8f8f8f8f888885550000000000000000005550000055500000000666566668665666886666566666666688666666655656668
00000000fffffffff9f9f9f9f8f8f8f8f8f888885550055555500555555005555550055500000000666656668665666888666656666666888866666666566688
00000000fffffff4f9f9f9f4f8f8f8f4f8f888885550055555500555555005555550055500000000666666668666666808866666666668800886666665666880
00000000fffffff4f9f9f9f4f8f8f8f4f8f888885550055555500555555005555550055500000000888888888666666800888888888888000088888888888800
00000000000000000000000000000000000000005550055555500555555005555550055500000000888888888666666855000000000000005550000000000000
00000000000000000000000000000000000000005550055555500555555005555550055500000000676767668666666805000000555050050050000055505550
00000000000000000000000000000000000000005550055555500555555005555550055500000000667676668767676805005550500050050050555050505000
00000000000000000000000000000000000000005566655555656555556665555566655500000000676767668676767805000000500050055550000050505000
00000000000000000000000000000000000000005555655555656555556555555565655500000000667676668767676805005550500055055000555055505000
00000000000000000000000000000000000000005566655555666555556665555566555500000000676767668676767805000000555055555000000050505550
00000000000000000000000000000000000000005565555555556555556565555565655500000000667676668767676805000000000000005000000000000000
00000000000000000000000000000000000000005566655555556555556665555565655500000000888888888666666805000000000000005550000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0011110000111c00001cc10000c11100001111000011110000111100001111000000000000000000000000000000000000000000000000000000000000000000
01111110011111c0011111100c111110011111100111111001111110011111100000000000000000000000000000000000000000000000000000000000000000
011111c00111111001111110011111100c1111100111111001111110011111100000000000000000000000000000000000000000000000000000000000000000
011111c00111111001111110011111100c1111100111111001111110011111100000000000000000000000000000000000000000000000000000000000000000
01111110011111100111111001111110011111100c11111001111110011111c00000000000000000000000000000000000000000000000000000000000000000
001111000011110000111100001111000011110000c11100001cc10000111c000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10100e1a1a1a1a0f101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101e0a0a0d101c1a1a1a1a0f10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101b1010101010100b10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e1a1a1a1a1d1010101010100b10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b100c2a0a0a0d10101010100b10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b100b1010101b3d101010100b10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e0a1f1010101e0a0a0a0a0a1f10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
