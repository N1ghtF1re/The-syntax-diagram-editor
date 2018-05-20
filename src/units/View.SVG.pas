unit View.SVG;

interface
uses Data.Types, Data.InitData;
procedure exportToSVG(head: PFigList; w,h: Integer; path:String; title: UTF8String; desc: UTF8String);
implementation
uses SysUtils, vcl.dialogs, vcl.graphics, Model, View.Canvas, main, Model.Lines;

// Заголовок SVG
const svg_head = '<?xml version="1.0" standalone="no"?>' + #10#13
                 + '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"'+ #10#13
                + '"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';

// Возвращает строку с открытием SVG-тега
function getSVGOpenTag(h,w: integer):UTF8String;
begin
  result := '<svg width="' + IntToStr(W) + '" height="' + IntToStr(H) + #10#13
        + '" viewBox="0 0 ' + IntToStr(W) + ' ' + IntToStr(h) + '"' + #10#13
        + 'xmlns="http://www.w3.org/2000/svg" version="1.1">'
end;

function writePatch(Point1, Point2: TPointsInfo; color: UTF8String = 'black'; width:Integer = Default_LineSVG_Width):UTF8String; overload;
begin
  Result := '<path d="M ' + IntToStr(Point1.x) + ' '
  + IntToStr(Point1.y) +   ' L ' + IntToStr(Point2.x)
  + ' '+ IntToStr(Point2.y) + '" '
  + 'fill="none" stroke="' + color +'" stroke-width="'
  + IntToStr(width) + '" />'
end;

function writePatch(Points: array of TPointsInfo;color: UTF8String = 'black'; width:Integer = Default_LineSVG_Width):UTF8String; overload;
var i:integer;
begin
  Result := '<path d="M ' + IntToStr(Points[0].x) + ' '
  + IntToStr(Points[0].y);
  for i := 1 to Length(Points)-1 do
  begin
    Result := Result + ' L ' + IntToStr(Points[i].x) + ' ' + IntToStr(Points[i].y);
  end;
  Result := result + '" '
  + 'fill="none" stroke="' + color +'" stroke-width="'
  + IntToStr(width) + '" />';
end;

// Функция возвращает строку с text-тегом с заданным содержанием
function writeSVGText(Figure: TFigureInfo; text: UTF8String; family:UTF8String =
                                        'Tahoma'; size:integer = 16):UTF8String;
var TX,TY: real;
const
  SVG_VerticalEpsilon = 4; // Погрешность (Расстояние от верхней точки буквы до
                           // верха выделяемой области больше, чем до нижней)
begin
  with figure do
  begin
    // Координаты центра прямоугольника
    TX := x1 + abs(x2 - x1) / 2;
    TY := y1 + abs(y2 - y1) / 2 + SVG_VerticalEpsilon;
  end;

  {'<rect x="' + IntToStr(figure.x1) +'" y="' + IntToStr(figure.y1) + '"'
  + ' width="'+ IntToStr(figure.x2-figure.x1) + '" height="'+ IntToStr(figure.y2-figure.y1) + '"'
  + ' style="fill:blue;stroke:pink;stroke-width:0;fill-opacity:0.1;stroke-opacity:0.9" />'}

  Result:=
  //  text-anchor="middle" - центрирует текст по вертикали и горизонтали относительно
  //  определенной точки. Подробнее - в документации по формату SVG
  '<text text-anchor="middle" font-family = "'+ family +'" font-size = "' + IntToStr(size) + '"'
  + ' x="'+ StringReplace(FormatFloat( '#.####', TX),',', '.', [rfReplaceAll])
  +'" y="'+StringReplace(FormatFloat( '#.####', TY),',', '.', [rfReplaceAll])
  +'">' + text + '</text>';
end;


procedure drawSVGBoundLine(var f: TextFile; FirstP: TPointsInfo; tmp:PPointsList; var lastp:PPointsList);
var
  coef: -1..1;
  P1, P2: TPointsInfo;
begin
  if FirstP.y - tmp^.adr^.Info.y < 0 then
    coef := 1
  else
    coef := -1;
  p1.x:= tmp^.Info.x-Lines_DegLenght;
  p1.y := tmp^.Info.y;
  p2.x :=  tmp^.Info.x;
  p2.y := tmp^.Info.y+coef*Lines_Deg;

  writeln(f, '<!-- BOUND LINE -->');
  writeln(f, writePatch(p1, p2));
  lastp^.Info := p2;
end;

procedure drawSVGArrowVertical(var f: textFile; x,y : integer; coef: ShortInt);
var
  p1, p2: TPointsInfo;
  points: array[0..2] of TPointsInfo;
