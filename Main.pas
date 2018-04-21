    unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, math,
  Vcl.Menus, SD_Types, SD_View, SD_InitData, SD_Model, SVGUtils;
type
  TEditorForm = class(TForm)
    edtRectText: TEdit;
    btnDef: TButton;
    btnMV: TButton;
    btnMC: TButton;
    btnLine: TButton;
    pnlOptions: TPanel;
    btnNone: TButton;
    btnALine: TButton;
    MainMenu: TMainMenu;
    mnFile: TMenuItem;
    mniSave: TMenuItem;
    mniOpen: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    mniToSVG: TMenuItem;
    canv: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure clearScreen;
    procedure canvMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure canvMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure canvMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure btnDefClick(Sender: TObject);
    procedure btnMVClick(Sender: TObject);
    procedure btnMCClick(Sender: TObject);
    procedure btnLineClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnNoneClick(Sender: TObject);
    procedure changeEditorText(newtext: string);
    procedure FormResize(Sender: TObject);
    procedure btnALineClick(Sender: TObject);
    procedure mniSaveClick(Sender: TObject);
    procedure mniOpenClick(Sender: TObject);
    procedure mniToSVGClick(Sender: TObject);
    procedure saveBrakhFile;
    procedure saveSVGFile;
    procedure canvPaint(Sender: TObject);
    
  private
  public
    procedure SD_Resize;
    function getFigureHead:PFigList;
    procedure getTextWH(var TW, TH: Integer; text: string; size: integer; family: string);
    function openFile(mode: TFileMode):string;
    function saveFile(mode: TFileMode):string;

    
  end;

var
  EditorForm: TEditorForm;
  FigHead: PFigList;
  CurrType: TType;
  CurrLineType: TLineType;
  CurrFigure, ClickFigure: PFigList;
  tempX, tempY: integer;
  DM: TDrawMode;
  EM: TEditMode;
  prevText:String;
  currPointAdr: PPointsList;
  //FT: TFigureType;


implementation
{$R *.dfm}


procedure TEditorForm.changeEditorText(newtext: string);
begin
  edtRectText.text := newtext;
end;


procedure TEditorForm.btnALineClick(Sender: TObject);
begin
  CurrType := Line;
  CurrLineType := LAdditLine;
end;

procedure TEditorForm.btnDefClick(Sender: TObject);
begin
  CurrType := def;
end;

procedure TEditorForm.btnLineClick(Sender: TObject);
begin
  CurrType := Line;
  CurrLineType := LLine;
end;

procedure TEditorForm.btnMCClick(Sender: TObject);
begin
  CurrType := MetaConst;
end;

procedure TEditorForm.btnMVClick(Sender: TObject);
begin
  CurrType := MetaVar;
end;

procedure TEditorForm.btnNoneClick(Sender: TObject);
begin
  CurrType := None;
end;



procedure TEditorForm.canvMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var x0, y0: Integer;
begin
  x0 := x;
  y0 := y;
  roundCoords(x,y);
  if dm = DrawLine then
  begin
    case button of
      TMouseButton.mbLeft: addNewPoint( CurrFigure^.Info.PointHead, x,y);
      TMouseButton.mbRight: dm:=NoDraw;
      TMouseButton.mbMiddle: dm:=NoDraw;
    end;

  end
  else
    DM := Draw; // Начинаем рисование
  
  //Label2.Caption := IntToStr(x) + ' ' + IntToStr(y);

  if (EM = NoEdit) and (CurrType <> None) then
  begin
    if CurrType <> Line then
    begin
      CurrFigure := addFigure(FigHead, x,y, CurrType, edtRectText.Text);
      CurrFigure.Info.y1 := y - abs(CurrFigure.Info.y1 - CurrFigure.Info.y2) div 2
    end
    else if (DM <> DrawLine) and (Button = mbLeft) then
    begin
      CurrFigure := addLine(FigHead, x,y);
      DM := DrawLine;
    end;
  end
  else
  begin
    tempx:= x;
    tempy:= y;
  end;

  ClickFigure := getClickFigure(x0,y0, FigHead);
  if (ClickFigure <> nil) and (ClickFigure^.Info.tp <> line) 
        and (CurrFigure^.Info.tp <> line) then
  begin
    changeEditorText(String(ClickFigure^.Info.Txt));
  end
  else
  begin
    changeEditorText(prevText);
  end;
end;

procedure changeCursor(Form:TForm; Mode: TEditMode);
begin
  case mode of
    NoEdit: Form.Cursor := crArrow;
    Move: Form.Cursor := crSizeAll;
    TSide: Form.Cursor := crSizeNS;
    BSide: Form.Cursor := crSizeNS;
    RSide: Form.Cursor := crSizeWE;
    LSide: Form.Cursor := crSizeWE;
    Vert1: Form.Cursor := crSizeNWSE;
    Vert2: Form.Cursor := crSizeNESW;
    Vert3: Form.Cursor := crSizeNESW;
    Vert4: Form.Cursor := crSizeNWSE;
  end;
end;

