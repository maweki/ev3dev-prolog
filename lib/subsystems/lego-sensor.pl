light_sensor(_) :- false.
ultrasonic_sensor(_) :- false.

uart_host(Port) :-
  light_sensor(Port);
  ultrasonic_sensor(Port).

device_path(Port, DevicePath) :-
  device_path(Port, '/sys/class/lego-sensor/sensor', DevicePath).

col_ambient(Port, Val) :-
  light_sensor(Port),
  mode(Port, 'COL-AMBIENT'),
  value(Port, 0, Val).

col_reflect(Port, Val) :-
  light_sensor(Port),
  mode(Port, 'COL-REFLECT'),
  value(Port, 0, Val).

adjust_val(Port, RawVal, ValAdjusted) :-
  decimals(Port, Decimals),
  ValAdjusted is RawVal / 10.0**Decimals.

us_dist_cm(Port, Val) :-
  ultrasonic_sensor(Port),
  mode(Port, 'US-DIST-CM'),
  value(Port, 0, RawVal),
  adjust_val(Port, RawVal, Val).

decimals(Port, Decimals) :-
  decimals_file(Port, File),
  file_read(File, Decimals).

decimals_file(Port, File) :-
  uart_host(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/decimals', File).

mode_file(Port, File) :-
  uart_host(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/mode', File).

value_file(Port, ValueNum, File) :-
  uart_host(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/value', BaseValuePath),
  atomic_concat(BaseValuePath, ValueNum, File).

value(Port, ValueNum, Value) :-
  value_file(Port, ValueNum, File),
  file_read(File, Value).

mode(D, C) :-
  nonvar(C),
  mode_file(D, F),
  file_write(F, C).

mode(D, C) :-
  var(C),
  mode_file(D, F),
  file_read(F, C).
