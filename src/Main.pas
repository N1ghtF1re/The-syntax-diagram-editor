unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, math,
  Vcl.Menus, SD_Types, SD_View, SD_InitData, SD_Model, SVGUtils, Vcl.Buttons,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.ToolWin, Model.UndoStack;
type
  TEditorForm = class(TForm)
    edtRectText: TEdit;
    MainMenu: TMainMenu;
    mnFile: TMenuItem;
    mniSave: TMenuItem;
    mniOpen: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    mniToSVG: TMenuItem;
    pbMain: TPaintBox;
    mniExportToBMP: TMenuItem;
    mniExport: TMenuItem;
    mniSaveAs: TMenuItem;
    mnSettings: TMenuItem;
    mniHolstSize: TMenuItem;
    ScrollBox1: TScrollBox;
    mniHtml: TMenuItem;
    mniWhatIsSD: TMenuItem;
    mniNew: TMenuItem;
    alMenu: TActionList;
    actNew: TAction;
    actOpen: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actExportBMP: TAction;
    actExportSVG: TAction;
    actCopy: TAction;
    mniEdit: TMenuItem;
    mniCopy: TMenuItem;
    actPast: TAction;
    mniPast: TMenuItem;
    ilMenu: TImageList;
    actCanvasSize: TAction;
    actAboutSB: TAction;
    tbarMenu: TToolBar;
    tbNew: TToolButton;
    tbOpen: TToolButton;
    tbSave: TToolButton;
    tbSaveAs: TToolButton;
    ToolButton5: TToolButton;
    tbCopy: TToolButton;
    tbPast: TToolButton;
    ToolButton1: TToolButton;
    tbBMP: TToolButton;
    tbSVG: TToolButton;
    tbSelectFigType: TToolBar;
    tbFigDef: TToolButton;
    tbFigMV: TToolButton;
    tbFigConst: TToolButton;
    tbFigLine: TToolButton;
    tbFigNone: TToolButton;
    ilFigures: TImageList;
    alSelectFigure: TActionList;
    actFigNone: TAction;
    actFigLine: TAction;
    actFigDef: TAction;
    actFigMetaVar: TAction;
    actFigMetaConst: TAction;
    lblEnterText: TLabel;
    tbSelectScale: TTrackBar;
    lblScale: TLabel;
    lblScaleView: TLabel;
    actUndo: TAction;
    mniUndo: TMenuItem;
    ToolButton2: TToolButton;
    actHelp: TAction;
    mniProgramHelp: TMenuItem;
    actPNG: TAction;
    mniPNGExport: TMenuItem;
    tbPNG: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure clearScreen;
    procedure pbMainMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure changeEditorText(newtext: string);
    procedure FormResize(Sender: TObject);
    function  saveBrakhFile:boolean;
    procedure saveSVGFile;
    procedure pbMainPaint(Sender: TObject);
    procedure saveBMPFile;
    procedure savePNGFile;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mniNewClick(Sender: TObject);
    procedure ScrollBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure actNewExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actExportBMPExecute(Sender: TObject);
    procedure actExportSVGExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actPastExecute(Sender: TObject);
    procedure actCanvasSizeExecute(Sender: TObject);
    procedure actAboutSBExecute(Sender: TObject);
    procedure actFigNoneExecute(Sender: TObject);
    procedure actFigLineExecute(Sender: TObject);
    procedure actFigDefExecute(Sender: TObject);
    procedure actFigMetaVarExecute(Sender: TObject);
    procedure actFigMetaConstExecute(Sender: TObject);
    procedure tbSelectScaleChange(Sender: TObject);
    procedure actUndoExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actPNGExecute(Sender: TObject);
    procedure Action1Execute(Sender: TObject);

    
  private
    isChanged: Boolean;
    currpath: string;
    isMoveFigure: Boolean;
    USVertex: PUndoStack; // US - Undo Stack
    procedure switchChangedStatus(flag: Boolean);
    procedure changePath(path: string);
    procedure newFile;
  public
    PBW, PBH: integer;
    FScale: Real;
    procedure useScale(var x,y: integer);
    procedure DiscardScale(var x,y: integer);
    procedure SD_Resize;
    function getFigureHead:PFigList;
    procedure getTextWH(var TW, TH: Integer; text: string; size: integer; family: string);
    function openFile(mode: TFileMode):string;
    function saveFile(mode: TFileMode):string;
    procedure changeCanvasSize(w,h: Integer);
    procedure getCanvasSIze(var w,h:Integer);
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
  CoppyFigure: PFigList;
  //FT: TFigureType;


