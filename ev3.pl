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

device_code(Port, Code) :-
  (ev3_large_motor(Port), Code = 'lego-ev3-l-motor');
  (ev3_medium_motor(Port), Code = 'lego-ev3-m-motor');
  (nxt_motor(Port), Code = 'lego-nxt-motor').

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
  memberchk(E, L).

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
  ).

filename_motor_speed_sp(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/speed_sp', File).

motorCommandFile(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/command', File).

max_speed(MotorPort, Speed) :-
  tacho_motor(MotorPort),
  Speed = 1000. % read this from max_speed-file

speed_sp(MotorPort, Speed) :- % this implementation evokes the action
  integer(Speed),
  ( tacho_motor(MotorPort),
    max_speed(MotorPort, MaxSpeed),!,
    MaxSpeed >= Speed,
    Speed >= -MaxSpeed,
    filename_motor_speed_sp(M, F),
    file_write(F, Speed),
    if(Speed == 0, motor_command(MotorPort, 'stop'), motor_command(MotorPort, 'run-forever'))
  ).

speed_sp(MotorPort, Speed) :- % this implementation reads the target speed
  var(Speed),
  ( tacho_motor(MotorPort),
    filename_motor_speed_sp(MotorPort, F),
    file_read(F, Speed),
  ).

motor_command(M, C) :-  % inline
  tacho_motor(M),
  motorCommandFile(M, F),
  file_write(F, C).

startMotor(M) :-
  tacho_motor(M),
  set_motor_command(M, 'run-forever').

stopMotor(M) :-
  tacho_motor(M),
  set_motor_command(M, 'stop').


largeMotor(portA).
largeMotor(portB).

main :-
  speed(portA, 100),
  speed(portB, -200),
  sleep(3),
  speed(portA, 0),
  speed(portB, 0).
