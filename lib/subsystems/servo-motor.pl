consult('../ev3dev.pl').
consult('../fileaccess.pl').

servo_motor(_) :- false.

device_path(Port, DevicePath) :-
  device_path(Port, '/sys/class/servo-motor/motor', DevicePath).