implementation
{$R *.dfm}
{$R HTML.RES}
{$R+}
{$R-}

uses FCanvasSizeSettings, FHtmlView, Model.FilesUtil;

procedure TEditorForm.changeEditorText(newtext: string);
begin
  edtRectText.text := newtext
end;

procedure TEditorForm.switchChangedStatus(flag: Boolean);
begin
  isChanged := flag;
end;

// Select the scale of the image
procedure TEditorForm.tbSelectScaleChange(Sender: TObject);
begin
  case (Sender as TTrackBar).Position of
    1: FScale := 0.1;
    2: FScale := 0.3;
    3: FScale := 0.5;
    4: FScale := 0.8;
    5: FScale := 1;
    6: FScale := 1.2;
    7: FScale := 1.5;
    8: FScale := 1.7;
    9: FScale := 2;
    10: FScale := 4;
  end;
  lblScaleView.Caption := '  ' + IntToStr( Round(FScale*100) ) + '%';
  changeCanvasSize(PBW, PBH);
  Self.Invalidate;
end;

procedure TEditorForm.useScale(var x, y: integer);
begin
  x := Round(FScale*x);
  y := Round(FScale*y);
end;

procedure TEditorForm.pbMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var x0, y0: Integer;
  UndoRec: TUndoStackInfo;
begin
  x0 := x;
  y0 := y;
  roundCoords(x,y); // round coords (Use steps)
  if dm = DrawLine then
  begin
    case button of
      TMouseButton.mbLeft:
      begin
        // Add new point of current line:
        UndoRec.PrevPointAdr := addNewPoint( CurrFigure^.Info.PointHead, Round(x / FScale),Round(y / FScale));
        // CHANGES STASCK PUSHING START
        UndoRec.ChangeType := chAddPoint;
        UndoRec.adr := CurrFigure;
        UndoStackPush(USVertex, UndoRec);
        isChanged := true;
        actUndo.Enabled := true;
        // CHANGES STASCK PUSHING END
      end;
      // If clicked button - right or middle then finish drawing
      TMouseButton.mbRight: dm:=NoDraw;
      TMouseButton.mbMiddle: dm:=NoDraw;
    end;

  end
  else
    DM := Draw; // Begin Drawing

  // If 
  if (EM = NoEdit) and (CurrType <> None) then
  begin
    isChanged := true;
    // if at the moment nothing draws, start drawing
    if CurrType <> Line then
    begin
      // Add new figure to canvas
      CurrFigure := addFigure(FigHead, Round(x/FScale),Round(y/FSCale), CurrType, edtRectText.Text);
      // CHANGES STACK PUSHING START
      UndoRec.ChangeType := chInsert;
      UndoRec.adr := Currfigure;
      CurrFigure.Info.y1 := y - abs(CurrFigure.Info.y1 - CurrFigure.Info.y2) div 2;
      UndoStackPush(USVertex, UndoRec);
      actUndo.Enabled := true;
      // CHANGES STACK PUSHING END
    end
    else if (DM <> DrawLine) and (Button = mbLeft) then
    begin
      // Add new lines to canvas
      CurrFigure := addLine(FigHead, Round(x/FScale),Round(y/FScale));
      // CHANGES STASCK PUSHING START
      UndoRec.ChangeType := chInsert;
      UndoRec.adr := Currfigure;
      DM := DrawLine;
      UndoStackPush(USVertex, UndoRec);
      actUndo.Enabled := true;
      // CHANGES STASCK PUSHING END
    end;
  end
  else
  begin
    tempx:= x; // Update coordinates for moving
    tempy:= y;
  end;

  // If the click occurred on the figure, we put the current variable in the 
  // appropriate variable
  ClickFigure := getClickFigure(Round(x0/FScale) ,Round(y0/FScale), FigHead);
  if (ClickFigure <> nil) and (ClickFigure^.Info.tp <> line) and (CurrFigure <> nil)
        and (CurrFigure^.Info.tp <> line) then
  begin
    // We paste into the text field with the text of the figure the text of the current shape
    changeEditorText(String(ClickFigure^.Info.Txt));
  end
  else
  begin
    changeEditorText(prevText);
  end;
  // Remove lines with one point
  removeTrashLines(FigHead, CurrFigure);
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
    LineMove: ScrollBox.Cursor := crHandPoint;
  end;
