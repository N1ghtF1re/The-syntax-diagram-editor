unit Model.Lines;

interface
  uses Data.Types, Data.InitData;

  function isHorisontalIntersection(head: PFigList; blocked: PPointsList): boolean;
  function needMiddleArrow(tmp: PPointsList; FirstP: TPointsInfo) :Boolean;
  function addLine(head: PFigList; x,y: integer):PFigList;
  function addNewPoint(var head: PPointsList; x,y:integer):PPointsList;
  function copyPointList(cf: PPointsList):PPointsList;
  function isBelongsLine(head: PPointsList; x,y: integer): Boolean;
  procedure MoveLine(head: PPointsList; oldp, newp: TPointsInfo);
  procedure moveALlLinePoint(head: PPointsList; dx, dy: integer);
  function isHorLine(curr, prev: PPointsList):boolean;
  procedure changeLineCoordsFromStr(head: PPointsList; st:string);
  function searchNearLine(head: PFigList; var x,y: integer):PPointsList;
  procedure removeTrashLines(head: PFigList; curr: PFigList);
  function isvertLine(curr, prev: TPointsInfo): Boolean;
 procedure checkForPointsMerge (head: PPointsList;curr: PPointsList;  deltay, deltax: integer);

implementation
  uses math, System.SysUtils, vcl.dialogs, Model;

// Парсинг строки формата "X1/Y1""X2/Y2"... и имзенение
// Координат списка точек линии на координаты, полученные
// при парсинге
procedure changeLineCoordsFromStr(head: PPointsList; st:string);
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

// Полная копия списка точек
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
    addNewPoint(Result, tmp^.Info.x + CopyShift, tmp^.Info.y + CopyShift);
    tmp := tmp^.Adr;
  end;
end;

// Добавляем линию и возвращаем ссылку на нее
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

  new(tmp^.Info.PointHead); // Создаем список точек
  tmp^.Info.PointHead^.Adr := nil;
  addNewPoint(tmp^.Info.PointHead, x,y); // Добавляем первую точку

  result := tmp; // Возвращаем созданную линию
end;

// Удаление "Мусорных линий" (состоящих из одной точки)
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

      if (tmp^.Info.PointHead^.Adr^.Adr = nil) and (tmp = curr) then
        removeFigure(head,tmp) // Точка - единственная и фигура дорисована => удаляем
      else
      if (tmp^.Info.PointHead^.Adr^.Adr <> nil)
        and
        (tmp^.Info.PointHead^.Adr.Info.x = tmp^.Info.PointHead^.Adr^.adr.Info.x)
        and
        (tmp^.Info.PointHead^.Adr.Info.y = tmp^.Info.PointHead^.Adr^.adr.Info.y)
      then
      begin
        // Добавленно много точек, но все с одними координатами => удаляем :)
        tmp^.Info.PointHead := tmp^.Info.PointHead^.Adr;
        removeTrashLines(head,curr);
      end;
    end;
      tmp := tmp^.Adr;
  end;
end;

// Добавление точки линии
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
      if (arctan(abs((y-py)/(x-px))) < pi/4)  then
        y:=py
      else
        x:=px;
    except on EZeroDivide do

    end;
  end;
  new(tmp^.adr);
  Result := tmp;
  tmp := tmp^.adr;
  tmp^.Info.x := x;
  tmp^.Info.y := y;
  tmp^.Adr := nil;
end;

procedure movePrevPoints(head, curr: PPointsList; oldp: TPointsInfo);
var
  tmp, beginofarea :PPointsList;
  isEnd: boolean;
  isFound:boolean;
