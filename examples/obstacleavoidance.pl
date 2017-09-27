:- ['../ev3.pl'].

obstacle_avoidance :-
  ((us_dist_cm(in4, Dist), Dist > 50,
    motor_run(outB, 20), motor_run(outC, 20)
  );
  (motor_stop(outC), motor_run(outB, 20, 360))),
  obstacle_avoidance.