end;

// Return canvas size
procedure TEditorForm.getCanvasSIze(var w, h: Integer);
begin
  w := Self.pbMain.Width;
  h := self.pbMain.Height;
end;

// Return figure head
function TEditorForm.getFigureHead:PFigList;
begin
  Result:= FigHead;
end;

procedure TEditorForm.pbMainMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  undorec: TUndoStackInfo;
begin
  if clickfigure = nil then
    prevText:= edtRectText.Text;
  if (CurrType <> Line) and (DM = DrawLine) then
    DM := nodraw;
  if (dm = NoDraw) and (CurrType = None) then
  begin
  
    EM := getEditMode(DM, Round(x/FScale),Round(y/FScale),FigHead, CurrType);
    changeCursor(ScrollBox1, EM); // Меняем курсор в зависимости от положения мыши

    if ClickFigure <> nil then
    begin
      selectFigure(pbMain.Canvas, ClickFigure); // add green verts for selected figure
    end;
  end;
  if (DM = draw) and (currfigure <> nil)  then
  begin
    if not isMoveFigure then
    begin
      // START MOVING

      // CHANGES STACK PUSHING START
      isMoveFigure := true;
      undorec.adr := CurrFigure;
      if CurrFigure^.Info.tp <> Line then
      begin
        undorec.ChangeType := chFigMove;
        undorec.PrevInfo := CurrFigure^.Info;
      end
      else
      begin
        undorec.ChangeType := chPointMove;
        undorec.st := pointsToStr(CurrFigure^.Info.PointHead^.adr);
      end;
      UndoStackPush(USVertex, undorec);
      actUndo.Enabled := true;
      // CHANGES STACK PUSHING END
    end;

    switchChangedStatus(TRUE); 
    ChangeCoords(CurrFigure, EM, x,y, tempX, tempY ); // Changes coords
    TempX:= X; // Update old coords
    TempY:= Y;
    pbMain.Repaint;
  end;
end;

procedure TEditorForm.pbMainMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if DM <> DrawLine then
  begin
    DM := NoDraw; // Заканчиваем рисование
    checkFigureCoord(CurrFigure);
  end;
  if isMoveFigure then
  begin
    isMoveFigure := false;
  end;

  MagnetizeLines(FigHead); 

  pbMain.Repaint;
end;

procedure TEditorForm.pbMainPaint(Sender: TObject);
begin
  with (Sender as TPaintBox) do
  begin
    clearScreen;
    drawFigure(Canvas, FigHead, FScale); // Draw all figures, lines
  end;
end;

procedure TEditorForm.clearScreen;
begin
  pbMain.Canvas.Pen.Width := 1;
  pbMain.Canvas.Rectangle(0,0,pbMain.Width,pbMain.Height); // Draw white rectangle :)
end;


procedure TEditorForm.DiscardScale(var x, y: integer);
begin
  x := Round(x/FScale);
  y := Round(y/FScale);
end;

procedure TEditorForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
 answer: integer;
