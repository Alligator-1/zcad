{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit langsystem;
{$INCLUDE def.inc}
interface
uses gdbasetypes{,varman},varmandef,memman,UBaseTypeDescriptor;
type
    TTypesArray=array of pointer;
var
   foneGDBInteger,foneGDBDouble:TTypesArray;
const

  basicoperatorcount = 5;
  basicfunctioncount = 1;
  basicoperatorparamcount = 26;
  basicfunctionparamcount = 1;
  {foneGDBBoolean = #7;
  foneGDBByte = #8;
  foneuGDBByte = #9;
  foneGDBWord = #10;
  foneuGDBWord = #11;
  foneuGDBInteger = #13;
  foneGDBString = #15;}
type
  operandstack = record
    count: GDBByte;
    stack: array[1..10] of vardesk;
  end;
  basicoperator = function(var rez, hrez: vardesk): vardesk;
  basicfunction = function(var stack: operandstack): vardesk;
  ptfunctionparamnype = ^tfunctionparamnype;
  tfunctionparamnype = record
    count: GDBWord;
    typearray: array[0..0] of GDBByte;
  end;
  operatornam = record
    name: GDBString;
    prior: GDBByte;
  end;
  operatortype = record
    name: GDBString;
    param: pointer;
    hparam: pointer;
    addr: basicoperator;
  end;
  functiontype = record
    name: GDBString;
    param: {GDBString}TTypesArray;
    addr: basicfunction;
  end;

  functionnam = record
    name: GDBString;
                       //param:ptfunctionparamnype;
  end;

procedure initvardesk(out vd: vardesk);
procedure initoperandstack(out opstac: operandstack);

function Tnothing_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBDouble_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_plus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_plus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function Tnothing_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function Tnothing_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBInteger_mul_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_div_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_div_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_div_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_div_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBDouble_let_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBInteger_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBString_let_TGDBString(var rez, hrez: vardesk): vardesk;
function TGDBByte_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBBoolean_let_TGDBBoolean(var rez, hrez: vardesk): vardesk;

function TGDBInteger_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;

function TGDBDouble_mul_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_mul_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_mul_TGDBDouble(var rez, hrez: vardesk): vardesk;

function TGDBDouble_let_TGDBInteger(var rez, hrez: vardesk): vardesk;

function TEnum_let_TIdentificator(var rez, hrez: vardesk): vardesk;


function Cos_TGDBInteger(var stack: operandstack): vardesk;

function itbasicoperator(expr: GDBString): GDBInteger;
function itbasicfunction(expr: GDBString): GDBInteger;
function findbasicoperator(expr: GDBString; rez, hrez: {PUserTypeDescriptor}vardesk): GDBInteger;
function findbasicfunction(name: GDBString; opstack: operandstack): GDBInteger;
const
  basicoperatorname: array[1..basicoperatorcount] of operatornam =
  (
    (name: '+'; prior: 0)
    , (name: '-'; prior: 0)
    , (name: '*'; prior: 1)
    , (name: '/'; prior: 1)
    , (name: ':='; prior: 0)
    );

  basicfunctionname: array[1..basicfunctioncount] of functionnam =
  (
    (name: 'cos')
    );

  basicoperatorparam: array[1..basicoperatorparamcount] of operatortype =
  (
    (name: '+'; param: nil; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}Tnothing_plus_TGDBInteger)
    , (name: '+'; param: @GDBIntegerDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_plus_TGDBInteger)
    , (name: '-'; param: nil; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}Tnothing_minus_TGDBInteger)
    , (name: '*'; param: @GDBIntegerDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_mul_TGDBInteger)
    , (name: ':='; param: @GDBDoubleDescriptorObj; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_let_TGDBDouble)
    , (name: ':='; param: @GDBStringDescriptorObj; hparam: @GDBStringDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBString_let_TGDBString)
    , (name: ':='; param: @GDBIntegerDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_let_TGDBInteger)
    , (name: ':='; param: @GDBByteDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBByte_let_TGDBInteger)
    , (name: '-'; param: nil; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}Tnothing_minus_TGDBDouble)
    , (name: ':='; param: @GDBBooleanDescriptorOdj; hparam: @GDBBooleanDescriptorOdj; addr: {$IFDEF FPC}@{$ENDIF}TGDBBoolean_let_TGDBBoolean)
    , (name: ':='; param: @GDBEnumDataDescriptorObj; hparam: @GDBEnumDataDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TEnum_let_TIdentificator)
    , (name: ':='; param: @GDBDoubleDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_let_TGDBInteger)
    , (name: '/'; param: @GDBIntegerDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_div_TGDBInteger)
    , (name: '/'; param: @GDBDoubleDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_div_TGDBInteger)
    , (name: '/'; param: @GDBIntegerDescriptorObj; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_div_TGDBDouble)
    , (name: '/'; param: @GDBDoubleDescriptorObj; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_div_TGDBDouble)
    , (name: '+'; param: @GDBDoubleDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_plus_TGDBInteger)
    , (name: '+'; param: @GDBIntegerDescriptorObj; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_plus_TGDBDouble)
    , (name: '+'; param: @GDBDoubleDescriptorObj; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_plus_TGDBDouble)
    , (name: '-'; param: @GDBIntegerDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_minus_TGDBInteger)
    , (name: '-'; param: @GDBIntegerDescriptorObj; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_minus_TGDBDouble)
    , (name: '-'; param: @GDBDoubleDescriptorObj; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_minus_TGDBDouble)
    , (name: '-'; param: @GDBDoubleDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_minus_TGDBInteger)
    , (name: '*'; param: @GDBDoubleDescriptorObj; hparam: @GDBIntegerDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_mul_TGDBInteger)
    , (name: '*'; param: @GDBIntegerDescriptorObj; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_mul_TGDBDouble)
    , (name: '*'; param: @GDBDoubleDescriptorObj; hparam: @GDBDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_mul_TGDBDouble)
    );
