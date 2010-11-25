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

unit iodxf;
{$INCLUDE def.inc}
interface
uses fileutil,UGDBTextStyleArray,varman,geometry,GDBSubordinated,shared,gdbasetypes{,GDBRoot},log,GDBGenericSubEntry,SysInfo,gdbase, GDBManager, {OGLtypes,} sysutils{, strmy}, memman, UGDBDescriptor,gdbobjectsconstdef,
     UGDBObjBlockdefArray,UGDBOpenArrayOfTObjLinkRecord{,varmandef},UGDBOpenArrayOfByte,UGDBVisibleOpenArray,GDBEntity{,GDBBlockInsert,GDBCircle,GDBArc,GDBPoint,GDBText,GDBMtext,GDBLine,GDBPolyLine,GDBLWPolyLine},TypeDescriptors;
type
  entnamindex=record
                    entname:GDBString;
              end;
const
     acadentsupportcol=10;
     entnamtable:array[1..acadentsupportcol]of entnamindex=
     (
     (entname:'POINT'),
     (entname:'LINE'),
     (entname:'CIRCLE'),
     (entname:'POLYLINE'),
     (entname:'TEXT'),
     (entname:'ARC'),
     (entname:'INSERT'),
     (entname:'MTEXT'),
     (entname:'LWPOLYLINE'),
     (entname:'3DFACE')
     );
type
  dxfhandlerec = record
    old, nev: GDBPlatformint;
  end;
  dxfhandlerecarray = array[0..300] of dxfhandlerec;
  pdxfhandlerecopenarray = ^dxfhandlerecopenarray;
  dxfhandlerecopenarray = record
    count: GDBInteger;
    arr: dxfhandlerecarray;
  end;
  TLoadOpt=(TLOLoad,TLOMerge);
const
  eol: GDBString = #13 + #10;
{$IFDEF DEBUGBUILD}
var i2:GDBInteger;
{$ENDIF}
var FOC:GDBInteger;
    phandlearray: pdxfhandlerecopenarray;
