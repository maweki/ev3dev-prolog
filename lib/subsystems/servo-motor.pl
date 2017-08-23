:- multifile servo_motor/1, device_path/2.
:- dynamic   servo_motor/1.
:- ['../fileaccess.pl'].


servo_motor(_) :- false.

device_path(Port, DevicePath) :-
  device_path(Port, '/sys/class/servo-motor/motor', DevicePath).
