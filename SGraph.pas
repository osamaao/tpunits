//
// Graphics mode library
//

Unit SGraph;

Interface

Uses
    UCrt,Dos;
Var
   MaxX,MaxY:Word;
   BankR,BankW,PgsOrdr:Byte;

Procedure SetCrt(Reg,Dta:Byte);
function  GetCrt(Reg:Byte):Byte;
Procedure SetBank(B:Byte);
Procedure SetPagesOrder(N:Byte);
Procedure SetWindow(X,Y:LongInt);
Procedure FlushVRam;
Procedure GraphOn(Mode:Word);
Procedure GraphOff;
Procedure Pset(X,Y:LongInt;C:Byte);
Function  PsetColor(X,Y:LongInt):Byte;
Procedure LineH(X,Y:Word;L:Integer;C:Byte);
Procedure LineV(X,Y:Word;L:Integer;C:Byte);
Procedure SLine(X1,Y1,X2,Y2:Integer;Color:Byte);
Procedure Rect(X,Y:Word;LX,LY:Integer;C:Byte);
Procedure Box(X,Y:Word;LX,LY:Integer;C:Byte);
Procedure SetRGB(C,RR,GG,BB:Byte);
Procedure GetRGB(C:Byte;Var RR:Byte;Var GG:Byte;Var BB:Byte);

Implementation

Var
   R:Registers;

Procedure SetCrt(Reg,Dta:Byte);
Begin
     Port[$3D4]:=Reg;
     Port[$3D4+1]:=Dta;
End;

Function GetCrt(Reg:Byte):Byte;
Begin
     Port[$3D4]:=Reg;
     GetCrt:=Port[$3D4+1];
End;

Procedure SetBank(B:Byte);
Begin
     Port[$3CE]:=9;
     Port[$3CF]:=B SHL 4;
     BankR:=B;
     BankW:=B;
End;

Procedure SetPagesOrder(N:Byte);
Begin
     SetCrt($13,N*MaxX Div 8);
     PgsOrdr:=N;
End;

Procedure SetWindow(X,Y:LongInt);
VAR
   L,M,W:LongInt;
BEGIN
     L:=MaxX*PgsOrdr*Y+X;
     M:=L SHR 18;
     IF M>1 THEN INC(M,2);
     W:=Word(L SHR 2);
     SetCrt(13,Lo(W));
     SetCrt(12,Hi(W));
     W:=GetCrt($1B);
     W:=(W And Not(5))+(M And 5);
     SetCrt($1B,Lo(W));
END;

Procedure FlushVRam;
Var
   C:Byte;
   BR,BW:Byte;
Begin
     BR:=BankR;
     BW:=BankW;
     For C:=0 To 15 Do
         Begin
              SetBank(C);
              FillChar(Mem[$A000:0000],$FFFF,0);
              Mem[$A000:$FFFF]:=0;
         End;
     SetBank(BR);
End;

Procedure GraphOn(Mode:Word);
Var
   C:Byte;
Begin
     MaxX:=Mode;
     Case Mode Of
          320:  Begin
                     R.AX:=$0013;
                     MaxY:=200;
                End;
          640:  Begin
                     R.AX:=$005F;
                     {R.AX:=$0101;}
                     MaxY:=480;
                End;
          800:  Begin
                     R.AX:=$005C;
                     MaxY:=600;
                End;
          32640:  Begin
                     R.AX:=$0066;
                     MaxX:=640;
                     MaxY:=480;
                End;
          32800:  Begin
                     R.AX:=$0067;
                     MaxX:=800;
                     MaxY:=600;
                End;
          1024: Begin
                     R.AX:=$0060;
                     MaxY:=768;
                End;
          1280: Begin
                     R.AX:=$006C;
                     MaxY:=1024;
                End;
          Else
                Begin
                     R.AX:=$0013;
                     MaxX:=320;
                     MaxY:=200;
                End;
     End;
     Intr($10,R);
     PORT[$3C4]:=15;
     PORT[$3C5]:=48;
End;

Procedure GraphOff;
Begin
     R.AX:=$0003;
     Intr($10,R);
End;

Procedure Pset(X,Y:LongInt;C:Byte);
Var
   L:LongInt;
   BW:Byte;
