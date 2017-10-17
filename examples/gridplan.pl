:- ['../ev3.pl'].

:- dynamic(obstructed/2).

obstructed(0, 0) :- false.

setup :-
  set_robot(5.6, 10.6, outB, outC),!,
  asserta(position(0,0,[0,1])).

free :-
  us_dist_cm(_, Distance),
  (Distance > 20;
  position(X,Y,[DX, DY]),
  asserta(obstructed(X+DX, Y+DY)),
  fail
  ).

move :-
  position(X, Y, [DX, DY]),
  go_cm(10, 20),
  retract(position(X, Y, [DX, DY])),
  asserta(position(X+DX, Y+DY, [DX, DY])).

move_if_free :-
  free, move.

turn_around :-
  position(X, Y, [DX, DY]),
  go_cm(10, -5),
  (maybe, turn(10, 180); turn(10, -180)),
  go_cm(10, 5),!,
  retract(position(X, Y, [DX, DY])),
  asserta(position(X, Y, [-DX, -DY])).

orientation([0,1], [1,0]).
orientation([1,0], [0,-1]).
orientation([0,-1], [-1,0]).
orientation([-1,0], [0,1]).

turn_left :-
  position(X, Y, [DX, DY]),
  go_cm(10, -5),
  turn(10, -90),
  go_cm(10, 5),!,
  retract(position(X, Y, [DX, DY])),
  orientation([NX, NY], [DX, DY]),
  asserta(position(X, Y, [NX, NY])).

turn_right :-
  position(X, Y, [DX, DY]),
  go_cm(10, -5),
  turn(10, 90),
  go_cm(10, 5),!,
  retract(position(X, Y, [DX, DY])),
  orientation([DX, DY], [NX, NY]),
  asserta(position(X, Y, [NX, NY])).
