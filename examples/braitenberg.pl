:- ['../ev3.pl'].

% Licht wird nur von einem der beiden Sensoren verwendet und auf beide motoren übertragen.
% Je mehr Licht desto schneller das Vehikel
braitenberg1a :-
  col_ambient(_, Light),
  forall(tacho_motor(M), motor_run(M, Light)),
  braitenberg1a.

% Licht wird nur von einem der beiden Sensoren verwendet und auf beide motoren übertragen.
% Je mehr licht um so schneller, wenn Licht > 50 sollte das Vehikel rückwärts fahren.
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

% Je mehr Licht desto schneller das Vehikel, Motor Sensor Abhänigkeit
% Für braitenberg2b, am Roboter Ports von Motoren ODER Sensoren tauschen
braitenberg2 :-
  col_ambient(in2, LightR), motor_run(outB, LightR),
  col_ambient(in3, LightL), motor_run(outC, LightL),
  braitenberg2.

% Je mehr Licht desto langsamer das Vehikel, Motor Sensor Abhänigkeit
% Für braitenberg3b, am Roboter Ports von Motoren ODER Sensoren tauschen
braitenberg3 :-
  col_ambient(in2, LightR), SpeedR is max(0, 50 - LightR),
  col_ambient(in3, LightL), SpeedL is max(0, 50 - LightL),
  motor_run(outB, SpeedR), motor_run(outC, SpeedL),
  braitenberg3.

%Je mehr Licht umso schneller bis Licht > 50, dann je mehr Licht langsamer
braitenberg4 :-
  col_ambient(in2, LightR),
  col_ambient(in3, LightL),
  ((LightR < 50,
    SpeedR is LightR^2 / 100.0);
    SpeedR is 50 - LightR^2 / 100.0
  ),
  ((LightL < 50,
    SpeedL is LightL^2 / 100.0);
    SpeedL is 50 - LightL^2 / 100.0
  ),
  motor_run(outB, SpeedR), motor_run(outC, SpeedL),
braitenberg4.

% Vehikel fährt mit konstanter Geschwindigkeit(100), bis Licht > 60, dann Motor(en) (fast) volle Leistung rückwärts
braitenberg5 :-
  col_ambient(in2, LightR),
  col_ambient(in3, LightL),
  ((LightR > 50, SpeedR is 100);
    SpeedR is 40),
  ((LightL > 50, SpeedL is 100);
    SpeedL is 40),
  motor_run(outB, SpeedL), motor_run(outC, SpeedR), sleep(1),
braitenberg5.
