consult('ev3_base.pl').

motor_start(M) :-
  tacho_motor(M),
  command(M, 'run-forever').

motor_stop(M) :-
  tacho_motor(M),
  command(M, 'stop').

stop_all_motors :-
  foreach(tacho_motor(M), stop_motor(M)).

motor_run(Motor, Speed) :- motor_run_forever(Motor, Speed).

motor_run_forever(Motor, Speed) :-
  speed_sp(Motor, Speed),
  command(Motor, 'run-forever').
