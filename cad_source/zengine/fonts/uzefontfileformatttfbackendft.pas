{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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

unit uzeFontFileFormatTTFBackendFT;
{$INCLUDE zengineconfig.inc}
interface
uses
  sysutils,Types,
  uzeFontFileFormatTTFBackend,
  uzegeometrytypes,
  freetypehdyn,ftfont;
const
  EmptyIndex=-1;
type
  TTTFBackendFreeType=Class(TTTFBackend)
    protected
      FreeTypeTTFImpl:TFreeTypeFont;
      GlyphInSlotIndex:Integer;

      FPointSize:single;
      FDPI:integer;

      function GetHinted:Boolean;override;
      procedure SetHinted(const AValue:Boolean);override;
      function GetFullName:String;override;
      function GetFamily:String;override;
      procedure SetSizeInPoints(const AValue:single);override;
      function GetSizeInPoints:single;override;
      function GetCharIndex(AUnicodeChar:integer):integer;override;

      //procedure SetDPI(const AValue:integer);
      //function GetDPI:integer;

      function GetAscent: single;override;
      function GetDescent: single;override;
      function GetCapHeight: single;override;
      function GetGlyph(Index: integer):TGlyphData;override;

    public
      constructor Create;override;
      destructor Destroy;override;
      procedure LoadFile(const AFile:String);override;
      //property DPI: integer read GetDPI write SetDPI;
      procedure DoneGlyph(var GD:TGlyphData);override;

      function TTFImplDummyGlobalScale:Double;override;

      function GetGlyphBounds(GD:TGlyphData):TRect;override;
      function GetGlyphAdvance(GD:TGlyphData):Single;override;
      function GetGlyphContoursCount(GD:TGlyphData):Integer;override;
      function GetGlyphPointsCount(GD:TGlyphData):Integer;override;
      function GetGlyphPoint(GD:TGlyphData;np:integer):GDBvertex2D;override;
      function GetGlyphPointFlag(GD:TGlyphData;np:integer):TTTFPointFlags;override;
      function GetGlyphConEnd(GD:TGlyphData;np:integer):Integer;override;
  end;

implementation
function readFT_SfntName(var SfntName:TFT_SfntName):UnicodeString;
const
  maxstringlength=16000;
var
  len,i:integer;
  ts:string;
begin
  if SfntName.String_len=0 then
    result:=''
  else begin
    if SfntName.platform_id<>1 then begin
      if SfntName.String_len>maxstringlength then
        len:=maxstringlength
      else
        len:=SfntName.String_len div 2;
      result:='';
      setlength(result,len);
      system.Move(SfntName.aString^,result[1],len*2);
      for i:=1 to len do
        PWord(@result[i])^:=BEtoN(PWord(@result[i])^);
    end else begin
      if SfntName.String_len>maxstringlength then
        len:=maxstringlength
      else
        len:=SfntName.String_len;
      ts:='';
      setlength(ts,len);
      system.Move(SfntName.aString^,ts[1],len);
      result:=ts;
    end;
  end;
end;

function TTTFBackendFreeType.TTFImplDummyGlobalScale:Double;
begin
  result:=6.51;
end;

function TTTFBackendFreeType.GetGlyph(Index: integer):TGlyphData;
begin
  if GlyphInSlotIndex<>Index then begin
    if FT_Load_Glyph(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),Index,FT_LOAD_DEFAULT)=0 then begin
      PtrInt(Result.PG):=Index;
      GlyphInSlotIndex:=Index;
      //FT_Get_Glyph(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph,Result.PG);
    end else
      raise Exception.CreateFmt('TTTFBackendFreeType.GetGlyph FT_Load_Glyph(%d)<>0', [Index]);
  end;
end;
procedure TTTFBackendFreeType.DoneGlyph(var GD:TGlyphData);
begin
  //FT_Done_Glyph(GD.PG);
end;

function TTTFBackendFreeType.GetGlyphBounds(GD:TGlyphData):TRect;
var
  BB:FT_BBox;
  gm:FT_Glyph_Metrics;
begin
  GetGlyph(PtrInt(GD.PG));
  BB:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).bbox;
  gm:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.metrics;
  with FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.metrics do begin
    result.left:=horiBearingX;
    result.right:=horiBearingX+width;
    result.top:=horiBearingY;
    result.Bottom:=horiBearingY-height;
  end;
end;
function TTTFBackendFreeType.GetGlyphAdvance(GD:TGlyphData):Single;
begin
  GetGlyph(PtrInt(GD.PG));
  result:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.metrics.horiAdvance;
end;
function TTTFBackendFreeType.GetGlyphContoursCount(GD:TGlyphData):Integer;
begin
  GetGlyph(PtrInt(GD.PG));
  result:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.n_contours;
end;
function TTTFBackendFreeType.GetGlyphPointsCount(GD:TGlyphData):Integer;
begin
  GetGlyph(PtrInt(GD.PG));
  result:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.n_points;
