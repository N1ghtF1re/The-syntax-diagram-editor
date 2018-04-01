unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, math;

type
  TDrawMode = (Draw, NoDraw, DrawLine);
  TEditMode = (NoEdit, Move, TSide, BSide, RSide, LSide, Vert1, Vert2, Vert3, Vert4);
  TType = (Def,MetaVar,MetaConst, Line, None);
  //TFigureType = (rect, line);

  // СПИСОК ТОЧЕК НАЧАЛО
  TPointsInfo = record
    id,x,y: integer;
  end;
  PPointsList = ^TPointsList;
  TPointsList = record
    Info: TPointsInfo;
    Adr:PPointsList;
  end;
  // СПИСОК ТОЧЕК КОНЕЦ

  // СПИСОК  ОБЪЕКТОВ НАЧАЛО
  TFigureInfo = record
    case tp:TType of
    Def, MetaConst, MetaVar: (Txt: string[255];x1,x2,y1,y2: integer);
    Line: (PointHead: PPointsList);
  end;
  PFigList = ^FigList;
  FigList = record
    Info: TFigureInfo;
    Adr: PFigList;
  end;
  // СПИСОК ОБЪЕКТОВ КОНЕЦ





  TEditorForm = class(TForm)
    canv: TImage;
    Label1: TLabel;
    Timer1: TTimer;
    Label2: TLabel;
    edtRectText: TEdit;
    btnDef: TButton;
    btnMV: TButton;
    btnMC: TButton;
    btnLine: TButton;
    pnlOptions: TPanel;
    btnNone: TButton;
    procedure FormCreate(Sender: TObject);
    procedure clearScreen;
    procedure canvMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure canvMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure canvMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure btnDefClick(Sender: TObject);
    procedure btnMVClick(Sender: TObject);
    procedure btnMCClick(Sender: TObject);
    procedure btnLineClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnNoneClick(Sender: TObject);
    procedure FormResize(Sender: TObject);  private
  public
    { Public declarations }
  end;

var
  EditorForm: TEditorForm;
  FigHead: PFigList;
  CurrType: TType;
  CurrFigure, ClickFigure: PFigList;
  tempX, tempY: integer;
  DM: TDrawMode;
  EM: TEditMode;
  currPointAdr: PPointsList;
  //FT: TFigureType;
const
  Tolerance = 5; // Кол-во пискелей, на которые юзеру можно "промахнуться"
  VertRad = 3; // Радиус вершин


implementation

{$R *.dfm}

procedure addNewPoint(var head: PPointsList; x,y:integer);
var
  tmp :PPointsList;
  id :integer;
  px, py: integer;
begin
  tmp := head;
  while tmp^.adr <> nil do
    tmp := tmp^.Adr;
  id := tmp^.Info.id + 1;
  if tmp <> head then
  begin
    px := tmp^.Info.x;
    py := tmp^.Info.y;
    // Запрещаем проводить прямую под углом.
    try
      if arctan(abs((y-py)/(x-px))) < pi/4 then
        y:=py
      else
        x:=px;
    except on E: Exception do

    end;
  end;
  new(tmp^.adr);
  tmp := tmp^.adr;
  tmp^.Info.x := x;
  tmp^.Info.y := y;
  tmp^.Info.id := id;
  tmp^.Adr := nil;
end;

function getClickFigure(x,y:integer; head: PFigList):PFigList;
var
  tmp:PFigList;
  tmpP: PPointsList;
  
begin
  tmp := head^.adr;
  while tmp <> nil do
  begin
    if tmp^.Info.tp <> Line then
    begin
      if (x > tmp^.Info.x1)
          and
          (x < tmp^.Info.x2)
          and
          (y > tmp^.Info.y1)
          and
          (y < tmp^.Info.y2)
          then
      begin
        result := tmp;
        exit;
      end;
    end
    else
    begin
      tmpP := tmp^.Info.PointHead^.Adr;
      while tmpP <> nil do
      begin
        if (abs(y-tmpP^.Info.x) < Tolerance) and (abs(x-tmpP^.Info.y) < Tolerance) then
        begin
          result := tmp;
          exit;
        end;

        if tmpP^.Adr <> nil then
        begin
          
          if ((abs(y - tmpP^.Info.y) < Tolerance*2 ) and (x > min(tmpP^.Info.x, tmpP^.adr^.Info.x)) and (x < max(tmpP^.Info.x, tmpP^.adr^.Info.x)) )
              or 
             ((abs(x - tmpP^.Info.x) < Tolerance*2) and (y > min(tmpP^.Info.y, tmpP^.adr^.Info.y)) and (y < max(tmpP^.Info.y, tmpP^.adr^.Info.y))) then
          begin
            Result:= tmp;
            exit;
          end;

        end;
        tmpP := tmpP^.Adr;

      end;

    end;
    tmp := tmp^.Adr;
  end;
  Result := nil;
