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

unit uzebeziersolver;
{$INCLUDE def.inc}
interface
uses uzgprimitivescreator,uzgprimitives,uzglvectorobject,uzegluinterface,gvector,uzbmemman,
     gzctnrvectortypes,uzbgeomtypes,UGDBOpenArrayOfByte,uzbtypesbase,sysutils,uzbtypes,uzegeometry,gzctnrstl;
type
TPointAttr=(TPA_OnCurve,TPA_NotOnCurve);
TSolverMode=(TSM_WaitStartCountur,TSM_WaitStartPoint,TSM_WaitPoint);
TVector2D={specialize }TVector<GDBVertex2D>;
TDummyData=record
                 v:GDBFontVertex2D;
                 attr:TPointAttr;
                 index:TArrayIndex;
           end;
TMyVectorArrayGDBFontVertex2D=TMyVectorArray<{GDBFontVertex2D}TDummyData>;
TBezierSolver2D=class
                     FArray:TVector2D;
                     FMode:TSolverMode;
                     BOrder:integer;
                     VectorData:PZGLVectorObject;
                     shxsize:PGDBWord;
                     scontur,truescontur:GDBvertex2D;
                     sconturpa:TPointAttr;
                     Conturs:TMyVectorArrayGDBFontVertex2D;
                     LastOncurveLineAdded:boolean;
                     constructor create;
                     destructor Destroy;override;
                     procedure AddPoint(x,y:double;pa:TPointAttr);overload;
                     procedure AddPoint(p:GDBvertex2D;pa:TPointAttr);overload;
                     procedure ChangeMode(Mode:TSolverMode);
                     procedure EndCountur;
                     procedure StartCountur;
                     procedure DrawCountur;
                     procedure ClearConturs;
                     procedure solve;
                     function getpoint(t:gdbdouble):GDBvertex2D;
                     procedure AddPointToContur(x,y:fontfloat;attr:TPointAttr);
                end;
var
   BS:TBezierSolver2D;
   triangle:array[0..2] of integer;
implementation
//uses {math,}log;
procedure TBezierSolver2D.AddPointToContur(x,y:fontfloat;attr:TPointAttr);
var
   {tff1,tff0,}tff:{GDBFontVertex2D}TDummyData;
   //a: GDBDouble;
begin
    //if attr=TPA_NotOnCurve then exit;
    tff.v.x:=x;
    tff.v.y:=y;
    tff.attr:=attr;
    Conturs.AddDataToCurrentArray(tff);
end;
constructor TBezierSolver2D.create;
begin
     FArray:=TVector2D.Create;
     Conturs:=TMyVectorArrayGDBFontVertex2D.Create;
     FArray.Reserve(10);
     FMode:=TSM_WaitStartCountur;
end;
destructor TBezierSolver2D.Destroy;
begin
     FArray.Destroy;
     Conturs.destroy;
     inherited;
end;

procedure TBezierSolver2D.AddPoint(x,y:double;pa:TPointAttr);
var
   p:GDBvertex2D;
begin
     p.x:=x;
     p.y:=y;
     AddPoint(p,pa);
end;
procedure TBezierSolver2D.AddPoint(p:GDBvertex2D;pa:TPointAttr);
begin
     case FMode of
     TSM_WaitStartCountur:begin
                             LastOncurveLineAdded:=false;
                             scontur:=p;
                             sconturpa:=pa;
                             if pa=TPA_OnCurve then
                                                   FArray.PushBack(p);
                             ChangeMode(TSM_WaitPoint);
                        end;
     TSM_WaitStartPoint:begin
                             FArray.PushBack(p);
                             ChangeMode(TSM_WaitPoint);
                        end;
     TSM_WaitPoint:begin
                        if pa=TPA_OnCurve then
                        begin
                             FArray.PushBack(p);
                             ChangeMode(TSM_WaitStartPoint);
                             AddPoint(p,pa);
                        end
                        else
                            begin
                                 if FArray.Size=0 then
                                 begin
                                      truescontur:=Vertexmorph(scontur,p,0.5);
                                      AddPoint(truescontur,TPA_OnCurve);
                                      AddPoint(p,pa);
                                 end
                            else if FArray.Size=2 then
                                 begin
                                      AddPoint(Vertexmorph(FArray.Back,p,0.5),TPA_OnCurve);
                                      AddPoint(p,pa);
                                 end
                                 else
                                 begin
                                      FArray.PushBack(p);
                                 end;
                            end;
                   end;
     end;
