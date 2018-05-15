unit FCanvasSizeSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFCanvasSettings = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    lblWidth: TLabel;
    lblHeight: TLabel;
    edtWidth: TEdit;
    edtHeight: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    lbl1px: TLabel;
    Label2: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    procedure ControlsToItem(var w,h: integer);
  public
    function showForm(var w,h: integer):TModalResult;
  end;

var
  FCanvasSettings: TFCanvasSettings;

implementation
uses main;
{$R *.dfm}

procedure TFCanvasSettings.btnOkClick(Sender: TObject);
var
w,h:integer;
begin
  {try
    w := StrToInt( edtWidth.Text );
    h := StrToInt( edtHeight.Text );
    EditorForm.changeCanvasSize(w,h);
    Self.Close;
  except on E:Exception  do
    ShowMessage('Ошибка ввода');
  end;     }
end;

procedure TFCanvasSettings.ControlsToItem(var w, h: integer);
begin
  try
    w := StrToInt( edtWidth.Text );
    h := StrToInt( edtHeight.Text );
  except on E: EConvertError   do
    ShowMessage('Ошибка ввода');
  end;
end;

function TFCanvasSettings.showForm(var w,h: integer):TModalResult;
begin
  edtWidth.Text := IntToStr(w);
  edtHeight.Text := IntToStr(h);
  Result := Self.ShowModal;
  if Result = mrOk then
    ControlsToItem(w,h);
end;

procedure TFCanvasSettings.btnCancelClick(Sender: TObject);
begin
//  Self.Close;
end;

end.


