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
{**
Project tree form
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
unit projecttreewnd;
{$INCLUDE def.inc}
interface
uses
 zcadsysvars,intftranslations,enitiesextendervariables,ugdbdrawing,paths,UGDBStringArray,gdbobjectsconstdef,zcadstrconsts,ucxmenumgr,strproc,umytreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 Classes,{ SysUtils,} FileUtil,{ LResources,} Forms, stdctrls, Controls, {Graphics, Dialogs,}ComCtrls,
 {ZTabControlsGeneric,zmenus,}{DeviceBase}devicebaseabstract,uzclog,SysUtils,{UGDBTree,}gdbase,UGDBDescriptor{,math,commandline},varman,languade{,UGDBTracePropArray},
  {ZEditsWithProcedure,zbasicvisible,}varmandef,uzcshared,uzcsysinfo{,ZTreeViewsGeneric},memman,gdbasetypes,commanddefinternal,commandlinedef;
const
  uncat='UNCAT';
  uncat_='UNCAT_';
type
      {**@abstract(Node represents a block definition)
         Modified TTreeNode}
      TBlockTreeNode=class(TmyTreeNode)
               public
                    FBlockName:String;{**<Block(Device) name}
                    procedure Select;override;
                    function GetParams:Pointer;override;
               end;
      {**Modified TTreeNode}
      TEqTreeNode=class(TBlockTreeNode)
               public
                    ptd:TTypedData;
                    //FBlockName:String;{**<Block(Device) name}
                    procedure Select;override;
                    function GetParams:Pointer;override;
               end;

  {**@abstract(Project tree class)
      Project tree class desk}
  TProjectTreeWnd = class(TFreedForm)
    PT_PageControl:TmyPageControl;{**<??}
    PT_P_ProgramDB:TTabSheet;{**<Чтото там для описания}
    PT_P_ProjectDB:TTabSheet;

    T_ProgramDB:TmyTreeView;
    T_ProjectDB:TmyTreeView;

    BlockNodeUnCatN,DeviceNodeUnCatN,BlockNodeN,DeviceNodeN,ProgramEquipmentN,ProjectEquipmentN:TmyTreeNode;

    procedure AfterConstruction; override;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction); override;
    private
    procedure BuildTreeByEQ(var BuildNode:TmyTreeNode;PDBUNIT:PTUnit;pcm:TmyPopupMenu);
    procedure ChangePage(Sender: TObject);
  end;
var
  ProjectTreeWindow:TProjectTreeWnd;{<Дерево проекта}
  BlockCategory,EqCategory:GDBGDBStringArray;

  //ProgramDBContextMenuN,ProjectDBContextMenuN,ProgramDEVContextMenuN:TmyPopupMenu;

implementation
uses {commandline,}GDBBlockDef,UBaseTypeDescriptor,zcadinterface,UUnitManager;
function TBlockTreeNode.GetParams;
begin
     result:=@FBlockName;
end;
procedure TBlockTreeNode.Select;
var
                  TypeDesk:PUserTypeDescriptor;
                  Instance:Pointer;

begin
     TypeDesk:=sysunit.TypeName2PTD('GDBObjBlockdef');
     Instance:=gdb.GetCurrentDWG.BlockDefArray.getblockdef(FBlockName);
     if instance<>nil then
                          begin
                               if assigned(SetGDBObjInspProc)then
                                                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,TypeDesk,Instance,gdb.GetCurrentDWG)
                          end
                      else
                          uzcshared.ShowError(format(rscmNoBlockDefInDWGCXMenu,[FBlockName]));
end;


procedure TEqTreeNode.Select;
begin
     if assigned(SetGDBObjInspProc)then
     SetGDBObjInspProc(nil,gdb.GetUnitsFormat,ptd.PTD,ptd.Instance,gdb.GetCurrentDWG);
end;
function TEqTreeNode.GetParams;
begin
     result:=@ptd;
end;
{function GDBBlockNode.GetNodeName;
begin
     result:=Name;
end;}
function Cat2UserNameCat(category:GDBString; const catalog:GDBGDBStringArray):GDBString;
var
   ps{,pspred}:pgdbstring;
//   s:gdbstring;
   ir:itrec;
begin
     ps:=catalog.beginiterate(ir);
     if (ps<>nil) then
     repeat
          if length(ps^)>length(category) then

          if (copy(ps^,1,length(category))=category)
          and(ps^[length(category)+1]='_') then
                                              begin
                                                    result:=copy(ps^,length(category)+2,length(ps^)-length(category)-1);
                                                    exit;
                                              end;
          ps:=catalog.iterate(ir);
     until ps=nil;
     result:=category;