Begin
     L:=Y*MaxX*PgsOrdr+X;
     BW:=L Shr 16;
     If BW<>BankW Then SetBank(BW);
     L:=L And $FFFF;
     Mem[$A000:L]:=C;
End;

Function PsetColor(X,Y:LongInt):Byte;
Var
   L:LongInt;
   BR:Byte;
Begin
     L:=Y*MaxX*PgsOrdr+X;
     BR:=L Shr 16;
     If Br<>BankR Then SetBank(BR);
     L:=L And $FFFF;
     PsetColor:=Mem[$A000:L];
End;

Procedure LineH(X,Y:Word;L:Integer;C:Byte);
Var
   CC:Word;
Begin
     If L<=0 Then
        For CC:=(X+L) To X Do Pset(CC,Y,C)
            Else For CC:=X To (X+L) Do Pset(CC,Y,C);
End;

Procedure LineV(X,Y:Word;L:Integer;C:Byte);
Var
   CC:Word;
Begin
     If L<=0 Then
        For CC:=(Y+L) To Y Do Pset(X,CC,C)
            Else For CC:=Y To (Y+L) Do Pset(X,CC,C);
End;

Procedure SLineX(X1,Y1,X2,Y2:Integer ;Color:Byte);
Var
   X,Y,dX,dY,ndY:Integer;
Begin
X:=X1;
Y:=Y1;
dX:=X2-X1+1;
dY:=Y2-Y1+1;
ndY:=0;
PSet(X1,Y1,Color);
Repeat
      Inc(X);
      Inc(ndY,dY);
      If ndY>=dX Then
         Begin
              Inc(Y);
              Dec(dY);
              Dec(ndY,dX);
              Dec(dX,X-X1);
              X1:=X;
         End;
      PSet(X,Y,Color);
Until X>=X2;
End;

Procedure SLineY(X1,Y1,X2,Y2:Integer ;Color:Byte);
Var
   X,Y,dX,dY,ndY:Integer;
Begin
X:=X1;
Y:=Y1;
dX:=X2-X1+1;
dY:=Y2-Y1+1;
ndY:=0;
PSet(X1,Y1,Color);
Repeat
      Inc(X);
      Inc(ndY,dY);
      If ndY>=dX Then
         Begin
              Inc(Y);
              Dec(dY);
              Dec(ndY,dX);
              Dec(dX,X-X1);
              X1:=X;
         End;
      PSet(X,Y,Color);
Until X>=X2;
End;

Procedure SLine(X1,Y1,X2,Y2:Integer;Color:Byte);
Var
   X,Y,dX,dY:Integer;
Begin
     If X1>X2 Then
        Begin
             dX:=X1;
             X1:=X2;
             X2:=dX;
        End;
     If Y1>Y2 Then
        Begin
             dX:=Y1;
             Y1:=Y2;
             Y2:=dX;
        End;
     X:=X1;
     Y:=Y1;
     dX:=X2-X1+1;
     dY:=Y2-Y1+1;
     If dX>=dY Then SLineX(X1,Y1,X2,Y2,Color)
               Else SLineY(X1,Y1,X2,Y2,Color);

End;

Procedure Rect(X,Y:Word;LX,LY:Integer;C:Byte);
Begin
     LineH(X   ,Y   ,LX,C);
     LineH(X   ,Y+LY,LX,C);
     LineV(X   ,Y   ,LY,C);
     LineV(X+LX,Y   ,LY,C);
End;
Procedure Box(X,Y:Word;LX,LY:Integer;C:Byte);
Var
   CC:Word;
Begin
     If LY<=0 Then
        For CC:=(Y+LY) To Y Do LineH(X,CC,LX,C)
            Else For CC:=Y To (Y+LY) Do LineH(X,CC,LX,C);
End;
Procedure SetRGB(C,RR,GG,BB:Byte);
Begin
     Port[$3C8]:=C;
     Port[$3C9]:=RR;
     Port[$3C9]:=GG;
     Port[$3C9]:=BB;
End;
Procedure GetRGB(C:Byte;Var RR:Byte;Var GG:Byte;Var BB:Byte);
Begin
     Port[$3C8]:=C;
     RR:=Port[$3C9];
     GG:=Port[$3C9];
     BB:=Port[$3C9];
End;
Begin
     BankR:=0;
     BankW:=0;
     PgsOrdr:=1;
End.
