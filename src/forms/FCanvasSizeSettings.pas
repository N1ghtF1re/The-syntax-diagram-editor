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
  private
    procedure ControlsToItem(var w,h: integer);
  public
    function showForm(var w,h: integer):TModalResult;
  end;

var
  FCanvasSettings: TFCanvasSettings;

implementation
uses main, Data.initdata;
{$R *.dfm}


// Возввращает в w,h размеры, введенные пользователем в текстовом поле
procedure TFCanvasSettings.ControlsToItem(var w, h: integer);
var
  nw, nh: Integer;
begin
  try
    nw := StrToInt( edtWidth.Text );
    nh := StrToInt( edtHeight.Text );
    if (nw <= 5000) and (nh <= 5000) then
    begin
      w := nw;
      h := nh;
    end
    else
    begin
      MessageDlg(rsInputBigSizes, mtError, [mbOk], 0);
    end;

  except on E: EConvertError   do
    ShowMessage(rsInputError);
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

end.


