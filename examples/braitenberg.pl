:- ['../lib/subsystems/lego-sensor.pl'].
:- ['../lib/subsystems/tacho-motor.pl'].

:- multifile ev3_large_motor/1.

ev3_large_motor(portB).
ev3_large_motor(portC).
light_sensor(port2).
light_sensor(port3).

% Licht wird nur von einem der beiden Sensoren verwendet und auf beide motoren übertragen.
% Je mehr Licht desto schneller das Vehikel
braitenberg1a :-
  col_ambient(port2, Light),
  speed_sp(portB, Light, true),
  speed_sp(portC, Light, true),
  braitenberg1a.

% Licht wird nur von einem der beiden Sensoren verwendet und auf beide motoren übertragen.
% Je mehr licht um so schneller, wenn Licht > 50 sollte das Vehikel rückwärts fahren.
braitenberg1b :-
  col_ambient(port2, Light),
  ((Light < 50,
    Speed is Light);
    Speed is -Light),
  speed_sp(portB, Speed, true),
  speed_sp(portC, Speed, true),
  braitenberg1b.

braitenberg1c :-
  col_ambient(port2, Light),
  Speed is 50 - Light,
  speed_sp(portB, Speed, true),
  speed_sp(portC, Speed, true),
  braitenberg1c.

% Je mehr Licht desto schneller das Vehikel, Motor Sensor Abhänigkeit
% Für braitenberg2b, am Roboter Ports von Motoren ODER Sensoren tauschen
braitenberg2 :-
  col_ambient(port2, LightR), speed_sp(portB, LightR, true),
  col_ambient(port3, LightL), speed_sp(portC, LightL, true),
  braitenberg2.

% Je mehr Licht desto langsamer das Vehikel, Motor Sensor Abhänigkeit
% Für braitenberg3b, am Roboter Ports von Motoren ODER Sensoren tauschen
braitenberg3 :-
  col_ambient(port2, LightR), SpeedR is max(0, 50 - LightR),
  col_ambient(port3, LightL), SpeedL is max(0, 50 - LightL),
  speed_sp(portB, SpeedR, true), speed_sp(portC, SpeedL, true),
  braitenberg3.

%Je mehr Licht umso schneller bis Licht > 50, dann je mehr Licht langsamer
braitenberg4 :-
  col_ambient(port2, LightR),
  col_ambient(port3, LightL),
  ((LightR < 50,
    SpeedR is LightR^2 / 100.0);
    SpeedR is 50 - LightR^2 / 100.0
  ),
  ((LightL < 50,
    SpeedL is LightL^2 / 100.0);
    SpeedL is 50 - LightL^2 / 100.0
  ),
  speed_sp(portB, SpeedR, true), speed_sp(portC, SpeedL, true),
braitenberg4.

% Vehikel fährt mit konstanter Geschwindigkeit(100), bis Licht > 60, dann Motor(en) (fast) volle Leistung rückwärts
braitenberg5 :-
  col_ambient(port2, LightR),
  col_ambient(port3, LightL),
  ((LightR > 50, SpeedR is 100);
    SpeedR is 40),
  ((LightL > 50, SpeedL is 100);
    SpeedL is 40),
  speed_sp(portB, SpeedL, true), speed_sp(portC, SpeedR, true), sleep(1),
braitenberg5.
