:- ['ev3_base.pl'].

% As done by Nalepa
set_robot(WheelDiameter, AxleLength, LeftMotor, RightMotor) :-
  nonvar(WheelDiameter),
  nonvar(AxleLength),
  nonvar(LeftMotor),
  nonvar(RightMotor),
  tacho_motor(LeftMotor),
  tacho_motor(RightMotor),
  retractall(
    robot(_, _, _, _)
  ),
  asserta(
    robot(WheelDiameter, AxleLength, LeftMotor, RightMotor)
  ).

stop :-
  robot(_, _, LM, RM),
  motor_stop(LM),
  motor_stop(RM).

stop :-
  stop_all_motors.

go(Speed) :-
  Speed \= 0,
  robot(_, _, LM, RM),
  motor_run(LM, Speed),
  motor_run(RM, Speed).

go(Speed, Angle) :-
  Speed \= 0, Angle \= 0,
  robot(_, _, LM, RM),
  thread_create(motor_run(LM, Speed, Angle), Id1, []),
  thread_create(motor_run(RM, Speed, Angle), Id2, []),
  thread_join(Id1, true),
  thread_join(Id2, true),!.

go_cm(Speed, Distance) :-
  robot(WD, _, _, _),
  Angle is round((Distance*360)/(pi*WD)),
  go(Speed,Angle).

turn(Speed, Angle) :-
  gyro_sensor(Port).

turn(Speed, Angle) :-
  robot(WD, AL, LM, RM),
  MAngle is round(AL/WD*Angle),
  NegMAngle is -MAngle,
  thread_create(motor_run(LM, Speed, MAngle), Id1, []),
  thread_create(motor_run(RM, Speed, NegMAngle), Id2, []),
  thread_join(Id1, true),
  thread_join(Id2, true),!.
