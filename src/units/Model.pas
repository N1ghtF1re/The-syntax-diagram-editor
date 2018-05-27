unit Model;
// MODEL par in MVC:
// responsible for processing information
interface

uses Data.Types, vcl.graphics, View.Canvas,vcl.dialogs, Data.InitData, math,
    View.SVG, Model.Files, Model.Lines, System.Types;

 function getPointsCount(head: PPointsList):integer;
 function getClickFigure(x,y:integer; head: PFigList):PFigList;
 function removeFigure(head: PFigList; adr: PFigList):PFigList;
 procedure removeAllList(head:PFigList);
 procedure ChangeCoords(F: PFigList; EM: TEditMode; x,y:integer; var TmpX, TmpY: integer; Scale: real);
 procedure createFigList(var head: PFigList);
 function addFigure(head: PFigList; x,y: integer; ftype: TType; Text:String = 'Kek'):PFigList;
 function nearRound(x:integer):integer;
 procedure roundCoords(var x,y:integer);
 function getEditMode(status: TDrawMode; x,y: Integer; head: PFigList; CT: TType) :TEditMode;
 procedure checkFigureCoord(R: PFigList);
 function copyFigure(head: PFigList; copyfigure:PFigList):PFigList;
 procedure MagnetizeLines(head: PFigList);
 function ScaleRound(scale: real; x: integer): integer;
 procedure undoChanges(UndoRec: TUndoStackInfo; Canvas: TCanvas);
 procedure SearchFiguresInOneLine(head, curr: PFigList);
 procedure createSelectList(var head: PSelectFigure);

 procedure removeSelectList(head: PSelectFigure);
 procedure addToSelectList(Fig: PFigList; var Selects: PSelectFigure; Rect: TRect);
 procedure insertSelectsList(head : PSelectFigure; adr: PFigList);

implementation
uses System.Sysutils, main;




procedure createFigList(var head: PFigList);
begin
  new(head);
  head.Adr := nil;
end;


function nearRound(x:integer):integer;
begin
  Result:= round(x/NearFigure)*NearFigure;
end;


// Проверка координат, чтобы выполнялись условия x2 > x1, y2 > y1
// Если условие не выполняется - процедура меняет координаты местами
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

function ScaleRound(scale: real; x: integer):integer;
begin
  Result := Round(X*Scale);
end;


// Создание копии фигуры и возврат ссылки на нее
function copyFigure(head: PFigList; copyfigure:PFigList):PFigList;
var
  newfigure: TFigureInfo;
  tmp: PFigList;
begin
  newfigure := copyfigure^.Info;
  if copyfigure^.Info.tp = Line then
  begin
    newfigure.PointHead := copyPointList(copyfigure^.Info.PointHead);
  end;
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
  if tmp^.Info.tp <> Line then
  begin
    with tmp^.Info do
    begin
      x1 := x1 + CopyShift;
      x2 := x2 + CopyShift;
      y1 := y1 + CopyShift;
      y2 := y2 + CopyShift;
    end;
  end;
  Result := tmp;
end;

// Функция вовзращает тип режима редактирования в зависимости от того,
// Что находится во координатам наведения мыши
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


// Округление координат с заданным шагом.
procedure roundCoords(var x,y:integer);
begin
  x := round(x/step_round)*step_round;
  y := round(y/step_round)*step_round;

  searchNearLine(FigHead, x,y);
end;


// Добавленеие новой фигуры и возврат ссылки на нее
function addFigure(head: PFigList; x,y: integer; ftype: TType; Text:String = 'Kek'):PFigList;
var
  tmp: PFigList;
begin
  tmp := head;
  if Trim(text) = '' then
  Text := 'None';
  while tmp^.adr <> nil do
    tmp := tmp^.Adr;
  new(tmp^.adr);
  tmp := tmp^.Adr;
  tmp^.Adr := nil;
  with tmp^.Info do
  begin
    // По-умолчанию - линия - точка. В дальнейшем - размеры подстроятся под
    // размеры текста (при отрисовке)
    x1 := x;
    x2 := x;
    y1 := y;
    y2 := y;
    Txt := ShortString(text);
    Tp := ftype;
  end;
 
  Result := tmp;
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
      if (x > tmp^.Info.x1)  // Если точка клика принадлежит прямоугольной поверхности
          and                // То возвращаем фигуру
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
      if (tmp^.Info.PointHead = nil) or (tmp^.Info.PointHead^.Adr = nil) then
      begin
        tmp := tmp^.adr;
       continue;
      end;
      tmpP := tmp^.Info.PointHead^.Adr;
      while tmpP <> nil do
      begin
        // Точка пренадлежит вершине
        if (abs(y-tmpP^.Info.x) <= Tolerance) and (abs(x-tmpP^.Info.y) <= Tolerance) then
        begin
          result := tmp;
          exit;
        end;

        if tmpP^.Adr <> nil then
        begin
          // Точка пренадлежит отрезку
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