type
TFunctionTypeArray=array of functiontype;

var
  basicfunctionparam: TFunctionTypeArray;

implementation
uses UEnumDescriptor,log;
function TEnum_let_TIdentificator(var rez, hrez: vardesk): vardesk;
//var
//  r: vardesk;
begin
  PEnumDescriptor(rez.data.PTD)^.SetValueFromString(rez.data.Instance,hrez.name);
  result.name:='';
  result.username:='';
  result.data.Instance:=nil;
  result.data.PTD:=nil;
end;
function funcstackequalGDBString(str: TTypesArray; opstack: operandstack): GDBBoolean;
var
  i: GDBInteger;
begin
  result := true;
  for i := 1 to opstack.count do
    if str[i-1]<>opstack.stack[i].data.PTD then
                                             begin
                                                  result := false;
                                                  exit;
                                             end;
end;

function findbasicfunction(name: GDBString; opstack: operandstack): GDBInteger;
var
  i{, j}: GDBInteger;
begin
  result := 0;
  for i :=low(basicfunctionparam) to high(basicfunctionparam) do
  begin
    if name = basicfunctionparam[i].name then
    begin
      if length(basicfunctionparam[i].param) = opstack.count then
      begin
        if funcstackequalGDBString(basicfunctionparam[i].param, opstack) then
        begin
          result := i;
          system.exit;
        end;
      end
    end;
  end;
end;

procedure initvardesk(out vd: vardesk);
begin
  pGDBInteger(vd.data.Instance) := nil;
  //vd.vartypecustom := 0;
  vd.data.ptd:=nil;
  vd.name := '';
end;

procedure initoperandstack(out opstac: operandstack);
var
  i: GDBInteger;
begin
  for i := 1 to 10 do
    initvardesk(opstac.stack[i]);
  opstac.count := 0;
end;

function Cos_TGDBInteger(var stack: operandstack): vardesk;
var
  r: vardesk;