end;

procedure TProjectTreeWnd.ChangePage;
begin
     if sender is TmyPageControl then
     if TmyPageControl(sender).ActivePageIndex=1 then
                       begin
                            T_ProjectDB.Selected:=nil;
                            self.ProjectEquipmentN.DeleteChildren;
                            BuildTreeByEQ(ProjectEquipmentN,ptdrawing(gdb.GetCurrentDWG).DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName),{ProjectDBContextMenuN}TmyPopupMenu(application.FindComponent(MenuNameModifier+'PROJECTDBCXMENU')));
                            (*
                            ProjectEquipmentNodeN.free;
                            gdbgetmem({$IFDEF DEBUGBUILD}'{B941B71E-2BA6-4B5E-B436-633B6C8FC500}',{$ENDIF}pointer(ProjectEquipmentNode.SubNode),sizeof(TGDBTree));
                            ProjectEquipmentNode.SubNode.init({$IFDEF DEBUGBUILD}'{CE1105DB-7CAD-4353-922A-5A31956421C4}',{$ENDIF}10);
                            BuildTreeByEQ(ProjectEquipmentNode,gdb.GetCurrentDWG.DWGUnits.findunit(DrawingDeviceBaseUnitName),ProjectDBContextMenu);
                            ProjectDB.Sync;
                            *)
                       end;

end;
procedure BuildBranchN(var CurrNode:TmyTreeNode;var TreePos:GDBString; const catalog:GDBGDBStringArray);
var
    i:integer;
    CurrFindNode{,tn}:TmyTreeNode;
    category:GDBString;
begin
     TmyTreeView(CurrNode.TreeView).NodeType:=TmyTreeNode;
     i:=pos('_',treepos);
     if i>0 then
     repeat
     category:=uppercase(copy(treepos,1,i-1));
     treepos:=copy(treepos,i+1,length(treepos)-i+1);

     CurrFindNode:=iteratefind(CurrNode,IterateFindCategoryN,@category,false);
     if CurrFindNode<>nil then
                                 CurrNode:=CurrFindNode
                             else
                                 begin
                                      CurrNode:=TmyTreeNode(TmyTreeView(CurrNode.TreeView).Items.addchild(CurrNode,(Cat2UserNameCat(category,catalog))));
                                      TmyTreeNode(CurrNode).fcategory:=category;
                                 end;

     i:=pos('_',treepos);
     until (i=0)or(category=uncat);
end;
procedure TProjectTreeWnd.BuildTreeByEQ(var BuildNode:TmyTreeNode;PDBUNIT:PTUnit;pcm:TmyPopupMenu);
var
   pvdeq:pvardesk;
   ir:itrec;
   offset:GDBInteger;
   tc:PUserTypeDescriptor;
   treepos,treesuperpos{,category,s}:GDBString;
   i:integer;
   CurrNode{,CurrFindNode,tn}:TmyTreeNode;
   eqnode:TEqTreeNode;
