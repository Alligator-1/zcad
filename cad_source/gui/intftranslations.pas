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

unit intftranslations;
{$INCLUDE def.inc}

interface
uses strproc,lclproc,gettext,translations,sysinfo,sysutils,fileutil,log,forms;

type
    TmyPOFile = class(TPOFile)
                     function FindByIdentifier(const Identifier: String):TPOFileItem;
                     procedure SaveToFile(const AFilename: string);
                     procedure Add(const Identifier, OriginalValue, TranslatedValue,
                                   Comments, Context, Flags, PreviousID: string);
                     function Translate(const Identifier, OriginalValue: String): String;
                end;

function InterfaceTranslate(const Identifier, OriginalValue: String): String;
var
   PODirectory, Lang, FallbackLang: String;
   po: TmyPOFile;
   _UpdatePO:integer=0;
   _NotEnlishWord:integer=0;
   _DebugWord:integer=0;
implementation
function TmyPOFile.FindByIdentifier(const Identifier: String):TPOFileItem;
begin
     result:=TPOFileItem(FIdentifierToItem.Data[Identifier]);
end;
procedure TmyPOFile.SaveToFile(const AFilename: string);
begin
     inherited//self.f
end;
function TmyPOFile.Translate(const Identifier, OriginalValue: String): String;
var
  Item: TPOFileItem;
begin
  Item:=TPOFileItem(FIdentifierToItem.Data[Identifier]);
  if Item=nil then
    Item:=TPOFileItem(FOriginalToItem.Data[OriginalValue]);
  if Item<>nil then begin
    Result:=Item.Translation;
    if Result='' then Result:=OriginalValue;
  end else
    Result:=OriginalValue;
end;
procedure TmyPOFile.Add(const Identifier, OriginalValue, TranslatedValue,
  Comments, Context, Flags, PreviousID: string);
var
   t:boolean;
begin
     t:=self.FAllEntries;
     self.FAllEntries:=true;
     inherited;
     self.FAllEntries:=t;
end;

procedure createpo;
var
   AFilename:string;
begin
     if not sysinfo.sysparam.updatepo then
     begin
           if Lang<>'' then
                           begin
                                AFilename:=Format(PODirectory + 'zcad.%s.po',[Lang]);
                                if FileExistsUTF8(AFilename) then
                                                                 begin
                                                                      po:=TmyPOFile.Create(AFilename);
                                                                 end;
                           end;
           if (FallbackLang<>'')and(not assigned(po)) then
                           begin
                                AFilename:=Format(PODirectory + 'zcad.%s.po',[FallbackLang]);
                                if FileExistsUTF8(AFilename) then
                                                                 begin
                                                                      po:=TmyPOFile.Create(AFilename);
                                                                 end;
                           end;
           if (not assigned(po)) then
                                     begin
                                          po:=TmyPOFile.Create;
                                     end;

     end
     else
         begin
              AFilename:=(PODirectory + 'zcad.po');
              if FileExistsUTF8(AFilename) then
                                               begin
                                                    po:=TmyPOFile.Create(AFilename,true);
                                               end
                                           else
                                               begin
                                                    log.programlog.LogOutStr('Founf command line swith "UpdatePO". File "zcad.po" not found. STOP!',0);
                                                    halt(0);
                                               end;
         end;
end;
function InterfaceTranslate(const Identifier, OriginalValue: String): String;
var
   s:string;
  Item: TPOFileItem;

begin
     if Identifier='TTextJustify~jstm' then
                                s:=s;
    log.programlog.LogOutStr(Identifier+' '+OriginalValue,0);
    result:=po.Translate({Identifier}'', OriginalValue);

    if sysinfo.sysparam.updatepo then
     begin
          Item:=TPOFileItem(po.FIdentifierToItem.Data[Identifier]);
          if not assigned(item) then
          begin
               if (pos('**',OriginalValue)>0)or(pos('??',OriginalValue)>0)then
               begin
                    inc(_DebugWord);
               end
               else
               begin
               if (utf8length(Identifier)=length(Identifier))and
                  (utf8length(OriginalValue)=length(OriginalValue)) then
               begin
                    po.Add(Identifier,OriginalValue, {TranslatedValue}'', {Comments}'',
                        {Context}'', {Flags}'', {PreviousID}'');
                    inc(_UpdatePO);
                    po.SaveToFile(PODirectory + 'zcad.po');
               end
                  else
                      inc(_NotEnlishWord);

               end;
          end
          else
          begin
               if item.Original<>OriginalValue then
                                                   begin
                                                   item.ModifyFlag('fuzzy',true);
                                                   item.Original:=OriginalValue;
                                                   end;
          end;

     end;
end;

procedure initialize;
    begin
      PODirectory := sysinfo.sysparam.programpath+'languades/';
      GetLanguageIDs(Lang, FallbackLang); // определено в модуле gettext
      createpo;
      if not sysinfo.sysparam.updatepo then
                                           TranslateResourceStrings(po);
      //TranslateUnitResourceStrings('aboutwnd',PODirectory + 'zcad.%s.po', Lang, FallbackLang);
      //MessageDlg('Title', 'Text', mtInformation, [mbOk, mbCancel, mbYes], 0);

      TranslateUnitResourceStrings('anchordockstr', PODirectory + 'anchordockstr.%s.po', Lang, FallbackLang)
    end;

begin
{$IFDEF DEBUGINITSECTION}log.LogOut('intftranslations.initialization');{$ENDIF}
initialize;
end.
