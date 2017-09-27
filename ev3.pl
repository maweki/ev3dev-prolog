:- ['ev3_base.pl'].

% As done by Nalepa
set_robot(WheelCircumference, AxleLength, LeftMotor, RightMotor, Reverse) :-
  nonvar(WheelCircumference),
  nonvar(AxleLength),
  nonvar(LeftMotor),
  nonvar(RightMotor),
  nonvar(Reverse),
  tacho_motor(LeftMotor),
  tacho_motor(RightMotor),
  retractall(
    robot(_, _, _, _, _)
  ),
  asserta(
    robot(WheelCircumference, AxleLength, LeftMotor, RightMotor, Reverse)
  ).

stop :-
  robot(_, _, LM, RM, _),
  motor_stop(LM),
  motor_stop(RM).

stop :-
  stop_all_motors.

go(Speed) :-
  Speed \= 0,
  robot(_, _, LM, RM, _),
  motor_run(LM, Speed),
  motor_run(RM, Speed).

go(Speed, Angle) :-
  Speed \= 0, Angle \= 0,
  robot(_, _, LM, RM, _),
  thread_create(motor_run(LM, Speed, Angle), Id1, []),
  thread_create(motor_run(RM, Speed, Angle), Id2, []),
  thread_join(Id1, true),
  thread_join(Id2, true),!.

go_cm(Speed, Distance) :-
  robot(WC, _, _, _, _),
  Angle is round(Distance/WC*360),
  go(Speed,Angle).

turn(Speed, Angle) :-
  gyro_sensor(Port).

turn(Speed, Angle) :-
  robot(WD, AL, LM, RM, _),
  MAngle is AL/WD*(Angle/360),
  NegMAngle is -MAngle,
  thread_create(motor_run(LM, Speed, MAngle), Id1, []),
  thread_create(motor_run(RM, Speed, NegMAngle), Id2, []),
  thread_join(Id1, true),
  thread_join(Id2, true),!.
