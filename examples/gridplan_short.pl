:- ['../ev3.pl'].

:- dynamic(obstructed/1).
:- dynamic(state_position/2).

% ===== High Level =====

setup :-
  set_robot(5.6, 10.6, 'ev3-ports:outB', 'ev3-ports:outC'),!,
  asserta(state_position([0,0],[0,1])).

plan_and_go_to([TX, TY], [DX, DY]) :-
  repeat,
  state_position([SX, SY], [SDX, SDY]),
  plan(Plan, state([SX, SY], [SDX, SDY]), state([TX, TY], [DX, DY])),
  dolist(Plan),!.

dolist([step(fin,_,_)]).
dolist([step(Move,_,_)|Tail]) :-
  Move,
  dolist(Tail),!.

% ===== Common =====

orientation([0,1], [1,0]).
orientation([1,0], [0,-1]).
orientation([0,-1], [-1,0]).
orientation([-1,0], [0,1]).

% ===== Execution =====

obstructed([0, 0]) :- false.

free :-
  us_dist_cm(_, Distance),
  (Distance > 20;
  state_position([X,Y],[DX, DY]),
  TX is X+DX, TY is Y+DY,
  asserta(obstructed([TX, TY])),
  fail).

move :-
  state_position([X, Y], [DX, DY]),
  go_cm(10, 20),
  retract(state_position([X, Y], [DX, DY])),
  TX is X+DX, TY is Y+DY,
  asserta(state_position([TX, TY], [DX, DY])).

move_if_free :-
  free, move.

turn_left :-
  state_position([X, Y], [DX, DY]),
  turn(10, -90),!,
  retract(state_position([X, Y], [DX, DY])),
  orientation([NX, NY], [DX, DY]),
  asserta(state_position([X, Y], [NX, NY])).

turn_right :-
  state_position([X, Y], [DX, DY]),
  turn(10, 90),!,
  retract(state_position([X, Y], [DX, DY])),
  orientation([DX, DY], [NX, NY]),
  asserta(state_position([X, Y], [NX, NY])).

% ===== Planning =====

plan(Plan, state(StartField, StartDirection), Goal) :-
  length(Plan, _),
  Plan = [step(_, StartField, StartDirection)|_],
  plan_fits(Plan, Goal).

plan_fits([step(fin, TargetField, TargetDirection)], state(TargetField, TargetDirection)) :- !, true.
plan_fits([step(move_if_free, [FX, FY], [DX, DY])|Tail], Goal) :-
  TX is FX + DX, TY is FY + DY,
  \+ obstructed([TX, TY]),
  Tail = [step(_, [TX, TY], [DX, DY])|_],
  plan_fits(Tail, Goal).

plan_fits([step(turn_right, FromField, Direction)|Tail], Goal) :-
  orientation(Direction, NewDirection),
  Tail = [step(_, FromField, NewDirection)|_], % turn left verbieten
  plan_fits(Tail, Goal).

plan_fits([step(turn_left, FromField, Direction)|Tail], Goal) :-
  orientation(NewDirection, Direction),
  Tail = [step(_, FromField, NewDirection)|_], % turn right verbieten
  plan_fits(Tail, Goal).
