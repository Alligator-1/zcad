unit uzcfblockinsert;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ButtonPanel,

  UGDBObjBlockdefArray, //описание таблицы блоков
  uzeblockdef,          //описания блоков
  gdbasetypes,          //базовые типы
  strproc               //билеберда для работы со стрингами
  ;

type

  { TBlockInsertForm }

  TBlockInsertForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit10: TFileNameEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure CheckBox5Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    function Run(PBlockDefs:PGDBObjBlockdefArray;LastInsertedBlockName:GDBString):Integer;
    { public declarations }
  end;

var
  BlockInsertForm: TBlockInsertForm;

implementation
{$R *.lfm}

procedure TBlockInsertForm.FormCreate(Sender: TObject);
begin

end;

procedure TBlockInsertForm.CheckBox4Change(Sender: TObject);
begin
  if Checkbox4.Checked = True then
     begin
   Edit1.Enabled := False;
   Edit2.Enabled := False;
   Edit3.Enabled := False;
  end
  else
  begin
   Edit1.Enabled := True;
   Edit2.Enabled := True;
   Edit3.Enabled := True;
  end;

end;

procedure TBlockInsertForm.CheckBox5Change(Sender: TObject);
begin
   if Checkbox3.Checked = False then
     begin
   Edit4.Enabled := True;
   Edit5.Enabled := False;
   Edit6.Enabled := False;
   end;
 end;

procedure TBlockInsertForm.CheckBox2Change(Sender: TObject);
begin
  if CheckBox2.Checked = True then
    begin
   Edit7.Enabled := False;
  end
  else
  begin
   Edit7.Enabled := True;
  end;

end;

procedure TBlockInsertForm.CheckBox3Change(Sender: TObject);
begin
  if Checkbox3.Checked = True then
    begin
      Edit4.Enabled := False;
      Edit5.Enabled := False;
      Edit6.Enabled := False;
    end
    else
    if Checkbox5.Checked = True then
     begin
       Edit4.Enabled := True;
       Edit5.Enabled := False;
       Edit6.Enabled := False;
       Edit5.Text:= Edit4.Text;
       Edit6.Text:= Edit4.Text;
    end
    else
    begin
      Edit4.Enabled := True;
      Edit5.Enabled := True;
      Edit6.Enabled := True;
  end;
end;

function TBlockInsertForm.Run(
                             PBlockDefs:PGDBObjBlockdefArray; //указатель на таблицу описаний блоков
                             LastInsertedBlockName:GDBString  //имя последнего (например в предидущем сеансе команды) вставленного блока, чтобы его выбрать "по умолчанию"
                                                              //его нужно сохранять гденить в чертеже
                             ):Integer;                       //модальнвй результат
var
  p:PGDBObjBlockdef;              //указатель на описание блоков, им будем перебирать таблицу
  ir:itrec;                       //"счетчтк" для перебора в таблице
  LastInsertedBlockIndex:integer; //индекс выделенного элемента в комбике
begin
  //mess
  ComboBox1.Clear;//чистим на всякий пожарный

  LastInsertedBlockIndex:=-1;// заранее предполагаем что последнего вставленного блока мы ненайдем
  LastInsertedBlockName:=uppercase(LastInsertedBlockName); //искать будем case`независимо

  begin
    p:=PBlockDefs^.BeginIterate(ir);//начинаем перебирать описания в таблице
    if p<>nil then
    repeat
         ComboBox1.AddItem(Tria_AnsiToUtf8(p^.Name),tobject(p));//загоняем имя и адрес найденного описания в комбик
                                                                //причем имена в описании лежат в анси кодировке, комбику они нужны в утф8
         if LastInsertedBlockName=uppercase(p^.Name) then       //если вдруг имя текущего блока совпало с ранее вставленным
          LastInsertedBlockIndex:=ComboBox1.Items.Count-1;      //запоминаем его индекс

         p:=PBlockDefs^.iterate(ir);                            //выбираем следующее определение
    until p=nil;                                                //выходим если перебрали все определения
  end;
  ComboBox1.ItemIndex:=LastInsertedBlockIndex;                  //присваиваем текущий выбраный в комбике элемент
                                                                //к возможно найденному ранее вставленному блоку
  ComboBox1.Sorted:=true;                                       //сортируем

  result:=ShowModal;
end;

initialization

end.

