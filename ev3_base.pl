:- expects_dialect(sicstus).

% Write Base ops
file_write(File, Content) :-
  open(File, write, Stream),
  write(Stream, Content),
  flush_output(Stream),
  catch(close(Stream), _, true).

file_read(File, Content) :-
  open(File, read, Stream),
  read_line(Stream, C),
  atom_string(Ca, C),
  ( atom_number(Ca, Content);
    Content = Ca
  ),
  catch(close(Stream), _, true).

% Pathnames for Device access

port_symbol(portA, 'outA').
port_symbol(portB, 'outB').
port_symbol(portC, 'outC').
port_symbol(portD, 'outD').
port_symbol(port1, 'in1').
port_symbol(port2, 'in2').
port_symbol(port3, 'in3').
port_symbol(port4, 'in4').

ev3_large_motor(_) :- false.
ev3_medium_motor(_) :- false.
nxt_motor(_) :- false.
light_sensor(_) :- false.
ultrasonic_sensor(_) :- false.

device_code(Port, Code) :-
  (ev3_large_motor(Port), Code = 'lego-ev3-l-motor');
  (ev3_medium_motor(Port), Code = 'lego-ev3-m-motor');
  (nxt_motor(Port), Code = 'lego-nxt-motor');
  (uart_host(Port), Code = 'ev3-uart-host').

%! tacho_motor(?M:Port) is nondet
%
% True if a tacho Motor exists at that port
%
% @arg M Motor Port of the motor
% @see "http://docs.ev3dev.org/projects/lego-linux-drivers/en/ev3dev-jessie/motors.html#tacho-motors"
tacho_motor(M) :-
  ev3_large_motor(M);
  ev3_medium_motor(M);
  nxt_motor(M).

uart_host(Port) :-
  light_sensor(Port);
  ultrasonic_sensor(Port).

% Auto-Detect these
% ev3_large_motor(Port) :- .
% ev3_medium_motor(Port) :- .
% nxt_motor(Port) :- .

%! expand_(+F:Wildcard, -E:Path) is nondet
%
% expand a wildcard pattern and return one match
%
% @arg F wildcard pattern
% @arg E single path matching wildcard
expand_(F, E) :-
  expand_file_name(F, L),
  member(E, L).

device_path(Port, DevicePath) :-
  port_symbol(Port, Symbol),
  ((tacho_motor(Port),
    expand_('/sys/class/tacho-motor/motor*/address', AddressFile)
   );
   (uart_host(Port),
    expand_('/sys/class/lego-sensor/sensor*/address', AddressFile)
   )),
  file_read(AddressFile, Content), Content = Symbol, !,
  file_directory_name(AddressFile, DevicePath).

col_ambient(Port, Val) :-
  light_sensor(Port),
  mode(Port, 'COL-AMBIENT'),
  value(Port, 0, Val).

col_reflect(Port, Val) :-
  light_sensor(Port),
  mode(Port, 'COL-REFLECT'),
  value(Port, 0, Val).

us_dist_cm(Port, Val) :-
  ultrasonic_sensor(Port),
  mode(Port, 'US-DIST-CM'),
  value(Port, 0, RawVal),
  Val is RawVal / 10.0. % sollte aus /decimals ausgelesen werden

speed_sp_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/speed_sp', File).

command_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/command', File).

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

mode(M, C) :- % also read variant
  mode_file(M, F),
  file_write(F, C).

command(M, C) :-  % inline
  command_file(M, F),
  file_write(F, C).

max_speed_file(Port, File) :-
  tacho_motor(Port),
  device_path(Port, Basepath),
  atomic_concat(Basepath, '/max_speed', File).

max_speed(MotorPort, Speed) :-
  max_speed_file(MotorPort, File),
  file_read(File, Speed).

speed_sp(MotorPort, Speed) :- % this implementation evokes the action
  integer(Speed),
  ( tacho_motor(MotorPort),
    max_speed(MotorPort, MaxSpeed),!,
    MaxSpeed >= Speed,
    Speed >= -MaxSpeed,
    speed_sp_file(MotorPort, F),
    file_write(F, Speed)
  ).

speed_sp(MotorPort, Speed) :- % this implementation reads the target speed
  var(Speed),
  ( tacho_motor(MotorPort),
    speed_sp_file(MotorPort, F),
    file_read(F, Speed)
  ).

speed_sp(MotorPort, Speed, Percent) :-
  Percent,!,
  (float(Speed); integer(Speed)),
  max_speed(MotorPort, MaxSpeed),
  CalcSpeed is floor(Speed / 100.0 * MaxSpeed),
  speed_sp(MotorPort, CalcSpeed).