begin
  // Draw Vertical Arrow
  P1.x := x;
  P1.y := y;
  points[1] := p1; // СРЕДНЯЯ ТОЧКА
  P2.x := x-Arrow_Height;
  P2.y:= y+Arrow_Width*coef;
  points[0] := p2;

  p2.x := x+Arrow_Height;
  p2.y := y+Arrow_Width*coef;
  writeln(f, '<!-- VERTICAL ARROW -->');
  points[2] := p2;
  writeln(f, writePatch(points));
end;

procedure drawSVGArrow(var F: TextFile; x,y : integer; coef: ShortInt);
var
  p1, p2: TPointsInfo;
  points: array[0..2] of TPointsInfo;
begin
  P1.x := x;
  P1.y := y;
  points[1] := p1; // СРЕДНЯЯ ТОЧКА
  P2.x := x-Arrow_Width*coef;
  P2.y:= y-Arrow_Height;

  points[0] := p2;
  p2.x :=  x-Arrow_Width*coef;
  p2.y := y+ +Arrow_Height;
  writeln(f, '<!-- ARROW -->');
  points[2] := p2;
  writeln(f, writePatch(points));
end;


// Превращаем специальные символы в "сущности"
function htmlspecialchars(s: UTF8String):UTF8String;
var
  st: string;
begin
  st := UTF8ToString(s);
  st:=StringReplace(st,'&','&amp;',[rfReplaceAll, rfIgnoreCase]);
  st:=StringReplace(st,'<','&lt;',[rfReplaceAll, rfIgnoreCase]);
  st:=StringReplace(st,'>','&gt;',[rfReplaceAll, rfIgnoreCase]);
  st:=StringReplace(st,'"','&quot;',[rfReplaceAll, rfIgnoreCase]);
  result:= AnsiToUtf8(st);
end;

procedure drawArrowAtSVG(var f: textfile; point, PrevPoint:TPointsInfo);
var
  tmpx, tmpy:integer;
begin
  tmpx := point.x - PrevPoint.x;
  if tmpx > 0 then
    drawSVGArrow(f,point.x, point.y,1)
  else if tmpx < 0 then
    drawSVGArrow(f,point.x, point.y,-1);

  tmpy := point.y - PrevPoint.y;
  if tmpy > 0 then
    drawSVGArrowVertical(f,point.x, point.y,-1)
  else if tmpy < 0 then
  drawSVGArrowVertical(f,point.x, point.y,1);
end;

procedure drawIncomingLineSVG(var f: textfile; point: TPointsInfo; coef: ShortInt; var d: PPointsList);
var
  p1,p2: TPointsInfo;
begin
  point.y := point.y - coef*Lines_DegLenght;
  p1 := point;
  p2:= point;
  p2.y := p2.y + (Lines_Deg*coef);


  p1 := p2;

  p2.x := point.x+Lines_DegLenght;
  p2.y := point.y;
  writeln(f, '<!-- Incoming Line -->');
  writeln(f, writePatch(p1,p2));
  drawSVGArrowVertical(f, point.x, point.y+Lines_DegLenght*coef, coef);
  {point.y := point.y + 2*coef*Lines_DegLenght;}
end;


// Экспорт в SVG
procedure exportToSVG(head: PFigList; w,h: Integer; path:String; title: UTF8String; desc: UTF8String);
var
  f: TextFile;
  Point1, Point2: TPointsInfo;
  tmp: PFigList;
  tmpx: integer;
  tmpP, prevP: PPointsList;
  firstP: TPointsInfo;
  isFirstLine,isDegEnd :Boolean;
  coef: ShortInt;
  text: UTF8String;
  prev: TPointsInfo;
  curr:TPointsInfo;
  isChanged: boolean;
  Points: array of TPointsInfo; // Массив точек линии!
  CurrIndex: Integer;
