unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, math,
  Vcl.Menus, Data.Types, View.Canvas, Data.InitData, Model, View.SVG, Vcl.Buttons,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.ToolWin, Model.UndoStack, Model.Lines;
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
    sbMain: TScrollBox;
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
    actResizeCanvas: TAction;
    tbResizeCanvas: TToolButton;
    ToolButton4: TToolButton;
    actChangeMagnetize: TAction;
    mniMagnetizeLine: TMenuItem;
    actRusLang: TAction;
    mniSelectLang: TMenuItem;
    actEngLang: TAction;
    mniEngLang: TMenuItem;
    mniRusLang: TMenuItem;
    actFrencLang: TAction;
    actFrencLang1: TMenuItem;
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
    procedure endDrawLine;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mniNewClick(Sender: TObject);
    procedure sbMainMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure sbMainMouseWheelUp(Sender: TObject; Shift: TShiftState;
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
    procedure FormDestroy(Sender: TObject);
    procedure actResizeCanvasExecute(Sender: TObject);
    procedure sbMainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sbMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actChangeMagnetizeExecute(Sender: TObject);
    procedure mniRusLangClick(Sender: TObject);
    procedure actEngLangExecute(Sender: TObject);
    procedure actRusLangExecute(Sender: TObject);
    procedure actFrencLangExecute(Sender: TObject);

    
  private
    isChanged: Boolean;
    SelectRect: TRect;
    currpath: string;
    selectFigures: PSelectFigure;
    isMoveFigure: Boolean;
    oldDM: TDrawMode;
    USVertex: PUndoStack; // US - Undo Stack
    procedure switchChangedStatus(flag: Boolean);
    procedure changePath(path: string);
    procedure newFile;
    procedure updateCanvasSizeWithCoords(x,y: Integer);
  public
    PBW, PBH: integer;
    FScale: Real;
    procedure useScale(var x,y: integer);
    procedure DiscardScale(var x,y: integer);
    procedure SD_Resize;
    function getFigureHead:PFigList;
    function openFile(mode: TFileMode):string;
    function saveFile(mode: TFileMode):string;
    procedure changeCanvasSize(w,h: Integer; flag: Boolean = true);
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
  CoppyFigures: PSelectFigure;
  //FT: TFigureType;


implementation
{$R *.dfm}
{$R HTML.RES}
{$R+}
{$R-}

uses FCanvasSizeSettings, FHtmlView, Model.Files,System.Win.Registry, System.UITypes,
Vcl.Touch.Gestures;

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

procedure TEditorForm.updateCanvasSizeWithCoords(x, y: Integer);
begin
  pbMain.Width := x;
  pbMain.Height := y; 
  pbMain.Repaint;
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
  if (CurrType = None) and (em = NoEdit) then
  begin
    removeSelectList(selectFigures);
    SelectRect.Left := x;
    SelectRect.Right := x;
    SelectRect.Top := y;
    SelectRect.Bottom := y;
  end;


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
      TMouseButton.mbRight: 
      begin
        // Remove lines with one point
        endDrawLine;
      end;
      TMouseButton.mbMiddle: endDrawLine;
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
  tmp: PSelectFigure;
begin
  if (x > pbMain.Width) or (x < 0) or (y < 0) or (y > pbMain.Height) then
     exit;
  if dm = ResizeCanvas then
  begin
    updateCanvasSizeWithCoords(x, y);
    exit;
  end;

  if (CurrType = None) and (EM = NoEdit) and (SelectRect.Top <> -1) then
  begin
    SelectRect.Bottom := y;
    SelectRect.Right := x;
    pbMain.Repaint;
    pbMain.Canvas.Brush.Style := bsClear;
    with SelectRect do
      pbMain.Canvas.Rectangle(Left, top, right, bottom);
    pbMain.Canvas.Brush.Style := bsSolid;
  end;

  if clickfigure = nil then
    prevText:= edtRectText.Text;

  if (CurrType = Line) and (DM=DrawLine) then
  begin
    pbMain.Repaint;
    drawProection(pbMain.Canvas, currfigure^.Info.PointHead, Round(x/FScale),Round(y/FScale));

  end;

  if (CurrType <> Line) and (DM = DrawLine) then
    DM := nodraw;
  if (dm = NoDraw) and (CurrType = None) then
  begin

    EM := getEditMode(DM, Round(x/FScale),Round(y/FScale),FigHead, CurrType);
    changeCursor(sbMain, EM); // Меняем курсор в зависимости от положения мыши

    
    if selectFigures.Adr <> nil then
    begin
      if em <> NoEdit then
        changeCursor(sbMain, Move);

      tmp := selectFigures^.Adr;
      while tmp <> nil do
      begin
        selectFigure(pbMain.Canvas, tmp.Figure);
        tmp := tmp^.Adr;
      end;
    end;


  end;
  if (DM = draw) and (currfigure <> nil)  then
  begin
    if (not isMoveFigure) and (CurrType = None) and (EM <> NoEdit) then
    begin
      // START MOVING
      tmp := selectFigures^.Adr;
      // CHANGES STACK PUSHING START
      isMoveFigure := true;
      while tmp <> nil do
      begin
        undorec.adr := tmp^.Figure;
        if tmp^.figure^.Info.tp <> Line then
        begin
          undorec.ChangeType := chFigMove;
          undorec.PrevInfo := tmp^.figure^.Info;
        end
        else
        begin
          undorec.ChangeType := chPointMove;
          undorec.st := pointsToStr(tmp^.figure^.Info.PointHead^.adr);
        end;
        UndoStackPush(USVertex, undorec);
        tmp := tmp^.Adr;
      end;
      actUndo.Enabled := true;
      // CHANGES STACK PUSHING END
    end;

    switchChangedStatus(TRUE);
    tmp := selectFigures^.Adr;

    if tmp = nil then
      ChangeCoords(CurrFigure, EM, x,y, tempX, tempY, fscale) // Changes coords
    else
    begin
      while tmp <> nil do
      begin
        if tmp^.Figure.Info.tp = line then
          ChangeCoords(tmp^.Figure, LineMove , x,y, tempX, tempY, fscale)
        else
          ChangeCoords(tmp^.Figure, Move , x,y, tempX, tempY, fscale);
        tmp := tmp^.Adr;
      end;
    end;
    TempX:= X; // Update old coords
    TempY:= Y;
    if EM <> NoEdit then
      pbMain.Repaint;
  end;
end;

procedure TEditorForm.pbMainMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  // If the click occurred on the figure, we put the current variable in the
  // appropriate variable
  ClickFigure := getClickFigure(Round(x/FScale) ,Round(y/FScale), FigHead);
  if (ClickFigure <> nil) and not isMoveFigure then
  begin
    removeSelectList(selectFigures);
    insertSelectsList(selectFigures, ClickFigure);
  end;
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

  if (CurrType = None) and (EM = noEdit) then
  begin
    removeSelectList(selectFigures);
    if (ClickFigure <> nil) then
      insertSelectsList(selectFigures, ClickFigure);
    addToSelectList(FigHead, selectFigures, SelectRect);
    SelectRect.Top := -1;
  end;

  if DM <> DrawLine then
  begin
    DM := NoDraw; // End draw
    checkFigureCoord(CurrFigure);
  end;
  if isMoveFigure then
  begin
    if mniMagnetizeLine.Checked and (CurrType <> line) then
      SearchFiguresInOneLine(FigHead, CurrFigure);
    isMoveFigure := false;
  end;
  if mniMagnetizeLine.Checked then    
    MagnetizeLines(FigHead);


  Self.pbMain.Repaint;
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
  if DM = ResizeCanvas then
  begin
    pbMain.Canvas.Pen.Width := 1;
    pbmain.Canvas.Pen.Style := psDash;
    pbMain.Canvas.Pen.Color := clBlack;
  end
  else
  begin
    pbMain.Canvas.Pen.Width := 1;
    pbMain.Canvas.Pen.Style := psSolid;
    pbMain.Canvas.Pen.Color := clBlack;    
  end;
  pbMain.Canvas.Brush.Color := clWhite;
  pbMain.Canvas.Rectangle(0,0,pbMain.Width,pbMain.Height); // Draw white rectangle :)
end;


procedure TEditorForm.DiscardScale(var x, y: integer);
begin
  x := Round(x/FScale);
  y := Round(y/FScale);
end;

procedure TEditorForm.endDrawLine;
begin
  removeTrashLines(FigHead, CurrFigure); 
  dm:=NoDraw;
  pbMain.Repaint;
end;

procedure TEditorForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
 answer: integer;
begin
  if isChanged then
  begin
    answer := MessageDlg(rsExitDlg,mtWarning,
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

procedure SetLocaleOverride(const FileName, LocaleOverride: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey('Software\Embarcadero\Locales', True) then
      Reg.WriteString(FileName, LocaleOverride);
  finally
    Reg.Free;
  end;
end;

function GetLocale(const FileNames:string):string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey('Software\Embarcadero\Locales', True) then
      Result := Reg.ReadString(FileNames);
      reg.ReadString(FileNames)
  finally
    Reg.Free;
  end;
end;

procedure TEditorForm.FormCreate(Sender: TObject);
var path : string;
  currLocal: string;
begin
  // Initialise:
  SelectRect.Top := -1;
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
  actFigNone.ShortCut := scCtrl or vk5; // CTRL + '5'
  actFigDef.ShortCut := scCtrl or vk1; // CTRL + '1'
  actFigMetaVar.ShortCut := scCtrl or vk2; // CTRL + '2'
  actFigMetaConst.ShortCut := scCtrl or vk3; // CTRL + '3'
  actFigLine.ShortCut := scCtrl or vk4; // CTRL + '4'
  CurrFigure := nil;
  clearScreen;
  createSelectList(CoppyFigures);
  createSelectList(selectFigures);
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

procedure TEditorForm.FormDestroy(Sender: TObject);
begin
  removeAllList(FigHead);
  Dispose(FigHead);
  UndoStackClear(USVertex);
  Dispose(USVertex);
end;

procedure TEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  UndoRec: TUndoStackInfo;
  temp: PSelectFigure;
begin
  if (key = VK_DELETE) and (selectFigures^.Adr <> nil) then
  begin
    temp := selectFigures^.adr;
    while temp <> nil do
    begin
      // CHANGES STACK PUSHING START
      UndoRec.adr := temp^.figure;
      UndoRec.PrevFigure := temp^.figure;
      removeFigure(FigHead, temp^.Figure);
      UndoRec.ChangeType :=chDelete;
      UndoStackPush(USVertex, UndoRec);
      // CHANGES STACK PUSHING END
      switchChangedStatus(true);
      temp := temp^.Adr;
    end;
    actUndo.Enabled := true;
    removeselectlist(selectFigures);
    Self.clearScreen;
    drawFigure(pbMain.canvas,FigHead, FScale);
  end;
  if (key = VK_RETURN) and (selectFigures^.Adr <> nil) then
  begin
    temp := selectFigures^.adr;
    while temp <> nil do
    begin
      if temp^.Figure.Info.tp = line then
      begin
        temp := temp^.Adr;
        continue;
      end;
      // CHANGES STACK PUSHING START
      UndoRec.adr := temp^.Figure;
      UndoRec.text := temp^.Figure.Info.Txt;
      UndoRec.ChangeType := chChangeText;
      UndoStackPush(USVertex, UndoRec);
      // CHANGES STACK PUSHING END

      // Change Caption of current figure
      temp^.figure.Info.Txt := ShortString(edtRectText.Text);
      temp := temp^.Adr;
    end;
    actUndo.Enabled := true;
    pbMain.Repaint;
  end;

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
  // pbMain.Repaint;
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
    removeSelectList(selectFigures);
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
procedure TEditorForm.changeCanvasSize(w,h: Integer; flag: Boolean = true);
var
  UndoRec: TUndoStackInfo;
begin
  if flag then
  begin
    // CHANGES STACK PUSHING START
    UndoRec.ChangeType := chCanvasSize;
    UndoRec.w := PBW;
    UndoRec.h := PBH;
    UndoStackPush(USVertex, UndoRec);
    actUndo.Enabled := true;
    // CHANGES STACK PUSHING EDD
  end;
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
  answer := MessageDlg(rsNewFileDlg,mtWarning,[mbYes,mbNo], 0);
  if  answer = mrYes then
  begin
    newFile;
  end;
end;

procedure TEditorForm.mniRusLangClick(Sender: TObject);
begin
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
    removeSelectList(selectFigures);
    try
      png := TPngImage.Create;
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
    ExportTOSvg(FigHead, pbMain.Width, pbMain.Height, path, UTF8String('Syntax Diagram Project'), UTF8String('Create by BrakhMen.info'));
end;

procedure TEditorForm.sbMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if dm = ResizeCanvas then
  begin
    changeCanvasSize(Round(X/FScale),Round(Y/FScale));
    DM := oldDM;
    actResizeCanvas.Enabled := true;
    tbResizeCanvas.Down := false;
    pbMain.Repaint;
  end;
end;

procedure TEditorForm.sbMainMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if dm = ResizeCanvas then
  begin
    updateCanvasSizeWithCoords(x, y);
  end;
end;

procedure TEditorForm.sbMainMouseWheelDown(Sender: TObject;
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

procedure TEditorForm.sbMainMouseWheelUp(Sender: TObject;
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
  FCanvasSettings.showForm(neww, newh); // Open form
  changeCanvasSize(neww, newh);
  Self.Repaint;
end;

procedure TEditorForm.actChangeMagnetizeExecute(Sender: TObject);
begin
  ;
end;

procedure TEditorForm.actCopyExecute(Sender: TObject);
var
  tmp: PSelectFigure;
begin
  tmp := selectFigures^.Adr;
  removeSelectList(CoppyFigures);
  while tmp <> nil do
  begin
    insertSelectsList(CoppyFigures, tmp^.Figure);
    tmp := tmp^.Adr;
  end;
  actPast.Enabled := true;
end;

procedure TEditorForm.actEngLangExecute(Sender: TObject);
begin
  SetLocaleOverride(ParamStr(0), 'ENU');
  MessageDlg(SEnChangeLangMsg, mtInformation, [mbok], 0);
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
  if CurrType = Line then
    endDrawLine;
  CurrType := def;
  tbFigDef.Down := true;
end;

procedure TEditorForm.actFigLineExecute(Sender: TObject);
begin
  CurrType := Line;
  CurrLineType := LLine;
  tbFigLine.Down := true;
end;

procedure TEditorForm.actFigMetaConstExecute(Sender: TObject);
begin
  if CurrType = Line then
    endDrawLine;
  CurrType := MetaConst;
  tbFigConst.Down := true;
end;

procedure TEditorForm.actFigMetaVarExecute(Sender: TObject);
begin
  if CurrType = Line then
    endDrawLine;
  CurrType := MetaVar;
  tbFigMV.Down := true;
end;

procedure TEditorForm.actFigNoneExecute(Sender: TObject);
begin
  if CurrType = Line then
    endDrawLine;
  CurrType := None;
  tbFigNone.Down := true;
end;

procedure TEditorForm.actFrencLangExecute(Sender: TObject);
begin
  SetLocaleOverride(ParamStr(0), 'FRA');
  MessageDlg(SFrChangeLangMsg, mtInformation, [mbok], 0);
end;

procedure TEditorForm.actHelpExecute(Sender: TObject);
begin
  FHTml.showHTML(rsHelp_Caption,rsHelp_ResName);
end;

procedure TEditorForm.Action1Execute(Sender: TObject);
begin
end;

// Create new Diagram
procedure TEditorForm.actNewExecute(Sender: TObject);
var
  answer: Integer;
begin
  answer := MessageDlg(rsNewFileDlg,mtWarning,[mbYes,mbNo], 0);
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
    answer := MessageDlg(rsExitDlg,mtWarning,
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
    pbMain.Repaint;
  end;
end;

procedure TEditorForm.actPastExecute(Sender: TObject);
var
undorec:TUndoStackInfo;
insfig: PFigList;
tmp: PSelectFigure;
begin

  actPast.Enabled := false;
  if CoppyFigures^.Adr = nil then exit;
  removeSelectList(selectFigures);
  tmp := CoppyFigures.Adr;
  while tmp <> nil do
  begin
    insfig := CopyFigure(FigHead, tmp^.Figure); // Create copy of CoppyFigure
    // CHANGES STASCK PUSHING START
    UndoRec.ChangeType := chInsert;
    UndoRec.adr := insfig;
    DM := DrawLine;
    UndoStackPush(USVertex, UndoRec);
    actUndo.Enabled := true;
    // CHANGES STASCK PUSHING END
    insertSelectsList(selectFigures, insfig);
    tmp := tmp^.Adr;
  end;
  pbMain.Repaint
end;

procedure TEditorForm.actPNGExecute(Sender: TObject);
begin
  savePNGFile;
end;

procedure TEditorForm.actResizeCanvasExecute(Sender: TObject);
begin
  tbResizeCanvas.Down := true;
  if DM <> ResizeCanvas then
  begin
    oldDM := DM;
    DM := ResizeCanvas;
  end;
end;

procedure TEditorForm.actRusLangExecute(Sender: TObject);
begin
  SetLocaleOverride(ParamStr(0), 'RUS');
  MessageDlg(SRuChangeLangMsg, mtInformation, [mbok], 0);
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
    if mniMagnetizeLine.Checked then
      MagnetizeLines(FigHead);
  end;

  if isStackEmpty(USVertex) then (Sender as TAction).Enabled := false;
  ClickFigure := nil;
  removeSelectList(selectFigures);
  pbMain.Repaint;
end;


end.
