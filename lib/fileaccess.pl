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

subsystem_detect(Port, Type, Path, Prefix) :-
  expand_file_name(Prefix, Paths),
  member(Path, Paths),
  atomic_concat(Path, '/address', AddressFile),
  atomic_concat(Path, '/driver_name', DriverFile),
  file_read(AddressFile, Port),
  file_read(DriverFile, Type).
