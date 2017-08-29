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

motor_run(Motor, Speed) :-
  speed_adjust(Speed, Motor, CSpeed),
  run_forever(Motor, CSpeed).

motor_run(Motor, Speed, Angle) :-
  speed_adjust(Speed, Motor, CSpeed),
  speed_sp(Motor, CSpeed),
  position_sp(Motor, Angle),
  command(Motor, 'run-to-rel-pos'),
  repeat,
  state(Motor, State),
  \+ memberchk('running', State).

run_forever(Motor, Speed) :-
  tacho_motor(Motor),
  speed_sp(Motor, Speed),
  command(Motor, 'run-forever').
