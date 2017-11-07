%%%%%%%%% Simple Prolog Planner %%%%%%%%
%%%
%%% This is one of the example programs from the textbook:
%%%
%%% Artificial Intelligence:
%%% Structures and strategies for complex problem solving
%%%
%%% by George F. Luger and William A. Stubblefield
%%%
%%% Corrections by Christopher E. Davis (chris2d@cs.unm.edu)
%%%
%%% These programs are copyrighted by Benjamin/Cummings Publishers.
%%%
%%% We offer them for use, free of charge, for educational purposes only.
%%%
%%% Disclaimer: These programs are provided with no warranty whatsoever as to
%%% their correctness, reliability, or any other property.  We have written
%%% them for specific educational purposes, and have made no effort
%%% to produce commercial quality computer programs.  Please do not expect
%%% more of them then we have intended.
%%%
%%% This code has been tested with SWI-Prolog (Multi-threaded, Version 5.2.13)
%%% and appears to function as intended.

:- [adts].
plan(State, Goal, _, Moves) :- 	equal_set(State, Goal),
				write('moves are'), nl,
				reverse_print_stack(Moves).
plan(State, Goal, Been_list, Moves) :-
				move(Name, Preconditions, Actions),
				conditions_met(Preconditions, State),
				change_state(State, Actions, Child_state),
				not(member_state(Child_state, Been_list)),
				stack(Child_state, Been_list, New_been_list),
				stack(Name, Moves, New_moves),
			plan(Child_state, Goal, New_been_list, New_moves),!.

change_state(S, [], S).
change_state(S, [add(P)|T], S_new) :-	change_state(S, T, S2),
					add_to_set(P, S2, S_new), !.
change_state(S, [del(P)|T], S_new) :-	change_state(S, T, S2),
					remove_from_set(P, S2, S_new), !.
conditions_met(P, S) :- subset(P, S).


member_state(S, [H|_]) :- 	equal_set(S, H).
member_state(S, [_|T]) :- 	member_state(S, T).

reverse_print_stack(S) :- 	empty_stack(S).
reverse_print_stack(S) :- 	stack(E, Rest, S),
				reverse_print_stack(Rest),
		 		write(E), nl.


/* sample moves */
obstructed(1,1).

clear(X,Y) :- \+ obstructed(X,Y).

move(move_if_free, [position(X,Y), orientation(DX, DY)], [del(position(X,Y)), add(position(X+DX, Y+DY))]).
% move_if_free -> [position(0,0),orientation(0,1),clear(0,1)]
% pickup(a) -> [ontable(b), ontable(c), clear(c), clear(b), holding(a)]

/*Drehung Links*/
move(turn_left, [orientation(0,1)], [del(orientation(0,1)), add(orientation(-1,0))]).
move(turn_left, [orientation(-1,0)], [del(orientation(-1,0)), add(orientation(0,-1))]).
move(turn_left, [orientation(0,-1)], [del(orientation(0,-1)), add(orientation(1,0))]).
move(turn_left, [orientation(1,0)], [del(orientation(1,0)), add(orientation(0,1))]).
/*Drehung Rechts*/
move(turn_right, [orientation(0,1)], [del(orientation(0,1)), add(orientation(1,0))]).
move(turn_right, [orientation(-1,0)], [del(orientation(-1,0)), add(orientation(0,1))]).
move(turn_right, [orientation(0,-1)], [del(orientation(0,-1)), add(orientation(-1,0))]).
move(turn_right, [orientation(1,0)], [del(orientation(1,0)), add(orientation(0,-1))]).

% move(pickup(X), [handempty, clear(X), on(X, Y)],
% 		[del(handempty), del(clear(X)), del(on(X, Y)),
% 				 add(clear(Y)),	add(holding(X))]).
%
% move(pickup(X), [handempty, clear(X), ontable(X)],
% 		[del(handempty), del(clear(X)), del(ontable(X)),
% 				 add(holding(X))]).
%
% move(putdown(X), [holding(X)],
% 		[del(holding(X)), add(ontable(X)), add(clear(X)),
% 				  add(handempty)]).
%
% move(stack(X, Y), [holding(X), clear(Y)],
% 		[del(holding(X)), del(clear(Y)), add(handempty), add(on(X, Y)),
% 				  add(clear(X))]).

go(S, G) :- plan(S, G, [S], []).
test :- bagof(way([PX, PY], [TX, TY], [OX, OY]), way([PX, PY], [TX, TY], [OX, OY]), L),
	append(L, [position(0,3), orientation(1,0)], Start),
	go(Start,	[position(2,3), orientation(0,1)]).

test2 :-
	bagof(way([PX, PY], [TX, TY], [OX, OY]), way([PX, PY], [TX, TY], [OX, OY]), L),
	append(L, [position(0,0), orientation(0,1)], Start),
	go(Start,	[position(2,3), orientation(1,0)]).

test3 :-
	bagof(way([PX, PY], [TX, TY], [OX, OY]), way([PX, PY], [TX, TY], [OX, OY]), L),
	append(L, [position(2,0), orientation(0,1)], Start),
	go(Start, [position(2,3), orientation(0,1)]).

way([PX, PY], [TX, TY], [OX, OY]) :-
	between(0,5, PX), between(0,5, PY),
	between(0,5, TX), between(0,5, TY),
	between(-1,1, OX), between(-1,1, OY),
	TX is PX + OX, TY is PY + OY.

%strips([position(2,3),orientation(0,1)],[position(2,0), orientation(0,1)],Plan).
% move_if_free ->
% pickup(a) -> [ontable(b), ontable(c), clear(c), clear(b), holding(a)]

% go(S, G) :- plan(S, G, [S], []).
% test :- go([handempty, ontable(b), ontable(c), on(a, b), clear(c), clear(a)],
%                  [handempty, ontable(c), on(a,b), on(b, c), clear(a)]).


% pickup(a) -> [ontable(b), ontable(c), clear(c), clear(b), holding(a)]
% pickup(c) -> [ontable(b), on(a, b), clear(a), holding(c)]
% pickup(a) -> putdown(a) -> [ontable(b), ontable(c), clear(c), clear(b), ontable(a), clear(a), handempty]