procedure addfromdxf(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
procedure savedxf2000(name: GDBString; PDrawing:PTDrawing);
procedure saveZCP(name: GDBString; gdb: PGDBDescriptor);
procedure LoadZCP(name: GDBString; gdb: PGDBDescriptor);
implementation
uses GDBBlockDef,mainwindow,UGDBLayerArray;
function dxfhandlearraycreate(col: GDBInteger): GDBPointer;
var
  temp: pdxfhandlerecopenarray;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{D0FC4FBD-35D4-4E1A-A5E0-6D74D0516215}',{$ENDIF}GDBPointer(temp), sizeof(GDBInteger) + col * sizeof(dxfhandlerec));
  temp^.count := 0;
  result := temp;
end;

procedure pushhandle(p: pdxfhandlerecopenarray; old, nev: GDBPlatformint);
begin
  p^.arr[p^.count].old := old;
  p^.arr[p^.count].nev := nev;
  inc(p^.count);
end;

function getnevhandle(p: pdxfhandlerecopenarray; old: GDBPlatformint): GDBPlatformint;
var
  i: GDBInteger;
begin
  for i := 0 to p^.count - 1 do
    if p^.arr[i].old = old then
    begin
      result := p^.arr[i].nev;
      exit;
    end;
  result := 0;
end;

function getoldhandle(p: pdxfhandlerecopenarray; nev: GDBLongword): GDBLongword;
var
  i: GDBInteger;
begin
  for i := 0 to p^.count - 1 do
    if p^.arr[i].nev = nev then
    begin
      result := p^.arr[i].old;
      exit;
    end;
  result := 0;
end;
function entname2GDBID(name:GDBString):GDBInteger;
var i:GDBInteger;
begin
     result:=-1;
     for i:=1 to acadentsupportcol do
          if uppercase(entnamtable[i].entname)=uppercase(name) then
          begin
               result:=i;
               exit;
          end;
end;
procedure gotodxf(var f: GDBOpenArrayOfByte; fcode: GDBInteger; fname: GDBString);
var
  byt: GDBByte;
  s: GDBString;
  error: GDBInteger;
begin
  while f.notEOF do
  begin
    s := f.readGDBString;
    val(s, byt, error);
    if error <> 0 then
      s := s{чето тут не так};
    s := f.readGDBString;
    if (byt = fcode) and (s = fname) then
      exit;
  end;
end;
procedure addentitiesfromdxf(var f: GDBOpenArrayOfByte;exitGDBString: GDBString;owner:PGDBObjSubordinated);
var
//  byt,LayerColor: GDBInteger;
  s{, sname, sx1, sy1, sz1,scode,LayerName}: GDBString;
//  ErrorCode,GroupCode: GDBInteger;

objid: GDBInteger;
  pobj,postobj: PGDBObjEntity;
//  tp: PGDBObjBlockdef;
  newowner:PGDBObjSubordinated;
  m4:DMatrix4D;
  trash:boolean;
  additionalunit:TUnit;
begin
  additionalunit.init('temparraryunit');
  additionalunit.InterfaceUses.addnodouble(@SysUnit);
  while (f.notEOF) and (s <> exitGDBString) do
  begin

    MainFormN.ProcessLongProcess(f.ReadPos);

    s := f.readGDBString;
    objid:=entname2GDBID(s);
    if objid>0 then
    begin
    if owner <> nil then
      begin
        {$IFDEF TOTALYLOG}programlog.logoutstr('AddEntitiesFromDXF.Found primitive '+s,0);{$ENDIF}
        {$IFDEF DEBUGBUILD}inc(i2);if i2=4349 then
                                                  i2:=i2;{$ENDIF}
        pobj := {po^.CreateInitObj(objid,owner)}CreateInitObjFree(objid,nil);
        PGDBObjEntity(pobj)^.LoadFromDXF(f,@additionalunit);
        pointer(postobj):=PGDBObjEntity(pobj)^.FromDXFPostProcessBeforeAdd(@additionalunit);
        trash:=false;
        if postobj=nil  then
                            begin
                                newowner:=owner;
                                if PGDBObjEntity(pobj).PExtAttrib<>nil then
                                begin
                                     if PGDBObjEntity(pobj).PExtAttrib.Handle>200 then
                                                                                      pushhandle(phandlearray,PGDBObjEntity(pobj).PExtAttrib.Handle,GDBPlatformint(pobj));
                                     if PGDBObjEntity(pobj).PExtAttrib.OwnerHandle>200 then
                                                                                      newowner:=pointer(getnevhandle(phandlearray,PGDBObjEntity(pobj).PExtAttrib.OwnerHandle));
                                     if PGDBObjEntity(pobj).PExtAttrib.OwnerHandle=h_trash then
                                                                                      trash:=true;


                                end;
                                if newowner=nil then
                                                    begin
                                                         historyoutstr('Warning! OwnerHandle $'+inttohex(PGDBObjEntity(pobj).PExtAttrib.OwnerHandle,8)+' not found');
                                                         newowner:=owner;
                                                    end;

                                if not trash then
                                if (newowner<>owner) then
                                begin
                                     m4:=PGDBObjEntity(newowner)^.getmatrix^;
                                     MatrixInvert(m4);
                                     pobj^.transform(m4);
                                end;

                                if not trash then
                                begin
                                 newowner.AddMi(@pobj);
                                 if foc=0 then
                                              PGDBObjEntity(pobj)^.BuildGeometry;
                                 if foc=0 then
                                              PGDBObjEntity(pobj)^.format;
                                 if foc=0 then PGDBObjEntity(pobj)^.FromDXFPostProcessAfterAdd;
                                end
                                   else
                                       begin
                                 pobj.done;
                                 GDBFreeMem(pointer(pobj));

                                       end;

                            end
                        else
                            begin
                                newowner:=owner;
                                if PGDBObjEntity(pobj).PExtAttrib<>nil then
                                begin
                                     if PGDBObjEntity(pobj).PExtAttrib.OwnerHandle>200 then
                                                                                      newowner:=pointer(getnevhandle(phandlearray,PGDBObjEntity(pobj).PExtAttrib.OwnerHandle));
                                end;
                                if newowner<>nil then
                                begin
                                if PGDBObjEntity(pobj).PExtAttrib<>nil then
                                begin
                                     if PGDBObjEntity(pobj).PExtAttrib.Handle>200 then
                                                                                      pushhandle(phandlearray,PGDBObjEntity(pobj).PExtAttrib.Handle,GDBPlatformint(postobj));
                                end;
                                if newowner<>owner then
                                begin
                                     m4:=PGDBObjEntity(newowner)^.getmatrix^;
                                     MatrixInvert(m4);
                                     postobj^.transform(m4);
                                end;

                                 newowner.AddMi(@postobj);
                                 pobj.OU.CopyTo(@PGDBObjEntity(postobj)^.ou);
                                 pobj.done;
                                 GDBFreeMem(pointer(pobj));
                                 if foc=0 then PGDBObjEntity(postobj)^.BuildGeometry;
                                 if foc=0 then
                                              PGDBObjEntity(postobj)^.FormatAfterDXFLoad;
                                 if foc=0 then PGDBObjEntity(postobj)^.FromDXFPostProcessAfterAdd;
                                end
                                   //else
                                   //    newowner:=newowner;
                            end;
      end;
      additionalunit.free;
    end;
  end;
  additionalunit.done;
end;
procedure addfromdxf12(var f:GDBOpenArrayOfByte;exitGDBString: GDBString;owner:PGDBObjSubordinated;LoadMode:TLoadOpt);
var
  {byt,}LayerColor: GDBInteger;
  s, sname{, sx1, sy1, sz1},scode,LayerName: GDBString;
  ErrorCode,GroupCode: GDBInteger;

//objid: GDBInteger;
//  pobj,postobj: PGDBObjEntity;
  tp: PGDBObjBlockdef;
begin
  {$IFDEF TOTALYLOG}programlog.logoutstr('AddFromDXF12',lp_IncPos);{$ENDIF}
  while (f.notEOF) and (s <> exitGDBString) do
  begin

  MainFormN.ProcessLongProcess(f.ReadPos);

    s := f.readGDBString;
    if s = 'LAYER' then
    begin
      {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer table',lp_IncPos);{$ENDIF}
      repeat
            scode := f.readGDBString;
            sname := f.readGDBString;
            val(scode,GroupCode,ErrorCode);
      until GroupCode=0;
      repeat
        if sname='ENDTAB' then system.break;
        if sname<>'LAYER' then FatalError('''LAYER'' expected but '''+sname+''' found');
        repeat
              scode := f.readGDBString;
              sname := f.readGDBString;
              val(scode,GroupCode,ErrorCode);
              case GroupCode of
                               2:LayerName:=sname;
                               62:val(sname,LayerColor,ErrorCode);
              end;{case}
        until GroupCode=0;
        {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer '+LayerName,0);{$ENDIF}
        gdb.GetCurrentDWG.LayerTable.addlayer(LayerName,LayerColor,-3,true,false,true);
      until sname='ENDTAB';
      {$IFDEF TOTALYLOG}programlog.logoutstr('end; {layer table}',lp_DecPos);{$ENDIF}
    end
    else if s = 'BLOCKS' then
    begin
      {$IFDEF TOTALYLOG}programlog.logoutstr('Found block table',lp_IncPos);{$ENDIF}
      sname := '';
      repeat
        if sname = '  2' then
          if (s = '$MODEL_SPACE') or (s = '$PAPER_SPACE') then
          begin
            while (s <> 'ENDBLK') do
              s := f.readGDBString;
          end
          else
          begin
            tp := gdb.GetCurrentDWG.BlockDefArray.create(s);
            programlog.logoutstr('Found block '+s+';',lp_IncPos);
            {addfromdxf12}addentitiesfromdxf(f, 'ENDBLK',tp);
            programlog.logoutstr('end; {block '+s+'}',lp_DecPos);
          end;
        sname := f.readGDBString;
        s := f.readGDBString;
      until (s = 'ENDSEC');
      {$IFDEF TOTALYLOG}programlog.logoutstr('end; {block table}',lp_DecPos);{$ENDIF}
    end
    else if s = 'ENTITIES' then
    begin
         {$IFDEF TOTALYLOG}programlog.logoutstr('Found entities section',lp_IncPos);{$ENDIF}
         addentitiesfromdxf(f, 'EOF',owner);;
         {$IFDEF TOTALYLOG}programlog.logoutstr('end {entities section}',lp_DecPos);{$ENDIF}
    end;
  end;
  {$IFDEF TOTALYLOG}programlog.logoutstr('end; {AddFromDXF12}',lp_decPos);{$ENDIF}
end;
procedure addfromdxf2000(var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
var
  byt: GDBInteger;
  error: GDBInteger;
  s, sname, lname, lcolor, llw: String;
  tp: PGDBObjBlockdef;
  oo,ll,pp:GDBBoolean;
  blockload:boolean;

  tstyle:GDBTextStyle;
begin
  blockload:=false;
  {$IFDEF TOTALYLOG}programlog.logoutstr('AddFromDXF2000',lp_IncPos);{$ENDIF}
  repeat
    gotodxf(f, 0, 'SECTION');
    if not f.notEOF then
      exit;
    s := f.readGDBString;
    s := f.readGDBString;
    if s = 'TABLES' then
    begin
      if not f.notEOF then
        exit;
      s := f.readGDBString;
      s := f.readGDBString;
      while s = 'TABLE' do
      begin
        if not f.notEOF then
          exit;
        s := f.readGDBString;
        s := f.readGDBString;

        if s = 'CLASSES' then
        begin
          gotodxf(f, 0, 'ENDTAB');
        end
        else
          if s = 'APPID' then
          begin
            gotodxf(f, 0, 'ENDTAB');
          end
          else
            if s = 'BLOCK_RECORD' then
            begin
              gotodxf(f, 0, 'ENDTAB');
            end
            else
              if s = 'DIMSTYLE' then
              begin
                gotodxf(f, 0, 'ENDTAB');
              end
              else
                if s = 'LAYER' then
                begin
                  {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer table',lp_IncPos);{$ENDIF}
                  gotodxf(f, 0, 'LAYER');

                  while s = 'LAYER' do
                  begin
                    byt := 2;
                    oo:=true;
                    ll:=false;
                    pp:=true;
                    while byt <> 0 do
                    begin
                      s := f.readGDBString;
                      byt := strtoint(s);
                      s := f.readGDBString;
                      case byt of
                        2:
                          begin
                            lname := s;
                          end;
                        62:
                          begin
                            lcolor := s;
                            if strtoint(lcolor)<0 then begin
                                                            oo:=false;
                                                       end;
                          end;
                        370:
                          begin
                            llw := s;
                          end;
                        70:
                          begin
                               if (strtoint(s)and 4)<>0 then
                                                                 begin
                                                                      ll:=true;
                                                                 end;
                           end;
                        290:
                          begin
                               if (strtoint(s)and 4)=0 then
                                                            begin
                                                                 pp:=false;
                                                            end;
                           end;


                      end;
                    end;
                    gdb.GetCurrentDWG.LayerTable.addlayer(lname, abs(strtoint(lcolor)), strtoint(llw),oo,ll,pp);
                    {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer '+lname,0);{$ENDIF}
                  end;
                  {$IFDEF TOTALYLOG}programlog.logoutstr('end; {layer table}',lp_DecPos);{$ENDIF}
          //gotodxf(f, 0, 'ENDTAB');
                end
                else
                  if s = 'LTYPE' then
                  begin
                    gotodxf(f, 0, 'ENDTAB');
                  end
                  else
                    if s = 'STYLE' then
                    {begin
                      gotodxf(f, 0, 'ENDTAB');
                    end}
                    begin
                      {$IFDEF TOTALYLOG}programlog.logoutstr('Found style table',lp_IncPos);{$ENDIF}
                      gotodxf(f, 0, 'STYLE');

                      while s = 'STYLE' do
                      begin
                        tstyle.name:='';
                        tstyle.pfont:=nil;
                        tstyle.prop.oblique:=0;
                        tstyle.prop.size:=1;

                        byt := 2;

                        while byt <> 0 do
                        begin
                          s := f.readGDBString;
                          byt := strtoint(s);
                          s := f.readGDBString;
                          case byt of
                            2:
                              begin
                                tstyle.name := s;
                              end;
                            40:
                              begin
                                tstyle.prop.size:=strtofloat(s);
                              end;
                            41:
                              begin
                                tstyle.prop.wfactor:=strtofloat(s);
                              end;
                            50:
                              begin
                                tstyle.prop.oblique:=strtofloat(s);
                              end;
                            3:
                              begin
                                   lname:=s;
                                   //FontManager.addFonf(FindInPaths(sysvar.PATH.Fonts_Path^,s));
                                   //tstyle.pfont:=FontManager.getAddres(s);
                                   //if tstyle.pfont:=;
                               end;
                          end;
                        end;
                        if gdb.GetCurrentDWG.TextStyleTable.FindStyle(tstyle.Name)<>-1 then
                        begin
                          if LoadMode=TLOLoad then
                                                  gdb.GetCurrentDWG.TextStyleTable.addstyle(tstyle.Name,lname,tstyle.prop);
                        end
                           else
                               gdb.GetCurrentDWG.TextStyleTable.addstyle(tstyle.Name,lname,tstyle.prop);
                        {$IFDEF TOTALYLOG}programlog.logoutstr('Found style '+tstyle.Name,0);{$ENDIF}
                      end;
                      {$IFDEF TOTALYLOG}programlog.logoutstr('end; {style table}',lp_DecPos);{$ENDIF}
              //gotodxf(f, 0, 'ENDTAB');
                    end
                    else
                      if s = 'UCS' then
                      begin
                        gotodxf(f, 0, 'ENDTAB');
                      end
                      else
                        if s = 'VIEW' then
                        begin
                          gotodxf(f, 0, 'ENDTAB');
                        end
                        else
                          if s = 'VPORT' then
                          begin
                            gotodxf(f, 0, 'ENDTAB');
                          end;
        s := f.readGDBString;
        s := f.readGDBString;
      end;

    end
    else
      if s = 'ENTITIES' then
      begin
        {$IFDEF TOTALYLOG}programlog.logoutstr('Found entities section',lp_IncPos);{$ENDIF}
        //inc(foc);
        {addfromdxf12}addentitiesfromdxf(f, 'ENDSEC',owner);
        owner.ObjArray.pack;
        owner.correctobjects(nil,0);
        //inc(foc);
        {$IFDEF TOTALYLOG}programlog.logoutstr('end {entities section}',lp_DecPos);{$ENDIF}
      end
      else
        if s = 'BLOCKS' then
        begin
          {$IFDEF TOTALYLOG}programlog.logoutstr('Found block table',lp_IncPos);{$ENDIF}
          sname := '';
          repeat
            if (sname = '  2') or (sname = '2') then
              if (pos('MODEL_SPACE',uppercase(s))<>0)or(pos('PAPER_SPACE',uppercase(s))<>0)then
              begin
                //programlog.logoutstr('Ignored block '+s+';',lp_OldPos);
                shared.HistoryOutStr('Ignored block '+s+';');
                while (s <> 'ENDBLK') do
                  s := f.readGDBString;
              end
              else if gdb.GetCurrentDWG.BlockDefArray.getindex(pointer(@s[1]))>=0 then
                               begin
                                    //programlog.logoutstr('Ignored double definition block '+s+';',lp_OldPos);
                                    shared.HistoryOutStr('Ignored double definition block '+s+';');
                                    if s='DEVICE_KIP_UK-P'then
                                               s:=s;
                                    while (s <> 'ENDBLK') do
                                    s := f.readGDBString;
                               end
              else begin
                   if s='*D1054' then
                                  s:=s;

                tp := gdb.GetCurrentDWG.BlockDefArray.create(s);
                programlog.logoutstr('Found block '+s+';',lp_IncPos);
                   //addfromdxf12(f, GDBPointer(GDB.pgdbblock^.blockarray[GDB.pgdbblock^.count].ppa),@tp^.Entities, 'ENDBLK');
                while (s <> ' 30') and (s <> '30') do
                begin
                  s := f.readGDBString;
                  val(s, byt, error);
                  case byt of
                    10:
                      begin
                        s := f.readGDBString;
                        tp^.Base.x := strtofloat(s);
                      end;
                    20:
                      begin
                        s := f.readGDBString;
                        tp^.Base.y := strtofloat(s);
                      end;
                  end;
                end;
                s := f.readGDBString;
                tp^.Base.z := strtofloat(s);
                inc(foc);
                AddEntitiesFromDXF(f,'ENDBLK',tp);
                dec(foc);
                if tp^.name='DEVICE_EL_MOTOR' then
                                                           tp.name:=tp.name;
                tp^.LoadFromDXF(f,nil);
                blockload:=true;
                programlog.logoutstr('end block;',lp_DecPos);
                sname:='##'
              end;
            if not blockload then
                                 sname := f.readGDBString;
            blockload:=false;
            s := f.readGDBString;
          until (s = 'ENDSEC');
          {$IFDEF TOTALYLOG}programlog.logoutstr('end; {block table}',lp_DecPos);{$ENDIF}
          gdb.GetCurrentDWG.BlockDefArray.Format;
        end;

    s := s;
//       if (byt=fcode) and (s=fname) then exit;
    MainFormN.ProcessLongProcess(f.ReadPos);
  until not f.notEOF;
  {$IFDEF TOTALYLOG}programlog.logoutstr('end; {AddFromDXF2000}',lp_decPos);{$ENDIF}
end;

procedure addfromdxf(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
var
  f: GDBOpenArrayOfByte;
  s: GDBString;
begin
  programlog.logoutstr('AddFromDXF',lp_IncPos);
  shared.HistoryOutStr('Loading file '+name+';');
  f.InitFromFile(name);
  if f.Count<>0 then
  begin
     phandlearray := dxfhandlearraycreate(10000);
  //f.ReadFromFile(name);
    MainFormN.StartLongProcess(f.Count);
  while f.notEOF do
  begin
    s := f.ReadString2;
    if s = '$ACADVER' then
    begin
      s := f.ReadString2;
      if s = '1' then
      begin
        s := f.ReadString2;
        if s = 'AC1009' then
        begin
          shared.HistoryOutStr('DXF12 fileformat;');
          //programlog.logout('DXF12 fileformat;',lp_OldPos);
          gotodxf(f, 0, 'ENDSEC');
          addfromdxf12(f,'EOF',owner,loadmode);
        end
        else if s = 'AC1015' then
        begin
          shared.HistoryOutStr('DXF2000 fileformat;');
          //programlog.logout('DXF2000 fileformat;',lp_OldPos);
          gotodxf(f, 0, 'ENDSEC');
          addfromdxf2000(f,'EOF',owner,loadmode);
        end
        else
        begin
             ShowError('Uncnown fileformat; $ACADVER='+s);
             //programlog.logoutstr('ERROR: Uncnown fileformat; $ACADVER='+s,lp_OldPos);
        end;
      end;
    end;
  end;
    MainFormN.EndLongProcess;
  owner.calcbb;
  GDBFreeMem(GDBPointer(phandlearray));
  end
     else
         shared.ShowError('IODXF.ADDFromDXF: Не могу открыть файл: '+name);
  f.done;
  programlog.logoutstr('end; {AddFromDXF}',lp_DecPos);
end;
procedure saveentitiesdxf2000(pva: PGDBObjEntityOpenArray; var outhandle:{GDBInteger}GDBOpenArrayOfByte; var handle: GDBInteger);
var
//  i:GDBInteger;
  pv:pgdbobjEntity;
  ir:itrec;
begin

     pv:=pva^.beginiterate(ir);
     if pv<>nil then
     repeat
          MainFormN.ProcessLongProcess(ir.itc);
          pv^.DXFOut(handle, outhandle);
     pv:=pva^.iterate(ir);
     until pv=nil;
end;

procedure savedxf2000;
var
  templatefile: GDBOpenArrayOfByte;
  outstream: {GDBInteger}GDBOpenArrayOfByte;
  groups, values: GDBString;
  groupi, valuei, intable: GDBInteger;
  handle,plottablefansdle,i{,cod}: GDBInteger;
  phandlea: pdxfhandlerecopenarray;
  inlayertable, inblocksec, inblocktable: GDBBoolean;
  handlepos:integer;
  ignoredsource:boolean;
  instyletable:boolean;
begin
  //--------------------------outstream := FileCreate(name);
  outstream.init(10*1024*1024);
  //--------------------------if outstream>0 then
  begin
  MainFormN.StartLongProcess(pdrawing^.pObjRoot^.ObjArray.Count);
  phandlea := dxfhandlearraycreate(10000);
  templatefile.InitFromFile(sysparam.programpath + 'components/empty.dxf');
  handle := $2;
  inlayertable := false;
  inblocksec := false;
  inblocktable := false;
  instyletable := false;
  ignoredsource:=false;
  while templatefile.notEOF do
  begin
    if  (templatefile.count-templatefile.ReadPos)<10
    then
        handle:=handle;
    groups := templatefile.readGDBString;
    values := templatefile.readGDBString;
    groupi := strtoint(groups);
    if (groupi = 9) and (values = '$HANDSEED') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      //WriteString_EOL(outstream, groups);
      outstream.TXTAddGDBStringEOL('$HANDSEED');
      //WriteString_EOL(outstream, '$HANDSEED');
      outstream.TXTAddGDBStringEOL('5');
      //WriteString_EOL(outstream, '5');
      handlepos:=outstream.Count;
      //handlepos:=FileSeek(outstream,0,1);
      outstream.TXTAddGDBStringEOL('FUCK OFF');
      //WriteString_EOL(outstream, 'FUCK OFF');
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
      handle := strtoint('$' + values);
    end
    else
      if (groupi = 5) or (groupi = 320) or (groupi = 330) or (groupi = 340) or (groupi = 350) or (groupi = 1005) or (groupi = 390) or (groupi = 360) or (groupi = 105) then
      begin
        valuei := strtoint('$' + values);
                          {if valuei<>0 then
                                       begin}
        intable := {getnevhandle(phandlea, valuei)}valuei;
        if {intable <> 0}true then
        begin
          outstream.TXTAddGDBStringEOL(groups);
          //WriteString_EOL(outstream, groups);
          outstream.TXTAddGDBStringEOL(inttohex(intable, 0));
          //WriteString_EOL(outstream, inttohex(intable, 0));
        end
        else
        begin
          pushhandle(phandlea, valuei, handle);
          outstream.TXTAddGDBStringEOL(groups);
          //WriteString_EOL(outstream, groups);
          outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
          //WriteString_EOL(outstream, inttohex(handle, 0));
          inc(handle);
        end;
        if inlayertable and (groupi=390) then
                                             plottablefansdle:={handle-1}intable;  {поймать плоттабле}
      end
      else
        if (groupi = 2) and (values = 'ENTITIES') then
        begin
          outstream.TXTAddGDBStringEOL(groups);
          //WriteString_EOL(outstream, groups);
          outstream.TXTAddGDBStringEOL(values);
          //WriteString_EOL(outstream, values);
          //historyoutstr('Entities start here_______________________________________________________');
          saveentitiesdxf2000(@pdrawing^.pObjRoot^.ObjArray, outstream, handle);
        end
        else
          if (groupi = 2) and (values = 'BLOCKS') then
          begin
            outstream.TXTAddGDBStringEOL(groups);
            outstream.TXTAddGDBStringEOL(values);
            //WriteString_EOL(outstream, groups);
            //WriteString_EOL(outstream, values);
            inblocksec := true;
          end
          else
            if (inblocksec) and ((groupi = 0) and (values = 'ENDSEC')) then
            begin
              //historyoutstr('Blockdefs start here_______________________________________________________');
              if pdrawing^.BlockDefArray.count>0 then
              for i := 0 to pdrawing^.BlockDefArray.count - 1 do
              begin
                outstream.TXTAddGDBStringEOL('0');
                outstream.TXTAddGDBStringEOL('BLOCK');
                outstream.TXTAddGDBStringEOL('5');
                outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
                inc(handle);
                outstream.TXTAddGDBStringEOL('100');
                outstream.TXTAddGDBStringEOL('AcDbEntity');
                outstream.TXTAddGDBStringEOL('8');
                outstream.TXTAddGDBStringEOL('0');
                outstream.TXTAddGDBStringEOL('100');
                outstream.TXTAddGDBStringEOL('AcDbBlockBegin');
                outstream.TXTAddGDBStringEOL('2');
                outstream.TXTAddGDBStringEOL(PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].name);
                outstream.TXTAddGDBStringEOL('70');
                outstream.TXTAddGDBStringEOL('2');
                outstream.TXTAddGDBStringEOL('10');
                outstream.TXTAddGDBStringEOL(floattostr(PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].base.x));
                outstream.TXTAddGDBStringEOL('20');
                outstream.TXTAddGDBStringEOL(floattostr(PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].base.y));
                outstream.TXTAddGDBStringEOL('30');
                outstream.TXTAddGDBStringEOL(floattostr(PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].base.z));
                outstream.TXTAddGDBStringEOL('3');
                outstream.TXTAddGDBStringEOL(PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].name);
                outstream.TXTAddGDBStringEOL('1');
                outstream.TXTAddGDBStringEOL('');

                saveentitiesdxf2000(@PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].ObjArray, outstream, handle);

                outstream.TXTAddGDBStringEOL('0');
                outstream.TXTAddGDBStringEOL('ENDBLK');
                outstream.TXTAddGDBStringEOL('5');
                outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
                inc(handle);
                outstream.TXTAddGDBStringEOL('100');
                outstream.TXTAddGDBStringEOL('AcDbEntity');
                outstream.TXTAddGDBStringEOL('8');
                outstream.TXTAddGDBStringEOL('0');
                outstream.TXTAddGDBStringEOL('100');
                outstream.TXTAddGDBStringEOL('AcDbBlockEnd');

                //PBlockdefArray(gdb^.BlockDefArray.parray)^[i].SaveToDXFPostProcess(outstream); asdasd

              end;

              outstream.TXTAddGDBStringEOL('0');
              outstream.TXTAddGDBStringEOL('ENDSEC');


              inblocksec := false;
            end
            else if (inblocktable) and ((groupi = 0) and (values = 'ENDTAB')) then
            begin
              inblocktable := false;
              if pdrawing^.BlockDefArray.count>0 then

              for i := 0 to pdrawing^.BlockDefArray.count - 1 do
              begin
                outstream.TXTAddGDBStringEOL('0');
                outstream.TXTAddGDBStringEOL('BLOCK_RECORD');
                outstream.TXTAddGDBStringEOL('5');
                outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
                inc(handle);
                outstream.TXTAddGDBStringEOL('100');
                outstream.TXTAddGDBStringEOL('AcDbSymbolTableRecord');
                outstream.TXTAddGDBStringEOL('100');
                outstream.TXTAddGDBStringEOL('AcDbBlockTableRecord');
                outstream.TXTAddGDBStringEOL('2');
                outstream.TXTAddGDBStringEOL(PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].name);

              end;
              outstream.TXTAddGDBStringEOL('0');
              outstream.TXTAddGDBStringEOL('ENDTAB');
            end

            else
              if (inlayertable) and ((groupi = 0) and (values = 'ENDTAB')) then
              begin
                inlayertable := false;
                ignoredsource:=false;
                for i := 0 to gdb.GetCurrentDWG.layertable.count - 1 do
                begin
                  //if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name <> '0' then
                  begin
                    outstream.TXTAddGDBStringEOL('0');
                    outstream.TXTAddGDBStringEOL('LAYER');
                    outstream.TXTAddGDBStringEOL('5');
                    outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
                    inc(handle);
                    outstream.TXTAddGDBStringEOL('100');
                    outstream.TXTAddGDBStringEOL('AcDbSymbolTableRecord');
                    outstream.TXTAddGDBStringEOL('100');
                    outstream.TXTAddGDBStringEOL('AcDbLayerTableRecord');
                    outstream.TXTAddGDBStringEOL('2');
                    outstream.TXTAddGDBStringEOL(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name);
                    outstream.TXTAddGDBStringEOL('70');
                    outstream.TXTAddGDBStringEOL('0');
                    outstream.TXTAddGDBStringEOL('62');
                    if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i]._on
                     then
                         outstream.TXTAddGDBStringEOL(inttostr(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].color))
                     else
                         outstream.TXTAddGDBStringEOL(inttostr(-PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].color));
                    outstream.TXTAddGDBStringEOL('6');
                    outstream.TXTAddGDBStringEOL('Continuous');
                    outstream.TXTAddGDBStringEOL('290');
                    if uppercase(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name) <> 'DEFPOINTS' then
                      outstream.TXTAddGDBStringEOL('1')
                    else
                      outstream.TXTAddGDBStringEOL('0');
                    outstream.TXTAddGDBStringEOL('370');
                    outstream.TXTAddGDBStringEOL(inttostr(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].lineweight));
                    //WriteString_EOL(outstream, '-3');
                    outstream.TXTAddGDBStringEOL('390');
                    outstream.TXTAddGDBStringEOL(inttohex(plottablefansdle,0));
                  end;
                end;
                outstream.TXTAddGDBStringEOL(groups);
                outstream.TXTAddGDBStringEOL(values);
              end


            else
              if (instyletable) and ((groupi = 0) and (values = 'ENDTAB')) then
              begin
                instyletable := false;
                ignoredsource:=false;
                for i := 0 to gdb.GetCurrentDWG.TextStyleTable.count - 1 do
                begin
                  //if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name <> '0' then
                  begin
                    outstream.TXTAddGDBStringEOL('0');
                    outstream.TXTAddGDBStringEOL('STYLE');
                    outstream.TXTAddGDBStringEOL('5');
                    outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
                    inc(handle);
                    outstream.TXTAddGDBStringEOL('100');
                    outstream.TXTAddGDBStringEOL('AcDbSymbolTableRecord');
                    outstream.TXTAddGDBStringEOL('100');
                    outstream.TXTAddGDBStringEOL('AcDbTextStyleTableRecord');
                    outstream.TXTAddGDBStringEOL('2');
                    outstream.TXTAddGDBStringEOL(PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(i))^.name);
                    outstream.TXTAddGDBStringEOL('70');
                    outstream.TXTAddGDBStringEOL('0');

                    outstream.TXTAddGDBStringEOL('40');
                    outstream.TXTAddGDBStringEOL(floattostr(PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(i))^.prop.size));

                    outstream.TXTAddGDBStringEOL('41');
                    outstream.TXTAddGDBStringEOL(floattostr(PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(i))^.prop.wfactor));

                    outstream.TXTAddGDBStringEOL('50');
                    outstream.TXTAddGDBStringEOL(floattostr(PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(i))^.prop.oblique));

                    outstream.TXTAddGDBStringEOL('71');
                    outstream.TXTAddGDBStringEOL('0');

                    outstream.TXTAddGDBStringEOL('42');
                    outstream.TXTAddGDBStringEOL('2.5');

                    outstream.TXTAddGDBStringEOL('3');
                    outstream.TXTAddGDBStringEOL(PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(i))^.dxfname);

                    outstream.TXTAddGDBStringEOL('4');
                    outstream.TXTAddGDBStringEOL('');

                  end;
                end;
                outstream.TXTAddGDBStringEOL(groups);
                outstream.TXTAddGDBStringEOL(values);
              end


              else
                if (groupi = 0) and (values = 'TABLE') then
                begin
                  outstream.TXTAddGDBStringEOL(groups);
                  outstream.TXTAddGDBStringEOL(values);
                  groups := templatefile.readGDBString;
                  values := templatefile.readGDBString;
                  groupi := strtoint(groups);
                  outstream.TXTAddGDBStringEOL(groups);
                  outstream.TXTAddGDBStringEOL(values);
                  if (groupi = 2) and (values = 'LAYER') then
                  begin
                    inlayertable := true;
                  end
                  else if (groupi = 2) and (values = 'BLOCK_RECORD') then
                  begin
                    inblocktable := true;
                  end
                  else if (groupi = 2) and (values = 'STYLE') then
                  begin
                    instyletable := true;
                  end;

                end

              else if (groupi = 0) and (values = 'LAYER')and inlayertable then
                  begin
                    IgnoredSource := true;
                  end
              else if (groupi = 0) and (values = 'STYLE')and instyletable then
                  begin
                    IgnoredSource := true;
                  end
                else
                begin
                  if not ignoredsource then
                  begin
                  outstream.TXTAddGDBStringEOL(groups);
                  outstream.TXTAddGDBStringEOL(values);
                  end;
                  //val('$' + values, i, cod);
                end;
    //s := readspace(s);
  end;
  //templatefileclose;

  i:=outstream.Count;
  outstream.Count:=handlepos;
  outstream.TXTAddGDBStringEOL(inttohex(handle+1,8));
  outstream.Count:=i;

  //-------------FileSeek(outstream,handlepos,0);
  //-------------WriteString_EOL(outstream,inttohex(handle+1,8));
  //-------------fileclose(outstream);


  GDBFreeMem(GDBPointer(phandlea));
  templatefile.done;

  if FileExists(utf8tosys(name)) then
                           begin
                                deletefile(name+'.bak');
                                renamefile(name,name+'.bak');
                           end;

  if outstream.SaveToFile(name)<=0 then
                                       shared.ShowError('Не могу открыть для записи файл: '+name);
  MainFormN.EndLongProcess;

  end;
  outstream.done;
end;
procedure SaveZCP(name: GDBString; gdb: PGDBDescriptor);
var
//  memsize:longint;
//  objcount:GDBInteger;
//  pmem,tmem:GDBPointer;
  outfile:GDBInteger;
  memorybuf:PGDBOpenArrayOfByte;
  s:ZCPHeader;
  linkbyf:PGDBOpenArrayOfTObjLinkRecord;
//  test:gdbvertex;
  sub:integer;
begin
     memorybuf:=nil;
     linkbyf:=nil;
     fillchar(s,sizeof(s),0);
     zcpmode:=zcptxt;
     sub:=0;
     sysunit.TypeName2PTD('ZCPHeader')^.Serialize(@ZCPHead,SA_SAVED_TO_SHD,memorybuf,linkbyf,sub);

     PTZCPOffsetTable(memorybuf^.getelement(ZCPHeadOffsetTableOffset))^.GDB:=memorybuf^.Count;

     linkbyf^.SetGenMode(EnableGen);
     //sysunit.TypeName2PTD('GDBDescriptor')^.Serialize(gdb,SA_SAVED_TO_SHD,memorybuf,linkbyf); убратькомент!!!!

     PTZCPOffsetTable(memorybuf^.getelement(ZCPHeadOffsetTableOffset))^.GDBRT:=memorybuf^.Count;

     linkbyf^.SetGenMode(DisableGen);

     {test.x:=1;
     test.y:=2;
     test.z:=3;
     systype.TypeName2PTD('GDBvertex')^.Serialize(@test,SA_SAVED_TO_SHD,memorybuf,linkbyf);}

     linkbyf^.Minimize;
     //sysunit.TypeName2PTD('GDBOpenArrayOfTObjLinkRecord')^.Serialize(linkbyf,SA_SAVED_TO_SHD,memorybuf,linkbyf);убратькомент!!!!

     {systype.TypeName2PTD('ZCPHeader')^.DeSerialize(@s,SA_SAVED_TO_SHD,memorybuf);
     fillchar(gdb^,sizeof(GDBDescriptor),0);
     systype.TypeName2PTD('GDBDescriptor')^.DeSerialize(gdb,SA_SAVED_TO_SHD,memorybuf);}

     outfile:=FileCreate(UTF8ToSys(name));
     FileWrite(outfile,memorybuf^.parray^,memorybuf^.Count);
     fileclose(outfile);
     outfile:=FileCreate(UTF8ToSys(name+'remap'));
     FileWrite(outfile,linkbyf^.parray^,linkbyf^.Count*linkbyf^.Size);
     fileclose(outfile);
     memorybuf.done;
     linkbyf.done;
end;
procedure LoadZCP(name: GDBString; gdb: PGDBDescriptor);
var
//  objcount:GDBInteger;
//  pmem,tmem:GDBPointer;
//  infile:GDBInteger;
//  head:ZCPheader;
  memorybuf:GDBOpenArrayOfByte;
  FileHeader:ZCPHeader;
//  test:gdbvertex;
  linkbyf:PGDBOpenArrayOfTObjLinkRecord;
begin
     fillchar(FileHeader,sizeof(FileHeader),0);
     memorybuf.InitFromFile(name);
     sysunit.TypeName2PTD('ZCPHeader')^.DeSerialize(@FileHeader,SA_SAVED_TO_SHD,memorybuf,nil);
     HistoryOutStr('Loading file: '+name);
     HistoryOutStr('ZCad project file v'+inttostr(FileHeader.HiVersion)+'.'+inttostr(FileHeader.LoVersion));
     HistoryOutStr('File coment: '+FileHeader.Coment);
     memorybuf.Seek(FileHeader.OffsetTable.GDBRT);
     GDBGetMem({$IFDEF DEBUGBUILD}'{E975EEDE-66A9-4391-8E28-17537B7A2C9C}',{$ENDIF}pointer(linkbyf),sizeof(GDBOpenArrayOfTObjLinkRecord));
     sysunit.TypeName2PTD('GDBOpenArrayOfTObjLinkRecord')^.DeSerialize(linkbyf,SA_SAVED_TO_SHD,memorybuf,nil);
     memorybuf.Seek(FileHeader.OffsetTable.GDB);
     fillchar(gdb^,sizeof(GDBDescriptor),0);
     sysunit.TypeName2PTD('GDBDescriptor')^.DeSerialize(gdb,SA_SAVED_TO_SHD,memorybuf,linkbyf);
     gdb.GetCurrentDWG.FileName:=name;
     gdb.GetCurrentROOT.correctobjects(nil,-1);
     //fillchar(FileHeader,sizeof(FileHeader),0);
     {systype.TypeName2PTD('GDBVertex')^.DeSerialize(@test,SA_SAVED_TO_SHD,memorybuf);}
     (*FileRead(infile,header,sizeof(shdblockheader));
     while header.blocktype<>shd_block_eof do
     begin
          case header.blocktype of
                                  shd_block_head:begin
                                                      FileRead(infile,head,sizeof(ZCPheader));
                                                 end;
                              shd_block_primitiv:begin
                                                      FileRead(infile,objcount,sizeof(objcount));
                                                      header.blocksize:=header.blocksize-sizeof(objcount);
                                                      GDBGetMem({$IFDEF DEBUGBUILD}'{01399BB7-5744-4DFE-97C3-00F5E501275C}',{$ENDIF}pmem,header.blocksize);
                                                      FileRead(infile,pmem^,header.blocksize);
                                                      tmem:=pmem;
                                                      //gdb.ObjRoot.ObjArray.LoadCompactMemSize2(tmem,objcount);
                                                      GDBFreeMem(pmem);
                                                 end;
                                            else begin
                                                      FileSeek(infile,header.blocksize,1)
                                                 end;
          end;
          FileRead(infile,header,sizeof(shdblockheader));
     end;
     fileclose(infile);*)
end;
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('iodxf.initialization');{$ENDIF} 
     i2:=0;
     FOC:=0;
end.
