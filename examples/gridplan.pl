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
  nice_plan(Plan, state([SX, SY], [SDX, SDY]), state([TX, TY], [DX, DY])),
  format("~nPLAN: ~p",[Plan]),
  dolist(Plan),!.

dolist([]) :- format("~nERROR - EMPTY PLAN",[]).
dolist([fin]).
dolist([Move|Tail]) :-
  format("~nEXEC: ~p",[Move]),
  Move,!,
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
  format("~nOBST: ~p",[[TX, TY]]),
  fail
  ).

move :-
  state_position([X, Y], [DX, DY]),
  go_cm(10, 20),
  retract(state_position([X, Y], [DX, DY])),
  TX is X+DX, TY is Y+DY,
  asserta(state_position([TX, TY], [DX, DY])).

move_if_free :-
  free, move.

turn_around :-
  state_position([X, Y], [DX, DY]),
  go_cm(10, -5),
  (maybe, turn(10, 180); turn(10, -180)),
  go_cm(10, 5),!,
  retract(state_position([X, Y], [DX, DY])),
  NDX is -DX, NDY is -DY,
  asserta(state_position([X, Y], [NDX, NDY])).

turn_left :-
  state_position([X, Y], [DX, DY]),
  go_cm(10, -5),
  turn(10, -90),
  go_cm(10, 5),!,
  retract(state_position([X, Y], [DX, DY])),
  orientation([NX, NY], [DX, DY]),
  asserta(state_position([X, Y], [NX, NY])).

turn_right :-
  state_position([X, Y], [DX, DY]),
  go_cm(10, -5),
  turn(10, 90),
  go_cm(10, 5),!,
  retract(state_position([X, Y], [DX, DY])),
  orientation([DX, DY], [NX, NY]),
  asserta(state_position([X, Y], [NX, NY])).

% ===== Planning =====

plan(Plan, state(StartField, StartDirection), Goal) :-
  (
    Goal = state(GPos ,_),
    \+ obstructed(GPos),
    between(1, 25, Length),
    format("~nTRYING PLAN LENGTH ~p",[Length]),
    length(Plan, Length),
    Plan = [step(_, StartField, StartDirection)|_],
    plan_fits(Plan, Goal)
  );
  Plan = [].

nice_plan1([], []).
nice_plan1([step(Move, _, _)|R], Nice) :-
  Nice = [Move|MR],
  nice_plan1(R, MR),!.

nice_plan(Plan, state(StartField, StartDirection), Goal) :-
  plan(Plan1, state(StartField, StartDirection), Goal), !,
  nice_plan1(Plan1, Plan).

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
