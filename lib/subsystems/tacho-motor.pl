:- multifile ev3_large_motor/1, ev3_medium_motor/1, nxt_motor/1, device_path/2.
:- dynamic   ev3_large_motor/1, ev3_medium_motor/1, nxt_motor/1.
:- ['../fileaccess.pl'].

ev3_large_motor(_) :- false.
ev3_medium_motor(_) :- false.
nxt_motor(_) :- false.

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

device_path(Port, DevicePath) :-
  tacho_motor(Port),!,
  device_path(Port, '/sys/class/tacho-motor/motor', DevicePath).

speed_sp_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/speed_sp', File).

command_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/command', File).

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

speed_sp(MotorPort, Speed, Percent) :-
  Percent,!,
  (float(Speed); integer(Speed)),
  max_speed(MotorPort, MaxSpeed),
  CalcSpeed is floor(Speed / 100.0 * MaxSpeed),
  speed_sp(MotorPort, CalcSpeed).