end;

// Добавляем линию
function addLine(head: PFigList; x,y: integer):PFigList;
var
  tmp: PFigList;
  id: integer;
begin
  tmp := head;
  while tmp^.adr <> nil do
    tmp := tmp^.Adr;
  new(tmp^.adr);
  tmp := tmp^.Adr;
  tmp^.Adr := nil;
  tmp^.Info.tp := line;
  new(tmp^.Info.PointHead);
  tmp^.Info.PointHead^.Adr := nil;
  tmp^.Info.PointHead^.Info.id := 0;
  addNewPoint(tmp^.Info.PointHead, x,y);

  result := tmp;
end;


// Добавляем новый прямоугольный объект и возвращаем ссылку на него!
function addFigure(head: PFigList; x,y: integer; ftype: TType; Text:String = 'Kek'):PFigList;
var
  tmp: PFigList;
begin
  tmp := head;
  while tmp^.adr <> nil do
    tmp := tmp^.Adr;
  new(tmp^.adr);
  tmp := tmp^.Adr;
  tmp^.Adr := nil;
  with tmp^.Info do
  begin
    x1 := x;
    x2 := x;
    y1 := y;
    y2 := y;
    Txt := text;
    Tp := ftype;
  end;

  Result := tmp;
end;


// Создаем массив прямоугольных фигур
procedure createFigList(var head: PFigList);
begin
  new(head);
  head.Adr := nil;
end;

procedure TEditorForm.btnDefClick(Sender: TObject);
begin
  CurrType := def;
end;

procedure TEditorForm.btnLineClick(Sender: TObject);
begin
  CurrType := Line;
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
begin
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

  if (EM = NoEdit) and (CurrType <> None) then
  begin
    if CurrType <> Line then
      CurrFigure := addFigure(FigHead, x,y, CurrType, edtRectText.Text)
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
  ClickFigure := getClickFigure(x,y, FigHead);
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

function getEditMode(status: TDrawMode; x,y: Integer; head: PFigList) :TEditMode;
var
  r:TFigureInfo;
  temp: PFigList;
  tmpPoint: PPointsList;
begin
  temp := head;
  while temp <> nil do
  begin
    R := temp^.Info;
    if (status = nodraw) and (R.tp <> Line) then
    begin
      if ( (x > R.x1) and (x < R.x2) and (y > R.y1) and (y < R.y2)) then
      begin
        // Внутри объекта
        Result := Move;
      end
      else
      begin
        // За пределами объекта
        Result := NoEdit;
      end;
      if ( (x > R.x1) and (x < R.x2) and ((abs(y - R.y1) < Tolerance) or (abs(y - R.y2) < Tolerance))) then
      begin
        // Горизонтальная сторона
        if (abs(y - R.y1) < Tolerance) then
          Result := TSide
        else
          Result:= BSide;
      end;
      if ( (y > R.y1) and (y < R.y2) and ((abs(x - R.x1) < Tolerance) or (abs(x - R.x2) < Tolerance))) then
      begin
        // Вертикальная сторона
        if (abs(x - R.x1) < Tolerance) then
          Result := Lside
        else
          Result:= RSide;
      end;
      if ((abs(y-R.y1) < Tolerance) and (abs(x-R.x1) < Tolerance)) then
      begin
        // Левая верхняя вершина
        Result := Vert1;
      end;
      if (abs(y-R.y1) < Tolerance) and (abs(x-R.x2) < Tolerance) then
      begin
        // Правая верхняя вершина
        Result := Vert2;
      end;
      if (abs(y-R.y2) < Tolerance) and (abs(x-R.x1) < Tolerance) then
      begin
        // Левая нижняя вершина
        Result := Vert3;
      end;
      if (abs(y-R.y2) < Tolerance) and (abs(x-R.x2) < Tolerance) then
      begin
        // Правая нижняя вершина
        Result := Vert4;
        // ?? ?? ??? ?? ??? ?? ?? \\
      end;
      if result <> NoEdit then
      begin
        CurrFigure := temp;
        exit;
      end;
    end
    else if (status = nodraw) then
    begin
      tmpPoint := R.PointHead;
      while tmpPoint <> nil do
      begin
        if (abs(y-tmpPoint^.Info.y) < Tolerance) and (abs(x-tmpPoint^.Info.x) < Tolerance) then
        begin
          CurrFigure := temp;
          currPointAdr := tmpPoint;
          Result := Move;
          exit;
        end;
        tmpPoint := tmpPoint^.Adr;
      end;
    end;
    temp := temp^.Adr;
  end;
