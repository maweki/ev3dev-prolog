% Pathnames for Device access

port_symbol(portA, 'outA').
port_symbol(portB, 'outB').
port_symbol(portC, 'outC').
port_symbol(portD, 'outD').
port_symbol(port1, 'in1').
port_symbol(port2, 'in2').
port_symbol(port3, 'in3').
port_symbol(port4, 'in4').
port_symbol(A, B) :- A = B. % for string addresses
