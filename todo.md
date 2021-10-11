- [ ] Reverse gear handling
  - [ ] Should not be treated as a "zero" gear
  - [ ] Maybe using reverse gear should not be possible? Or should decrease RPM fast? Or should break the car?
- [ ] RPM handling
  - [ ] Issue about shifting gears down. Current scheme works fine when there is high RPM (e.g. driving on "5" then shifting to "4" or "3"), but is broken if player will wait until the RPM goes down (e.g. driving on "5", then driving on "0", then shifting to "4" will result in RPM spike to ~2000 RPM). Maybe I should use percentages instead of fixed values for rpm dropdowns?