// Функция выполняет ЛОГИЧЕСКОЕ удаление фигуры и возвращает ссылку
// На предшествующую удаленной фигуру фигуру.
// Потребность в ЛОГИЧЕСКОМ удалении обусловлено тем, что необходимо
// предусмотреть возможность отменить имзенение и восстановить
// фигуру
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
    end
    else
      temp:= temp^.adr;
  end;
end;

// Полностью удалить список фигур (Кроме головы)
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

// Редактирование фигуры и редактирование ее координат
procedure ChangeCoords(F: PFigList; EM: TEditMode; x,y:integer; var TmpX, TmpY: integer; Scale: real);
var
  oldp: TPointsInfo;
  DeltaX, DeltaY: integer;
begin
  DeltaX := Round((TmpX - x)/Scale);
  DeltaY := Round((TmpY - y)/Scale);
  if F <> nil then
  case EM of
    NoEdit:
    begin

    end;
    Move: // Перемещаем объект :)
    begin
      if F^.Info.tp = Line then
      begin
        oldp:= currPointAdr^.Info;
        currPointAdr^.Info.x := currPointAdr^.Info.x - DeltaX;
        currPointAdr^.Info.y := currPointAdr^.Info.y - DeltaY;
        MoveLine(CurrFigure^.Info.PointHead, oldp, currPointAdr^.Info);
        checkForPointsMerge(CurrFigure^.Info.PointHead, currPointAdr, DeltaX, DeltaY);
      end
      else
      begin
        // Смещаем объект
        // TmpX, TmpY - смещение координат относительно прошлого вызова события
        F^.Info.x1 := F^.Info.x1 - DeltaX;
        F^.Info.x2 := F^.Info.x2 - DeltaX;
        F^.Info.y1 := F^.Info.y1 - DeltaY;
        F^.Info.y2 := F^.Info.y2 - DeltaY;
      end;
    end;
    LineMove:
    begin
      moveALlLinePoint(CurrFigure^.Info.PointHead, DeltaX, DeltaY);
    end;
    TSide:
    begin
      // смещаем верхнюю сторону
      F^.Info.y1 := F^.Info.y1 - DeltaY;
    end;
    BSide:
    begin
      // Смещаем нижнюю сторону
       F^.Info.y2 := F^.Info.y2 - DeltaY;
    end;
    RSide:
    begin
      // Смещаем правую сторону
      F^.Info.x2 := F^.Info.x2 - DeltaX;
    end;
    LSide:
    begin
      // Смещаем левую сторону
      F^.Info.x1 := F^.Info.x1 - DeltaX;
    end;
    Vert1:
    begin
      F^.Info.x1 := F^.Info.x1 - DeltaX;
      F^.Info.y1 := F^.Info.y1 - DeltaY;
    end;
    Vert2:
    begin
      F^.Info.x2 := F^.Info.x2 - DeltaX;
      F^.Info.y1 := F^.Info.y1 - DeltaY;
    end;
    Vert3:
    begin
      F^.Info.x1 := F^.Info.x1 - DeltaX;
      F^.Info.y2 := F^.Info.y2 - DeltaY;
    end;
    Vert4:
    begin
      F^.Info.x2 := F^.Info.x2 - DeltaX;
      F^.Info.y2 := F^.Info.y2 - DeltaY;
    end;
  end;
end;

// Функция "Примагничивает" точку к фигуре и возвращает true, если
// "примагничивание" удалось
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
      if (abs( Point^.Info.x - temp^.Info.x1) < NearFigure) // Левая грань
        and
        ( Point^.Info.y < temp^.Info.y2 )
        and
        ( Point^.Info.y > temp^.Info.y1 )
      then
      begin
        Result := true;
        Point^.info.x := temp^.Info.x1;
        point^.Info.y := (temp^.Info.y1 + temp^.Info.y2) div 2;
      end else if (abs( Point^.Info.x - temp^.Info.x2) < NearFigure)  // Правая грань
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