end;
procedure TBezierSolver2D.ChangeMode(Mode:TSolverMode);
begin
  case Mode of
  TSM_WaitStartPoint:begin
                          if FMode=TSM_WaitPoint then
                          begin
                               solve;
                               FArray.Clear;
                          end;
                     end;
  end;
  FMode:=mode;
end;
procedure TBezierSolver2D.EndCountur;
begin
  //case fMode of
  //TSM_WaitStartPoint:begin

  if sconturpa=TPA_OnCurve then
                               AddPoint(scontur,TPA_OnCurve)
                           else
                               begin
                                    AddPoint(scontur,TPA_NotOnCurve);
                                    AddPoint(truescontur,TPA_OnCurve);
                               end;
  //                   end;
  //end;
  //solve;
  ChangeMode(TSM_WaitStartCountur);
  farray.Clear;
end;
procedure TBezierSolver2D.StartCountur;
begin
     Conturs.SetCurrentArray(Conturs.AddArray);
end;
procedure TBezierSolver2D.ClearConturs;
begin
  Conturs.destroy;
  Conturs:=TMyVectorArrayGDBFontVertex2D.Create;
end;

procedure TBezierSolver2D.DrawCountur;
var
   i,j,simpleindex,polyindex,ii:integer;
   ptpl:PTLLPolyLine;
begin
     for i:=0 to Conturs.VArray.Size-1 do
     begin
          polyindex:={VectorData.LLprimitives.}DefaultLLPCreator.CreateLLPolyLine(VectorData.LLprimitives,VectorData.GeomData.Vertex3S.Count,Conturs.VArray[i].Size-1,true);
          ptpl:=pointer(VectorData.LLprimitives.getDataMutable(polyindex));
          inc(shxsize^);
          for j:=0 to Conturs.VArray[i].Size-1 do
          begin
               ii:=VectorData.GeomData.Add2DPoint(Conturs.VArray[i].mutable[j]^.v.x,Conturs.VArray[i].mutable[j]^.v.y);
               Conturs.VArray[i].mutable[j]^.index:=ii;
               if Conturs.VArray[i].mutable[j]^.attr=TPA_OnCurve then
                                                                     begin
                                                                          simpleindex:=VectorData.GeomData.Indexes.PushBackData(Conturs.VArray[i].mutable[j]^.index);
                                                                          ptpl^.AddSimplifiedIndex(simpleindex);
                                                                     end;
          end;
     end;
end;

function TBezierSolver2D.getpoint(t:gdbdouble):GDBvertex2D;
var
   i,j,k,rindex:integer;
begin
     rindex:=BOrder-1;
     j:=BOrder;
     k:=j;
     for i:=0 to round((BOrder+2)*(BOrder-1)/2) do
     begin
          dec(k);
          if k>0 then
          begin
          inc(rindex);
          farray[rindex]:=Vertexmorph(FArray[i],FArray[i+1],t);
          end
          else
          begin
               dec(j);
               k:=j;
          end;
     end;
     result:=farray[rindex];
end;
procedure TBezierSolver2D.solve;
var
   size,j,n:integer;
   p,prevp:GDBvertex2D;
begin
     BOrder:=FArray.Size;
     if border<3 then
     begin
          if border=2 then
          begin
          if not LastOncurveLineAdded then
          AddPointToContur(FArray[0].x,FArray[0].y,TPA_OnCurve);
          AddPointToContur(FArray[1].x,FArray[1].y,TPA_OnCurve);
          LastOncurveLineAdded:=true;
          end;
          exit;
     end;
     size:=round((BOrder+2)*(BOrder-1)/2)+1;
     FArray.Resize(size);
     n:=BOrder;//<----------------------------
     for j:=1 to n-1 do
     begin
          p:=getpoint(j/n);
          //addgcross(VectorData,shxsize^,p.x,p.y);
          if j>1 then
                     AddPointToContur(prevp.x,prevp.y,TPA_NotOnCurve)
                 else
                     begin
                       if not LastOncurveLineAdded then;
                       AddPointToContur(FArray[0].x,FArray[0].y,TPA_OnCurve);
                     end;
          prevp:=p;
     end;
          AddPointToContur(p.x,p.y,TPA_NotOnCurve);
     LastOncurveLineAdded:=false;
end;
initialization
  BS:=TBezierSolver2D.create;
finalization
  bs.Destroy;
end.
