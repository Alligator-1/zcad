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
unit uzccommand_cllayeron;

{$INCLUDE def.inc}

interface
uses
  LazLogger,SysUtils,
  uzccommandsabstract,uzeentity,uzcdrawing,uzcdrawings,uzccommandsmanager,
  uzcstrconsts,uzcutils,zcchangeundocommand,uzbtypes,uzccommandsimpl,
  uzestyleslayers,uzcinterface;

implementation
const
  ClLayerOnCommandName='ClLayerOn';
function ClLayerOn_com(operands:TCommandOperands):TCommandResult;
var
  UndoStartMarkerPlaced:boolean;
  plp:PGDBLayerProp;
begin
  UndoStartMarkerPlaced:=false;
  plp:=drawings.GetCurrentDWG^.LayerTable.getAddres(operands);
  if plp<>nil then begin
    if plp^._on then begin
      ZCMsgCallBackInterface.TextMessage(format(rsLayerAlreadyOn,[operands]),TMWOHistoryOut);
      result:=cmd_error;
    end else begin
      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,ClLayerOnCommandName,true);
      with PushCreateTGChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,plp^._on)^ do begin
        plp^._on:=not plp^._on;
        ComitFromObj;
      end;
      zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
      result:=cmd_ok;
    end;
  end else begin
    ZCMsgCallBackInterface.TextMessage(format(rsLayerNotFound,[operands]),TMWOShowError);
    result:=cmd_error;
  end;
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@ClLayerOn_com,ClLayerOnCommandName,CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.