- [ ] Reverse gear handling
  - [ ] Should not be treated as a "zero" gear
  - [ ] Maybe using reverse gear should not be possible? Or should decrease RPM fast? Or should break the car?
- [ ] Every turn should have recommended speed
- [ ] Porssa should be faster than Hondu, but after several laps the distance between them does not change at all
  - [ ] It  may be more complicated. When I was racing Hondu vs Abarb, then I could not overtake Abarb even at 260 kmph. I needed to reach 272 kmph and then my car suddenly "jumped" forth.
    * Most likely it's issue with rounding values to integers by PICO-8. 
    * Maybe it's worth to implement simple table: {car.speed: px_per_frame}
- [ ] There is something wrong with my acceleration calculations – new supercar has worse acceleration than basic sport car
- [ ] AI should rely on two values: 1) gear shifting speed (time on zero-gear) 2) rpm accuracy (will ai shift gear exactly on max rpm? will it drive on max rpm for few secs? will shift gear too soon?)
- [ ] Would need 4 cars per class
- [ ] Abarb accelerates way slower than Pord and Auda
- [ ] Hondu is way faster than Mitatsubi and BMM