begin
  pvdeq:=PDBUNIT^.InterfaceVariables.vardescarray.beginiterate(ir);
  if pvdeq<>nil then
  repeat
        if pos('_EQ',pvdeq^.name)=1 then

        begin
         offset:=0;
         pvdeq^.data.PTD^.ApplyOperator('.','TreeCoord',offset,tc);
         if (offset<>0)and(tc=@GDBStringDescriptorObj) then
         begin
              treesuperpos:=pgdbstring(ptruint(pvdeq^.data.Instance) + offset)^;
         end
         else
             treesuperpos:='';
         if treesuperpos='' then
                            treesuperpos:=uncat_+pvdeq^.name;
         repeat
         i:=pos('|',treesuperpos);
         if i=0 then i:=length(treesuperpos)+1;

         treepos:=copy(treesuperpos,1,i-1);
         treesuperpos:=copy(treesuperpos,i+1,length(treesuperpos)-i);

         //treepos:=treesuperpos;


         CurrNode:=BuildNode;

         buildbranchn(CurrNode,treepos,EqCategory);

         //gdbgetmem({$IFDEF DEBUGBUILD}'{3987F838-D729-4E08-813E-6818030B801C}',{$ENDIF}pointer(eqnode),sizeof(GDBEqNode));
         if PDBUNIT<>DBUnit then
                                s:=PDbBaseObject(pvdeq^.data.Instance)^.NameShort+' из '
                            else
                                s:='';
         TmyTreeView(CurrNode.TreeView).NodeType:=TEqTreeNode;
         if treepos=uncat then
                                begin
                                     eqnode:=TEqTreeNode({tree}TmyTreeView(BuildNode.TreeView).Items.addchild(CurrNode,(treepos)));
                                     eqnode.fBlockName:=pvdeq^.name;
                                     eqnode.FPopupMenu:=pcm;
                                     eqnode.ptd.PTD:=pvdeq^.data.PTD;
                                     eqnode.ptd.Instance:=pvdeq^.data.Instance;

                                     //eqnode.init(s+pvdeq^.name,pvdeq^.name,pvdeq^.data.PTD,pvdeq^.data.Instance,pcm)
                                end
                             else
                                 begin
                                      eqnode:=TEqTreeNode({tree}TmyTreeView(BuildNode.TreeView).Items.addchild(CurrNode,(PDbBaseObject(pvdeq^.data.Instance)^.NameShort)+' ('+pvdeq^.name+') '+' из '+treepos));
                                      eqnode.fBlockName:=pvdeq^.name;
                                      eqnode.FPopupMenu:=pcm;
                                      eqnode.ptd.PTD:=pvdeq^.data.PTD;
                                      eqnode.ptd.Instance:=pvdeq^.data.Instance;

                                 //eqnode.init(s+treepos,pvdeq^.name,pvdeq^.data.PTD,pvdeq^.data.Instance,pcm);
                                 end;
         //CurrNode.SubNode.AddNode(eqnode);
         until treesuperpos='';

        end;
        pvdeq:=PDBUNIT^.InterfaceVariables.vardescarray.iterate(ir);
  until pvdeq=nil;
end;
procedure TProjectTreeWnd.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  inherited;
  if CloseAction=caFree then
                            StoreBoundsToSavedUnit('ProjectTreeWND',self.BoundsRect);
end;

procedure TProjectTreeWnd.AfterConstruction;
var
   //tnode:TTreeNode;
   pb:PGDBObjBlockdef;
    ir:itrec;
    i:integer;
    CurrNode:TTreeNode;
    pvd{,pvd2}:pvardesk;
    treepos{,treesuperpos,category}:GDBString;
    //pmenuitem:pzmenuitem;

    BlockNode:TBlockTreeNode;
    pentvarext:PTVariablesExtender;
