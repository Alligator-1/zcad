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

unit ugdbfont;
{$INCLUDE def.inc}
interface
uses ugdbshxfont,memman,UGDBPolyPoint3DArray,gdbobjectsconstdef,UGDBPoint3DArray,strproc,UGDBOpenArrayOfByte{,UGDBPoint3DArray},gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,{UGDBVisibleOpenArray,}geometry{,gdbEntity,UGDBOpenArrayOfPV};
type
{EXPORT+}
PGDBfont=^GDBfont;
GDBfont=object(GDBNamedObject)
    fontfile:GDBString;
    Internalname:GDBString;
    font:{PSHXFont}PBASEFont;
    constructor initnul;
    constructor init(n:GDBString);
    procedure ItSHX;
    procedure ItFFT;
    destructor done;virtual;
    function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function GetOrReplaceSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
    procedure CreateSymbol(var Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;_symbol:GDBInteger;const objmatrix:DMatrix4D;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;ln:GDBInteger);
  end;
{EXPORT-}
var
   pbasefont: PGDBfont;
implementation
uses {math,}log;
procedure GDBfont.CreateSymbol(var Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;_symbol:GDBInteger;const objmatrix:DMatrix4D;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;ln:GDBInteger);
var
  psymbol: GDBPointer;
  {i, }j, k: GDBInteger;
  len: GDBWord;
  //matr,m1: DMatrix4D;
  v:GDBvertex4D;
  //pv:GDBPolyVertex2D;
  pv3:GDBPolyVertex3D;

  //plp,plp2:pgdbvertex;
  //lp,tv:gdbvertex;
  //pl:GDBPoint3DArray;
  //ispl:gdbboolean;
  //ir:itrec;
  psyminfo:PGDBsymdolinfo;
  //deb:GDBsymdolinfo;
begin
  if _symbol=100 then
                      _symbol:=_symbol;
  {if _symbol<256 then
                    _symbol:=ach2uch(_symbol);}
  if _symbol=32 then
                      _symbol:=_symbol;

  psyminfo:=self.GetOrReplaceSymbolInfo(integer(_symbol));
  //deb:=psyminfo^;
  psymbol := self.font.GetSymbolDataAddr(psyminfo.addr);
  if {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size <> 0 then
    for j := 1 to {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size do
    begin
      case GDBByte(psymbol^) of
        2:
          begin
            inc(pGDBByte(psymbol), sizeof(GDBLineID));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);
            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=0;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;

            v:=VectorTransform(v,objmatrix);

            pv3.coord:=PGDBvertex(@v)^;

            //tv:=pv3.coord;
            pv3.LineNumber:=ln;

            pv3.count:=0;
            Vertex3D_in_WCS_Array.add(@pv3);

            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:=0;

            pv3.LineNumber:=ln;

            Vertex3D_in_WCS_Array.add(@pv3);


            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=0;
            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
          end;
        4:
          begin
            inc(pGDBByte(psymbol), sizeof(GDBPolylineID));
            len := GDBWord(psymbol^);
            inc(pGDBByte(psymbol), sizeof(GDBWord));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);
            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=len;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:=len;

            //tv:=pv3.coord;
            pv3.LineNumber:=ln;

            Vertex3D_in_WCS_Array.add(@pv3);


            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            k := 1;
            while k < len do //for k:=1 to len-1 do
            begin
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;

            v:=VectorTransform(v,matr);

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=-1;

            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:={-1}k-len+1;

            pv3.LineNumber:=ln;
            //tv:=pv3.coord;

            Vertex3D_in_WCS_Array.add(@pv3);


            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            inc(k);
            end;
          end;
      end;
    end;
  end;
constructor GDBfont.initnul;
begin
     inherited;
     pointer(fontfile):=nil;
end;
destructor GDBfont.done;
begin
     fontfile:='';
     Internalname:='';
     if font<>nil then
                      font.done;
     inherited;
end;
procedure GDBfont.ItSHX;
begin
     GDBGetMem(font,sizeof(SHXFont));
     PSHXFont(font)^.init;
end;
procedure GDBfont.ItFFT;
begin
     GDBGetMem(font,sizeof(TTFFont));
     PTTFFont(font)^.init;
end;
constructor GDBfont.Init;
begin
     initnul;
     inherited;
     font:=nil;
     {GDBGetMem(font,sizeof(SHXFont));
     font^.init;}
end;
function GDBfont.findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   //debug:GDBInteger;
begin
     pobj:=font.unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           //debug:=pobj^.symbol;
           //debug:=pobj^.symbolinfo.addr;
           if pobj^.symbol=symbol then
                                      begin
                                           result:=@pobj^.symbolinfo;
                                           exit;
                                      end;
           pobj:=font.unisymbolinfo.iterate(ir);
     until pobj=nil;
     result:=nil;
end;
function GDBfont.GetOrReplaceSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
//var
   //usi:GDBUNISymbolInfo;
begin
     if symbol=49 then
                        symbol:=symbol;
     if symbol<256 then
                       begin
                       result:=@self.font.symbolinfo[symbol];
                       if result^.addr=0 then
                                        result:=@self.font.symbolinfo[ord('?')];
                       end
                   else
                       //result:=@self.symbolinfo[ord('?')]
                       begin
                            result:=findunisymbolinfo(symbol);
                            //result:=@symbolinfo[ord('?')];
                            //usi.symbolinfo:=result^;;
                            if result=nil then
                            begin
                                 result:=@self.font.symbolinfo[ord('?')];
                                 exit;
                            end;
                            if result^.addr=0 then
                                             result:=@self.font.symbolinfo[ord('?')];

                       end;
end;
function GDBfont.GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   usi:GDBUNISymbolInfo;
begin
     if symbol<256 then
                       result:=@self.font.symbolinfo[symbol]
                   else
                       //result:=@self.symbolinfo[0]
                       begin
                            result:=findunisymbolinfo(symbol);
                            if result=nil then
                            begin
                                 usi.symbol:=symbol;
                                 usi.symbolinfo.addr:=0;
                                 usi.symbolinfo.NextSymX:=0;
                                 usi.symbolinfo.SymMaxY:=0;
                                 usi.symbolinfo.h:=0;
                                 usi.symbolinfo.size:=0;
                                 usi.symbolinfo.w:=0;
                                 usi.symbolinfo.SymMinY:=0;
                                 usi.symbolinfo.LatestCreate:=false;
                                 killstring(usi.symbolinfo.Name);
                                 font.unisymbolinfo.Add(@usi);

                                 result:=@(PGDBUNISymbolInfo(font.unisymbolinfo.getelement(font.unisymbolinfo.Count-1))^.symbolinfo);
                            end;
                       end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBFont.initialization');{$ENDIF}
end.
