program SyntaxDiag;



{$R *.dres}

uses
  Vcl.Forms,
  Main in 'Main.pas' {EditorForm},
  SD_Types in 'units\SD_Types.pas',
  SD_Model in 'units\SD_Model.pas',
  SD_View in 'units\SD_View.pas',
  SD_InitData in 'units\SD_InitData.pas',
  SVGUtils in 'units\SVGUtils.pas',
  FCanvasSizeSettings in 'forms\FCanvasSizeSettings.pas' {CanvasSettingsForm},
  FHtmlView in 'forms\FHtmlView.pas' {FHtml};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Syntax Diagrams Editor';
  Application.CreateForm(TEditorForm, EditorForm);
  Application.CreateForm(TCanvasSettingsForm, CanvasSettingsForm);
  Application.CreateForm(TFHtml, FHtml);
  Application.Run;
end.
