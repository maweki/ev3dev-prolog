:- ['ev3_base.pl'].

motor_start(M) :-
  tacho_motor(M),
  command(M, 'run-forever').

motor_stop(M) :-
  tacho_motor(M),
  speed_sp(M, 0),
  command(M, 'stop').

stop_all_motors :-
  foreach(tacho_motor(M), motor_stop(M)).

motor_run(Motor, Speed) :- run_forever(Motor, Speed).

run_forever(Motor, Speed) :-
  tacho_motor(Motor),
  speed_sp(Motor, Speed),
  command(Motor, 'run-forever').
