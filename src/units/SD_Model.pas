unit SD_Model;
// MODEL par in MVC:
// responsible for processing information
interface

uses SD_types, vcl.graphics, SD_View,vcl.dialogs, SD_InitData, math, SVGUtils, Model.FilesUtil;
 function isHorisontalIntersection(head: PFigList; blocked: PPointsList): boolean;
 function getClickFigure(x,y:integer; head: PFigList):PFigList;
 function removeFigure(head: PFigList; adr: PFigList):PFigList;
 procedure selectFigure(canvas: TCanvas; head:PFigList);
 procedure removeAllList(head:PFigList);
 procedure ChangeCoords(F: PFigList; EM: TEditMode; x,y:integer; var TmpX, TmpY: integer);
 procedure checkLineCoords(head: PPointsList);
 function addNewPoint(var head: PPointsList; x,y:integer):PPointsList;
 procedure createFigList(var head: PFigList);
 function addLine(head: PFigList; x,y: integer):PFigList;
 function searchNearFigure(head: PFigList; var x,y: integer):PPointsList;
 function addFigure(head: PFigList; x,y: integer; ftype: TType; Text:String = 'Kek'):PFigList;
 function nearRound(x:integer):integer;
 procedure roundCoords(var x,y:integer);
 function getEditMode(status: TDrawMode; x,y: Integer; head: PFigList; CT: TType) :TEditMode;
 procedure checkFigureCoord(R: PFigList);
 procedure removeTrashLines(head: PFigList; curr: PFigList);
 procedure copyFigure(head: PFigList; copyfigure:PFigList);
 procedure MagnetizeLines(head: PFigList);
 function ScaleRound(scale: real; x: integer): integer;
 procedure undoChanges(UndoRec: TUndoStackInfo; Canvas: TCanvas);

implementation
uses System.Sysutils, main;

function nearRound(x:integer):integer;
begin
  Result:= round(x/NearFigure)*NearFigure;
end;


function isHorisontalIntersection(head: PFigList; blocked: PPointsList):boolean;
var
  tmp: PFigList;
  tmpP: PPointsList;
  ti1, ti2: TPointsInfo;
begin
  Result := false;
  tmp:= head^.adr;
  while tmp <> nil do
  begin
    if tmp^.Info.tp = Line then
    begin
      if tmp^.info.PointHead = nil then
      begin
        tmp := tmp^.adr;
        continue;
      end;

      tmpP := tmp^.Info.PointHead^.adr;
      while (tmpP <> nil) and (tmpP^.adr <> nil) do
      begin

        ti1 := tmpP^.Info;
        ti2 := tmpP^.adr.Info;
        if (abs(ti1.x- blocked.Info.x) < NearFigure)
        and (abs(ti2.x - blocked.Info.x) < NearFigure)
        and (blocked.Info.y < max(ti1.y, ti2.y))
        and (blocked.Info.y > min(ti1.y, ti2.y))
        and (tmpP <> blocked) and (tmpP^.adr <> blocked)
        then
        begin
          //blocked^.Info.x := tmpP^.adr^.Info.x;
          Result := true;
          exit;
        end;
        tmpP:= tmpP^.adr;
      end;
    end;
    tmp := tmp^.Adr;
  end;
end;

procedure checkFigureCoord(R: PFigList);
var
  temp:integer;
begin
  if (R<>nil) and (R^.Info.tp <> Line) then
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


function isBelongsLine(head: PPointsList; x,y: integer): Boolean;
var
  tmp, tmp2 : PPointsList;
begin
  if (head = nil) or (head^.Adr = nil) or (head^.Adr^.Adr = nil) then exit;
  tmp := head^.adr;
  tmp2 := tmp^.Adr;
  Result := false;
  while (tmp <> nil) and (tmp2 <> nil) do
  begin
    if (tmp^.Info.x = tmp2^.Info.x) and (abs(tmp^.Info.x - x) < Tolerance) then
    begin
      if (y > min(tmp^.Info.y, tmp2^.Info.y)) and (y < max(tmp^.Info.y, tmp2^.Info.y)) then
      begin
        Result := true;
        exit
      end;
    end;
     if (tmp^.Info.y = tmp2^.Info.y) and  (abs(tmp^.Info.y - y) < Tolerance) then
    begin
      if (x > min(tmp^.Info.x, tmp2^.Info.x)) and (x < max(tmp^.Info.x, tmp2^.Info.x)) then
      begin
        Result := true;
        exit
      end;
    end;
    tmp := tmp^.Adr;
    tmp2 := tmp2^.adr;

  end;


