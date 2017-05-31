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

setMotorSpeed(M, S) :-
  motor(M),
  motorSpeedFile(M, F),
  file_write(F, S).

setMotorCommand(M, C) :-
  motor(M),
  motorCommandFile(M, F),
  file_write(F, C).

startMotor(M) :-
  motor(M),
  setMotorCommand(M, 'run-forever').

stopMotor(M) :-
  motor(M),
  setMotorCommand(M, 'stop').


largeMotor(portA).
mediumMotor(portB).

main :-
  setMotorSpeed(portA, 100),
  setMotorSpeed(portB, 100),
  startMotor(portA),
  startMotor(portB),
  sleep(3),
  stopMotor(portA),
  stopMotor(portB).