end;

procedure checkFigureCoord(R: PFigList);
var
  temp:integer;
begin
  if R<>nil then
  with R^.Info do
  begin
    if x1 > x2 then
    begin
      temp := x1;
      x1 := x2;
      x2:=temp;
    end;
    if y1 > y2 then
    begin
      temp := y1;
      y1 := y2;
      y2:=temp;
    end;
  end;
end;

procedure ChangeCoords(F: PFigList; EM: TEditMode; x,y:integer; var TmpX, TmpY: integer);
var
  tmp: PPointsList;
begin
  if F <> nil then
  case EM of
    NoEdit:
    begin
      F^.Info.x2 := x;
      F^.Info.y2 := y;
    end;
    Move: // Перемещаем объект :)
    begin
      if F^.Info.tp = Line then
      begin

        currPointAdr^.Info.x := currPointAdr^.Info.x - (TmpX - x);
        currPointAdr^.Info.y := currPointAdr^.Info.y - (Tmpy - y);
      end
      else
      begin
      // Смещаем объект
      // TmpX, TmpY - смещение координат относительно прошлого вызова события
      F^.Info.x1 := F^.Info.x1 - (TmpX - x);
      F^.Info.x2 := F^.Info.x2 - (TmpX - x);
      F^.Info.y1 := F^.Info.y1 - (Tmpy - y);
      F^.Info.y2 := F^.Info.y2 - (TmpY - y);
      end;
    end;
    TSide:
    begin
      // смещаем верхнюю сторону
      F^.Info.y1 := F^.Info.y1 - (Tmpy - y);
    end;
    BSide:
    begin
      // Смещаем нижнюю сторону
       F^.Info.y2 := F^.Info.y2 - (Tmpy - y);
    end;
    RSide:
    begin
      // Смещаем правую сторону
      F^.Info.x2 := F^.Info.x2 - (Tmpx - x);
    end;
    LSide:
    begin
      // Смещаем левую сторону
      F^.Info.x1 := F^.Info.x1 - (Tmpx - x);
    end;
    Vert1:
    begin
      F^.Info.x1 := F^.Info.x1 - (TmpX - x);
      F^.Info.y1 := F^.Info.y1 - (Tmpy - y);
    end;
    Vert2:
    begin
      F^.Info.x2 := F^.Info.x2 - (TmpX - x);
      F^.Info.y1 := F^.Info.y1 - (Tmpy - y);
    end;
    Vert3:
    begin
      F^.Info.x1 := F^.Info.x1 - (TmpX - x);
      F^.Info.y2 := F^.Info.y2 - (Tmpy - y);
    end;
    Vert4:
    begin
      F^.Info.x2 := F^.Info.x2 - (TmpX - x);
      F^.Info.y2 := F^.Info.y2 - (Tmpy - y);
    end;
  end;
end;

procedure drawArrow(Canvas:TCanvas; x,y : integer);
begin
  canvas.MoveTo(x,y);
  canvas.LineTo(x-25,y-15);
  canvas.MoveTo(x,y);
  canvas.LineTo(x-25,y+15);
  canvas.MoveTo(x,y);
end;

procedure drawLines(Canvas:TCanvas; head: PPointsList);
var
  tmp: PPointsList;
  midx, midy: integer;
  FirstP: TPointsInfo;    
  delta: byte;
  isDegEnd: boolean;