function TEditorForm.getFigureHead:PFigList;
begin
  Result:= FigHead;
end;

procedure TEditorForm.getTextWH (var TW, TH: Integer; text: string; size: integer; family: string);
var 
  PrevF: string;
  prevSize:integer;
begin
  with canv do
  begin
    prevSize := Canvas.Font.Size;

    //canvas.Font.Size := size;
    TW := canvas.TextWidth(text);
    TH := Canvas.TextHeight(text);

    canvas.Font.Size := prevSize;
  end;

end;

procedure TEditorForm.canvMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  if clickfigure = nil then
    prevText:= edtRectText.Text;
  if (CurrType <> Line) and (DM = DrawLine) then
    DM := nodraw;
  if dm = NoDraw then
  begin
    EM := getEditMode(DM, x,y,FigHead);
    changeCursor(Self, EM); // Меняем курсор в зависимости от положения мыши

    if ClickFigure <> nil then
    begin
      selectFigure(canv.Canvas, ClickFigure);
    end;
  end;
  if (DM = draw) and (currfigure <> nil)  then
  begin
    if CurrFigure.Info.tp = Line then
      roundCoords(x,y);

    ChangeCoords(CurrFigure, EM, x,y, tempX, tempY);
    TempX:= X; // Обновляем прошлые координаты
    TempY:= Y;
    canv.Repaint;
    //clearScreen; // Чистим экран
    //drawFigure(canv.Canvas, FigHead);
  end;
end;

procedure TEditorForm.canvMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if DM <> DrawLine then
  begin
    DM := NoDraw; // Заканчиваем рисование
    checkFigureCoord(CurrFigure);
  end;
  {if CurrType = Line then
    clearScreen;}
  canv.Repaint;
end;

procedure TEditorForm.canvPaint(Sender: TObject);
begin
  clearScreen;
  drawFigure(canv.Canvas, FigHead);
end;

procedure TEditorForm.clearScreen;
begin
  canv.Canvas.Rectangle(0,0,canv.Width,canv.Height);
end;

procedure TEditorForm.FormCreate(Sender: TObject);
begin
  Self.DoubleBuffered := true;
  createFigList(FigHead);
  CurrType := Def;
  EM := NoEdit;
  CurrFigure := nil;
  clearScreen;
end;

procedure TEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = VK_DELETE) and (ClickFigure <> nil) then
  begin
    removeFigure(FigHead, ClickFigure);
    updateScreen(canv.Canvas, FigHead);
    ClickFigure := nil;
  end;
  if (key = VK_RETURN) and (ClickFigure <> nil) and (ClickFigure.Info.tp <> Line) then
  begin
    ClickFigure.Info.Txt := ShortString(edtRectText.Text);
    Self.Resize;
  end;
end;

procedure TEditorForm.FormResize(Sender: TObject);
begin
  //canv.Picture.Bitmap.Height := canv.Height;
  //canv.Picture.Bitmap.Width := canv.Width;
  canv.Repaint;
end;

function TEditorForm.openFile(mode: TFileMode):string;
begin
  Result := '';
  case mode of
    FSVG:
    begin
      OpenDialog1.DefaultExt := 'svg';
      OpenDialog1.Filter := 'SVG|*.svg';
    end;
    FBRakh:
    begin
      OpenDialog1.DefaultExt := 'brakh';
      OpenDialog1.Filter := 'Source-File|*.brakh';
    end;
  end;
  if OpenDialog1.Execute then
  begin
    Result := OpenDialog1.FileName;
  end;
end;

procedure TEditorForm.mniOpenClick(Sender: TObject);
var
  path: string;
begin
  path := openFile(FBrakh);
  if path <> '' then
  begin
    removeAllList(FigHead);
    readFile(FigHead, path);
  end;
end;

function TEditorForm.saveFile(mode: TFileMode):string;
begin
  Result := '';
  case mode of
    FSvg:
    begin
      saveDialog1.Filter := 'SVG|*.svg';
      saveDialog1.DefaultExt := 'svg';
    end;
    FBrakh:
    begin
      saveDialog1.Filter := 'Source-File|*.brakh';
      saveDialog1.DefaultExt := 'brakh';
    end;
  end;
  if SaveDialog1.Execute then
  begin
    Result := SaveDialog1.FileName;
  end;

end;

procedure TEditorForm.saveBrakhFile;
  var
  path: string;
begin
  path := saveFile(FBrakh);
  if path <> '' then
    saveToFile(FigHead, path);
end;

procedure TEditorForm.saveSVGFile;
var
  path: string;
begin
  path := saveFile(FSvg);
  if path <> '' then
    ExportTOSvg(FigHead, canv.Width, canv.Height, path, 'Syntax Diagram Project', 'Create by BrakhMen.info');
end;

procedure TEditorForm.mniSaveClick(Sender: TObject);
begin
  saveBrakhFile;
end;

procedure TEditorForm.mniToSVGClick(Sender: TObject);
begin
  saveSVGFile;
end;

procedure TEditorForm.SD_Resize;
begin
  self.resize;
end;
end.
