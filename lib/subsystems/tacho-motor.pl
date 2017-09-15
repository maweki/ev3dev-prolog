:- ['../fileaccess.pl'].
:- ['../ev3dev.pl'].

% http://docs.ev3dev.org/projects/lego-linux-drivers/en/ev3dev-jessie/motors.html#tacho-motors
ev3_large_motor(M) :- tacho_motor(M, 'lego-ev3-l-motor', _).
ev3_medium_motor(M) :- tacho_motor(M, 'lego-ev3-m-motor', _).
nxt_motor(M) :- tacho_motor(M, 'lego-nxt-motor', _).

tacho_motor(Port, Type, Path) :-
  subsystem_detect(Port, Type, Path, '/sys/class/tacho-motor/motor*/').

tacho_motor(M) :-
  tacho_motor(M, _, _).

tacho_motor(M, Type) :-
  tacho_motor(M, Type, _).

speed_sp_file(Port, File) :-
  tacho_motor(Port, _, Basepath),
  atomic_concat(Basepath, '/speed_sp', File).

speed_file(Port, File) :-
  tacho_motor(Port, _, Basepath),
  atomic_concat(Basepath, '/speed', File).

position_sp_file(Port, File) :-
  tacho_motor(Port, _, Basepath),
  atomic_concat(Basepath, '/position_sp', File).

position_file(Port, File) :-
  tacho_motor(Port, _, Basepath),
  atomic_concat(Basepath, '/position', File).

command_file(Port, File) :-
  tacho_motor(Port, _, Basepath),
  atomic_concat(Basepath, '/command', File).

state_file(Port, File) :-
  tacho_motor(Port, _, Basepath),
  atomic_concat(Basepath, '/state', File).

command(M, C) :-  % inline
  command_file(M, F),
  file_write(F, C).

max_speed_file(Port, File) :-
  tacho_motor(Port, _, Basepath),
  atomic_concat(Basepath, '/max_speed', File).

max_speed(MotorPort, Speed) :-
  max_speed_file(MotorPort, File),
  file_read(File, Speed).

speed_sp(MotorPort, Speed) :- % this implementation evokes the action
  integer(Speed),
  ( max_speed(MotorPort, MaxSpeed),!,
    MaxSpeed >= Speed,
    Speed >= -MaxSpeed,
    speed_sp_file(MotorPort, F),
    file_write(F, Speed)
  ).

speed_sp(MotorPort, Speed) :- % this implementation reads the target speed
  var(Speed),
  ( speed_sp_file(MotorPort, F),
    file_read(F, Speed)
  ).

speed(MotorPort, Speed) :-
  speed_file(MotorPort, F),
  file_read(F, Speed).

position_sp(MotorPort, Position) :-
  integer(Position),
  ( position_sp_file(MotorPort, F),
    file_write(F, Position)
  ).

position_sp(MotorPort, Position) :-
  var(Position),
  ( position_sp_file(MotorPort, F),
    file_read(F, Position)
  ).

position(MotorPort, Position) :-
  position_file(MotorPort, F),
  file_read(F, Position).

state(MotorPort, State) :-
  state_file(MotorPort, F),
  file_read(F, StateString),
  atomic_list_concat(State, ' ', StateString).

speed_adjust(PercentVal, MotorPort, Speed) :-
  max_speed(MotorPort, MaxSpeed),
  Speed is floor(PercentVal / 100.0 * MaxSpeed).
