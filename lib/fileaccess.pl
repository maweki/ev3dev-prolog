:- ['ev3dev.pl'].

% Write Base ops
file_write(File, Content) :-
  open(File, write, Stream),
  write(Stream, Content),
  flush_output(Stream),
  catch(close(Stream), _, true).

file_read(File, Content) :-
  open(File, read, Stream),
  read_line_to_codes(Stream, Codes),
  atom_codes(Ca, Codes),
  ( atom_number(Ca, Content);
    Content = Ca % try to split this up for list-like results
  ),
  catch(close(Stream), _, true).

try_split_list(String, Result) :-
  String = Result.

device_path(Port, Basepath, DevicePath) :-
  port_symbol(Port, Symbol),
  atomic_concat(Basepath, '*/address', Template),
  expand_(Template, AddressFile),
  file_read(AddressFile, Content), Content = Symbol, !,
  file_directory_name(AddressFile, DevicePath).

%! expand_(+F:Wildcard, -E:Path) is nondet
%
% expand a wildcard pattern and return one match
%
% @arg F wildcard pattern
% @arg E single path matching wildcard
expand_(F, E) :-
  expand_file_name(F, L),
  member(E, L).
