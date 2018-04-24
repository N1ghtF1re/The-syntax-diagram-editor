unit FHtmlView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw;

type
  TFHtml = class(TForm)
    WebBrowser1: TWebBrowser;
  private
    { Private declarations }
  public
    procedure showHTML(title, htmlres: WideString);
  end;

var
  FHtml: TFHtml;


implementation

{$R *.dfm}

procedure TFHtml.showHTML(title, htmlres: WideString);
var
  s: WideString;
begin
  Self.Caption := title;
  WebBrowser1.Navigate('res://' + Application.ExeName + '/' + htmlres);

  //WebBrowser1.Navigate('about:'+html);
  //WebBrowser1.Navigate ('res://SyntaxDiag.exe/HTMLPage');
  Self.ShowModal;
end;

end.