// Поиск фигур, расположенных приблизительно в одну линию
// И изменение координат так, чтобы они оказались точно
// в одной линии
procedure SearchFiguresInOneLine(head, curr: PFigList);
var   
  temp: PFigList;
  CurrY : Integer;
  tempY : integer;
begin
  if curr^.Info.tp = Line then exit;

  with curr^.Info do
  begin
    CurrY := y1 + (y2 - y1) div 2; // Центр по Y переданной фигуры
  end;
  temp := head^.Adr;
  while temp <> nil do
  begin
    if (temp^.Info.tp = line) or (temp = curr) then 
    begin
      temp := temp^.Adr;
      continue;
    end;
    with temp^.Info do
    begin
      tempY := y1 + (y2 - y1) div 2; // Центр по Y текущей фигуры
    end;
    if abs( CurrY - tempY ) < NearFigure then
    begin
      temp^.Info.y1 := curry - (Temp^.Info.y2 - Temp^.Info.y1) div 2;
      temp^.Info.y2 := curry + (Temp^.Info.y2 - Temp^.Info.y1) div 2; 
    end;
    
    temp := temp^.Adr;
  end;
  
end;


// "Примагничивание" линий к другим фигурам
procedure MagnetizeLines(head: PFigList);
var
  tmp: PFigList;
  tmpP: PPointsList;
  NearP: PPointsList;
  x,y : integer;
  oldP, newP: TPointsInfo;
  prevP: PPointsList;
begin
  tmp := head^.adr;
  while tmp <> nil do
  begin
    if tmp^.Info.tp <> Line then
    begin
      SearchFiguresInOneLine(head, tmp); // Пробуем найти фигуры в одну линию
      tmp := tmp^.Adr;
      continue;
    end;
    prevP:=nil;
    tmpP:= tmP^.Info.PointHead^.Adr;
    while tmpP <> nil do
    begin
      x := tmpP^.Info.x;
      y := tmpP^.Info.y;
      // Пробуем примагнитить линию к текстовой фигуре
      if (isHorLine(tmpP, prevP)) and (magnetizeWithFigures(head, tmpP)) then
      begin
        oldp.x := x;
        oldp.y := y;
        MoveLine(tmp^.Info.PointHead,oldP, tmpP^.Info);
        prevP := tmpP;
        tmpP := tmpP^.adr;
        continue;
      end;

      // Пробуем примгнитить линию к другой линии
      NearP := searchNearLine(head, x,y);
      if NearP <> nil then
      begin
        oldp.x := tmpP^.Info.x;
        oldp.y := tmpP^.Info.y;
        newP.x := nearP.Info.x;
        newP.y := tmpP^.Info.y;

        if (abs(tmpP^.Info.x  - nearP.Info.x) < nearFigure) then
        begin
          if (tmpP^.Adr <> nil) and (abs(tmpP^.Adr.Info.x - nearP.Info.x) < NearFigure) then
          begin
            // Запрещаем магнитить тупо вертикальные линии
            tmpP := tmpP^.Adr;
            while (tmpP <> nil) and ((tmpP^.Info.x  - nearP.Info.x) < nearFigure) do
              tmpP := tmpP^.adr;
            if tmpP = nil then break;

          end
          else
          begin
            tmpP^.Info := newP;
            MoveLine(tmp^.Info.PointHead,oldP, tmpP^.Info);
          end;
        end;
        newP.x := tmpP^.Info.x;
        newP.y := nearP.Info.y;
        if abs(tmpP^.Info.y - nearP.Info.y) < nearFigure then
        begin
          if (tmpP^.Adr <> nil) and (abs(tmpP^.Adr.Info.y - nearP.Info.y) < NearFigure) then
          begin
            // Запрещаем магнитить тупо горизонтальные линии
            tmpP := tmpP^.Adr;
            while (tmpP <> nil) and ((tmpP^.Info.y  - nearP.Info.y) < nearFigure) do
              tmpP := tmpP^.adr;
            if tmpP = nil then break;

          end
          else
          begin
            tmpP^.Info := newP;
            MoveLine(tmp^.Info.PointHead,oldP, tmpP^.Info);
          end;
        end;
      end;
      prevP := tmpP;
      tmpP := tmpP^.Adr;
    end;
    tmp := tmp^.Adr;

  end;