begin
  inherited;
  //self.Position:=poScreenCenter;
  self.BoundsRect:=GetBoundsFromSavedUnit('ProjectTreeWND',SysParam.ScreenX,SysParam.Screeny);
  caption:=rsProjectTree;
  self.borderstyle:=bsSizeToolWin;

  PT_PageControl:=TmyPageControl.create(self);
  PT_PageControl.align:=alClient;
  PT_PageControl.OnChange:=self.ChangePage;

  PT_P_ProgramDB:=TTabSheet.create(PT_PageControl);
  PT_P_ProgramDB.Caption:=rsProgramDB;
  T_ProgramDB:=TmyTreeView.create(PT_P_ProgramDB);
  T_ProgramDB.ReadOnly:=true;
  BlockNodeN:=TmyTreeNode(T_ProgramDB.Items.add(nil,(rsBlocks)));
  BlockNodeUnCatN:=TmyTreeNode(T_ProgramDB.Items.addchild(BlockNodeN,(rsUncategorized)));
  BlockNodeUnCatN.fcategory:=uncat;
  DeviceNodeN:=TmyTreeNode(T_ProgramDB.Items.add(nil,(rsDevices)));
  DeviceNodeUnCatN:=TmyTreeNode(T_ProgramDB.Items.addchild(DeviceNodeN,(rsUncategorized)));
  DeviceNodeUnCatN.fcategory:=uncat;
  ProgramEquipmentN:=TmyTreeNode(T_ProgramDB.Items.add(nil,(rsEquipment)));



  T_ProgramDB.align:=alClient;
  T_ProgramDB.scrollbars:=ssAutoBoth;
  T_ProgramDB.Parent:=PT_P_ProgramDB;

  PT_P_ProgramDB.Parent:=PT_PageControl;

  PT_P_ProjectDB:=TTabSheet.create(PT_PageControl);
  PT_P_ProjectDB.Caption:=rsProjectDB;
  T_ProjectDB:=TmyTreeView.create(PT_P_ProjectDB);
  T_ProjectDB.ReadOnly:=true;
  ProjectEquipmentN :=TmyTreeNode(T_ProjectDB.Items.add(nil,(rsEquipment)));
  T_ProjectDB.align:=alClient;
  T_ProjectDB.scrollbars:=ssAutoBoth;
  T_ProjectDB.Parent:=PT_P_ProjectDB;

  PT_P_ProjectDB.Parent:=PT_PageControl;

  PT_PageControl.Parent:=self;

  begin
  pb:=BlockBaseDWG.BlockDefArray.beginiterate(ir);
  if pb<>nil then
  repeat
        i:=pos(DevicePrefix,pb^.name);
        if i=0 then
                   begin
                        CurrNode:=BlockNodeN;
                   end
               else
                   begin
                        CurrNode:=DeviceNodeN;
                   end;
        treepos:=uncat_+pb^.name;
        pentvarext:=pb.GetExtension(typeof(TVariablesExtender));
        pvd:=pentvarext.entityunit.FindVariable('BTY_TreeCoord');
        if pvd<>nil then
        if pvd^.data.Instance<>nil then
                                        treepos:=pstring(pvd^.data.Instance)^;
        //log.programlog.LogOutStr(treepos,0);


        BuildBranchN(TmyTreeNode(CurrNode),treepos,BlockCategory);

        TmyTreeView(CurrNode.TreeView).NodeType:=TBlockTreeNode;
        BlockNode:=TBlockTreeNode(T_ProgramDB.Items.addchild(CurrNode,(treepos)));
        BlockNode.fBlockName:=pb^.name;
        BlockNode.FPopupMenu:={ProgramDEVContextMenuN}TmyPopupMenu(application.FindComponent(MenuNameModifier+'PROGRAMBLOCKSCXMENU'));

        pb:=BlockBaseDWG.BlockDefArray.iterate(ir);
  until pb=nil;
  end;

  BuildTreeByEQ(ProgramEquipmentN,DBUnit,{ProgramDBContextMenuN}{}TmyPopupMenu(application.FindComponent(MenuNameModifier+'PROGRAMDBCXMENU')){});
  if gdb.GetCurrentDWG<>nil then
  BuildTreeByEQ(ProjectEquipmentN,ptdrawing(gdb.GetCurrentDWG).DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName),{ProjectDBContextMenuN}TmyPopupMenu(application.FindComponent(MenuNameModifier+'PROJECTDBCXMENU')));

end;
function ProjectTree_com(Operands:pansichar):GDBInteger;
begin
  if not assigned(ProjectTreeWindow) then
                                  ProjectTreeWindow:=TProjectTreeWnd.mycreate(Application,@ProjectTreeWindow);
  ProjectTreeWindow.Show;
end;
initialization
begin
  ProjectTreeWindow:=nil;
  BlockCategory.init(100);
  EqCategory.init(100);
  BlockCategory.loadfromfile(expandpath('*rtl/BlockCategory.cat'));
  EqCategory.loadfromfile(expandpath('*rtl/EqCategory.cat'));
  CreateCommandFastObjectPlugin(@ProjectTree_com,'ProjectTree',CADWG,0);
  (*
  ProgramDBContextMenuN:=TmyPopupMenu.create(nil);
  cxmenumgr.RegisterLCLMenu(ProgramDBContextMenuN);
  //ProgramDBContextMenuN.OnClose:=cxmenumgr.CloseNotify;
  ProgramDBContextMenuN.Items.Add(TmyMenuItem.create(ProgramDBContextMenuN,'Добавить в базу данных чертежа','DBaseAdd'));

  ProjectDBContextMenuN:=TmyPopupMenu.create(nil);
  ProjectDBContextMenuN.Items.Add(TmyMenuItem.create(ProjectDBContextMenuN,'Cвязать с выделенными объектами','DBaseLink'));
  ProjectDBContextMenuN.Items.Add(TmyMenuItem.create(ProjectDBContextMenuN,'Переименовать','DBaseRename'));

  ProgramDEVContextMenuN:=TmyPopupMenu.create(nil);
  ProgramDEVContextMenuN.Items.Add(TmyMenuItem.create(ProgramDEVContextMenuN,'Вставить в чертеж','Insert2'));
  cxmenumgr.RegisterLCLMenu(ProgramDEVContextMenuN);
  //ProgramDEVContextMenuN.OnClose:=cxmenumgr.CloseNotify;
  *)
end;
finalization
begin
     {FreeAndNil(ProgramDBContextMenuN);
     FreeAndNil(ProjectDBContextMenuN);
     FreeAndNil(ProgramDEVContextMenuN);}
     BlockCategory.FreeAndDone;
     EqCategory.FreeAndDone;
end;
end.