begin
  pGDBDouble(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{EF01E8D1-A060-4C72-B5A1-894B5AD95E65}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pdouble(r.data.Instance)^ := cos(pGDBInteger(stack.stack[1].data.Instance)^);
  result := r;
end;
function Cos_TGDBDouble(var stack: operandstack): vardesk;
var
  r: vardesk;
begin
  pGDBDouble(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{EF01E8D1-A060-4C72-B5A1-894B5AD95E65}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pdouble(r.data.Instance)^ := cos(pGDBDouble(stack.stack[1].data.Instance)^);
  result := r;
end;


function TGDBBoolean_let_TGDBBoolean(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBBooleanDescriptorOdj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{3B765FB8-0899-4BE5-B0B2-303EFA6397DC}',{$ENDIF}r.data.Instance,GDBBooleanDescriptorOdj.SizeInGDBBytes);
  PGDBBoolean(r.data.Instance)^ := PGDBBoolean(hrez.data.Instance)^;
  PGDBBoolean(rez.data.Instance)^ := PGDBBoolean(hrez.data.Instance)^;
  result := r;
end;

function TGDBDouble_let_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{16787BA2-CB34-474C-8111-51332666044A}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pdouble(r.data.Instance)^ := pdouble(hrez.data.Instance)^;
  pdouble(rez.data.Instance)^ := pdouble(hrez.data.Instance)^;
  result := r;
end;
function TGDBDouble_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{16787BA2-CB34-474C-8111-51332666044A}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pdouble(r.data.Instance)^ := pgdbinteger(hrez.data.Instance)^;
  pdouble(rez.data.Instance)^ := pgdbinteger(hrez.data.Instance)^;
  result := r;
end;


function TGDBInteger_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBIntegerDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{246D7A0D-55E4-4343-9471-D8B200D6136D}',{$ENDIF}r.data.Instance,GDBIntegerDescriptorObj.SizeInGDBBytes);
  pGDBInteger(r.data.Instance)^ := pGDBInteger(hrez.data.Instance)^;
  pGDBInteger(rez.data.Instance)^ := pGDBInteger(hrez.data.Instance)^;
  result := r;
end;
function TGDBByte_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBByteDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{ED860FE9-3A15-459D-B352-7FA4A3AE6F49}',{$ENDIF}r.data.Instance,GDBByteDescriptorObj.SizeInGDBBytes);
  pGDBByte(r.data.Instance)^ := pGDBInteger(hrez.data.Instance)^;
  pGDBByte(rez.data.Instance)^ := pGDBInteger(hrez.data.Instance)^;
  result := r;
end;

function TGDBString_let_TGDBString(var rez, hrez: vardesk): vardesk;
//var
  //r: vardesk;
  //ts:string;
begin
  pGDBInteger(result.data.Instance) := nil;
  result.data.ptd:=@GDBStringDescriptorObj;
  result.name := '';
  //data.Instance := nil;
  // r.data.Instance=nil then
                              GDBGetMem({$IFDEF DEBUGBUILD}'{ED860FE9-3A15-459D-B352-7FA4A3AE6F49}',{$ENDIF}result.data.Instance,GDBStringDescriptorObj.SizeInGDBBytes);
  if rez.data.Instance=nil then
                              GDBGetMem({$IFDEF DEBUGBUILD}'{ED860FE9-3A15-459D-B352-7FA4A3AE6F49}',{$ENDIF}rez.data.Instance,GDBStringDescriptorObj.SizeInGDBBytes)
                          else
                              GDBString(rez.data.Instance^):='';
  //GDBGetMem(r.pvalue, basetypearrayptr^.typearray[TGDBString].size);
  //pointer(ts):=hrez.data.Instance;
  //pointer(ts):=pointer(hrez.data.Instance^);
  GDBString(result.data.Instance^) := GDBString(hrez.data.Instance^);
  GDBString(rez.data.Instance^) := GDBString(hrez.data.Instance^);
  //r.pvalue := hrez.pvalue;
  //result := r;
  //GDBPointer(r.data.Instance^):=nil;
end;
function TGDBInteger_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBIntegerDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBIntegerDescriptorObj.SizeInGDBBytes);
  pGDBInteger(r.data.Instance)^ := pGDBInteger(rez.data.Instance)^-pGDBInteger(hrez.data.Instance)^;
  result := r;
end;
function TGDBInteger_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  PGDBDouble(r.data.Instance)^ := PGDBInteger(rez.data.Instance)^-PGDBDouble(hrez.data.Instance)^;
  result := r;
end;
function TGDBDouble_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  PGDBDouble(r.data.Instance)^ := PGDBDouble(rez.data.Instance)^-PGDBDouble(hrez.data.Instance)^;
  result := r;
end;
function TGDBDouble_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  PGDBDouble(r.data.Instance)^ := PGDBDouble(rez.data.Instance)^-PGDBInteger(hrez.data.Instance)^;
  result := r;
end;
function TGDBDouble_mul_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pGDBDouble(r.data.Instance)^ := pGDBDouble(rez.data.Instance)^*pGDBInteger(hrez.data.Instance)^;
  result := r;
end;
function TGDBInteger_mul_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBDouble(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{7A416715-3850-4B76-B2E6-F5FE45C775F8}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pGDBDouble(r.data.Instance)^ := pGDBInteger(rez.data.Instance)^ * pGDBDouble(hrez.data.Instance)^;
  result := r;
end;
function TGDBDouble_mul_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBDouble(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{7A416715-3850-4B76-B2E6-F5FE45C775F8}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pGDBDouble(r.data.Instance)^ := pGDBDouble(rez.data.Instance)^ * pGDBDouble(hrez.data.Instance)^;
  result := r;
end;
function TGDBInteger_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBIntegerDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBIntegerDescriptorObj.SizeInGDBBytes);
  pGDBInteger(r.data.Instance)^ := pGDBInteger(rez.data.Instance)^+pGDBInteger(hrez.data.Instance)^;
  result := r;
end;
function TGDBDouble_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  PGDBDouble(r.data.Instance)^ := PGDBDouble(rez.data.Instance)^+PGDBInteger(hrez.data.Instance)^;
  result := r;
end;
function TGDBInteger_plus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  PGDBDouble(r.data.Instance)^ := PGDBInteger(rez.data.Instance)^+PGDBDouble(hrez.data.Instance)^;
  result := r;
end;
function TGDBDouble_plus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  PGDBDouble(r.data.Instance)^ := PGDBDouble(rez.data.Instance)^+PGDBDouble(hrez.data.Instance)^;
  result := r;
end;
function Tnothing_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBIntegerDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{9E62203B-EF07-4775-A646-1030CA029C38}',{$ENDIF}r.data.Instance,GDBIntegerDescriptorObj.SizeInGDBBytes);
  pGDBInteger(r.data.Instance)^ := pGDBInteger(hrez.data.Instance)^;
  result := r;
end;

function Tnothing_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pdouble(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{31E6BE51-DA49-4ECC-9B63-43F3CCA367AD}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  PGDBDouble(r.data.Instance)^ := -(pdouble(hrez.data.Instance)^);
  result := r;
end;

function Tnothing_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBIntegerDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{BE0FF755-7D8B-4CDC-8717-7D28E970D1D9}',{$ENDIF}r.data.Instance,GDBIntegerDescriptorObj.SizeInGDBBytes);
  pGDBInteger(r.data.Instance)^ := -(pGDBInteger(hrez.data.Instance)^);
  result := r;
end;

function TGDBInteger_mul_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBInteger(r.data.Instance) := nil;
  r.data.ptd:=@GDBIntegerDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{7A416715-3850-4B76-B2E6-F5FE45C775F8}',{$ENDIF}r.data.Instance,GDBIntegerDescriptorObj.SizeInGDBBytes);
  pGDBInteger(r.data.Instance)^ := pGDBInteger(rez.data.Instance)^ * pGDBInteger(hrez.data.Instance)^;
  result := r;
end;
function TGDBInteger_div_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBDouble(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{7A416715-3850-4B76-B2E6-F5FE45C775F8}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pGDBDouble(r.data.Instance)^ := pGDBInteger(rez.data.Instance)^ / pGDBInteger(hrez.data.Instance)^;
  result := r;
end;
function TGDBInteger_div_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBDouble(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{7A416715-3850-4B76-B2E6-F5FE45C775F8}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pGDBDouble(r.data.Instance)^ := pGDBInteger(rez.data.Instance)^ / pGDBDouble(hrez.data.Instance)^;
  result := r;
end;
function TGDBDouble_div_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBDouble(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{7A416715-3850-4B76-B2E6-F5FE45C775F8}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pGDBDouble(r.data.Instance)^ := pGDBDouble(rez.data.Instance)^ / pGDBDouble(hrez.data.Instance)^;
  result := r;
end;
function TGDBDouble_div_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  pGDBDouble(r.data.Instance) := nil;
  r.data.ptd:=@GDBDoubleDescriptorObj;
  r.name := '';
  GDBGetMem({$IFDEF DEBUGBUILD}'{7A416715-3850-4B76-B2E6-F5FE45C775F8}',{$ENDIF}r.data.Instance,GDBDoubleDescriptorObj.SizeInGDBBytes);
  pGDBDouble(r.data.Instance)^ := pGDBDouble(rez.data.Instance)^ / pGDBInteger(hrez.data.Instance)^;
  result := r;
end;



function itbasicoperator(expr: GDBString): GDBInteger;
var
  i: GDBInteger;
begin
  result := 0;
  for i := 1 to basicoperatorcount do
    if expr = basicoperatorname[i].name then
    begin
      result := i;
      exit;
    end
end;

function itbasicfunction(expr: GDBString): GDBInteger;
var
  i: GDBInteger;
begin
  result := 0;
  for i := 1 to basicfunctioncount do
    if expr = basicfunctionname[i].name then
    begin
      result := i;
      exit;
    end
end;

function findbasicoperator(expr: GDBString; rez, hrez: vardesk): GDBInteger;
var
  i: GDBInteger;
  rezptd,hrezptd:PUserTypeDescriptor;
begin
  result := 0;
  if rez.data.PTD<>nil then
    if ((rez.data.PTD.GetTypeAttributes and ta_enum)>0) and
       (hrez.data.ptd=nil) and
       (hrez.name<>'') then
                           begin
                                result:=11;
                                exit;
                           end;
  begin
  if rez.data.ptd<>nil then
  if rez.data.ptd.TypeName='GDBXCoordinate' then
                                                rez.data.ptd:=rez.data.ptd;
  if hrez.data.ptd<>nil then
  if hrez.data.ptd.TypeName='GDBXCoordinate' then
                                                  rez.data.ptd:=rez.data.ptd;
  if rez.data.ptd<>nil then
                           rezptd:=rez.data.ptd^.GetFactTypedef
                       else
                           rezptd:=nil;
  if hrez.data.ptd<>nil then
                            hrezptd:=hrez.data.ptd^.GetFactTypedef
                        else
                            hrezptd:=nil;
  for i := 1 to basicoperatorparamcount do
    if (rezptd = basicoperatorparam[i].param) and (hrezptd = basicoperatorparam[i].hparam) and (expr = basicoperatorparam[i].name) then
    begin
      result := i;
      exit;
    end
  end
end;
var
  tv,tv1:functiontype;
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('langsystem.initialization');{$ENDIF}
     {if FPC_FULlVERSION>=20701}
     //foneGDBInteger:=TTypesArray.create(@GDBIntegerDescriptorObj);
     {ELSE}
     setlength(foneGDBInteger,1);foneGDBInteger[0]:=@GDBIntegerDescriptorObj;
     {ENDIF}
     {if FPC_FULlVERSION>=20701}
     //foneGDBDouble:=TTypesArray.create(@GDBDoubleDescriptorObj);
     {ELSE}
     setlength(foneGDBDouble,1);foneGDBDouble[0]:=@GDBDoubleDescriptorObj;
     {ENDIF}
     tv.name:='cos';tv.param:=foneGDBInteger;tv.addr:=Cos_TGDBInteger;
     tv1.name:='cos';tv1.param:=foneGDBDouble;tv1.addr:=Cos_TGDBDouble;
     {if FPC_FULlVERSION>=20701}
     //basicfunctionparam:=TFunctionTypeArray.create(tv,tv1);
     {ELSE}
     setlength(basicfunctionparam,2);
     basicfunctionparam[0]:=tv;
     basicfunctionparam[1]:=tv1;
     {ENDIF}
end.