end;

// Отмена изменений
procedure undoChanges(UndoRec: TUndoStackInfo; Canvas: TCanvas);
var
  tmp, tmp2: PFigList;
  tmpP: PPointsList;
begin
  case UndoRec.ChangeType of
    chDelete:
    begin
      // Снова возвращаем фигуру (Она не была удалена физически, только логически)
      tmp := UndoRec.adr;
      tmp2 := EditorForm.getFigureHead;
      tmp2 := tmp2;
      while tmp2^.Adr <> nil do
      begin
        tmp2 := tmp2^.adr;
      end;
      new(tmp2^.Adr);
      tmp2 := tmp2^.adr;
      tmp2^.Adr := nil;
      tmp2^.Info := tmp^.Info;
      Dispose(tmp);
    end;
    chAddPoint:
    begin
      // Удаление точки (физическое)
      tmpP:= UndoRec.PrevPointAdr^.adr;
      UndoRec.PrevPointAdr^.Adr := nil;
      Dispose(tmpP);
    end;
    chInsert:
    begin
      // Удаление фигуры
      removeFigure(EditorForm.getFigureHead, UndoRec.adr)
    end;
    chFigMove:
    begin
      // Возврат предыдущих координат фигуры
      UndoRec.adr^.Info := UndoRec.PrevInfo;
    end;
    chPointMove:
    begin
      // Вовзрат предыдущих координат точек линии
      changeLineCoordsFromStr(UndoRec.adr^.Info.PointHead, UndoRec.st);
    end;
    chChangeText:
    begin
      // Возврат предыдущего текста
      UndoRec.adr^.Info.Txt := UndoRec.text;
    end;
    chCanvasSize:
    begin
      // Возврат прошлых размеров полотна
      EditorForm.changeCanvasSize(UndoRec.w, UndoRec.h, false);
    end;
    NonDeleted: // Ничего не делаем :)
    ;
  end;


end;

function getPointsCount(head: PPointsList):integer;
var
temp:PPointsList;
begin
  Result := 0;
  temp := head^.Adr;
  while temp <> nil do
  begin
    inc(Result);
    temp := temp^.Adr;
  end;
end;

procedure createSelectList(var head: PSelectFigure);
begin
  new(head);
  head^.Adr := nil;
end;

procedure removeSelectList(head: PSelectFigure);
var
  temp, temp2: PSelectFigure;
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


procedure swap(var x,y: Integer);
var
temp:  integer;
begin
  temp := x;
  x := y;
  y := temp;
end;

procedure insertSelectsList(head : PSelectFigure; adr: PFigList);
var
  temp: PSelectFigure;
begin
  temp := head;
  while temp^.Adr <> nil do
    temp := temp^.Adr;
  new(temp^.Adr);
  temp := temp^.Adr;
  temP^.Adr := nil;
  temp^.Figure := adr;


end;

procedure addToSelectList(Fig: PFigList; var Selects: PSelectFigure; Rect: TRect);
var
  tempF: PFigList;
  tempS: PSelectFigure;
  tempP: PPointsList;
  temp: Integer;
begin
  If(Rect.Right < rect.Left) then
    swap(Rect.Right, rect.Left);
  if (Rect.Top < rect.Bottom) then
    swap(Rect.Top, rect.Bottom);


  tempF := Fig^.adr;
  while tempF <> nil do
  begin
    if tempF^.Info.tp <> line then
    begin
      with tempf^.Info do
      begin
        if (((x1 < rect.Right) and (x1 > rect.Left))
          or
            ((x2 < rect.Right) and (x2 > rect.Left)))
          and
            (((y1 < rect.Top) and (y1 > rect.Bottom))
          and
            ((y2 < rect.Top) and (y2 > rect.Bottom)))
        then
        begin
          insertSelectsList(Selects, tempF);
        end;
      end;
    end
    else
    begin
      tempP := tempF^.Info.PointHead.Adr;
      while tempP <> nil do
      begin
        with tempP^.Info do
        begin
          if (x < rect.Right) and (x > rect.Left)
              and
             (y < rect.Top) and (y > rect.Bottom)
          then
          begin
            insertSelectsList(Selects, tempF);
            break;
          end;
        end;
        tempP := tempP^.Adr;
      end;
    end;

    tempF := tempF^.Adr;
  end;
end;

end.
