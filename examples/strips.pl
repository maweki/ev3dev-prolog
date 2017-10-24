%% Strips in prolog. November 2006.  Tim Finin.  finin@umbc.edu

% LIBRARIES -- load our local dbug utility
%:- ensure_loaded(dbug).

/* **********************************************************************

strips/3 is the top level predicate for strips
strips(+GoalState, +InitialState, -PlanSteps)
e.g. strips([on(a,b)],[ontable(a),ontable(b),...], Plan)

calls strips/6, the internal strips predicate, and reverse it's
plan, so that the steps go from first to last

*********************************************************************** */

strips(Goal, InitState, Plan):-
  strips(Goal, InitState, [], [], _, RevPlan),
  reverse(RevPlan, Plan).


/* **********************************************************************

strips/6 also keeps track of the plan stack and produces an extended
plan and modifided state on each iteraction.

strips(+GoalList, +State, +Plan, +PlanStack, -NewState, -NewPlan )

*********************************************************************** */

% This clause recognizes that we are done when each goal in Goals is also
% in the current State.

strips(Goals, State, Plan, PlanStack, State, Plan) :-

  subset(Goals,State), !,

  % Depth is the Depth of recursion, only used in printing.
  length(PlanStack, L),
  Depth is L*5,
  format("~n~*cStips planning done with:",[Depth,32]).
%  dbug("~n~*c  goal: ~p",[Depth,32,Goals]),
%  dbug("~n~*c  state: ~p",[Depth,32,State]),
%  dbug("~n~*c  current plan: ~p",[Depth,32,Plan]),
%  dbug("~n~*c  plan stack: ~p",[Depth,32,PlanStack]).


% this is the basic recursive step

strips(Goals, State, Plan, PlanStack, NewState, NewPlan):-

  % is this potential plan too long already?
  length(Plan,PlanLength),
  length(PlanStack, PlanStackLength),
  Steps is PlanLength+PlanStackLength,
  stripsMaxPlanLength(MaxPlanLength),
  Steps<MaxPlanLength,

  % Indent only used in printing.
  Indent is PlanStackLength*5,

  format("~n~*cCalling strips with:",[Indent,32]),
  format("~n~*c  goal: ~p",[Indent,32,Goals]),
  format("~n~*c  state: ~p",[Indent,32,State]),
  format("~n~*c  current plan: ~p",[Indent,32,Plan]),
  format("~n~*c  Plan stack: ~p",[Indent,32,PlanStack]),

  % select an unsatisfied goal G to work on
  % modify this for Hw7

  member(G, Goals),
  (\+ member(G, State)),

  % Op is an Operator that has makes G true
  operator(Op, Preconditions, Adds, Deletes),
  member(G,Adds),

  % fail if we're about to repeat an action during the planing. This
  % hack keeps us from looping at the expense of preventing us from
  % solving some planning problems.

  (\+ member(Op, PlanStack)),

  % Try to achieve Op's preconditions via a recursive call to strips

%  dbug("~n~*cAchieve ~p via ~p with preconds: ~p",[Indent,32,G, Op,Preconditions]),
  strips(Preconditions, State, Plan, [Op|PlanStack], TmpState1, TmpPlan1),

  % Now that the preconditions have been satisfied, 'do' the action
  % defined by op, i.e. remove the deletes and add adds

  %dbug("~n~*cApplying ~p ",[Indent,32,Op]),
  subtract(TmpState1, Deletes, TmpState2),
  union(Adds, TmpState2, TmpState3),

  % Continue planning by making iterative call to strips, with Op
  % added to the evolving plan

  strips(Goals, TmpState3, [Op|TmpPlan1], PlanStack, NewState, NewPlan).



% maximum number of steps in a plan before we give up.  This prevents
% overly long plans that are probably due to loops.

stripsMaxPlanLength(100).

/* **********************************************************************

test/0, test/1 and test/2 provide a simple testing predicate for
strips and several other simple planners.  Define a test case using
init_state/2 and goal/2 predicates.  Here's test case 11:

  init_state(11, [on(a,b), clear(a), ...]).
  goal(11, [ontable(a), ontable(b)]).

*********************************************************************** */

test :-
  member(N, [1,2,3,4,5,6,7,8,9]),
  test(N).

test(N) :- test(strips, N, _).

test(Planner, N) :- test(Planner, N,_).

test(Planner, N, Plan) :-
  init_state(N,Initial),
  goal(N,Goal),
  Term =.. [Planner,Goal,Initial,Plan],
  call(Term),
  format("~n~n  From ~p~n  To ~p~n  Do:~n",[Initial,Goal]),
  writeplan(Plan),nl.

writeplan([]).
writeplan([A|B]):-
  write('       '),write(A),nl,
  writeplan(B).


  %operator(Op, Preconditions, Adds, Deletes), member(G,Adds),
  operator(move_if_free, [position(X,Y), orientation(DX, DY)],[position(X+DX, Y+DY)], [position(X,Y)]).

  /*Drehung Links*/
  operator(turn_left, [orientation(0,1)],[orientation(-1,0)] ,[orientation(0,1)]).
  operator(turn_left, [orientation(-1,0)],[orientation(0,-1)],[orientation(-1,0)]).
  operator(turn_left, [orientation(0,-1)],[orientation(1,0)], [orientation(0,-1)]).
  operator(turn_left, [orientation(1,0)],[orientation(0,1)], [orientation(1,0)]).
  /*Drehung Rechts*/
  operator(turn_right, [orientation(0,1)],[orientation(1,0)], [orientation(0,1)]).
  operator(turn_right, [orientation(-1,0)],[orientation(0,1)], [orientation(-1,0)]).
  operator(turn_right, [orientation(0,-1)],[orientation(-1,0)], [orientation(0,-1)]).
  operator(turn_right, [orientation(1,0)],[orientation(0,-1)], [orientation(1,0)]).
