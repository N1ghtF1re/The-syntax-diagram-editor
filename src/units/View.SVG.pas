unit View.SVG;

interface
uses Data.Types, Data.InitData;
procedure exportToSVG(head: PFigList; w,h: Integer; path:UTF8String; title: UTF8String; desc: UTF8String);

implementation
uses SysUtils, vcl.dialogs, vcl.graphics, Model, View.Canvas, main;
const svg_head = '<?xml version="1.0" standalone="no"?>' + #10#13
                 + '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"'+ #10#13
                + '"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';

function getSVGOpenTag(h,w: integer):UTF8String;
begin
  result := '<svg width="' + IntToStr(W) + '" height="' + IntToStr(H) + #10#13
        + '" viewBox="0 0 ' + IntToStr(W) + ' ' + IntToStr(h) + '"' + #10#13
        + 'xmlns="http://www.w3.org/2000/svg" version="1.1">'
end;

function writePatch(Point1, Point2: TPointsInfo; color: UTF8String = 'black'; width:Integer = Default_LineSVG_Width):UTF8String;
begin
  Result := '<path d="M ' + IntToStr(Point1.x) + ' '
  + IntToStr(Point1.y) +   ' L ' + IntToStr(Point2.x)
  + ' '+ IntToStr(Point2.y) + '" '
  + 'fill="none" stroke="' + color +'" stroke-width="'
  + IntToStr(width) + '" />'
end;

function writeSVGText(Figure: TFigureInfo; text: UTF8String; family:UTF8String =
                                        'Tahoma'; size:integer = 16):UTF8String;
var TH, TW, TX,TY: real;
TextW, TextH: integer;
const
  SVG_VerticalEpsilon = 4; // ѕогрешность (–ассто€ние от верхней точки буквы до
                           // верха выдел€емой области больше, чем до нижней)
begin
  //EditorForm.getTextWH(TW,TH, Text, size, family);

  with figure do
  begin
    //  оординаты центра пр€моугольника
    TX := x1 + abs(x2 - x1) / 2;
    TY := y1 + abs(y2 - y1) / 2 + SVG_VerticalEpsilon;
  end;

  {'<rect x="' + IntToStr(figure.x1) +'" y="' + IntToStr(figure.y1) + '"'
  + ' width="'+ IntToStr(figure.x2-figure.x1) + '" height="'+ IntToStr(figure.y2-figure.y1) + '"'
  + ' style="fill:blue;stroke:pink;stroke-width:0;fill-opacity:0.1;stroke-opacity:0.9" />'}

  Result:=
  //  text-anchor="middle" - центрирует текст по вертикали и горизонтали относительно
  //  определенной точки
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
  // canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y+15*coef-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+15*coef+VertRad);
end;

procedure drawSVGArrowVertical(var f: textFile; x,y : integer; coef: ShortInt);
var
  p1, p2: TPointsInfo;
begin
  // Draw Vertical Arrow
  P1.x := x;
  P1.y := y;
  P2.x := x-Arrow_Height;
  P2.y:= y+Arrow_Width*coef;
  writeln(f, '<!-- ARROS LEFT -->');
  writeln(f, writePatch(p1,p2));

  p2.x := x+Arrow_Height;
  p2.y := y+Arrow_Width*coef;
  writeln(f, '<!-- ARROW RIGHT -->');
  writeln(f, writePatch(p1,p2));
end;

procedure drawSVGArrow(var F: TextFile; x,y : integer; coef: ShortInt);
var
  p1, p2: TPointsInfo;
begin
  P1.x := x;
  P1.y := y;
  P2.x := x-Arrow_Width*coef;
  P2.y:= y-Arrow_Height;
  writeln(f, '<!-- ARROS LEFT -->');
  writeln(f, writePatch(p1,p2));

  p2.x :=  x-Arrow_Width*coef;
  p2.y := y+ +Arrow_Height;
  writeln(f, '<!-- ARROW RIGHT -->');
  writeln(f, writePatch(p1,p2));
end;

function htmlspecialchars(s: UTF8String):UTF8String;
begin
 s:=StringReplace(s,'&','&amp;',[rfReplaceAll, rfIgnoreCase]);
 s:=StringReplace(s,'<','&lt;',[rfReplaceAll, rfIgnoreCase]);
 s:=StringReplace(s,'>','&gt;',[rfReplaceAll, rfIgnoreCase]);
 s:=StringReplace(s,'"','&quot;',[rfReplaceAll, rfIgnoreCase]);
 result:=s;
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

procedure exportToSVG(head: PFigList; w,h: Integer; path:UTF8String; title: UTF8String; desc: UTF8String);
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
begin
  AssignFile(f, path,CP_UTF8);
  rewrite(f);
  writeln(f, svg_head);
  writeln(f, getSVGOpenTag(h,w));
  writeln(f, '<title>' + title + '</title>');


  tmp := head^.adr;
  while tmp <> nil do
  begin

    if tmp^.Info.tp = line then
    begin
      tmpP := tmp^.Info.PointHead^.adr;
      prevp := tmpP;
      curr := tmpP^.Info;
      firstP := tmpP^.Info;
      isFirstLine := false;
      if beginOfVertLine(tmpP,firstP) then
      begin
        prev := prevP^.Info;
        drawSVGBoundLine(f, firstp, tmpP, prevp);
        writeln(f, '<!-- Line After Bound -->');
        Writeln(f, writePatch(prevP^.Info, tmpP^.adr.Info));
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
        isChanged := true;

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
          writeln(f, writePatch(Point1,Point2,'black'));
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
        writeln(f, '<!-- LINE: -->');
        Writeln(f, writePatch( prev, curr));
        if (tmpP^.Adr = nil) and isDegEnd {and (tmp^.Info.LT <> LAdditLine)} and (prevP^.Info.x = curr.x)  then
        begin

          drawIncomingLineSVG(f, curr, coef, tmpp);
          prevP := tmpP;
          prev := tmpP^.Info;
          continue;
        end;

        if (tmpP^.Adr = nil) then
        begin
          drawArrowAtSVG(f, curr, prev);
            //drawArrow(canvas,tmp^.Info.x, tmp^.Info.y);
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
    end
    else
    begin // Other Figures
      text:= AnsiToUtf8( tmp^.Info.Txt );
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



  writeln(f, '</svg>');
  close(f);
end;

end.
