unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, math,
  Vcl.Menus, SD_Types, SD_View, SD_InitData, SD_Model, SVGUtils, Vcl.Buttons,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.ToolWin;
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
    procedure btnALineClick(Sender: TObject);
    function  saveBrakhFile:boolean;
    procedure saveSVGFile;
    procedure pbMainPaint(Sender: TObject);
    procedure saveBMPFile;
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
    procedure mnFileDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      Selected: Boolean);
    procedure actCopyExecute(Sender: TObject);
    procedure actPastExecute(Sender: TObject);
    procedure actCanvasSizeExecute(Sender: TObject);
    procedure actAboutSBExecute(Sender: TObject);
    procedure actFigNoneExecute(Sender: TObject);
    procedure actFigLineExecute(Sender: TObject);
    procedure actFigDefExecute(Sender: TObject);
    procedure actFigMetaVarExecute(Sender: TObject);
    procedure actFigMetaConstExecute(Sender: TObject);

    
  private
    isChanged: Boolean;
    currpath: string;
    procedure switchChangedStatus(flag: Boolean);
    procedure changePath(path: string);
    procedure newFile;

  public
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

uses FCanvasSizeSettings, FHtmlView;

procedure TEditorForm.changeEditorText(newtext: string);
begin
  edtRectText.text := newtext;
end;


procedure TEditorForm.actAboutSBExecute(Sender: TObject);
begin
  FHTml.showHTML(rsHelpHowIsSD_Caption,rsHelpHowIsSD_ResName);
end;

procedure TEditorForm.actCanvasSizeExecute(Sender: TObject);
var
  neww, newh : integer;
begin
  neww:= pbMain.Width;
  newh := pbMain.Height;
  CanvasSettingsForm.showForm(neww, newh);
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

procedure TEditorForm.actNewExecute(Sender: TObject);
var
  answer: Integer;
begin
  answer := MessageDlg(rsNewFileDlg,mtCustom,[mbYes,mbNo], 0);
  if  answer = mrYes then
  begin
    newFile;
  end;
end;

procedure TEditorForm.actOpenExecute(Sender: TObject);
var
  path: string;
  answer: integer;
begin
  if isChanged then
  begin
    answer := MessageDlg(rsExitDlg,mtCustom,
                              [mbYes,mbNo,mbCancel], 0);
    case answer of
      mrYes:
      begin
        if not saveBrakhFile then
          exit
      end;
      mrNo: ;
      mrCancel: exit;
    end;
  end;

  path := openFile(FBrakh);
  if path <> '' then
  begin

    removeAllList(FigHead);
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
  
  CopyFigure(FigHead, CoppyFigure);
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

procedure TEditorForm.btnALineClick(Sender: TObject);
begin
  CurrType := Line;
end;

procedure TEditorForm.switchChangedStatus(flag: Boolean);
begin
  isChanged := flag;
end;

procedure TEditorForm.pbMainMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TEditorForm.getCanvasSIze(var w, h: Integer);
begin
  w := Self.pbMain.Width;
  h := self.pbMain.Height;
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
  with pbMain do
  begin
    prevSize := Canvas.Font.Size;

    //canvas.Font.Size := size;
    TW := canvas.TextWidth(text);
    TH := Canvas.TextHeight(text);

    canvas.Font.Size := prevSize;
  end;

end;

procedure TEditorForm.pbMainMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
{var          // LOGS
  f:TextFile;}
begin
  if clickfigure = nil then
    prevText:= edtRectText.Text;
  if (CurrType <> Line) and (DM = DrawLine) then
    DM := nodraw;
  if dm = NoDraw then
  begin
    EM := getEditMode(DM, x,y,FigHead, CurrType);
    changeCursor(ScrollBox1, EM); // Меняем курсор в зависимости от положения мыши

    if ClickFigure <> nil then
    begin
      selectFigure(pbMain.Canvas, ClickFigure);
    end;
  end;
  if (DM = draw) and (currfigure <> nil)  then
  begin
    switchChangedStatus(TRUE);
    ChangeCoords(CurrFigure, EM, x,y, tempX, tempY);
    TempX:= X; // Обновляем прошлые координаты
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
  MagnetizeLines(FigHead);
  {if CurrType = Line then
    clearScreen;}
  pbMain.Repaint;
end;

procedure TEditorForm.pbMainPaint(Sender: TObject);
begin
  with (Sender as TPaintBox) do
  begin
    clearScreen;
    drawFigure(Canvas, FigHead);
  end;
end;

procedure TEditorForm.clearScreen;
begin
  pbMain.Canvas.Pen.Width := 1;
  pbMain.Canvas.Rectangle(0,0,pbMain.Width,pbMain.Height);
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

procedure TEditorForm.FormCreate(Sender: TObject);
begin
  tbFigNone.Down := true;
  actPast.Enabled := false;
  currpath := '';
  Self.DoubleBuffered := true;
  switchChangedStatus(false);
  createFigList(FigHead);
  CurrType := Def;
  EM := NoEdit;
  CurrFigure := nil;
  clearScreen;
  CoppyFigure := nil;
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
    drawFigure(pbMain.canvas,FigHead);
  end;
  if (key = VK_RETURN) and (ClickFigure <> nil) and (ClickFigure.Info.tp <> Line) then
  begin
    ClickFigure.Info.Txt := ShortString(edtRectText.Text);
    pbMain.Repaint;
  end;

  
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
  pbMain.Repaint;
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
    with TBitMap.Create do begin
      width := pbMain.Width;
      height := pbMain.Height;
      drawFigure(Canvas, FigHead,false);
      SaveToFile(path);
    end;
  end;
end;

procedure TEditorForm.mnFileDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
var
  w,h: integer;
begin
  with ACanvas do
  begin
   if Selected then
    begin
      Font.Size   := 10;
    end
    else
    begin
      Font.Size   := 10;
    end;
   Arect.Left := Arect.Left - 20*( Sender as TMenuItem ).tag;
   Arect.Right := Arect.Right - 40*( Sender as TMenuItem ).tag;
   w := ACanvas.TextWidth((Sender as TMenuItem ).Caption );
   ARect.width := w+10;
   FillRect( ARect );
   TextOut( ARect.Left + 10, Arect.Top, ( Sender as TMenuItem ).Caption );

  end;

end;

procedure TEditorForm.changeCanvasSize(w,h: Integer);
begin
  pbMain.width := w;
  pbMain.height := h;
end;

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
    ExportTOSvg(FigHead, pbMain.Width, pbMain.Height, path, 'Syntax Diagram Project', 'Create by BrakhMen.info');
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
