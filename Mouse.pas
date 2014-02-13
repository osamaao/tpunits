Unit Mouse;

Interface

Procedure InitMouse(Var M:Boolean);
Procedure MouseOn;
Procedure MouseOff;
Procedure SetBoard(X1,Y1,X2,Y2:Word);
Procedure MousePos(Var X,Y:Word;Var RB,LB:Boolean);
Procedure MouseTo(X,Y:Word);
Procedure ReadMouse(B:Byte;Var P:Boolean;Var X,Y:Word);

Implementation

Uses
    UCrt,Dos;
Var
   R:Registers;

Procedure InitMouse(Var M:boolean);
Begin
     M:=True;
     R.AX:=0;
     Intr($33,R);
     If R.AX=0 Then M:=False;
End;

Procedure MouseOn;
Begin
     R.AX:=1;
     Intr($33,R);
End;

Procedure MouseOff;
Begin
     R.AX:=2;
     Intr($33,R);
End;

Procedure SetBoard(X1,Y1,X2,Y2:Word);
Begin
     R.AX:=$0008;
     R.CX:=Y1;
     R.DX:=Y2;
     Intr($33,R);
     R.AX:=$0007;
     R.CX:=X1;
     R.DX:=X2;
     Intr($33,R);
End;

Procedure MousePos(Var X,Y:Word;Var RB,LB:Boolean);
Begin
     R.AX:=3;
     Intr($33,R);
     X:=R.CX;
     Y:=R.DX;
     RB:=((R.BX Div 2)=1);
     LB:=((R.BX Mod 2)=1);
End;

Procedure MouseTo(X,Y:Word);
Begin
     R.AX:=4;
     R.CX:=X;
     R.DX:=Y;
     Intr($33,R);
End;

Procedure ReadMouse(B:Byte;Var P:Boolean;Var X,Y:Word);
Begin
     R.AX:=5;
     R.BX:=B;
     Intr($33,R);
     B:=R.AX And (B+1);
     P:=(B <> 0);
     X:=R.CX;
     Y:=R.DX;
End;

Begin
End.