begin
  tmp:= head.Adr;
  isend:= false;
  BeginOfArea:= nil;
  isFound := false;
  
  // Поиск начала искомой области
  while (tmp <> nil) and not isEnd do
  begin
    if (tmp^.Info.y = oldp.y) or (tmp^.Info.x = oldp.x) or (tmp = curr) then
    begin
      if BeginOfArea = nil then
        BeginOfArea:= tmp;

      isFound:= true;
      if tmp = curr then
        isEnd := true;
    end
    else
    begin
      BeginOfArea := nil; // Если точка противоречит одному из перечисленных выше условий,
      // то заного ищем начало области
    end;
    if not isEnd then
      tmp := tmp^.Adr;
  end;

  tmp := BeginOfArea;
  // изменение координат точек внутри области
  while (tmp<>nil) and isFound and (tmp <> curr) do
  begin
    if tmp^.Info.y = oldp.y then
      tmp^.Info.y := curr.Info.y;
    if tmp^.Info.x = oldp.x then
      tmp^.Info.x := curr.Info.x;
    tmp := tmp^.Adr;
  end;
end;

// Процедура не допускает "слияния" точек линии
procedure checkForPointsMerge (head: PPointsList;curr: PPointsList;  deltay, deltax: integer);
var
  temp: PPointsList;
  oldP, newP: TPointsInfo;
  coef: Integer;
  isAfter: Boolean; // true, если после перемещаемой точки
begin
  temp := head;
  isAfter := false;
  while temp <> nil do
  begin
    if temp = curr then
      isAfter := true;

    if (temp^.adr <> nil) and (temp^.adr^.Adr <> nil) then
    begin
      if ((temp^.Info.y = temp^.Adr.Info.y) or ((temp^.adr^.adr^.Adr <> nil) and (temp^.Adr.Adr.Adr.Info.y = temp^.Adr.Info.y))) and
         (temp^.Adr.Info.y = temp^.Adr^.Adr.Info.y ) and
         (temp^.Adr.Info.x = temp^.Adr^.Adr.Info.x ) then
      begin

        if deltay > 0 then
          coef := 1
        else
          coef := -1;
        if temp^.Info.y <> temp^.Adr.Info.y then
          isAfter := true;

        if isAfter then
          temp:= temp^.adr
        else
          temp := temp^.adr^.Adr;

        oldP:= temp^.Info;
        temp^.Info.y := temp^.Info.y - 5*coef;
        newP:= temp^.Info;
        if isAfter then
        begin
          movePrevPoints(head, temp, oldp);
          exit;
        end;
        temp := temp^.Adr;
        while (temp <> nil) and ((temp^.Info.y = oldp.y) or (temp^.Info.x = oldp.x)) do
        begin
          if temp^.Info.y = oldp.y then
            temp^.Info.y := newp.y;
          if temp^.Info.x = oldp.x then
            temp^.Info.x := newp.x;
          temp := temp^.Adr;
        end;
        exit;
      end;
      if ((temp^.Info.x = temp^.Adr.Info.x) or ((temp^.adr^.adr^.Adr <> nil) and (temp^.Adr.Adr.Adr.Info.x = temp^.Adr.Info.x))) and
         (temp^.Adr.Info.x = temp^.Adr^.Adr.Info.x ) and
         (temp^.Adr.Info.y = temp^.Adr^.Adr.Info.y ) then
      begin
        oldP:= temp^.adr^.adr^.Info;
        if deltax > 0 then
          coef := 1
        else
          coef := -1;
        if temp^.Info.x <> temp^.Adr.Info.x then
          isAfter := true;

        if isAfter then
          temp:= temp^.adr
        else
          temp := temp^.adr^.Adr;
          
        temp^.Info.x := temp^.Info.x - 5*coef;
        newP:= temp^.Info;
        if isAfter then
        begin
          move(head, temp, oldp);
          exit;
        end;
        temp := temp^.Adr;
        
        while (temp <> nil) and ((temp^.Info.y = oldp.y) or (temp^.Info.x = oldp.x)) do
        begin
          if temp^.Info.y = oldp.y then
            temp^.Info.y := newp.y;
          if temp^.Info.x = oldp.x then
            temp^.Info.x := newp.x;
          temp := temp^.Adr;
        end;
        exit;
      end;
    end;

    temp := temp^.Adr;
  end;
end;


