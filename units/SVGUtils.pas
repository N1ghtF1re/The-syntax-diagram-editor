unit SVGUtils;

interface
uses SD_Types, SD_InitData;
procedure exportToSVG(head: PFigList; w,h: Integer; path:string; title: string; desc: string);

implementation
uses SysUtils, vcl.dialogs, vcl.graphics, SD_Model, SD_View, main;
const svg_head = '<?xml version="1.0" standalone="no"?>' + #10#13
                 + '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"'+ #10#13
                + '"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';

function getSVGOpenTag(h,w: integer):string;
begin
  result := '<svg width="' + IntToStr(W) + '" height="' + IntToStr(H) + #10#13
        + '" viewBox="0 0 ' + IntToStr(W) + ' ' + IntToStr(h) + '"' + #10#13
        + 'xmlns="http://www.w3.org/2000/svg" version="1.1">'
end;

function writePatch(Point1, Point2: TPointsInfo; color: string = 'black'; width:Integer = Default_LineSVG_Width):string;
begin
  Result := '<path d="M ' + IntToStr(Point1.x) + ' '
  + IntToStr(Point1.y) +   ' L ' + IntToStr(Point2.x)
  + ' '+ IntToStr(Point2.y) + '" '
  + 'fill="none" stroke="' + color +'" stroke-width="'
  + IntToStr(width) + '" />'
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
  writeln(f, '<!-- xa-xa-xa-->');
  writeln(f, writePatch(p1,p2));
  drawSVGArrowVertical(f, point.x, point.y+Lines_DegLenght*coef, coef);
  {point.y := point.y + 2*coef*Lines_DegLenght;}
end;

procedure exportToSVG(head: PFigList; w,h: Integer; path:string; title: string; desc: string);
var
  f: TextFile;
  Point1, Point2: TPointsInfo;
  tmp: PFigList;
  tmpx: integer;
  tmpP, prevP: PPointsList;
  firstP: TPointsInfo;
  isFirstLine,isDegEnd :Boolean;
  coef: ShortInt;
begin
  AssignFile(f, path);
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
      firstP := tmpP^.Info;
      isFirstLine := false;
      if beginOfVertLine(tmpP,firstP) then
      begin
        drawSVGBoundLine(f, firstp, tmpP, prevp);
        tmpP^.Info := prevP^.Info;
        isFirstLine :=  true;
      end;

      if (tmp^.info.LT = LAdditLine) and isHorisontalIntersection(EditorForm.getFigureHead,tmpP) then
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
        tmpP^.Info.x := tmpP^.Info.x+Lines_Deg*coef;
      end;
    
      while (tmpP <> nil) and (tmpP^.Adr <> nil) do
      begin
        prevp := tmpP;
        tmpP := tmpP^.Adr;
        
        if (tmpP^.Adr = nil) and (tmp^.Info.LT = LAdditLine) and  isHorisontalIntersection(EditorForm.getFigureHead,tmpP)  then
        begin
          point1 := prevP.Info;
          Point2.x := tmpP^.Info.x-Lines_Deg*coef;
          point2.y := tmpP^.Info.y;
          writeln(f, '<!-- Additional line: -->');
          writeln(f, writePatch(Point1,Point2,'black'));
          point1.x := tmpP^.Info.x;
          point1.y := tmpP^.Info.y-Lines_DegLenght;
          point2.x := tmpp^.Info.x-Lines_Deg*coef;
          point2.y :=  tmpP^.Info.y;
          writeln(f, '<!-- Additional line Intersect 2: -->');
          writeln(f, writePatch(Point1,Point2,'black'));
          tmpP^.Info := point1;
          prevP := tmpP;
          tmpP:=tmpp^.Adr;
          continue;
        end;
      
        if (tmpP^.Adr = nil) and (tmp^.info.LT <> LAdditLine) then
        begin
          writeln(f, '<!-- LAST: -->');
          tmpp^.Info.y := tmpp^.Info.y + 15*coef;
        end;
        writeln(f, '<!-- LINE: -->');
        Writeln(f, writePatch( prevP^.Info, tmpP^.Info));
        if (tmpP^.Adr = nil) and isDegEnd and (tmp^.Info.LT <> LAdditLine)  then
        begin
          
          drawIncomingLineSVG(f, tmpP^.Info, coef, tmpp);
          prevP := tmpP;
          
          continue;
        end;
      
        if (tmpP^.Adr = nil) and  (tmp^.Info.LT <> LAdditLine) then
        begin
          drawArrowAtSVG(f, tmpP^.Info, prevP^.info);
            //drawArrow(canvas,tmp^.Info.x, tmp^.Info.y);
        end;
      
         if (tmp^.Info.LT <> LAdditLine) and needMiddleArrow(tmpp, FirstP) then // if these is incoming and outgoing lines
          begin
            if isFirstLine then
            begin
              tmpx := tmpp^.Info.x - PrevP^.info.x;
              if tmpx > 0 then
                tmpx := 1
              else
                tmpx := -1;
              drawSVGArrow(f,tmpp^.Info.x + 10 - (tmpp^.Info.x - PrevP^.info.x) div 2, tmpP^.Info.y, tmpx);
              
            end;
            if tmpP^.Info.y - tmpP^.adr^.Info.y < 0 then
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
    end;

    tmp := tmp^.Adr;
  end;



  writeln(f, '</svg>');
  close(f);
end;                          

end.
