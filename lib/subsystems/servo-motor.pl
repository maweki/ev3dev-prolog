:- ['../fileaccess.pl'].


servo_motor(_) :- false.

% this no longer works
device_path(Port, DevicePath) :-
  device_path(Port, '/sys/class/servo-motor/motor', DevicePath).
