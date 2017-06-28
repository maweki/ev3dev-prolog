:- expects_dialect(sicstus).
device_prefix('/sys/bus/lego/devices/').

% Write Base ops
file_write(File, Content) :-
  open(File, write, Stream),
  write(Stream, Content),
  flush_output(Stream),
  catch(close(Stream), _, true).

file_read(File, Content) :-
  open(File, read, Stream),
  read_line(Stream, C),
  atom_string(Ca, C),
  ( atom_number(Ca, Content);
    Content = Ca
  ),
  catch(close(Stream), _, true).

% Pathnames for Device access

port_symbol(portA, 'outA').
port_symbol(portB, 'outB').
port_symbol(portC, 'outC').
port_symbol(portD, 'outD').
port_symbol(port1, 'in1').
port_symbol(port2, 'in2').
port_symbol(port3, 'in3').
port_symbol(port4, 'in4').

ev3_large_motor(_) :- false.
ev3_medium_motor(_) :- false.
nxt_motor(_) :- false.
light_sensor(_) :- false.
ultrasonic_sensor(_) :- false.

device_code(Port, Code) :-
  (ev3_large_motor(Port), Code = 'lego-ev3-l-motor');
  (ev3_medium_motor(Port), Code = 'lego-ev3-m-motor');
  (nxt_motor(Port), Code = 'lego-nxt-motor');
  (uart_host(Port), Code = 'ev3-uart-host').

%! tacho_motor(?M:Port) is nondet
%
% True if a tacho Motor exists at that port
%
% @arg M Motor Port of the motor
% @see "http://docs.ev3dev.org/projects/lego-linux-drivers/en/ev3dev-jessie/motors.html#tacho-motors"
tacho_motor(M) :-
  ev3_large_motor(M);
  ev3_medium_motor(M);
  nxt_motor(M).

uart_host(Port) :-
  light_sensor(Port);
  ultrasonic_sensor(Port).

% Auto-Detect these
% ev3_large_motor(Port) :- .
% ev3_medium_motor(Port) :- .
% nxt_motor(Port) :- .

%! expand_(+F:Wildcard, -E:Path) is nondet
%
% expand a wildcard pattern and return one match
%
% @arg F wildcard pattern
% @arg E single path matching wildcard
expand_(F, E) :-
  expand_file_name(F, L),
  member(E, L).

device_path(Port, DevicePath) :-
  device_prefix(Prefix),
  device_code(Port, Code),
  port_symbol(Port, Symbol),
  ( tacho_motor(Port),
    atomic_concat(Prefix, Symbol, C1), % atomic_list_concat(+List, -Atom)
    atomic_concat(C1, ':', C2),
    atomic_concat(C2, Code, C3),
    atomic_concat(C3, '/tacho-motor/motor*', WildCard),
    expand_(WildCard, DevicePath)
  );
  ( uart_host(Port),
    expand_('/sys/class/lego-sensor/sensor*/address', AddressFile),
    file_read(AddressFile, Content),
    port_symbol(Port, Symbol),
    Content = Symbol,!,
    file_directory_name(AddressFile, DevicePath)
  ).

col_ambient(Port, Val) :-
  light_sensor(Port),
  mode(Port, 'COL-AMBIENT'),
  value(Port, 0, Val).

col_reflect(Port, Val) :-
  light_sensor(Port),
  mode(Port, 'COL-REFLECT'),
  value(Port, 0, Val).

us_dist_cm(Port, Val) :-
  ultrasonic_sensor(Port),
  mode(Port, 'US-DIST-CM'),
  value(Port, 0, RawVal),
  Val is RawVal / 10.0. % sollte aus /decimals ausgelesen werden

filename_motor_speed_sp(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/speed_sp', File).

command_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/command', File).

mode_file(Port, File) :-
  uart_host(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/mode', File).

value_file(Port, ValueNum, File) :-
  uart_host(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/value', BaseValuePath),
  atomic_concat(BaseValuePath, ValueNum, File).

value(Port, ValueNum, Value) :-
  value_file(Port, ValueNum, File),
  file_read(File, Value).

mode(M, C) :- % also read variant
  mode_file(M, F),
  file_write(F, C).

command(M, C) :-  % inline
  command_file(M, F),
  file_write(F, C).

max_speed(MotorPort, Speed) :-
  tacho_motor(MotorPort),
  Speed = 1050. % read this from max_speed-file

speed_sp(MotorPort, Speed) :- % this implementation evokes the action
  integer(Speed),
  ( tacho_motor(MotorPort),
    max_speed(MotorPort, MaxSpeed),!,
    MaxSpeed >= Speed,
    Speed >= -MaxSpeed,
    filename_motor_speed_sp(MotorPort, F),
    file_write(F, Speed),
    if(Speed == 0, command(MotorPort, 'stop'), command(MotorPort, 'run-forever'))
  ).

speed_sp(MotorPort, Speed) :- % this implementation reads the target speed
  var(Speed),
  ( tacho_motor(MotorPort),
    filename_motor_speed_sp(MotorPort, F),
    file_read(F, Speed)
  ).

speed_sp(MotorPort, Speed, Percent) :-
  Percent,!,
  (float(Speed); integer(Speed)),
  max_speed(MotorPort, MaxSpeed),
  CalcSpeed is floor(Speed / 100.0 * MaxSpeed),
  speed_sp(MotorPort, CalcSpeed).

start_motor(M) :-
  tacho_motor(M),
  command(M, 'run-forever').

stop_motor(M) :-
  tacho_motor(M),
  command(M, 'stop').


ev3_large_motor(portB).
ev3_large_motor(portC).
light_sensor(port2).
light_sensor(port3).



% BRAITENBERG

normalized(X, Y) :- Y is X * 5.
speed_back_when(X,Y) :- X > 50, Y is X *(-1).
speed_power(X,Y,Z) :- Y > 60, Z > 60, X is -900.
speed_slower(X, Y, Z) :- X is Y - Z.
speed_slower_when(X, Y, Z) :- Z > 50, X is Y - Z.
power(X, Y) :- X is Y.

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