end;

function ScaleRound(scale: real; x: integer):integer;
begin
  Result := Round(X*Scale);
end;


function copyPointList(cf: PPointsList):PPointsList;
var
  tmp: PPointsList;
begin
  
  new(Result);
  Result^.adr := nil;
  tmp := cf;
  if tmp = nil then exit;
  tmp := tmp^.Adr;
  while tmp <> nil do
  begin
    addNewPoint(Result, tmp^.Info.x, tmp^.Info.y);
    tmp := tmp^.Adr;
  end;
  
end;

procedure copyFigure(head: PFigList; copyfigure:PFigList);
var
  newfigure: TFigureInfo;
  tmp: PFigList;
begin
  newfigure := copyfigure^.Info;
  if copyfigure^.Info.tp = Line then
    newfigure.PointHead := copyPointList(copyfigure^.Info.PointHead);
  if head = nil then exit;
  tmp := head;
  while tmp^.Adr <> nil do
  begin 
    tmp := tmp^.Adr;
  end;
  new(tmp^.adr);
  tmp := tmp^.Adr;
  tmp^.Adr := nil;
  tmp^.Info := newfigure;
      
end;

function getEditMode(status: TDrawMode; x,y: Integer; head: PFigList; CT: TType) :TEditMode;
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
        { ToDo: KEK }
        tmpPoint := tmpPoint^.Adr;
      end;
      if (CT =  TType(4)) and (isBelongsLine(temp^.Info.PointHead, x,y)) then
      begin
        CurrFigure := temp;
        Result := LineMove;
        Exit;
      end;
    end;
    temp := temp^.Adr;
  end;
  Result :=  NoEdit;
end;

procedure roundCoords(var x,y:integer);
begin
  x := round(x/step_round)*step_round;
  y := round(y/step_round)*step_round;

  searchNearFigure(FigHead, x,y);
  //ShowMessage( IntToStr(x) + ' ' + IntToStr(y) );
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
    Txt := ShortString(text);
    Tp := ftype;
  end;

  Result := tmp;
end;

// Создаем массив прямоугольных фигур


function searchNearFigure(head: PFigList; var x,y: integer):PPointsList;
var
  temp: PFigList;
  tmpP: PPointsList;
  lastP: PPointsList;
  maxX, maxY, minX, minY:integer;
begin
  Result := nil;
  temp:= head.adr;

  while temp <> nil do
  begin
    if temp^.Info.tp = line then
    begin
      if temp^.Info.PointHead = nil then
      begin
        temp := temp^.adr;
        Continue;
      end;

      tmpP:= temp^.Info.PointHead^.adr;
      lastP:=tmpP;
      if tmpP^.Adr <> nil then
        tmpP := tmpP^.adr;
      while tmpP <> nil do
      begin
        maxY := max(tmpP.Info.y, lastP.Info.y);
        minY := min(tmpP.Info.y, lastP.Info.y);
        maxX := max(tmpP.Info.x, lastP.Info.x);
        minX := min(tmpP.Info.x, lastP.Info.x);
        if (abs(MaxX - x) < NearFigure)
            and
           (y > minY)
            and
           (y < maxY) then
        begin
          x := MaxX;
          Result := tmpP;
          exit;

        end;

        if (abs(MinX - x) < NearFigure)
            and
           (y > minY)
            and
           (y < maxY) then
        begin
          x := MinX;
          Result := tmpP;

          exit;
        end;

        if (abs(MaxY - y) < nearFigure)
            and
           (x > minx)
            and
           (x < maxx) then
        begin
          y := MaxY;
          Result := tmpP;
          exit;
        end;

        if (abs(MinY - Y) < NearFigure)
            and
           (X > minX)
            and
           (X < maxX) then
        begin
          Y := MinY;
          Result := tmpP;
          exit;
        end;
        lastp:= tmpP;
        tmpP := tmpP^.adr;
      end;

    end
    else
    begin
      temp := temp^.Adr;
      continue;
      if round(temp.Info.x1/NearFigure)*NearFigure = round(x/NearFigure)*NearFigure then
      begin
        x := temp.Info.x1;
      end;
      if round(temp.Info.x2/NearFigure)*NearFigure = round(x/NearFigure)*NearFigure then
      begin
        x := temp.Info.x2;
      end;
      if round(temp.Info.y1/NearFigure)*NearFigure = round(y/NearFigure)*NearFigure then
      begin
        y := temp.Info.y1;
      end;
      if round(temp.Info.y2/NearFigure)*NearFigure = round(y/NearFigure)*NearFigure then
      begin
        y := temp.Info.y2;
      end;

    end;
    temp := temp^.Adr;
  end;
