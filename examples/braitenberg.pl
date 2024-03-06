:- ['../ev3.pl'].

% See https://en.wikipedia.org/wiki/Braitenberg_vehicle for more information

% Light only used from one sensor and transfered to both motors
% The more light, the faster the vehicle
braitenberg1a :-
  col_ambient(_, Light),
  forall(tacho_motor(M), motor_run(M, Light)),
  braitenberg1a.

% Light only used from one sensor and transfered to both motors
% The more light, the faster the vehicle. If the light level is greater than 50 the vehicle goes backwards.
braitenberg1b :-
  col_ambient(_, Light),
  ((Light < 50,
    Speed is Light);
    Speed is -Light),
  forall(tacho_motor(M), motor_run(M, Speed)),
  braitenberg1b.

braitenberg1c :-
  col_ambient(_, Light),
  Speed is 50 - Light,
  forall(tacho_motor(M), motor_run(M, Speed)),
  braitenberg1c.

% The more light, the faster the vehicle.
% The vehicle either turns towards the light or away from it. Switch motor or sensor ports (in software or physically) to change the behaviour
braitenberg2 :-
  col_ambient('ev3-ports:in2', LightR), motor_run('ev3-ports:outB', LightR),
  col_ambient('ev3-ports:in3', LightL), motor_run('ev3-ports:outC', LightL),
  braitenberg2.

% The more light, the slower the vehicle.
% For braitenberg 3b, switch sensors or motors
braitenberg3 :-
  col_ambient('ev3-ports:in2', LightR), SpeedR is max(0, 50 - LightR),
  col_ambient('ev3-ports:in3', LightL), SpeedL is max(0, 50 - LightL),
  motor_run('ev3-ports:outB', SpeedR), motor_run('ev3-ports:outC', SpeedL),
  braitenberg3.

% The more light, the faster the vehicle. If the light level is greater than 50 the vehicle goes slower.
braitenberg4 :-
  col_ambient('ev3-ports:in2', LightR),
  col_ambient('ev3-ports:in3', LightL),
  ((LightR < 50,
    SpeedR is LightR^2 / 100.0);
    SpeedR is 50 - LightR^2 / 100.0
  ),
  ((LightL < 50,
    SpeedL is LightL^2 / 100.0);
    SpeedL is 50 - LightL^2 / 100.0
  ),
  motor_run('ev3-ports:outB', SpeedR), motor_run('ev3-ports:outC', SpeedL),
braitenberg4.

% Vehicle goes with constant speed, up until light level 60 and then it goes backwards
braitenberg5 :-
  col_ambient('ev3-ports:in2', LightR),
  col_ambient('ev3-ports:in3', LightL),
  ((LightR > 50, SpeedR is 100);
    SpeedR is 40),
  ((LightL > 50, SpeedL is 100);
    SpeedL is 40),
  motor_run('ev3-ports:outB', SpeedL), motor_run('ev3-ports:outC', SpeedR), sleep(1),
braitenberg5.
