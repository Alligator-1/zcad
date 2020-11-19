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
{$mode delphi}
unit uzccommand_rebuildtree;

{$INCLUDE def.inc}

interface
uses
  uzccommandsabstract,uzccommandsimpl,
  uzelongprocesssupport,
  uzcdrawings,
  uzcinterface,
  uzcutils;

implementation

function RebuildTree_com(operands:TCommandOperands):TCommandResult;
var
  lpsh:TLPSHandle;
begin
  lpsh:=LPS.StartLongProcess(drawings.GetCurrentROOT.ObjArray.count,'Rebuild drawing spatial',nil);
  drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
  LPS.EndLongProcess(lpsh);
  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  clearcp;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

initialization
  CreateCommandFastObjectPlugin(@RebuildTree_com,'RebuildTree',CADWG,0);
end.