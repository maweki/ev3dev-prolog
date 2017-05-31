% Write Base ops
write_(File, Content) :-
  open(File, write, Stream),
  write(Stream, Content),
  flush_output(Stream),
  catch(close(Stream), _, true).

write_dummy_(File, Content) :-
  write('Dummywrote '),
  write(Content),
  write(' to '),
  write(File),nl,
  flush_output.

% Pathnames for Device access

port_symbol(portA, 'outA').
port_symbol(portB, 'outB').
port_symbol(portC, 'outC').
port_symbol(portD, 'outD').
port_symbol(port1, 'in1').
port_symbol(port2, 'in2').
port_symbol(port3, 'in3').
port_symbol(port4, 'in4').

% expand_file_name(+WildCard, -List)
% /sys/bus/lego/devices/outA:lego-ev3-l-motor/tacho-motor/motor0

expand_(F, E) :-
  expand_file_name(F, L),
  memberchk(E, L).

% expand_(F, E) :- F = E.

device_path(Port, DevicePath) :-
  Prefix = '/sys/bus/lego/devices/',
  device_code(Port, Code),
  port_symbol(Port, Symbol),
  ( tacho_motor(Port),
    atomic_concat(Prefix, Symbol, C1),
    atomic_concat(C1, ':', C2),
    atomic_concat(C2, Code, C3),
    atomic_concat(C3, '/tacho-motor/motor*/', WildCard),
    expand_(WildCard, DevicePath)
  ).

device_code(Port, Code) :-
  (largeMotor(Port), Code = 'lego-ev3-l-motor').

tacho_motor(M) :-
  largeMotor(M);
  mediumMotor(M).

file_write(File, Content) :- write_dummy_(File, Content).
% file_write(File, Content) :- write_(File, Content).

motorSpeedFile(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, 'speed_sp', File).

motorCommandFile(M, F) :-  :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, 'command', File).

max_speed(MotorPort, Speed) :-
  tacho_motor(MotorPort),
  Speed = 100. % read this from max_speed-file

speed(MotorPort, Speed) :-
  ( integer(Speed),tacho_motor(MotorPort),
    max_speed(MotorPort, MaxSpeed),!,
    Speed <= MaxSpeed,
    Speed >= -MaxSpeed,
    set_motor_speed(MotorPort, Speed),
    if(Speed == 0, set_motor_command(MotorPort, 'stop'), set_motor_command(MotorPort, 'run-forever'))
  )

set_motor_speed(M, S) :- % inline
  motor(M),
  motorSpeedFile(M, F),
  file_write(F, S).

set_motor_command(M, C) :-  % inline
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
mediumMotor(portB).

main :-
  set_motor_speed(portA, 100),
  set_motor_speed(portB, 100),
  startMotor(portA),
  startMotor(portB),
  sleep(3),
  stopMotor(portA),
  stopMotor(portB).