begin
  
  canvas.Pen.Width := 2;
  tmp := head;
  if tmp^.Adr <> nil then
  begin
    FirstP.X := tmp^.Adr^.Info.x;
    FirstP.y := tmp^.Adr^.Info.y;
    tmp := tmp^.Adr;
    canvas.MoveTo(tmp^.Info.x, tmp^.Info.y);

    if (tmp^.Adr <> nil) and (FirstP.x = tmp^.adr^.Info.x) and (FirstP.y <> tmp^.adr^.Info.y)  then
    begin
      //showMessage('kek');
      canvas.moveTo(tmp^.Info.x-15, tmp^.Info.y);
      canvas.LineTo(tmp^.Info.x, tmp^.Info.y+15);
      canvas.moveTo(tmp^.Info.x, tmp^.Info.y+15);
      canvas.Pen.Width := 1;
      canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y+15-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+15+VertRad);
      canvas.Pen.Width := 2;
    end
    else 
      canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+VertRad);
    tmp := tmp^.adr;
    isDegEnd := false;
    while tmp <> nil do
    begin
      
      if isDegEnd then
      begin
        canvas.lineto(tmp^.Info.x, tmp^.Info.y+15); 
        canvas.moveto(tmp^.Info.x, tmp^.Info.y+15); 
        canvas.lineto(tmp^.Info.x+15, tmp^.Info.y); 
        
        canvas.Pen.Width := 1;
        canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y+15-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+15+VertRad);
        canvas.Pen.Width := 2;
        tmp := tmp^.Adr;
        continue;
      end
      else
      canvas.lineto(tmp^.Info.x, tmp^.Info.y);
      canvas.moveto(tmp^.Info.x, tmp^.Info.y);
      canvas.Pen.Width := 1;
      canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+VertRad);
      canvas.Pen.Width := 2;

      if tmp^.Adr = nil then
      begin
        drawArrow(canvas,tmp^.Info.x, tmp^.Info.y);
      end;
      if (tmp^.Adr <> nil) and (tmp^.adr^.Adr = nil) and (tmp^.Info.x <> FirstP.x) 
        and (tmp^.Info.x = tmp^.adr^.Info.x) and (tmp^.Info.y <> tmp^.adr^.Info.y) then
      begin
        isDegEnd := true;
      end
      else
      begin
        isDegEnd:= false;
      end;
      tmp:= tmp^.Adr;
    end;

  end;
  canvas.Pen.Width := 1;

end;

procedure drawFigure(Canvas:TCanvas; head:PFigList);
var
  temp:PFigList;
  TextW: Integer;
  TextH: Integer;
  TX, TY: integer;
  text:string;
begin
  temp := head;
  while temp <> nil do
  begin
    with temp^.Info do
    begin
      text := txt;
      case Tp of
        Def: Text := Text + ' ::= ';
        MetaVar: Text := '< ' + Text + ' >';
        MetaConst: ;
        line:
        begin
          drawLines(Canvas, temp^.Info.PointHead);
          temp := temp^.adr;
          continue;
        end;
      end;

      TextW := canvas.TextWidth(text);
      textH := Canvas.TextHeight(text);

      // Расчитываем координаты, чтобы текст был по середине
      TX := x1 + (x2 - x1) div 2 - TextW div 2;
      TY := y1 + (y2 - y1) div 2 - TextH div 2;

      // Если ширина или высота блока меньше, чем текста, то подгоняем под размер текста
      if (abs(x2 - x1) < TextW) then
      begin
        x1 := x1 - textw div 2 - 10;
        x2 := x2 + textw div 2 + 10;
      end;
      if (abs(y2 - y1) < TextH) then
      begin
        y1 := y1 - textH div 2 - 10;
        y2 := y2 + textH div 2 + 10;
      end;
      canvas.Pen.Color := clWhite;
      Canvas.Rectangle(x1, y1, x2, y2);
      canvas.Pen.Color := clBlack;

      // Рисуем вершины
      canvas.Rectangle(x1-VertRad,y1-VertRad, x1+VertRad, y1+VertRad);
      canvas.Rectangle(x2-VertRad,y1-VertRad, x2+VertRad, y1+VertRad);
      canvas.Rectangle(x1-VertRad,y2-VertRad, x1+VertRad, y2+VertRad);
      canvas.Rectangle(x2-VertRad,y2-VertRad, x2+VertRad, y2+VertRad);

      Canvas.TextOut(TX,TY, text);
    end;

    temp := temp^.Adr;
  end;
end;

