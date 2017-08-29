:- multifile ev3_large_motor/1, ev3_medium_motor/1, nxt_motor/1, device_path/2, detect_port/2.
:- dynamic   ev3_large_motor/1, ev3_medium_motor/1, nxt_motor/1.
:- ['../fileaccess.pl'].
:- ['../ev3dev.pl'].

% http://docs.ev3dev.org/projects/lego-linux-drivers/en/ev3dev-jessie/motors.html#tacho-motors
ev3_large_motor(M) :- detect_port(M, 'lego-ev3-l-motor').
ev3_medium_motor(M) :- detect_port(M, 'lego-ev3-m-motor').
nxt_motor(M) :- detect_port(M, 'lego-nxt-motor').

tacho_motor(M) :-
  ev3_large_motor(M);
  ev3_medium_motor(M);
  nxt_motor(M).

tacho_motor(M, Type) :-
  tacho_motor(M),
  detect_port(M, Type).

detect_port(Port, DriverName) :-
  detect_port(Port, '/sys/class/tacho-motor/motor', DriverName).

device_path(Port, DevicePath) :-
  tacho_motor(Port),!,
  device_path(Port, '/sys/class/tacho-motor/motor', DevicePath).

speed_sp_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/speed_sp', File).

speed_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/speed', File).

position_sp_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/position_sp', File).

position_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/position', File).

command_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/command', File).

state_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/state', File).

command(M, C) :-  % inline
  command_file(M, F),
  file_write(F, C).

max_speed_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/max_speed', File).

max_speed(MotorPort, Speed) :-
  max_speed_file(MotorPort, File),
  file_read(File, Speed).

speed_sp(MotorPort, Speed) :- % this implementation evokes the action
  integer(Speed),
  ( tacho_motor(MotorPort),
    max_speed(MotorPort, MaxSpeed),!,
    MaxSpeed >= Speed,
    Speed >= -MaxSpeed,
    speed_sp_file(MotorPort, F),
    file_write(F, Speed)
  ).

speed_sp(MotorPort, Speed) :- % this implementation reads the target speed
  var(Speed),
  ( tacho_motor(MotorPort),
    speed_sp_file(MotorPort, F),
    file_read(F, Speed)
  ).

speed(MotorPort, Speed) :-
  tacho_motor(MotorPort),
  speed_file(MotorPort, F),
  file_read(F, Speed).

position_sp(MotorPort, Position) :-
  integer(Position),
  ( tacho_motor(MotorPort),
    position_sp_file(MotorPort, F),
    file_write(F, Position)
  ).

position_sp(MotorPort, Position) :-
  var(Position),
  ( tacho_motor(MotorPort),
    position_sp_file(MotorPort, F),
    file_read(F, Position)
  ).

position(MotorPort, Position) :-
  tacho_motor(MotorPort),
  position_file(MotorPort, F),
  file_read(F, Position).

state(MotorPort, State) :-
  tacho_motor(MotorPort),
  state_file(MotorPort, F),
  file_read(F, StateString),
  split_string(StateString, " ", "", State).

speed_adjust(PercentVal, MotorPort, Speed) :-
  max_speed(MotorPort, MaxSpeed),
  Speed is floor(PercentVal / 100.0 * MaxSpeed).
