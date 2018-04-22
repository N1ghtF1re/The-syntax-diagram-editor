unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, math,
  Vcl.Menus, SD_Types, SD_View, SD_InitData, SD_Model, SVGUtils, Vcl.Buttons;
type
  TEditorForm = class(TForm)
    edtRectText: TEdit;
    btnDef: TButton;
    btnMV: TButton;
    btnMC: TButton;
    btnLine: TButton;
    pnlOptions: TPanel;
    btnNone: TButton;
    MainMenu: TMainMenu;
    mnFile: TMenuItem;
    mniSave: TMenuItem;
    mniOpen: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    mniToSVG: TMenuItem;
    canv: TPaintBox;
    mniExportToBMP: TMenuItem;
    mniExport: TMenuItem;
    mniSaveAs: TMenuItem;
    mniNew: TMenuItem;
    mnSettings: TMenuItem;
    mniHolstSize: TMenuItem;
    ScrollBox1: TScrollBox;
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
    function  saveBrakhFile:boolean;
    procedure saveSVGFile;
    procedure canvPaint(Sender: TObject);
    procedure saveBMPFile;
    procedure mniExportToBMPClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mniSaveAsClick(Sender: TObject);
    procedure mniNewClick(Sender: TObject);
    procedure mniHolstSizeClick(Sender: TObject);
    procedure ScrollBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    
  private
    isChanged: Boolean;
    currpath: string;
    procedure switchChangedStatus(flag: Boolean);
    procedure changePath(path: string);
  public
    procedure SD_Resize;
    function getFigureHead:PFigList;
    procedure getTextWH(var TW, TH: Integer; text: string; size: integer; family: string);
    function openFile(mode: TFileMode):string;
    function saveFile(mode: TFileMode):string;
    procedure changeCanvasSize(w,h: Integer);

    
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

uses FCanvasSizeSettings;

procedure TEditorForm.changeEditorText(newtext: string);
begin
  edtRectText.text := newtext;
end;


procedure TEditorForm.btnALineClick(Sender: TObject);
begin
  CurrType := Line;
end;

procedure TEditorForm.btnDefClick(Sender: TObject);
begin
  CurrType := def;
end;

procedure TEditorForm.switchChangedStatus(flag: Boolean);
begin
  isChanged := flag;
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
      TMouseButton.mbLeft:
      begin
        addNewPoint( CurrFigure^.Info.PointHead, x,y);
        isChanged := true;
      end;
      TMouseButton.mbRight: dm:=NoDraw;
      TMouseButton.mbMiddle: dm:=NoDraw;
    end;

  end
  else
    DM := Draw; // Начинаем рисование
  
  //Label2.Caption := IntToStr(x) + ' ' + IntToStr(y);

  if (EM = NoEdit) and (CurrType <> None) then
  begin
    isChanged := true;
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

procedure changeCursor(ScrollBox:TScrollBox; Mode: TEditMode);
begin
  case mode of
    NoEdit: ScrollBox.Cursor := crArrow;
    Move: ScrollBox.Cursor := crSizeAll;
    TSide: ScrollBox.Cursor := crSizeNS;
    BSide: ScrollBox.Cursor := crSizeNS;
    RSide: ScrollBox.Cursor := crSizeWE;
    LSide: ScrollBox.Cursor := crSizeWE;
    Vert1: ScrollBox.Cursor := crSizeNWSE;
    Vert2: ScrollBox.Cursor := crSizeNESW;
    Vert3: ScrollBox.Cursor := crSizeNESW;
    Vert4: ScrollBox.Cursor := crSizeNWSE;
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
    changeCursor(ScrollBox1, EM); // Меняем курсор в зависимости от положения мыши

    if ClickFigure <> nil then
    begin
      selectFigure(canv.Canvas, ClickFigure);
    end;
  end;
  if (DM = draw) and (currfigure <> nil)  then
  begin
    switchChangedStatus(TRUE);
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
  Canv.Canvas.Pen.Width := 1;
  canv.Canvas.Rectangle(0,0,canv.Width,canv.Height);
end;

procedure TEditorForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
 answer: integer;
begin
  if isChanged then
  begin
    answer := MessageDlg('Вы внесли изменения.. А не хотите ли Вы сохраниться перед тем, как выйти?',mtCustom,
                              [mbYes,mbNo,mbCancel], 0);
    case answer of
      mrYes:
      begin
        if saveBrakhFile then
          Action := caFree
        else
          Action := caNone;
      end;
      mrNo: Action := caFree;
      mrCancel: Action := caNone;
    end;
  end;

end;