// Процедура превращает линии под углом в вертикальные или горизонтальные
// В зависимости от угла наклона. (Все линии в синтаксических диаграммах
// Должны быть параллельны одной из осей.
procedure checkLineCoords(head: PPointsList);
var
  tmp:PPointsList;
begin
  tmp := head^.adr;
  while tmp^.adr <> NIL do
  begin
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


{Идея алгоритма: найти область линии, все точки которой иметь
либо координату x, либо координату y, равную старому значение
координаты перемещаемой точки. При этом все точки области
должны идти подряд и в области не должно содержаться ни
одной точки, не соответствующих данному условию.
После нахождения области, нужно изменить координаты
каждой точки внутри области.}
procedure MoveLine(head: PPointsList; oldp, newp: TPointsInfo);
var
  tmp: PPointsList;
  BeginOfArea: PPointsList;
  isFound:Boolean;
  isEnd: boolean;
begin
  tmp:=head^.adr;
  isFound := true;
  BeginOfArea := nil;
  isEnd := false;

  // Поиск начала искомой области
  while (tmp <> nil) and not isEnd do
  begin
    if (tmp^.Info.y = oldp.y) or (tmp^.Info.x = oldp.x) or ((tmp^.Info.x = newP.x) and (tmp^.Info.y = newP.y)) then
    begin
      if BeginOfArea = nil then
        BeginOfArea:= tmp;
      isFound:= true;
      if (tmp^.Info.x = newP.x) and (tmp^.Info.y = newP.y) then
        isEnd := true;
    end
    else
    begin
      BeginOfArea := nil; // Если точка противоречит одному из перечисленных выше условий,
      // то заного ищем начало области
    end;
    if not isEnd then
      tmp := tmp^.Adr;
  end;

  tmp := BeginOfArea;
  // изменение координат точек внутри области
  while (tmp<>nil) and isFound and ((tmp^.Info.y = oldp.y) or (tmp^.Info.x = oldp.x) or ((tmp^.Info.x = newP.x) and (tmp^.Info.y = newP.y) )) do
  begin
    if tmp^.Info.y = oldp.y then
      tmp^.Info.y := newp.y;
    if tmp^.Info.x = oldp.x then
      tmp^.Info.x := newp.x;
    tmp := tmp^.Adr;
  end;

end;


// Изменение координат всех точек линии на одинаковое количество
// пикселей
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

// Функция ищет линию вблизи точки и возвращает в x,y точку на прямой
// вблизи исходной точки. Если фигура не нашлась, функция вернет nil
function searchNearLine(head: PFigList; var x,y: integer):PPointsList;
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
        // Перебирает точки фигуры
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

    end;
    temp := temp^.Adr;
  end;
end;




// BOOOLEAN FUNCTIONS

// Возвращает true если линия горизонтальная
function isHorLine(curr, prev: PPointsList):boolean;
begin
  if prev = nil then
    Result := (curr^.Adr <> nil) and (curr^.Info.y = curr^.adr^.Info.y)
  else
    Result := prev^.Info.y = curr^.Info.y;
end;



// Возвращает true если нужна стрелка по середине
function needMiddleArrow(tmp: PPointsList; FirstP: TPointsInfo) :Boolean;
begin
  Result := (tmp^.Adr <> nil) {and (tmp^.adr^.Adr = nil) }and (tmp^.Info.x <> FirstP.x)
        and (tmp^.Info.x = tmp^.adr^.Info.x) and (tmp^.Info.y <> tmp^.adr^.Info.y) //(abs(tmp^.Info.y - tmp^.adr^.Info.y) > Tolerance)
end;


// Возвращает true если нужен диагональный срез
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
          Result := true;
          exit;
        end;
        tmpP:= tmpP^.adr;
      end;
    end;
    tmp := tmp^.Adr;
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

function isvertLine(curr, prev: TPointsInfo): Boolean;
begin
  Result:= (curr.x = prev.x) and (curr.y <> prev.y);  
end;

end.

