program SyntaxDiag;

uses
  Vcl.Forms,
  Main in 'Main.pas' {EditorForm},
  SD_Types in 'units/SD_Types.pas',
  SD_Model in 'units/SD_Model.pas',
  SD_View in 'units/SD_View.pas', 
  SD_InitData in 'units/SD_InitData.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TEditorForm, EditorForm);
  Application.Run;
end.
