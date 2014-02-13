// Clear screen to white in graphic mode 320

Uses
    Crt,SGraph;
Var
   C:INTEGER;
Begin
GraphOn(320);
For C:=0 To 63 Do
    Begin
         Port[$3C8] := C;
         Port[$3C9] := C;
         Port[$3C9] := C;
         Port[$3C9] := 0;
         FillChar(Mem[SegA000:0],$FFFF,C);
         Delay(10);
    End;
Graphoff;
End.
