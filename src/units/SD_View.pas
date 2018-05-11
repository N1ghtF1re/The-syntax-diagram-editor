unit SD_View;
// VIEW par in MVC:
// responsible for displaying information

interface
uses SD_Types, vcl.graphics, SD_InitData, vcl.dialogs;

// ### VIEW PART PROCEDURES ###

// A search of the list of figures and their drawing
procedure drawFigure(Canvas:TCanvas; head:PFigList; scale: real; isVertex:boolean = true);
procedure drawSelectFigure(canvas:tcanvas; figure: TFigureInfo);
procedure drawSelectLineVertex(canvas: TCanvas; Point: TPointsInfo);
procedure updateScreen(canvas:tcanvas; FigHead: PFigList);
function beginOfVertLine(tmp:PPointsList;firstP: TPointsInfo):boolean;
function needMiddleArrow(tmp: PPointsList; FirstP: TPointsInfo) :Boolean;



implementation
uses main, SD_Model;

procedure ScaleMoveTo(canvas:TCanvas; x,y: integer);
var scale : real;
begin
  scale := EditorForm.FScale;
  canvas.MoveTo( ScaleRound(scale,x), ScaleRound(scale, y) );
end;

procedure ScaleLineTo(canvas:TCanvas; x,y: integer);
var scale : real;
begin
  scale := EditorForm.FScale;
  canvas.LineTo( ScaleRound(scale,x), ScaleRound(scale, y) );
end;
procedure updateScreen(canvas:tcanvas; FigHead: PFigList);
begin
  EditorForm.Repaint;
end;

procedure drawArrowVertical(Canvas:TCanvas; x,y : integer; coef: ShortInt);
begin
  // Draw Vertical Arrow
  ScaleMoveTo(Canvas,x,y);
  ScaleLineTo(Canvas,x-Arrow_Height,y+Arrow_Width*coef);
  ScaleMoveTo(Canvas,x,y);
  ScaleLineTo(Canvas,x+Arrow_Height,y+Arrow_Width*coef);
  ScaleMoveTo(Canvas,x,y);
end;

procedure drawArrow(Canvas:TCanvas; x,y : integer; coef: ShortInt);
begin
  ScaleMoveTo(Canvas,x,y);
  ScaleLineTo(Canvas,x-Arrow_Width*coef,y-Arrow_Height);
  ScaleMoveTo(Canvas,x,y);
  ScaleLineTo(Canvas,x-Arrow_Width*coef,y+Arrow_Height);
  ScaleMoveTo(Canvas,x,y);
end;

procedure drawOutBoundLine(canvas: TCanvas; FirstP: TPointsInfo; tmp:PPointsList);
var
  coef: -1..1;
begin
  if FirstP.y - tmp^.adr^.Info.y < 0 then
    coef := 1
  else
    coef := -1;
  ScaleMoveTo(Canvas,tmp^.Info.x- Lines_DegLenght, tmp^.Info.y);
  ScaleLineTo(Canvas,tmp^.Info.x, tmp^.Info.y+coef*Lines_Deg);
  ScaleMoveTo(Canvas,tmp^.Info.x, tmp^.Info.y+coef*Lines_Deg);
  // canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y+15*coef-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+15*coef+VertRad);
end;

function beginOfVertLine(tmp:PPointsList;firstP: TPointsInfo):boolean;
begin
  result := (tmp^.Adr <> nil) and
      (FirstP.x = tmp^.adr^.Info.x)  and // If vertical line
      (FirstP.y <> tmp^.adr^.Info.y);
end;

procedure drawVertexRect(canvas:TCanvas; point: TPointsInfo; color:TColor = clBlack);
var
  ScaleVertRad: integer;
begin
  canvas.Pen.Color := color;
  if color <> clBlack then
    Canvas.Brush.Color := color;

  canvas.Pen.Width := 1;
  EditorForm.useScale(Point.x, point.y);
  ScaleVertRad := ScaleRound(EditorForm.FScale, VertRad);
  canvas.Rectangle(point.x-ScaleVertRad,point.y-ScaleVertRad, point.x+ScaleVertRad, point.y+ScaleVertRad);
  canvas.Pen.Width := Round(Lines_Width*EditorForm.FScale);
  canvas.Pen.Color := clBlack;
  canvas.Brush.Color := clwhite;

end;

procedure drawIncomingLine(canvas: tcanvas; point: TPointsInfo; coef: ShortInt);
begin
  ScaleLineTo(Canvas,point.x, point.y + (Lines_Deg*coef));
  ScaleMoveTo(Canvas,point.x, point.y + (Lines_Deg*coef));
  ScaleLineTo(Canvas,point.x+Lines_DegLenght, point.y);
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

procedure drawLines(Canvas:TCanvas; head: PPointsList; LT: TLineType; isVertex: boolean; scale: Real);
var
  tmp: PPointsList; // Temp variable
  FirstP,PrevP: TPointsInfo; // First and Prev Point in list
  tmpx: integer;
  isFirstLine:boolean;
  point1:TPointsInfo;
  AddY: integer;
  isDegEnd: boolean;
  coef: -1..1;
