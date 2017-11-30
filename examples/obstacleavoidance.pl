:- ['../ev3.pl'].

start :-
  set_robot(5.6, 10.6, outB, outC),
  obstacle_avoidance.

obstacle_avoidance :-
  ((us_dist_cm(_, Dist), Dist > 50, go(20));
  turn(20, 90)),!,
  obstacle_avoidance.
