program SyntaxDiag;





uses
  Vcl.Forms,
  Main in 'Main.pas' {EditorForm},
  Data.Types in 'units\Data.Types.pas',
  Model in 'units\Model.pas',
  View.Canvas in 'units\View.Canvas.pas',
  Data.InitData in 'units\Data.InitData.pas',
  View.SVG in 'units\View.SVG.pas',
  FCanvasSizeSettings in 'forms\FCanvasSizeSettings.pas' {FCanvasSettings},
  FHtmlView in 'forms\FHtmlView.pas' {FHtml},
  Model.UndoStack in 'units\Model.UndoStack.pas',
  Model.Files in 'units\Model.Files.pas',
  Model.Lines in 'units\Model.Lines.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Syntax Diagrams Editor';
  Application.CreateForm(TEditorForm, EditorForm);
  Application.CreateForm(TFCanvasSettings, FCanvasSettings);
  Application.CreateForm(TFHtml, FHtml);
  Application.Run;
end.
