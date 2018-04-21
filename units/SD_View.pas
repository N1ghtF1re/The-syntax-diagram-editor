unit SD_View;
// VIEW par in MVC:
// responsible for displaying information

interface
uses SD_Types, vcl.graphics, SD_InitData, vcl.dialogs;

// ### VIEW PART PROCEDURES ###

// A search of the list of figures and their drawing
procedure drawFigure(Canvas:TCanvas; head:PFigList);
procedure drawSelectFigure(canvas:tcanvas; figure: TFigureInfo);
procedure drawSelectLineVertex(canvas: TCanvas; Point: TPointsInfo);
procedure updateScreen(canvas:tcanvas; FigHead: PFigList);
function beginOfVertLine(tmp:PPointsList;firstP: TPointsInfo):boolean;
function needMiddleArrow(tmp: PPointsList; FirstP: TPointsInfo) :Boolean;

// ### VIEW PART CONSTANTS ###

const
  VertRad = 3; // Verts Radius

  Arrow_Width = 20; // length of dowel arrows
  Arrow_Height = 10;

  Lines_Width = 2;
  Lines_Deg = 15;
  Lines_DegLenght = 15;

implementation
uses main, SD_Model;

procedure updateScreen(canvas:tcanvas; FigHead: PFigList);
begin
  EditorForm.clearScreen; // Чистим экран
  drawFigure(Canvas, FigHead);
end;

procedure drawArrowVertical(Canvas:TCanvas; x,y : integer; coef: ShortInt);
begin
  // Draw Vertical Arrow
  canvas.MoveTo(x,y);
  canvas.LineTo(x-Arrow_Height,y+Arrow_Width*coef);
  canvas.MoveTo(x,y);
  canvas.LineTo(x+Arrow_Height,y+Arrow_Width*coef);
  canvas.MoveTo(x,y);
end;

procedure drawArrow(Canvas:TCanvas; x,y : integer; coef: ShortInt);
begin
  canvas.MoveTo(x,y);
  canvas.LineTo(x-Arrow_Width*coef,y-Arrow_Height);
  canvas.MoveTo(x,y);
  canvas.LineTo(x-Arrow_Width*coef,y+Arrow_Height);
  canvas.MoveTo(x,y);
end;

procedure drawOutBoundLine(canvas: TCanvas; FirstP: TPointsInfo; tmp:PPointsList);
var
  coef: -1..1;
begin
  if FirstP.y - tmp^.adr^.Info.y < 0 then
    coef := 1
  else
    coef := -1;
  canvas.moveTo(tmp^.Info.x-15, tmp^.Info.y);
  canvas.LineTo(tmp^.Info.x, tmp^.Info.y+coef*15);
  canvas.moveTo(tmp^.Info.x, tmp^.Info.y+coef*15);
  // canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y+15*coef-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+15*coef+VertRad);
end;

function beginOfVertLine(tmp:PPointsList;firstP: TPointsInfo):boolean;
begin
  result := (tmp^.Adr <> nil) and
      (FirstP.x = tmp^.adr^.Info.x)  and // If vertical line
      (FirstP.y <> tmp^.adr^.Info.y);
end;

procedure drawVertexRect(canvas:TCanvas; point: TPointsInfo; color:TColor = clBlack);
begin
  canvas.Pen.Color := color;
  if color <> clBlack then
    Canvas.Brush.Color := color;

  canvas.Pen.Width := 1;
  canvas.Rectangle(point.x-VertRad,point.y-VertRad, point.x+VertRad, point.y+VertRad);
  canvas.Pen.Width := Lines_Width;
  canvas.Pen.Color := clBlack;
  canvas.Brush.Color := clwhite;

end;

procedure drawIncomingLine(canvas: tcanvas; point: TPointsInfo; coef: ShortInt);
begin
  canvas.lineto(point.x, point.y + (Lines_Deg*coef));
  canvas.moveto(point.x, point.y + (Lines_Deg*coef));
  canvas.lineto(point.x+Lines_DegLenght, point.y);
  drawVertexRect(canvas, point);
  drawArrowVertical(canvas, point.x, point.y+Lines_DegLenght*coef, coef);
end;

procedure drawArrowAtEnd(canvas:TCanvas; point, PrevPoint:TPointsInfo);
var
  tmpx, tmpy:integer;
begin
  tmpx := point.x - PrevPoint.x;
  if tmpx > 0 then
    drawArrow(canvas,point.x, point.y,1)
  else if tmpx < 0 then
    drawArrow(canvas,point.x, point.y,-1);

  tmpy := point.y - PrevPoint.y;
  if tmpy > 0 then
    drawArrowVertical(canvas,point.x, point.y,-1)
  else if tmpy < 0 then
  drawArrowVertical(canvas,point.x, point.y,1);
end;

function needMiddleArrow(tmp: PPointsList; FirstP: TPointsInfo) :Boolean;
begin
  Result := (tmp^.Adr <> nil) and (tmp^.adr^.Adr = nil) and (tmp^.Info.x <> FirstP.x)
        and (tmp^.Info.x = tmp^.adr^.Info.x) and (abs(tmp^.Info.y - tmp^.adr^.Info.y) > Tolerance*2)
end;

procedure drawLines(Canvas:TCanvas; head: PPointsList; LT: TLineType);
var
  tmp: PPointsList; // Temp variable
  FirstP,PrevP: TPointsInfo; // First and Prev Point in list
  tmpx: integer;
  isFirstLine:boolean;
  AddY: integer;
  isDegEnd: boolean;
  coef: -1..1;
