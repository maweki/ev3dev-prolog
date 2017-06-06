expand_(F,E) :- F = E.

file_write(File, Content) :-
  write('Dummywrote '),
  write(Content),
  write(' to '),
  write(File),nl,
  flush_output.

:- [doc].
