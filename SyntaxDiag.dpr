program SyntaxDiag;

uses
  Vcl.Forms,
  Main in 'Main.pas' {EditorForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TEditorForm, EditorForm);
  Application.Run;
end.