end;

procedure createFigList(var head: PFigList);
begin
  new(head);
  head.Adr := nil;
end;



// Добавляем линию
function addLine(head: PFigList; x,y: integer):PFigList;
var
  tmp: PFigList;
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
  tmp^.Info.LT := CurrLineType;
  addNewPoint(tmp^.Info.PointHead, x,y);

  result := tmp;
end;

procedure removeTrashLines(head: PFigList; curr: PFigList);
var
  tmp: PFigList;
begin
  if head = nil then exit;

  tmp := head^.adr;
  while tmp <> nil do
  begin
    if tmp^.Info.tp = Line then
    begin
      if (tmp^.Info.PointHead = nil) or (tmp^.Info.PointHead^.Adr = nil) then continue;
      
      if (tmp^.Info.PointHead^.Adr^.Adr = nil) and (tmp <> curr) then
        removeFigure(head,tmp);
    end;
     tmp := tmp^.Adr;
  end;
  


end;

// Возвращает фигуру, по которой был клик
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
        //showMessage('kek');
        exit;
      end;
    end
    else
    begin
      if (tmp^.Info.PointHead = nil) or (tmp^.Info.PointHead^.Adr = nil) then
      begin
        tmp := tmp^.adr;
       continue;
      end;
      tmpP := tmp^.Info.PointHead^.Adr;
      while tmpP <> nil do
      begin
        if (abs(y-tmpP^.Info.x) <= Tolerance) and (abs(x-tmpP^.Info.y) <= Tolerance) then
        begin
          result := tmp;
          exit;
        end;

        if tmpP^.Adr <> nil then
        begin

          if ((abs(y - tmpP^.Info.y) <= Tolerance*2 ) and (x > min(tmpP^.Info.x, tmpP^.adr^.Info.x)) and (x <= max(tmpP^.Info.x, tmpP^.adr^.Info.x)) )
              or
             ((abs(x - tmpP^.Info.x) <= Tolerance*2) and (y > min(tmpP^.Info.y, tmpP^.adr^.Info.y)) and (y <= max(tmpP^.Info.y, tmpP^.adr^.Info.y))) then
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

function addNewPoint(var head: PPointsList; x,y:integer):PPointsList;
var
  tmp :PPointsList;
  id :integer;
  px, py: integer;
begin
  tmp := head;
  while tmp^.adr <> nil do
    tmp := tmp^.Adr;
  if tmp <> head then
  begin
    px := tmp^.Info.x;
    py := tmp^.Info.y;
    // Запрещаем проводить прямую под углом.
    try
      if (arctan(abs((y-py)/(x-px))) < pi/4) {or (CurrLineType = LAdditLine)} then
        y:=py
      else
        x:=px;
    except on EZeroDivide do
      // kek
    end;
  end;
  new(tmp^.adr);
  Result := tmp;
  tmp := tmp^.adr;
  tmp^.Info.x := x;
  tmp^.Info.y := y;
  tmp^.Adr := nil;
end;

// Функция выполняет логическое удаление фигуры и возвращает ссылку
// На предшествующую удаленной фигуру фигуру.
function removeFigure(head: PFigList; adr: PFigList):PFigList;
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
      Result := temp;
      //dispose(temp2);
    end
    else
      temp:= temp^.adr;
  end;
end;


procedure selectFigure(canvas: TCanvas; head:PFigList);
var
  tmp : PPointsList;
begin
  //ShowMessage('kek');
  if head^.Info.tp <> line then
  begin
    // Рисуем вершины
    drawSelectFigure(canvas, head^.Info);
  end
  else
  begin
    //showmessage('kek');
    if head^.Info.PointHead = nil then exit;
    tmp := head^.Info.PointHead^.adr;
    while tmp <> nil do
    begin
      drawSelectLineVertex(canvas,tmp^.info);
      tmp := tmp^.Adr;
    end;
  end;
