unit sysvar;
interface
uses System;
var
  DWG_OSMode:GDBInteger;
  DWG_PolarMode:GDBBoolean;
  DWG_SystmGeometryDraw:GDBBoolean;
  DWG_HelpGeometryDraw:GDBBoolean;
  DWG_EditInSubEntry:GDBBoolean;
  DWG_AdditionalGrips:GDBBoolean;
  DWG_SelectedObjToInsp:GDBBoolean;
  DWG_RotateTextInLT:GDBBoolean;
  DSGN_TraceAutoInc:GDBBoolean;
  DSGN_LeaderDefaultWidth:GDBDouble;
  DSGN_HelpScale:GDBDouble;
  DSGN_LCNet:TLayerControl;
  DSGN_LCCable:TLayerControl;
  DSGN_LCLeader:TLayerControl;
  DSGN_SelNew:GDBBoolean;
  INTF_ShowScrollBars:GDBBoolean;
  INTF_ShowDwgTabs:GDBBoolean;
  INTF_DwgTabsPosition:TAlign;
  INTF_ShowDwgTabCloseBurron:GDBBoolean;
  VIEW_CommandLineVisible:GDBBoolean;
  VIEW_HistoryLineVisible:GDBBoolean;
  VIEW_ObjInspVisible:GDBBoolean;
  PMenuProjType:GDBPointer;
  PMenuCommandLine:GDBPointer;
  PMenuHistoryLine:GDBPointer;
  PMenuStatusPanel:GDBPointer;
  PMenuDebugObjInsp:GDBPointer;
  StatusPanelVisible:GDBBoolean;
  DISP_ZoomFactor:GDBDouble;
  DISP_CursorSize:GDBInteger;
  DISP_CrosshairSize:GDBDouble;
  DISP_OSSize:GDBDouble;
  DISP_DrawZAxis:GDBBoolean;
  DISP_ColorAxis:GDBBoolean;
  RD_UseStencil:GDBBoolean;
  RD_PanObjectDegradation:GDBBoolean;
  RD_LineSmooth:GDBBoolean;
  RD_MaxLineWidth:GDBDouble;
  RD_MaxPointSize:GDBDouble;
  RD_Vendor:GDBString;
  RD_Renderer:GDBString;
  RD_Extensions:GDBString;
  RD_Version:GDBString;
  RD_GLUVersion:GDBString;
  RD_GLUExtensions:GDBString;
  RD_MaxWidth:GDBInteger;
  RD_BackGroundColor:TRGB;
  RD_Restore_Mode:TRestoreMode;
  RD_LastRenderTime:GDBInteger;
  RD_LastUpdateTime:GDBInteger;
  RD_MaxRenderTime:GDBInteger;
  RD_Light:GDBBoolean;
  RD_VSync:TVSControl;
  RD_ID_Enabled:GDBBoolean;
  RD_ID_MaxDegradationFactor:GDBDouble;
  RD_ID_PrefferedRenderTime:GDBInteger;
  RD_SpatialNodesDepth:GDBInteger;
  RD_SpatialNodeCount:GDBInteger;
  RD_MaxLTPatternsInEntity:GDBInteger;
  SAVE_Auto_Interval:GDBInteger;
  SAVE_Auto_Current_Interval:GDBInteger;
  SAVE_Auto_FileName:GDBString;
  SAVE_Auto_On:GDBBoolean;
  SYS_RunTime:GDBInteger;
  SYS_Version:GDBString;
  SYS_SystmGeometryColor:GDBInteger;
  SYS_IsHistoryLineCreated:GDBBoolean;
  SYS_AlternateFont:GDBString;
  PATH_Device_Library:GDBString;
  PATH_Template_Path:GDBString;
  PATH_Template_File:GDBString;
  PATH_Program_Run:GDBString;
  PATH_Support_Path:GDBString;
  PATH_Fonts:GDBString;
  PATH_LayoutFile:GDBString;
  ShowHiddenFieldInObjInsp:GDBBoolean;
  testGDBBoolean:GDBBoolean;
  pi:GDBDouble;