begin                  //\\
  coef := 1;
  canvas.Pen.Width := Lines_Width; // Width For Line
  isFirstLine := false;
  tmp := head;
  if tmp^.Adr <> nil then
  begin
    FirstP.X := tmp^.Adr^.Info.x; // Initialise First Points
    FirstP.y := tmp^.Adr^.Info.y;

    prevp.x := FirstP.X; // Initialise Preview Point
    prevp.y := FirstP.Y;

    tmp := tmp^.Adr;

    canvas.MoveTo(tmp^.Info.x, tmp^.Info.y); // Move to first point in list

    // FIRST POINT:
    if beginOfVertLine(tmp,firstP) then
    begin
      drawOutBoundLine(canvas,FirstP, tmp);
      isFirstLine :=  true;
    end;
    if LT =LAdditLine then
    begin
      AddY := tmp^.Info.y;
    end;
    // POTOM
    if (LT = LAdditLine) and isHorisontalIntersection(EditorForm.getFigureHead,tmp) then
    begin
      if (tmp^.Adr <> nil) and (FirstP.x - tmp^.adr^.Info.x < 0) then
        coef := 1
      else
        coef := -1;
      canvas.MoveTo(tmp^.Info.x, tmp^.Info.y-Lines_DegLenght);
      canvas.LineTo(tmp^.Info.x+Lines_Deg*coef, tmp^.Info.y);
    end;
    // POTOM END;

    drawVertexRect(canvas, tmp^.Info);

    // OTHER POINTS:
    tmp := tmp^.adr;
    isDegEnd := false;
    while tmp <> nil do
    begin
      if LT =LAdditLine then
      begin
        tmp^.Info.y := AddY;
      end;
      if (tmp^.Adr = nil) and (LT = LAdditLine) and  isHorisontalIntersection(EditorForm.getFigureHead,tmp)  then
      begin
        canvas.LineTo(tmp^.Info.x-Lines_Deg*coef, tmp^.Info.y);
        canvas.MoveTo(tmp^.Info.x, tmp^.Info.y-Lines_DegLenght);
        canvas.LineTo(tmp^.Info.x-Lines_Deg*coef, tmp^.Info.y);
        canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+VertRad);
        tmp:=tmp^.Adr;
        continue;
      end;
      if isDegEnd and (LT <> LAdditLine)  then
      begin
        drawIncomingLine(canvas, tmp^.Info, coef);
        tmp := tmp^.Adr;
        continue;
      end
      else
        canvas.lineto(tmp^.Info.x, tmp^.Info.y);

      canvas.moveto(tmp^.Info.x, tmp^.Info.y);
      drawVertexRect(canvas, tmp^.Info);

      // Рисуем стрелочку в конце линии
      if (tmp^.Adr = nil) and  (LT <> LAdditLine) then
      begin
        drawArrowAtEnd(canvas, tmp^.Info, prevP);
        //drawArrow(canvas,tmp^.Info.x, tmp^.Info.y);
      end;



      if (LT <> LAdditLine) and needMiddleArrow(tmp, FirstP) then // if these is incoming and outgoing lines
      begin
        if isFirstLine then
        begin
          tmpx := tmp^.Info.x - PrevP.x;
          if tmpx > 0 then
            tmpx := 1
          else
            tmpx := -1;
          drawArrow(Canvas,tmp^.Info.x + 10 - (tmp^.Info.x - PrevP.x) div 2, tmp^.Info.y, tmpx);
          canvas.moveto(tmp^.Info.x , tmp^.Info.y)
        end;
        if tmp^.Info.y - tmp^.adr^.Info.y < 0 then
          coef := -1
        else
          coef := 1;
        isDegEnd := true;
      end
      else
      begin
        isDegEnd:= false;
      end;
      prevp.x := tmp^.Info.x;
      prevp.y := tmp^.Info.y;
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
  Point: TPointsInfo;
  text:string;
begin
  temp := head;
  while temp <> nil do
  begin
    with temp^.Info do
    begin
      text := String(txt);
      case Tp of
        Def: Text := Text + ' ::= ';
        MetaVar: Text := '< ' + Text + ' >';
        MetaConst: ;
        line:
        begin
          drawLines(Canvas, temp^.Info.PointHead, temp^.Info.LT);
          temp := temp^.adr;
          continue; // if figure - line => draw this line and skip ineration
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

      // Рисуем вершины
      Point.x := x1;
      Point.y := y1;
      drawVertexRect(canvas, Point);

      Point.y := y2;
      drawVertexRect(canvas, Point);

      Point.x := x2;
      drawVertexRect(canvas, Point);

      Point.y := y1;
      drawVertexRect(canvas, Point);

      Canvas.TextOut(TX,TY, text);
    end;

    temp := temp^.Adr;
  end;
end;

procedure drawSelectFigure(canvas:tcanvas; figure: TFigureInfo);
var x1,x2,y1,y2: integer;
point: TPointsInfo;
begin
  x1 := figure.x1;
  x2 := figure.x2;
  y1 := figure.y1;
  y2 := figure.y2;

  Point.x := x1;
  Point.y := y1;
  drawVertexRect(canvas, Point, clGreen);

  Point.y := y2;
  drawVertexRect(canvas, Point, clGreen);

  Point.x := x2;
  drawVertexRect(canvas, Point, clGreen);

  Point.y := y1;
  drawVertexRect(canvas, Point, clGreen);

end;

procedure drawSelectLineVertex(canvas: TCanvas; Point: TPointsInfo);
begin
  drawVertexRect(canvas,Point, clGreen);
end;

end.