end;




procedure removeAllList(head:PFigList);
var
  temp, temp2: PFigList;
begin
  temp := head^.Adr;
  while temp <> nil do
  begin
    temp2:=temp^.Adr;
    dispose(temp);
    temp:=temp2;
  end;
  head.Adr := nil;
end;


procedure checkLineCoords(head: PPointsList);
var
  tmp:PPointsList;
begin
  tmp := head^.adr;
  while tmp^.adr <> NIL do
  begin
    //showmessage( Inttostr( tmp^.Adr^.Info.y ) );
    try
      if arctan(abs((tmp^.Adr^.Info.y-tmp^.Info.y)/(tmp^.Adr^.Info.x-tmp^.Info.x))) < pi/4 then
          tmp^.Info.y := tmp^.adr^.Info.y
      else
         tmp^.Info.x := tmp^.adr^.Info.x;
      except on E: EZeroDivide do

    end;
    tmp := tmp^.Adr;
  end;
end;

procedure MoveLine(head: PPointsList; oldp, newp: TPointsInfo);
var
  tmp: PPointsList;
  Good: PPointsList;
  isFound:Boolean;
begin
  tmp:=head^.adr;
  isFound := true;
  Good := nil;
  while tmp <> nil do
  begin
    if (tmp^.Info.y = oldp.y) or (tmp^.Info.x = oldp.x) or ((tmp^.Info.x = newP.x) and (tmp^.Info.y = newP.y)) then
    begin
      if Good = nil then
        Good:= tmp;
      isFound:= true;
      if (tmp^.Info.x = newP.x) and (tmp^.Info.y = newP.y) then
        break;
    end
    else
    begin
      Good := nil;
    end;
    tmp := tmp^.Adr;
  end;

  tmp := good;
  while (tmp<>nil) and isFound and ((tmp^.Info.y = oldp.y) or (tmp^.Info.x = oldp.x) or ((tmp^.Info.x = newP.x) and (tmp^.Info.y = newP.y) )) do
  begin
    if tmp^.Info.y = oldp.y then
      tmp^.Info.y := newp.y;
    if tmp^.Info.x = oldp.x then
      tmp^.Info.x := newp.x;
    tmp := tmp^.Adr;
  end;



end;

procedure moveALlLinePoint(head: PPointsList; dx, dy: integer);
var
  tmp: PPointsList;
begin
  tmp := head^.Adr;
  while tmp <> nil do
  begin
    tmp^.Info.x := tmp^.Info.x - dx;
    tmp^.Info.y := tmp^.Info.y - dy;
    tmp := tmp^.Adr;
  end;
end;

procedure ChangeCoords(F: PFigList; EM: TEditMode; x,y:integer; var TmpX, TmpY: integer);
var
  oldp: TPointsInfo;
begin
  if F <> nil then
  case EM of
    NoEdit:
    begin
      {F^.Info.x2 := x;
            F^.Info.y2 := y;}
    end;
    Move: // Перемещаем объект :)
    begin
      if F^.Info.tp = Line then
      begin
        oldp:= currPointAdr^.Info;
        currPointAdr^.Info.x := currPointAdr^.Info.x - (TmpX - x);
        currPointAdr^.Info.y := currPointAdr^.Info.y - (Tmpy - y);
        MoveLine(CurrFigure^.Info.PointHead, oldp, currPointAdr^.Info);
        //checkLineCoords(CurrFigure^.Info.PointHead);
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
    LineMove:
    begin
      moveALlLinePoint(CurrFigure^.Info.PointHead, (TmpX - x), (Tmpy - y));
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

function magnetizeWithFigures(head: PFigList; Point: PPointsList):boolean;
var
  temp: PFigList;
begin
  temp := head^.adr;
  Result := false;
  while temp <> nil do
  begin
    if temp^.Info.tp <> Line then
    begin
      if (abs( Point^.Info.x - temp^.Info.x1) < NearFigure*2)
        and
        ( Point^.Info.y < temp^.Info.y2 )
        and
        ( Point^.Info.y > temp^.Info.y1 )
      then
      begin
        Result := true;
        Point^.info.x := temp^.Info.x1;
        point^.Info.y := (temp^.Info.y1 + temp^.Info.y2) div 2;
      end;

      if (abs( Point^.Info.x - temp^.Info.x2) < NearFigure*2)
        and
        ( Point^.Info.y < temp^.Info.y2 )
        and
        ( Point^.Info.y > temp^.Info.y1 )
      then
      begin
        Result := true;
        Point^.info.x := temp^.Info.x2;
        point^.Info.y := (temp^.Info.y1 + temp^.Info.y2) div 2;
      end;
    end;
    temp := temp^.Adr;
  end;