begin                  //\\
  coef := 1;
  canvas.Pen.Width := Trunc(Lines_Width*scale); // Width For Line
  isFirstLine := false;
  tmp := head;

  if (tmp <> nil) and (tmp^.Adr <> nil) then
  begin
    FirstP.X := tmp^.Adr^.Info.x; // Initialise First Points
    FirstP.y := tmp^.Adr^.Info.y;

    prevp.x := FirstP.X; // Initialise Preview Point
    prevp.y := FirstP.Y;

    tmp := tmp^.Adr;

    ScaleMoveTo(Canvas,tmp^.Info.x, tmp^.Info.y); // Move to first point in list

    // FIRST POINT:
    if beginOfVertLine(tmp,firstP) and (PrevP.y = tmp^.Info.y) then
    begin
      drawOutBoundLine(canvas,FirstP, tmp);
      isFirstLine :=  true;
    end;
    {if LT = LAdditLine then
    begin
      AddY := tmp^.Info.y;
    end;}
    // POTOM
    if (tmp^.Adr <> nil) and (PrevP.y = tmp^.adr^.Info.y) and isHorisontalIntersection(EditorForm.getFigureHead,tmp) then
    begin
      if (tmp^.Adr <> nil) and (FirstP.x - tmp^.adr^.Info.x < 0) then
        coef := 1
      else
        coef := -1;
      ScaleMoveTo(Canvas,tmp^.Info.x, tmp^.Info.y-Lines_DegLenght);
      ScaleLineTo(Canvas,tmp^.Info.x+Lines_Deg*coef, tmp^.Info.y);
    end;
    // POTOM END;

    if isVertex then
      drawVertexRect(canvas, tmp^.Info);

    // OTHER POINTS:
    tmp := tmp^.adr;
    isDegEnd := false;
    while tmp <> nil do
    begin
      {if LT =LAdditLine then
      begin
        tmp^.Info.y := AddY;
      end;}
      if (PrevP.y = tmp^.Info.y) and (tmp^.Adr = nil) and  isHorisontalIntersection(EditorForm.getFigureHead,tmp)  then
      begin
        ScaleLineTo(Canvas,tmp^.Info.x-Lines_Deg*coef, tmp^.Info.y);
        // Перед \ - стрелочка
        if (PrevP.x - tmp^.Info.x > 0) and (PrevP.y = tmp^.Info.y) then
          drawArrow(canvas, tmp^.Info.x-Lines_Deg*coef, tmp^.Info.y, -1)
        else if (PrevP.y = tmp^.Info.y) then
          drawArrow(canvas, tmp^.Info.x-Lines_Deg*coef, tmp^.Info.y, 1);
        ScaleMoveTo(Canvas,tmp^.Info.x, tmp^.Info.y+Lines_DegLenght);
        ScaleLineTo(Canvas,tmp^.Info.x-Lines_Deg*coef, tmp^.Info.y);
        Point1 :=  tmp^.Info;
        if isVertex then
          drawVertexRect(canvas, point1);

        //canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+VertRad);
        tmp:=tmp^.Adr;
        continue;
      end;


      if isDegEnd then
      begin
        drawIncomingLine(canvas, tmp^.Info, coef);
        if isVertex then
          drawVertexRect(canvas, tmp^.Info);
        tmp := tmp^.Adr;
        continue;
      end
      else
        ScaleLineTo(Canvas,tmp^.Info.x, tmp^.Info.y);

      ScaleMoveTo(Canvas,tmp^.Info.x, tmp^.Info.y);
      if isVertex then
        drawVertexRect(canvas, tmp^.Info);

      // Рисуем стрелочку в конце линии
      if (tmp^.Adr = nil) then
      begin
        drawArrowAtEnd(canvas, tmp^.Info, prevP);
        //drawArrow(canvas,tmp^.Info.x, tmp^.Info.y);
      end;



      if needMiddleArrow(tmp, FirstP) then // if these is incoming and outgoing lines
      begin
        if isFirstLine then
        begin
          tmpx := tmp^.Info.x - PrevP.x;
          if tmpx > 0 then
            tmpx := 1
          else
            tmpx := -1;
          drawArrow(Canvas,tmp^.Info.x + 10 - (tmp^.Info.x - PrevP.x) div 2, tmp^.Info.y, tmpx);
          ScaleMoveTo(Canvas,tmp^.Info.x , tmp^.Info.y)
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


procedure drawFigure(Canvas:TCanvas; head:PFigList; scale: real; isVertex:boolean = true);
var
  temp:PFigList;
  TextW: Integer;
  TextH: Integer;
  TX, TY: integer;
  Point: TPointsInfo;
  text:string;
begin
  temp := head^.adr;
  while temp <> nil do
  begin
    with temp^.Info do
    begin
      if tp <> Line then
        text := String(txt);
      case Tp of
        Def: Text := '< ' + Text + ' > ::= ';
        MetaVar: Text := '< ' + Text + ' >';
        MetaConst: ;
        line:
        begin
          drawLines(Canvas, temp^.Info.PointHead, temp^.Info.LT, isVertex, scale);
          temp := temp^.adr;
          continue; // if figure - line => draw this line and skip ineration
        end;
        else
        ;
      end;
      Canvas.Font.Size := Font_Size;
      TextW := canvas.TextWidth(text);
      textH := Canvas.TextHeight(text);
      // Расчитываем координаты, чтобы текст был по середине
      TX := x1 + (x2 - x1) div 2 - TextW div 2;
      TY := y1 + (y2 - y1) div 2 - TextH div 2;
      Canvas.Font.Size := ScaleRound(Scale, Font_Size);
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


      if isVertex then
      begin
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
      end;
      Canvas.Font.Size := ScaleRound(Scale, Font_Size);
      Canvas.TextOut(ScaleRound(Scale, TX),ScaleRound(Scale, TY), text);
    end;

    temp := temp^.Adr;
  end;
end;

procedure drawSelectFigure(canvas:tcanvas; figure: TFigureInfo);
var x1,x2,y1,y2: integer;
point: TPointsInfo;
Scale: Real;
begin
  Scale := EditorForm.FScale;
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