begin
  AssignFile(f, path,CP_UTF8);
  rewrite(f);

  writeln(f, svg_head);
  writeln(f, getSVGOpenTag(h,w));
  Writeln(F, SGeneratedText);
  writeln(f, '<title>' + title + '</title>');
  writeln(f, '<desc>' + desc + '</desc>');
  isDegEnd := false;
  coef := 1;

  tmp := head^.adr;
  while tmp <> nil do
  begin

    if tmp^.Info.tp = line then
    begin
      SetLength(Points, getPointsCount(tmp^.Info.PointHead));
      CurrIndex := 1;
      tmpP := tmp^.Info.PointHead^.adr;
      prevp := tmpP;
      curr := tmpP^.Info;
      firstP := tmpP^.Info;
      Points[0] := firstP; // Первая точка
      isFirstLine := false;
      if beginOfVertLine(tmpP,firstP) then
      begin
        prev := prevP^.Info;
        drawSVGBoundLine(f, firstp, tmpP, prevp);

        points[0] := prevP^.Info; // Новая первая точка
        points[CurrIndex] := tmpP^.Adr.Info;

        Inc(CurrIndex);
        prevP^.Info := prev;
        tmpP := tmpP^.Adr;
        isFirstLine :=  true;
      end;
      isChanged := false;
      if isHorisontalIntersection(EditorForm.getFigureHead,tmpP) then
      begin
        if (tmpP^.Adr <> nil) and (FirstP.x - tmpP^.adr^.Info.x < 0) then
          coef := 1
        else
          coef := -1;
        Point1 := tmpP^.Info;
        point1.y := tmpP^.Info.y-Lines_DegLenght;
        point2 := tmpP^.Info;
        point2.x := tmpP^.Info.x+Lines_Deg*coef;
        writeln(f, '<!-- Additional line Intersection: -->');
        writeln(f, writePatch(Point1,Point2,'black'));
        curr := tmpP^.Info;

        curr.x := tmpP^.Info.x+Lines_Deg*coef;
        points[0] := curr; // Новая первая точка
        isChanged := true;

      end;
      if (tmpP^.Adr = nil) then
      begin
        writeln(f, '<!-- LASTARROW -->');
        drawArrowAtSVG(f, tmpP^.info, firstP);
      end;
      while (tmpP <> nil) and (tmpP^.Adr <> nil) do
      begin
        if not isChanged then
          prev := tmpP^.Info
        else
          prev := curr;
        prevp := tmpP;
        tmpP := tmpP^.Adr;
        curr := tmpP^.Info;
        if (tmpP^.Adr = nil) and  isHorisontalIntersection(EditorForm.getFigureHead,tmpP)  then
        begin
          point1 := prevP.Info;
          Point2.x := curr.x-Lines_Deg*coef;
          point2.y := curr.y;
          writeln(f, '<!-- Additional line: -->');
          //writeln(f, writePatch(Point1,Point2,'black'));
          Points[CurrIndex] := point2;
          Inc(CurrIndex);
          if Prev.x - curr.x > 0 then
            drawSVGArrow(f, curr.x-Lines_Deg*coef, curr.y, -1)
          else
            drawSVGArrow(f, curr.x-Lines_Deg*coef, curr.y, 1);
          point1.x := curr.x;
          point1.y := curr.y+Lines_DegLenght;
          point2.x := curr.x-Lines_Deg*coef;
          point2.y :=  curr.y;
          writeln(f, '<!-- Additional line Intersect 2: -->');
          writeln(f, writePatch(Point1,Point2,'black'));
          curr := point1;
          prevP := tmpP;
          prev := tmpP^.Info;
          tmpP:=tmpp^.Adr;
          continue;
        end;

        if (tmpP^.Adr = nil) and (prevP.Info.x = curr.x) then
        begin
          writeln(f, '<!-- LAST VERTICAL: -->');
          curr.y := curr.y + 15*coef;
        end;
        Points[CurrIndex] := curr;
        Inc(CurrIndex);
        //Writeln(f, writePatch( prev, curr));
        if (tmpP^.Adr = nil) and isDegEnd and (prevP^.Info.x = curr.x)  then
        begin

          drawIncomingLineSVG(f, curr, coef, tmpp);
          prevP := tmpP;
          prev := tmpP^.Info;
          continue;
        end;

        if (tmpP^.Adr = nil) then
        begin
          writeln(f, '<!-- LASTARROW -->');
          drawArrowAtSVG(f, curr, prev);
        end;

         if needMiddleArrow(tmpp, FirstP) then // if these is incoming and outgoing lines
          begin
            if isFirstLine then
            begin
              tmpx := curr.x - Prev.x;
              if tmpx > 0 then
                tmpx := 1
              else
                tmpx := -1;
              drawSVGArrow(f,curr.x + Arrow_Height - (curr.x - PrevP^.info.x) div 2, curr.y, tmpx);

            end;
            if curr.y - tmpP^.adr^.Info.y < 0 then
              coef := -1
            else
              coef := 1;
            isDegEnd := true;
          end
          else
          begin
            isDegEnd:= false;
          end;

      end;
      writeln(f, '<!-- LINE WITH ' + IntToStr(Length(points)) +' POINTS: -->');
      Writeln(f, writePatch(Points));
    end
    else
    begin // Other Figures
      text:= AnsiToUtf8( String(tmp^.Info.Txt) );
      case tmp^.Info.tp of
        Def: Text := '< ' + Text + ' > ::= ';
        MetaVar: Text := '< ' + Text + ' >';
        MetaConst: ;
      end;
      text := htmlspecialchars(text);
      Writeln(f, writeSVGText(tmp^.Info, text));
    end;
    tmp := tmp^.Adr;
  end;



  writeln(f, '</svg>'); // Зарытие тега SVG
  close(f);
end;

end.