end;

procedure MagnetizeLines(head: PFigList);
var
  tmp: PFigList;
  tmpP: PPointsList;
  NearP: PPointsList;
  x,y : integer;
  oldP, newP: TPointsInfo;
begin
  tmp := head^.adr;
  while tmp <> nil do
  begin
    if tmp^.Info.tp <> Line then
    begin
      tmp := tmp^.Adr;
      continue;
    end;

    tmpP:= tmP^.Info.PointHead^.Adr;
    while tmpP <> nil do
    begin
      x := tmpP^.Info.x;
      y := tmpP^.Info.y;
      if magnetizeWithFigures(head, tmpP) then
      begin
        oldp.x := x;
        oldp.y := y;
        MoveLine(tmp^.Info.PointHead,oldP, tmpP^.Info);
      end;
      NearP := searchNearFigure(head, x,y);
      if NearP <> nil then
      begin
        oldp.x := tmpP^.Info.x;
        oldp.y := tmpP^.Info.y;
        newP.x := nearP.Info.x;
        newP.y := tmpP^.Info.y;
        {currPointAdr^.Info.x := currPointAdr^.Info.x - (TmpX - x);
        currPointAdr^.Info.y := currPointAdr^.Info.y - (Tmpy - y);
        MoveLine(CurrFigure^.Info.PointHead, oldp, currPointAdr^.Info);}
        if abs(tmpP^.Info.x  - nearP.Info.x) < nearFigure then
        begin
          tmpP^.Info := newP;
          MoveLine(tmp^.Info.PointHead,oldP, tmpP^.Info);
        end;
        newP.x := tmpP^.Info.x;
        newP.y := nearP.Info.y;
        if abs(tmpP^.Info.y - nearP.Info.y) < nearFigure then
        begin
          tmpP^.Info := newP;
          MoveLine(tmp^.Info.PointHead,oldP, tmpP^.Info);
        end;
      end;
      tmpP := tmpP^.Adr;
    end;


    tmp := tmp^.Adr;
  end;
end;


procedure changeListCoords(head: PPointsList; st:string);
var
  tmp: PPointsList;
  xy: string;
begin
  tmp:= head^.Adr;
  if st <> '' then
  begin
    Delete(st,1,1);
    st := st + '"';
  end;
  while (length(st) <> 0) and (st <> '"') do
  begin
    xy := copy(st, 1, pos('"', st)-1);
    Delete(st,1, pos('"', st)+1);
    if (st <> '') or (xy <> '') then
    begin
      if tmp <> nil then
      begin
        tmp^.Info.x := strtoint(copy(xy, 1,pos('/', xy)-1));
        tmp^.Info.y :=  strtoint(copy(xy, pos('/', xy)+1, length(xy)));
        tmp := tmp^.Adr;
      end
      else
      begin
        ShowMessage('Error (small)');
        Exit;
      end;

    end;
  end;
end;

procedure undoChanges(UndoRec: TUndoStackInfo; Canvas: TCanvas);
var
  tmp: PFigList;
  tmpP: PPointsList;
begin
  case UndoRec.ChangeType of
    chDelete:
    begin
      tmp := UndoRec.adr;
      tmp.Adr := UndoRec.PrevFigure^.Adr;
      undoRec.PrevFigure^.Adr := tmp;
    end;
    chAddPoint:
    begin
      tmpP:= UndoRec.PrevPointAdr^.adr;
      UndoRec.PrevPointAdr^.Adr := nil;
      Dispose(tmpP);
    end;
    chInsert:
    begin
      removeFigure(EditorForm.getFigureHead, UndoRec.adr)
    end;
    chFigMove:
    begin
      UndoRec.adr^.Info := UndoRec.PrevInfo;
    end;
    chPointMove:
    begin
      changeListCoords(UndoRec.adr^.Info.PointHead, UndoRec.st);
    end;
    chChangeText:
    begin
      UndoRec.adr^.Info.Txt := UndoRec.text;
    end;
    NonDeleted: ;
  end;


end;



end.
