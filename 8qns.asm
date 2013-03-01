FLD_SIZE equ 16;     <-- input data
 
XOR ECX, ECX;
LEA EAX, [ECX + 1];
MOV CL, FLD_SIZE;
SHL EAX, CL;
DEC EAX;
INC ECX;
MOV EDX, ECX;
 
@mask:
  PUSH EAX;
  DEC EDX;
JNE @mask;
MOV EAX, ECX;
 
@null:
  PUSH EDX;
  DEC EAX;
JNE @null;
LEA EBP, [ECX - 2];
 
@loop:
  LEA ESI, [ESP + 4];
  MOV ECX, 4*(FLD_SIZE + 1)*2 - 4;
  SUB ESP, ECX;
  MOV EDI, ESP;
  MOV EDX, EDI;
  LEA EBX, [EDI + 4*(FLD_SIZE + 1)];
  REP MOVSB;
 
  MOV EAX, ECX;
  INC ECX;
  PUSH ECX;
  SUB ECX, 2;
  PUSH ECX;
 
  MOV ECX, EBP;
  LEA ESI, [EAX + 1];
  SHL ESI, CL;
  MOV [EDX], ESI;
 
  @tree:
    MOV EDI, [EDX + EAX*4];
    BT EDI, ECX;
    JNC @zero;
 
      XOR EDI, EDI;
      AND [EBX + EAX*4], EDI;
 
      LEA ESI, [EDI - 2];
      ROL ESI, CL;
      ADD EDI, FLD_SIZE - 1;
      @vert:
        AND [EBX + EDI*4], ESI;
        DEC EDI;
        CMP EDI, EAX;
      JGE @vert;
 
      XOR EDI, EDI;
      LEA ESI, [EDI - 2];
      LEA EDI, [EAX + ECX];
      PUSH ECX;
      LEA ECX, [ESI + 2];
      CMP EDI, FLD_SIZE;
      JL @sskp;
        ADD ECX, (FLD_SIZE - 1);
        SUB EDI, ECX;
        XCHG EDI, ECX;
      @sskp:
      ROL ESI, CL;
      POP ECX;
      @swne:
        AND [EBX + EDI*4], ESI;
        LEA ESI, [ESI + ESI + 1];
        DEC EDI;
        CMP EDI, EAX;
      JGE @swne;
 
      XOR EDI, EDI;
      LEA ESI, [EDI - 2];
      SUB EDI, ECX;
      PUSH ECX;
      LEA ECX, [ESI + 2 + (FLD_SIZE - 1)];
      LEA EDI, [EDI + EAX + (FLD_SIZE - 1)];
      CMP EDI, FLD_SIZE;
      JL @nskp;
        XCHG EDI, ECX;
        NEG ECX;
        LEA ECX, [EDI*2 + ECX];
      @nskp:
      ROL ESI, CL;
      POP ECX;
      @nwse:
        AND [EBX + EDI*4], ESI;
        SAR ESI, 1;
        DEC EDI;
        CMP EDI, EAX;
      JGE @nwse;
 
    @zero:
 
    MOV ECX, (FLD_SIZE - 1);
    @ichk:
      MOV ESI, [EBX + ECX*4];
      MOV EDI, [EDX + ECX*4];
      OR EDI, ESI;
      JE @fail;
      TEST ESI, ESI;
      JNE @iskp;
        SUB ESI, 2;
        ROL ESI, CL;
        AND [EBX - 4], ESI;
      @iskp:
      DEC ECX;
    JGE @ichk;
 
    @fail:
    XOR EAX, EAX;
    CMP ECX, EAX;
    JL @done;
      LEA ESI, [EAX - 1];
      ADD [EDX - 4], ESI;
      MOV [EBX - 4], EAX;
    @done:
 
    CMP [EBX - 4], EAX;
    JNE @find;
      LEA EBX, [EBX + 4*(FLD_SIZE - 1)];
      LEA EDI, [EAX + 4*(FLD_SIZE + 1)];
      LEA EAX, [EAX - FLD_SIZE];
      MOV ESI, [EDX - 4];
      POP EBX;
      MOVZX ECX, BL;
      MOVZX EAX, BH;
      LEA ESP, [ESP + EDI*2];
      LEA EDX, [ESP + 8];
      LEA EBX, [ESP + EDI + 8];
      ADD [EDX - 4], ESI;
      CMP AL, -1;
      JE @endl;
      JMP @tree;
 
    @find:
      MOV ESI, [EBX + EAX*4];
      INC EAX;
      BSF ECX, ESI;
    JE @find;
    DEC EAX;
 
    BTR [EBX + EAX*4], ECX;
    LEA EDI, [ESI - 1];
    TEST ESI, EDI;
    JE @ncpy;
      MOV EDX, ECX;
      LEA ESI, [ESP + 8];
      MOV ECX, 4*(FLD_SIZE + 1)*2 - 4;
      SUB ESP, ECX;
      MOV EDI, ESP;
      LEA EBX, [EDI + 4*(FLD_SIZE + 1)];
      REP MOVSB;
      INC ECX;
      PUSH ECX;
      MOV ECX, EDX;
      MOV DH, AL;
      PUSH EDX;
      LEA EDX, [ESP + 8];
    @ncpy:
 
    BTS [EDX + EAX*4], ECX;
    JMP @tree;
  @endl:
  DEC EBP;
JGE @loop;
 
POP EAX;
POP EAX;
PUSH EBP;
 
LEA ECX, [EBP + 11];
@bits:
  XOR EDX, EDX;
  DIV ECX;
  PUSH EDX;
  TEST EAX, EAX;
JNE @bits;
 
LEA EDX, [EBP + 2];
MOV EBX, EDX;
MOV ESI, @ntbl;
ADD EBP, 5;
POP EDI;
 
@char:
  LEA ECX, [ESI + EDI];
  MOV EAX, EBP;
  INT 80h;
  POP EDI;
  CMP EDI, 0;
JGE @char;
 
LEA EAX, [EBP - 3];
DEC EBX;
INT 80h;
 
@ntbl:
  DB '0123456789';
