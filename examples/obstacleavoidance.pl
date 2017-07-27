consult('../ev3.pl').

ev3_large_motor(portB).
ev3_large_motor(portC).
ultrasonic_sensor(port1).

obstacle_avoidance :-
  ((us_dist_cm(port1, Dist), Dist > 50,
    speed_sp(portB, 50, true), speed_sp(portC, 50, true)
  );
  speed_sp(portB, 0)),
  obstacle_avoidance.
