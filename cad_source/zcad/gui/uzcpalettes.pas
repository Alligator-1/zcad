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

unit uzcpalettes;
{$INCLUDE def.inc}
interface
uses
     uzcsysparams,uzcutils,uzcsysvars,uzbtypesbase,uzbtypes,uzcsysinfo,
     uzcinfoform,Varman,uzcinterface,
     uzedrawingdef,uzbstrproc,uzeenttext,uzeconsts,uzcstrconsts,uzcfsinglelinetexteditor,
     Controls,Classes,Forms,uzccommandsmanager,Laz2_DOM,ComCtrls,uztoolbarsmanager,uzcimagesmanager,uzctranslations,uzcdrawings;
type
    TZPaletteListItem=class(TListItem)
    public
      Command:ansistring;
  end;
  TZPaletteTreeNode=class(TTreeNode)
    public
      Command:ansistring;
  end;
  TZPaletteListView=class(TListView)
    procedure ProcessClick(ListItem:TListItem;DblClck:Boolean);

    protected
    MouseDownItem:TListItem;
    DoubleClick:Boolean;
      procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
      procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
  end;
  TZPaletteTreeView=class(TTreeView)
  end;

TPaletteHelper=class

class procedure ZPalettevsIconDoubleClick(Sender: TObject);
class function ZPalettevsIconCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode):TPaletteControlBaseType;
class procedure ZPalettevsIconItemCreator(aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType);

class procedure ZPaletteTreeCreatorClass(Sender: TCustomTreeView;var NodeClass: TTreeNodeClass);
class function ZPaletteTreeCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode):TPaletteControlBaseType;
class procedure ZPaletteTreeItemCreator(aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType);
class procedure ZPaletteTreeNodeCreator(aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType);
end;

implementation
procedure TZPaletteListView.MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
  if Button=mbLeft then
  begin
   MouseDownItem:=GetItemAt(x,y);
   if ssDouble in Shift then
     doubleclick:=true
   else
     doubleclick:=false;
  end;
end;

procedure TZPaletteListView.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
var
   li:TListItem;
begin
     if Button=mbLeft then
     begin
       li:=GetItemAt(x,y);
       if li=MouseDownItem then
         ProcessClick(li,DoubleClick);
     end;
     MouseDownItem:=nil;
     DoubleClick:=false;
end;

procedure TZPaletteListView.ProcessClick(ListItem:TListItem;DblClck:Boolean);
var i:integer;
begin
  if DblClck then
     ListItem:=ListItem;
     {BeginUpdate;
     process(ListItem,SubItem,DblClck);
     for i:=0 to Items.Count-1 do
     begin
          if Items[i].Selected then
          if Items[i]<>ListItem then
             process(Items[i],SubItem,false);
     end;
     EndUpdate;}
end;


class function TPaletteHelper.ZPalettevsIconCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode):TPaletteControlBaseType;
begin
  result:=TCustomForm(Tform.NewInstance);
//if DoDisableAlign then
  if result is TWinControl then
    TWinControl(result).DisableAlign;
  TCustomForm(result).CreateNew(Application);
  TCustomForm(result).Name:=aControlName;
  TCustomForm(result).Caption:=getAttrValue(TBNode,'Caption',aInternalCaption);
  with TZPaletteListView.Create(result) do
  begin
    LargeImagesWidth:=getAttrValue(TBNode,'ImagesWidth',64);
    SmallImagesWidth:=LargeImagesWidth;
    LargeImages:=ImagesManager.IconList;
    SmallImages:=ImagesManager.IconList;
    align:=alClient;
    ViewStyle:=vsIcon;
    ReadOnly:=true;
    IconOptions.AutoArrange:=True;
    DragMode:=dmAutomatic;
    Parent:=result;
    OnDblClick:=ZPalettevsIconDoubleClick;
  end;
end;
class procedure TPaletteHelper.ZPaletteTreeCreatorClass(Sender: TCustomTreeView;var NodeClass: TTreeNodeClass);
begin
  NodeClass:=TZPaletteTreeNode;
end;

class function TPaletteHelper.ZPaletteTreeCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode):TPaletteControlBaseType;
begin
  result:=TCustomForm(Tform.NewInstance);