procedure selectFigure(canvas: TCanvas; head:PFigList);
var x1,x2,y1,y2: integer;
tmp : PPointsList;
begin
  //ShowMessage('kek');
  canvas.Pen.Color := clGreen;
  canvas.Brush.Color := clGreen;
  if head^.Info.tp <> line then
  begin
    x1 := head^.Info.x1;
    x2 := head^.Info.x2;
    y1 := head^.Info.y1;
    y2 := head^.Info.y2;
    // Рисуем вершины
    canvas.Rectangle(x1-VertRad,y1-VertRad, x1+VertRad, y1+VertRad);
    canvas.Rectangle(x2-VertRad,y1-VertRad, x2+VertRad, y1+VertRad);
    canvas.Rectangle(x1-VertRad,y2-VertRad, x1+VertRad, y2+VertRad);
    canvas.Rectangle(x2-VertRad,y2-VertRad, x2+VertRad, y2+VertRad);
  end
  else
  begin
    //showmessage('kek');
    tmp := head^.Info.PointHead^.adr;
    while tmp <> nil do
    begin
      x1 := tmp^.Info.x;
      y1 := tmp^.Info.y;
      canvas.Rectangle(x1-VertRad,y1-VertRad, x1+VertRad, y1+VertRad);
      tmp := tmp^.Adr;
    end;
  end;
  canvas.Pen.Color := clBlack;
  //showMessage('kek');
  canvas.Brush.Color := clWhite;
end;


procedure TEditorForm.canvMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  if (CurrType <> Line) and (DM = DrawLine) then
    DM := nodraw;
  if dm = NoDraw then
  begin
    EM := getEditMode(DM, x,y,FigHead);
    changeCursor(Self, EM); // Меняем курсор в зависимости от положения мыши

    if ClickFigure <> nil then
      selectFigure(canv.Canvas, ClickFigure);
  end;
  if (DM = draw) and (currfigure <> nil)  then
  begin
    ChangeCoords(CurrFigure, EM, x,y, tempX, tempY);
    TempX:= X; // Обновляем прошлые координаты
    TempY:= Y;
    clearScreen; // Чистим экран
    drawFigure(canv.Canvas, FigHead);
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
  if CurrType = Line then
    clearScreen;
  drawFigure(canv.Canvas, FigHead);
end;

procedure TEditorForm.clearScreen;
begin
  canv.Canvas.Rectangle(0,0,canv.Width,canv.Height);
end;

procedure TEditorForm.FormCreate(Sender: TObject);
begin
  createFigList(FigHead);
  CurrType := Def;
  EM := NoEdit;
  CurrFigure := nil;
  clearScreen;
end;

procedure removeFigure(head: PFigList; adr: PFigList);
var
  temp,temp2:PFigList;
begin
  temp := head;
  while temp^.adr <> nil do
  begin
    temp2 := temp^.adr;
    if temp2 = adr then
    begin
      temp^.adr := temp2^.adr;
      dispose(temp2);
    end
    else
      temp:= temp^.adr;
  end;
end;

procedure TEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 46) and (ClickFigure <> nil) then
  begin
    removeFigure(FigHead, ClickFigure);
    clearScreen; // Чистим экран
    drawFigure(canv.Canvas, FigHead);
    ClickFigure := nil;
  end;
end;

procedure TEditorForm.FormResize(Sender: TObject);
begin
  canv.Picture.Bitmap.Height := canv.Height;
  canv.Picture.Bitmap.Width := canv.Width;
  clearScreen;
  drawFigure(canv.Canvas, FigHead);
end;

procedure TEditorForm.Timer1Timer(Sender: TObject);
begin
  case em of
    NoEdit: Label1.Caption := 'NoEdit';
    Move: Label1.Caption := 'Move' ;
    TSide: Label1.Caption := 'TSide' ;
    BSide: Label1.Caption := 'BSide' ;
    RSide: Label1.Caption := 'RSide' ;
    LSide: Label1.Caption := 'LSIde' ;
    Vert1: Label1.Caption := 'Vert1' ;
    Vert2: Label1.Caption := 'Vert2' ;
    Vert3: Label1.Caption := 'Vert3' ;
    Vert4: Label1.Caption := 'Vert4' ;
  end;
  case dm of
    Draw: Label2.Caption := 'Draw';
    NoDraw: Label2.Caption := 'Nodraw';
    DrawLine: Label2.Caption := 'DrawLine';
  end;
end;

end.