begin
  if isChanged then
  begin
    answer := MessageDlg(rsExitDlg,mtCustom,
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

function analyseParams: string;  // The name of the file when opened is not through the program
var
  params: string;
  i: integer;
begin
  params:='';
  if ParamCount>0 then
  for i := 1 to ParamCount do
  begin
  params := params + ParamStr(i);
  if i<>ParamCount then params := params + ' ';
  end;
  result := params;
end;

procedure TEditorForm.FormCreate(Sender: TObject); 
var path : string;
begin
  // Initialise: 
  FScale := 1; // Default Scale
  PBH := pbMain.height;
  PBW := pbMain.Width;
  pbMain.Width := round(pbMain.Width*Fscale);
  pbMain.Height := round(pbMain.height*Fscale);
  tbFigNone.Down := true;
  actPast.Enabled := false;
  currpath := '';
  Self.DoubleBuffered := true;
  switchChangedStatus(false);
  createFigList(FigHead);
  CurrType := None;
  EM := NoEdit;
  CurrFigure := nil;
  clearScreen;
  CoppyFigure := nil;

  // UNDO STACK
  CreateStack(USVertex);
  path := analyseParams; // Анализируем входные параметры, открыта ли программа
  // открытием .brakh-файла
  if path <> '' then
  begin
    removeAllList(FigHead);
    changePath(path);
    readFile(FigHead, path);
  end;
end;

procedure TEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  UndoRec: TUndoStackInfo;
begin
  if (key = VK_DELETE) and (ClickFigure <> nil) then
  begin
    // CHANGES STACK PUSHING START
    UndoRec.adr := ClickFigure;
    UndoRec.PrevFigure := removeFigure(FigHead, ClickFigure);
    UndoRec.ChangeType :=chDelete;
    actUndo.Enabled := true;
    UndoStackPush(USVertex, UndoRec);
    // CHANGES STACK PUSHING END
    switchChangedStatus(true);
    ClickFigure := nil;
    Self.clearScreen;
    drawFigure(pbMain.canvas,FigHead, FScale);
  end;
  if (key = VK_RETURN) and (ClickFigure <> nil) and (ClickFigure.Info.tp <> Line) then
  begin
    // CHANGES STACK PUSHING START
    UndoRec.adr := ClickFigure;
    UndoRec.text := ClickFigure.Info.Txt;
    UndoRec.ChangeType := chChangeText;
    UndoStackPush(USVertex, UndoRec);
    actUndo.Enabled := true;
    // CHANGES STACK PUSHING END

    // Change Caption of current figure
    ClickFigure.Info.Txt := ShortString(edtRectText.Text);
    pbMain.Repaint;
  end;

  //ShowMessage( IntToStr(key) );

  // SHORTCUT FOR SCALE UP : ctrl + "+"
  if (GetKeyState( VK_OEM_PLUS ) < 0) and (GetKeyState(VK_CONTROL) < 0) then
  begin
    tbSelectScale.Position := tbSelectScale.Position + 1;
    tbSelectScale.Update;
  end;
  
  // SHORTCUT FOR SCALE DOWN : ctrl + "-"
  if (GetKeyState( VK_OEM_MINUS ) < 0) and (GetKeyState(VK_CONTROL) < 0) then
  begin
    tbSelectScale.Position := tbSelectScale.Position - 1;
    tbSelectScale.Update;
  end;  
end;

procedure TEditorForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  // REMOVE BEEEEEEEEP WHERE PRESSED "ENTER"
  if (Key = #13) and (ClickFigure <> nil) and (ClickFigure.Info.tp <> Line) then
  begin
    Key := #0;
  end;
end;

procedure TEditorForm.FormResize(Sender: TObject);
begin
  pbMain.Repaint;
end;


// Reurn only filename, delete other path 
// Example: input: C:/data/input.brakh
//          output: input brakh
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


// SAVING BMP FILE
procedure TEditorForm.saveBMPFile;
var
  path: string;
  oldScale: real;
const
  ExportScale = 4; // Create good DPI for image :)
begin
  oldScale := FScale; // Save old scale
  path := saveFile(FBmp); // Getting path of file
  if path <> '' then
  begin
    ClickFigure := nil;
    with TBitMap.Create do begin // Create bitmap
      // Change bitmap size
      width := pbMain.Width*ExportScale;
      height := pbMain.Height*ExportScale;

      // Change Scale for image
      FScale := ExportScale;

      // Draw figure for bitmap canvas
      drawFigure(Canvas, FigHead,ExportScale, false);
      
      FScale := oldScale; // Return old scale
      SaveToFile(path); // Save bmp
      free; // free bitmap
    end;
  end;
end;

// Change canvas size
procedure TEditorForm.changeCanvasSize(w,h: Integer);
begin
  PBH := h; // Update global size (for scale = 1)
  PBW := w;
  useScale(W, H); // Use scale for height and width
  pbMain.width := w; // update sizes
  pbMain.height := h;
end;

// Create new diagram
procedure TEditorForm.newFile;
begin
  Self.Caption := rsNewFile + ' - Syntax Diagrams';
  removeAllList(FigHead);
  currpath := '';
  switchChangedStatus(false);
  pbMain.Repaint;
end;

procedure TEditorForm.mniNewClick(Sender: TObject);
var
  answer: Integer;
begin
  answer := MessageDlg(rsNewFileDlg,mtCustom,[mbYes,mbNo], 0);
  if  answer = mrYes then
  begin
    newFile;
  end;
end;

// Change path 
procedure TEditorForm.changePath(path: string);
var
    FileName: string;
begin
  FileName := ExtractFileNameEx(path);
  Self.Caption := FileName + ' - Syntax Diagrams';
  currpath := path;

end;


function TEditorForm.saveFile(mode: TFileMode):string;
begin
  Result := '';
  case mode of
    FSvg:
    begin
      saveDialog1.FileName := 'SyntaxDiagrams.svg';
      saveDialog1.Filter := 'SVG|*.svg';
      saveDialog1.DefaultExt := 'svg';
    end;
    FBrakh:
    begin
      saveDialog1.FileName := 'SyntaxDiagrams.brakh';
      saveDialog1.Filter := 'Source-File|*.brakh';
      saveDialog1.DefaultExt := 'brakh';
    end;
    FBmp:
    begin
      saveDialog1.FileName := 'SyntaxDiagrams.bmp';
      saveDialog1.Filter := 'Bitmap Picture|*.bmp';
      saveDialog1.DefaultExt := 'bmp';
    end;
    FPng:
     begin
      saveDialog1.FileName := 'SyntaxDiagrams.png';
      saveDialog1.Filter := 'PNG|*.png';
      saveDialog1.DefaultExt := 'png';
    end;
  end;
  if SaveDialog1.Execute then
  begin
    Result := SaveDialog1.FileName;
  end;

end;


// EXPORT TO PNG FILE
procedure TEditorForm.savePNGFile;
var
  path: string;
  oldScale: real;
  png : TPngImage;
  bitmap: TBitmap;
const
  ExportScale = 4;
begin
  oldScale := FScale; // Save old scale
  path := saveFile(FPng); // Get file path
  if path <> '' then
  begin
    ClickFigure := nil;
    try
      bitmap := TBitMap.Create;  // create bitmap
      with bitmap do
      begin
        png := TPNGImage.Create; // Create PNGimage
        width := pbMain.Width*ExportScale; // Change bitmap size
        height := pbMain.Height*ExportScale; 
        FScale := ExportScale; // Scale for image
        drawFigure(Canvas, FigHead,ExportScale, false); // Drawing figure for bitmap canvas
        FScale := oldScale; // return old scale
      end;
        png.Assign(bitmap); // SAVE TO PNG:
        png.Draw(bitmap.Canvas, Rect(0, 0, bitmap.Width, bitmap.Height));
        png.SaveToFile(path)
     finally
        bitmap.free;
        png.free;
    end;
  end;
end;

// SAVE SOURCE FILE
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


// EXPORT TO SVG
procedure TEditorForm.saveSVGFile;
var
  path: string;
begin
  path := saveFile(FSvg);
  if path <> '' then
    ExportTOSvg(FigHead, pbMain.Width, pbMain.Height, path, 'Syntax Diagram Project', 'Create by BrakhMen.info');
end;

procedure TEditorForm.ScrollBox1MouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssShift in Shift then
  begin
    with (Sender as TScrollBox).HorzScrollBar do
     Position := Position + Increment;
  end
  else
  begin
    with (Sender as TScrollBox).VertScrollBar do
     Position := Position + Increment;
  end;
end;

procedure TEditorForm.ScrollBox1MouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssShift in Shift then
  begin
    with (Sender as TScrollBox).HorzScrollBar do
     Position := Position - Increment;
  end
  else
  begin
    with (Sender as TScrollBox).VertScrollBar do
     Position := Position - Increment;
  end;
end;


procedure TEditorForm.SD_Resize;
begin
  self.resize;
end;



// ACTIONS IMPLIMENTATION
procedure TEditorForm.actAboutSBExecute(Sender: TObject);
begin
  // Open the form with displaying HTML
  FHTml.showHTML(rsHelpHowIsSD_Caption,rsHelpHowIsSD_ResName);
end;


// Open the form with the form size settings
procedure TEditorForm.actCanvasSizeExecute(Sender: TObject);
var
  neww, newh : integer;
begin
  neww:= PBW;
  newh := PBH;
  CanvasSettingsForm.showForm(neww, newh); // Open form
  changeCanvasSize(neww, newh);
  Self.Repaint;
end;

procedure TEditorForm.actCopyExecute(Sender: TObject);
begin
  CoppyFigure := ClickFigure;
  actPast.Enabled := true;
end;

procedure TEditorForm.actExportBMPExecute(Sender: TObject);
begin
  saveBMPFile;
end;

procedure TEditorForm.actExportSVGExecute(Sender: TObject);
begin
  saveSVGFile;
end;

procedure TEditorForm.actFigDefExecute(Sender: TObject);
begin
  CurrType := def;
end;

procedure TEditorForm.actFigLineExecute(Sender: TObject);
begin
  CurrType := Line;
  CurrLineType := LLine;
end;

procedure TEditorForm.actFigMetaConstExecute(Sender: TObject);
begin
  CurrType := MetaConst;
end;

procedure TEditorForm.actFigMetaVarExecute(Sender: TObject);
begin
  CurrType := MetaVar;
end;

procedure TEditorForm.actFigNoneExecute(Sender: TObject);
begin
  CurrType := None;
end;

procedure TEditorForm.actHelpExecute(Sender: TObject);
begin
  FHTml.showHTML(rsHelp_Caption,rsHelp_ResName);
end;

procedure TEditorForm.Action1Execute(Sender: TObject);
begin
  showMessage('kek');
end;

// Create new Diagram
procedure TEditorForm.actNewExecute(Sender: TObject);
var
  answer: Integer;
begin
  answer := MessageDlg(rsNewFileDlg,mtCustom,[mbYes,mbNo], 0);  
  if  answer = mrYes then
  begin
    newFile;
    actUndo.Enabled := false;
    UndoStackClear(USVertex);
  end;

end;

// Open file
procedure TEditorForm.actOpenExecute(Sender: TObject);
var
  path: string;
  answer: integer;
begin
  if isChanged then  // if the diagram is changed, it is suggested to save the file 
  begin
    answer := MessageDlg(rsExitDlg,mtCustom,
                              [mbYes,mbNo,mbCancel], 0);
    case answer of
      mrYes:
      begin
        if not saveBrakhFile then exit  // Save file
      end;
      mrNo: ;
      mrCancel: exit;
    end;
  end;

  path := openFile(FBrakh);
  if path <> '' then
  begin

    removeAllList(FigHead);
    actUndo.Enabled := false;
    UndoStackClear(USVertex);
    if readFile(FigHead, path) then
    begin
      changePath(path);
      switchChangedStatus(False);
    end
    else
      newFile;
  end;
end;

procedure TEditorForm.actPastExecute(Sender: TObject);
begin

  actPast.Enabled := false;
  if CoppyFigure = nil then exit;
  
  CopyFigure(FigHead, CoppyFigure); // Create copy of CoppyFigure
end;

procedure TEditorForm.actPNGExecute(Sender: TObject);
begin
  savePNGFile;
end;

procedure TEditorForm.actSaveAsExecute(Sender: TObject);
begin
  saveBrakhFile;
end;

procedure TEditorForm.actSaveExecute(Sender: TObject);
begin
 if currpath <> '' then
  begin
    saveToFile(FigHead, currpath);
    switchChangedStatus(False);
  end
  else
    saveBrakhFile;
end;

procedure TEditorForm.actUndoExecute(Sender: TObject);
  var
    undoRec: TUndoStackInfo;
begin
  if undoStackPop(USVertex, undoRec) then // "Pop" an item from the stack
  begin
    undoChanges(undoRec, Canvas); // cancel changes
  end;

  if isStackEmpty(USVertex) then (Sender as TAction).Enabled := false;
  ClickFigure := nil;
  pbMain.Repaint;
end;

// Return text width (For SVGUtils)
procedure TEditorForm.getTextWH (var TW, TH: Integer; text: string; size: integer; family: string);
var

  prevSize:integer;
begin
  with pbMain do
  begin
    prevSize := Canvas.Font.Size;

    //canvas.Font.Size := size;
    TW := canvas.TextWidth(text);
    TH := Canvas.TextHeight(text);

    canvas.Font.Size := prevSize;
  end;

end;

end.