//if DoDisableAlign then
  if result is TWinControl then
    TWinControl(result).DisableAlign;
  TCustomForm(result).CreateNew(Application);
  TCustomForm(result).Name:=aControlName;
  TCustomForm(result).Caption:=getAttrValue(TBNode,'Caption',aInternalCaption);
  with TZPaletteTreeView.Create(result) do
  begin
    OnCreateNodeClass:=ZPaletteTreeCreatorClass;
    //OnCustomCreateItem:=
    ImagesWidth:=getAttrValue(TBNode,'ImagesWidth',64);
    //SmallImagesWidth:=LargeImagesWidth;
    Images:=ImagesManager.IconList;
    StateImages:=ImagesManager.IconList;
    //select
    //SmallImages:=ImagesManager.IconList;
    align:=alClient;
    //ViewStyle:=vsIcon;
    ReadOnly:=true;
    //IconOptions.AutoArrange:=True;
    DragMode:=dmAutomatic;
    Parent:=result;
    OnDblClick:=ZPalettevsIconDoubleClick;
  end;
end;
class procedure TPaletteHelper.ZPaletteTreeItemCreator(aNode: TDomNode;rootnode:TPersistent; palette:TPaletteControlBaseType);
var
  TN:TZPaletteTreeNode;
begin
  TN:=TZPaletteTreeNode(TZPaletteTreeView(palette).Items.AddChild(TTreeNode(rootnode),getAttrValue(aNode,'Caption','')));
  TN.Text:=InterfaceTranslate(palette.Parent.Name+'~caption',TN.Text);
  TN.ImageIndex:=ImagesManager.GetImageIndex(getAttrValue(aNode,'Img',''));
  TN.SelectedIndex:=TN.ImageIndex;
  TN.Command:=getAttrValue(aNode,'Command','');
end;
class procedure TPaletteHelper.ZPaletteTreeNodeCreator(aNode: TDomNode;rootnode:TPersistent; palette:TPaletteControlBaseType);
var
  TN:TZPaletteTreeNode;
  TBSubNode:TDomNode;
  imgname:AnsiString;
begin
  TN:=TZPaletteTreeNode(TZPaletteTreeView(palette).Items.AddChild(TTreeNode(rootnode),getAttrValue(aNode,'Caption','')));
  TN.Text:=InterfaceTranslate(palette.Parent.Name+'~caption',TN.Text);
  imgname:=getAttrValue(aNode,'Img','');
  if imgname<>'' then
    TN.ImageIndex:=ImagesManager.GetImageIndex(imgname);
  TBSubNode:=aNode.FirstChild;
  while assigned(TBSubNode)do
  begin
    ToolBarsManager.DoToolPaletteItemCreateFunc(TBSubNode.NodeName,TBSubNode,TN,palette);
    TBSubNode:=TBSubNode.NextSibling;
  end;
end;

class procedure TPaletteHelper.ZPalettevsIconDoubleClick(Sender: TObject);
var
    cmd:AnsiString;
    TN:TZPaletteTreeNode;
begin
  if Sender is TZPaletteListView then begin
    if TZPaletteListView(Sender).Selected=nil then  exit;
    cmd:=TZPaletteListItem(TZPaletteListView(Sender).Selected).Command;
  end else
  if Sender is TZPaletteTreeView then begin
    if TZPaletteTreeView(Sender).Selected=nil then  exit;
    TN:=TZPaletteTreeNode(TZPaletteTreeView(Sender).Selected);
    cmd:=TZPaletteTreeNode(TZPaletteTreeView(Sender).Selected).Command;
  end;
  if cmd<>'' then
    commandmanager.executecommandsilent(@cmd[1],drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
end;

class procedure TPaletteHelper.ZPalettevsIconItemCreator(aNode: TDomNode;rootnode:TPersistent; palette:TPaletteControlBaseType);
var
  LI:TZPaletteListItem;
begin
  LI:=TZPaletteListItem.Create(TListView(palette).Items);
  TListView(palette).Items.AddItem(LI);
  LI.Caption:=getAttrValue(aNode,'Caption','');
  LI.Caption:=InterfaceTranslate(palette.Parent.Name+'~caption',LI.Caption);
  LI.ImageIndex:=ImagesManager.GetImageIndex(getAttrValue(aNode,'Img',''));
  LI.Command:=getAttrValue(aNode,'Command','');
end;


begin
end.