implementation
begin
  DWG_OSMode:=14311;
  DWG_PolarMode:=True;
  DWG_SystmGeometryDraw:=False;
  DWG_HelpGeometryDraw:=True;
  DWG_EditInSubEntry:=False;
  DWG_AdditionalGrips:=False;
  DWG_SelectedObjToInsp:=True;
  DWG_RotateTextInLT:=True;
  DSGN_TraceAutoInc:=False;
  DSGN_LeaderDefaultWidth:=10.0;
  DSGN_HelpScale:=1.0;
  DSGN_LCNet.Enabled:=True;
  DSGN_LCNet.LayerName:='DEFPOINTS';
  DSGN_LCCable.Enabled:=True;
  DSGN_LCCable.LayerName:='EL_KABLE';
  DSGN_LCLeader.Enabled:=True;
  DSGN_LCLeader.LayerName:='TEXT';
  DSGN_SelNew:=false;
  INTF_ShowScrollBars:=True;
  INTF_ShowDwgTabs:=True;
  INTF_DwgTabsPosition:=TATop;
  INTF_ShowDwgTabCloseBurron:=True;
  VIEW_CommandLineVisible:=True;
  VIEW_HistoryLineVisible:=True;
  VIEW_ObjInspVisible:=True;
  StatusPanelVisible:=False;
  DISP_ZoomFactor:=1.624;
  DISP_CursorSize:=6;
  DISP_CrosshairSize:=0.05;
  DISP_OSSize:=10.0;
  DISP_DrawZAxis:=False;
  DISP_ColorAxis:=False;
  RD_UseStencil:=True;
  RD_PanObjectDegradation:=False;
  RD_LineSmooth:=False;
  RD_MaxLineWidth:=10.0;
  RD_MaxPointSize:=63.375;
  RD_Vendor:='NVIDIA Corporation';
  RD_Renderer:='GeForce GTX 460/PCIe/SSE2';
  RD_Version:='4.3.0';
  RD_MaxWidth:=10;
  RD_BackGroundColor.r:=0;
  RD_BackGroundColor.g:=0;
  RD_BackGroundColor.b:=0;
  RD_BackGroundColor.a:=255;
  RD_Restore_Mode:=WND_Texture;
  RD_LastRenderTime:=22;
  RD_LastUpdateTime:=0;
  RD_MaxRenderTime:=0;
  RD_Light:=False;
  RD_VSync:=TVSOff;
  RD_ID_Enabled:=True;
  RD_ID_MaxDegradationFactor:=15.0;
  RD_ID_PrefferedRenderTime:=20;
  RD_SpatialNodesDepth:=16;
  RD_SpatialNodeCount:=-1;
  RD_MaxLTPatternsInEntity:=10000;
  SAVE_Auto_Interval:=300;
  SAVE_Auto_Current_Interval:=860;
  SAVE_Auto_FileName:='*autosave/autosave.dxf';
  SAVE_Auto_On:=True;
  SYS_RunTime:=1170;
  SYS_Version:='0.9.8 Revision SVN:516';
  SYS_SystmGeometryColor:=250;
  SYS_IsHistoryLineCreated:=True;
  SYS_AlternateFont:='GEWIND.SHX';
  PATH_Device_Library:='*programdb|c:/zcad/userdb';
  PATH_Template_Path:='*template';
  PATH_Template_File:='default.dxf';
  PATH_Program_Run:='C:\zcad\cad\';
  PATH_Support_Path:='*rtl|*rtl/objdefunits|*rtl/objdefunits/include|*components|*blocks/el/general|*rtl/styles';
  PATH_Fonts:='*fonts/|C:/Program Files/AutoCAD 2010/Fonts/|C:/APPS/MY/acad/support/|C:\Program Files\Autodesk\AutoCAD 2012 - Russian\Fonts\|C:\Windows\Fonts\';
  PATH_LayoutFile:='C:\zcad\cad\components/defaultlayout.xml';
  ShowHiddenFieldInObjInsp:=False;
  testGDBBoolean:=False;
  pi:=3.14159265359;
end.