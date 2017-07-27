consult('ev3_base.pl').

start_motor(M) :-
  tacho_motor(M),
  command(M, 'run-forever').

stop_motor(M) :-
  tacho_motor(M),
  command(M, 'stop').

stop_all_motors :-
  foreach(tacho_motor(M), stop_motor(M)).