end;
function TTTFBackendFreeType.GetGlyphPoint(GD:TGlyphData;np:integer):GDBvertex2D;
begin
  GetGlyph(PtrInt(GD.PG));
  with FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.points[np] do begin
    result.x:=x*64;
    result.y:=y*64;
  end;
end;
function TTTFBackendFreeType.GetGlyphPointFlag(GD:TGlyphData;np:integer):TTTFPointFlags;
begin
  GetGlyph(PtrInt(GD.PG));
  if (byte(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.tags[np]) and 1)<>0 then
    result:=[TTFPFOnCurve]
  else
    result:=[];
end;
function  TTTFBackendFreeType.GetGlyphConEnd(GD:TGlyphData;np:integer):Integer;
begin
  GetGlyph(PtrInt(GD.PG));
  result:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.contours[np];
end;
function TTTFBackendFreeType.GetAscent: single;
var
  p:pointer;
begin
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_OS2);
  if p<>nil then
    result:=PTT_OS(p)^.sTypoAscender
  else
    exit(0);
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_HEAD);
  if p<>nil then
    result:=result/PTT_Header(p)^.Units_Per_EM
  else
    exit(0);

  result:=result * FPointSize * FDPI / 72;
end;

function TTTFBackendFreeType.GetDescent: single;
var
  p:pointer;
begin
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_OS2);
  if p<>nil then
    result:=PTT_OS(p)^.sTypoDescender
  else
    exit(0);
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_HEAD);
  if p<>nil then
    result:=result/PTT_Header(p)^.Units_Per_EM
  else
    exit(0);

  result:=result * FPointSize * FDPI / 72;
end;

function TTTFBackendFreeType.GetCapHeight:single;
var
  pos2,phead,phori:pointer;
begin
  pos2:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_OS2);
  phead:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_HEAD);
  if pos2<>nil then begin
    if PTT_OS(pos2)^.version>=2 then
      result:=PTT_OS(pos2)^.sCapHeight
    else begin
      phori:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_HHEA);
      if phori<>nil then
        result:= PTT_HoriHeader(phori)^.Ascender
      else
        result:=0;
      if result = 0 then
      begin
        if PTT_OS(pos2)^.version<>$ffff then
        begin
          if PTT_OS(pos2)^.usWinAscent <> 0 then
            result := PTT_OS(pos2)^.usWinAscent
          else
            result := PTT_OS(pos2)^.sTypoAscender;
        end;
      end;
      result:=result*2/3 {todo: добавить это в LazFreeType (если sCapHeight в заголовке нет, то она 3/2 Ascender)}
    end;
  end else
    exit(0);
  if phead<>nil then
    result:=result/PTT_Header(phead)^.Units_Per_EM
  else
    exit(0);

  result:=(result * FPointSize * FDPI / 72);
end;

function TTTFBackendFreeType.GetCharIndex(AUnicodeChar:integer):integer;
begin
  result:=FT_Get_Char_Index(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),AUnicodeChar);
end;
function TTTFBackendFreeType.GetSizeInPoints:single;
begin
  result:=FPointSize;
end;

procedure TTTFBackendFreeType.SetSizeInPoints(const AValue:single);
var
  err:integer;
begin
  FPointSize:=AValue;
  FT_Set_Char_Size(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),round(64*AValue),round(64*AValue),600,600);
end;

function TTTFBackendFreeType.GetFullName:String;
var
  SfntName:TFT_SfntName;
begin
  SfntName:=Default(TFT_SfntName);
  FT_Get_Sfnt_Name(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),TT_NAME_ID_FULL_NAME,SfntName);
  result:=readFT_SfntName(SfntName);
end;
function TTTFBackendFreeType.GetFamily:String;
var
  SfntName:TFT_SfntName;
begin
  SfntName:=Default(TFT_SfntName);
  FT_Get_Sfnt_Name(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),TT_NAME_ID_FONT_FAMILY,SfntName);
  result:=readFT_SfntName(SfntName);
end;

function TTTFBackendFreeType.GetHinted:Boolean;
begin
  //Result:=FreeTypeTTFImpl.Hinted;
end;
procedure TTTFBackendFreeType.SetHinted(const AValue:Boolean);
begin
  //FreeTypeTTFImpl.Hinted:=AValue;
end;

constructor TTTFBackendFreeType.Create;
begin
  FreeTypeTTFImpl:=TFreeTypeFont.Create;
  FDPI:=96;
  FPointSize:=1;
  GlyphInSlotIndex:=EmptyIndex;
end;
destructor TTTFBackendFreeType.Destroy;
begin
  FreeAndNil(FreeTypeTTFImpl);
end;
procedure TTTFBackendFreeType.LoadFile(const AFile:String);
begin
  FreeTypeTTFImpl.AllocateResources(nil);
  FreeTypeTTFImpl.Name:=AFile;
end;

end.
