# Write Base ops
write_(File, Content) :-
  open(File, write, Stream),
  write(Stream, Content),
  flush_output(Stream),
  catch(close(Stream), _, true).

writeDummy_(File, Content) :-
  write('Dummywrote '),
  write(Content),
  write(' to '),
  write(File),nl,
  flush_output.

fileWrite(File, Content) :- writeDummy_(File, Content).

motorSpeedFile(M, F) :- motor(M),
  F = 'somespeedfile'.

motorCommandFile(M, F) :- motor(M),
  F = 'somecommandfile'.

setMotorSpeed(M, S) :-
  motor(M),
  motorSpeedFile(M, F),
  fileWrite(F, S).

setMotorCommand(M, C) :-
  motor(M),
  motorCommandFile(M, F),
  fileWrite(F, C).

startMotor(M) :-
  motor(M),
  setMotorCommand(M, 'run-forever').

stopMotor(M) :-
  motor(M),
  setMotorCommand(M, 'stop').

motor(portA).
motor(portB).

main :-
  setMotorSpeed(portA, 100),
  setMotorSpeed(portB, 100),
  startMotor(portA),
  startMotor(portB),
  sleep(3),
  stopMotor(portA),
  stopMotor(portB).