procedure TEditorForm.FormCreate(Sender: TObject);
begin
  currpath := '';
  Self.DoubleBuffered := true;
  switchChangedStatus(false);
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
    switchChangedStatus(true);
    ClickFigure := nil;
    Self.clearScreen;
    drawFigure(canv.canvas,FigHead);
  end;
  if (key = VK_RETURN) and (ClickFigure <> nil) and (ClickFigure.Info.tp <> Line) then
  begin
    ClickFigure.Info.Txt := ShortString(edtRectText.Text);
    canv.Repaint;
  end;
  if (GetKeyState(ord('S')) < 0) and (GetKeyState(VK_CONTROL) < 0) then
    mniSave.Click;
end;

procedure TEditorForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) and (ClickFigure <> nil) and (ClickFigure.Info.tp <> Line) then
  begin
    Key := #0;
  end;
end;

procedure TEditorForm.FormResize(Sender: TObject);
begin
  canv.Repaint;
end;

function ExtractFileNameEx(FileName:string):string;
var
  i:integer;
begin
  i:=Length(FileName);
  if i<>0 then
  begin
    while (FileName[i]<>'\') and (i>0) do
    begin
      i:=i-1;
      Result:=Copy(FileName,i+1,Length(FileName)-i);
    end;
  end;
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

procedure TEditorForm.saveBMPFile;
var
  path: string;
begin
  path := saveFile(FBmp);
  if path <> '' then
  begin
    ClickFigure := nil;
    clearScreen;
    drawFigure(canv.Canvas, FigHead,false);

    with TBitMap.Create do begin
      width := canv.Width;
      height := canv.Height;
      bitblt(canvas.Handle,0,0,width,height,canv.Canvas.Handle,0,0,srcCopy);
      SaveToFile(path);
    end;

    canv.Repaint;
  end;
end;

procedure TEditorForm.mniExportToBMPClick(Sender: TObject);
begin
  saveBMPFile;
end;

procedure TEditorForm.mniHolstSizeClick(Sender: TObject);
var
  neww, newh : integer;
begin
  CanvasSettingsForm.showForm(canv.Width ,canv.Height);
  Self.Repaint;
end;

procedure TEditorForm.changeCanvasSize(w,h: Integer);
begin
  canv.width := w;
  canv.height := h;
end;

procedure TEditorForm.mniNewClick(Sender: TObject);
begin
  if MessageDlg('Вы уверены? Все несохраненные данные будут удалены. Продолжить?',mtCustom,[mbYes,mbNo], 0) = mrYes then
  begin
    Self.Caption := 'Новый файл - Syntax Diagrams';
    removeAllList(FigHead);
    currpath := '';
    switchChangedStatus(false);
    Repaint;
  end;
end;

procedure TEditorForm.changePath(path: string);
var
    FileName: string;
begin
  FileName := ExtractFileNameEx(path);
  Self.Caption := FileName + ' - Syntax Diagrams';
  currpath := path;

end;

procedure TEditorForm.mniOpenClick(Sender: TObject);
var
  path: string;
begin
  path := openFile(FBrakh);
  if path <> '' then
  begin
    changePath(path);
    switchChangedStatus(False);
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
    FBmp:
    begin

      saveDialog1.Filter := 'Bitmap Picture|*.bmp';
      saveDialog1.DefaultExt := 'bmp';
    end;
  end;
  if SaveDialog1.Execute then
  begin
    Result := SaveDialog1.FileName;
  end;

end;

function TEditorForm.saveBrakhFile:boolean;
  var
  path: string;
begin
  Result:=false;
  path := saveFile(FBrakh);
  if path <> '' then
  begin
    saveToFile(FigHead, path);
    changePath(path);
    switchChangedStatus(False);
    Result := true;
  end;
end;

procedure TEditorForm.saveSVGFile;
var
  path: string;
begin
  path := saveFile(FSvg);
  if path <> '' then
    ExportTOSvg(FigHead, canv.Width, canv.Height, path, 'Syntax Diagram Project', 'Create by BrakhMen.info');
end;

procedure TEditorForm.mniSaveAsClick(Sender: TObject);
begin
  saveBrakhFile;
end;

procedure TEditorForm.mniSaveClick(Sender: TObject);
begin
  if currpath <> '' then
  begin
    saveToFile(FigHead, currpath);
    switchChangedStatus(False);
  end
  else
    saveBrakhFile;
end;

procedure TEditorForm.mniToSVGClick(Sender: TObject);
begin
  saveSVGFile;
end;

procedure TEditorForm.ScrollBox1MouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with scrollBox1.VertScrollBar do
   Position := Position + Increment;
end;

procedure TEditorForm.ScrollBox1MouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with scrollBox1.VertScrollBar do
   Position := Position - Increment;

end;

procedure TEditorForm.SD_Resize;
begin
  self.resize;
end;

end.
