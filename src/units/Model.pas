unit Model;
// MODEL par in MVC:
// responsible for processing information
interface

uses Data.Types, vcl.graphics, View.Canvas,vcl.dialogs, Data.InitData, math,
    View.SVG, Model.Files, Model.Lines;

 function getClickFigure(x,y:integer; head: PFigList):PFigList;
 function removeFigure(head: PFigList; adr: PFigList):PFigList;
 procedure removeAllList(head:PFigList);
 procedure ChangeCoords(F: PFigList; EM: TEditMode; x,y:integer; var TmpX, TmpY: integer);
 procedure createFigList(var head: PFigList);
 function addFigure(head: PFigList; x,y: integer; ftype: TType; Text:String = 'Kek'):PFigList;
 function nearRound(x:integer):integer;
 procedure roundCoords(var x,y:integer);
 function getEditMode(status: TDrawMode; x,y: Integer; head: PFigList; CT: TType) :TEditMode;
 procedure checkFigureCoord(R: PFigList);
 procedure copyFigure(head: PFigList; copyfigure:PFigList);
 procedure MagnetizeLines(head: PFigList);
 function ScaleRound(scale: real; x: integer): integer;
 procedure undoChanges(UndoRec: TUndoStackInfo; Canvas: TCanvas);
 procedure SearchFiguresInOneLine(head, curr: PFigList);

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

  searchNearLine(FigHead, x,y);
  //ShowMessage( IntToStr(x) + ' ' + IntToStr(y) );
end;


// Добавленеие новой фигуры и возврат ссылки на нее
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
      if (abs( Point^.Info.x - temp^.Info.x1) < NearFigure)
        and
        ( Point^.Info.y < temp^.Info.y2 )
        and
        ( Point^.Info.y > temp^.Info.y1 )
      then
      begin
        Result := true;
        Point^.info.x := temp^.Info.x1;
        point^.Info.y := (temp^.Info.y1 + temp^.Info.y2) div 2;
      end else if (abs( Point^.Info.x - temp^.Info.x2) < NearFigure)
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


procedure SearchFiguresInOneLine(head, curr: PFigList);
var   
  temp: PFigList;
  CurrY : Integer;
  tempY : integer;
begin
  with curr^.Info do
  begin
    CurrY := y1 + (y2 - y1) div 2;
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
      tempY := y1 + (y2 - y1) div 2;
    end;
    if abs( CurrY - tempY ) < NearFigure then
    begin
      temp^.Info.y1 := curry - (Temp^.Info.y2 - Temp^.Info.y1) div 2;
      temp^.Info.y2 := curry + (Temp^.Info.y2 - Temp^.Info.y1) div 2; 
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
  prevP: PPointsList;
begin
  tmp := head^.adr;
  while tmp <> nil do
  begin
    if tmp^.Info.tp <> Line then
    begin
      SearchFiguresInOneLine(head, tmp);
      tmp := tmp^.Adr;
      continue;
    end;
    prevP:=nil;
    tmpP:= tmP^.Info.PointHead^.Adr;
    while tmpP <> nil do
    begin
      x := tmpP^.Info.x;
      y := tmpP^.Info.y;
      if (isHorLine(tmpP, prevP)) and (magnetizeWithFigures(head, tmpP)) then
      begin
        oldp.x := x;
        oldp.y := y;
        MoveLine(tmp^.Info.PointHead,oldP, tmpP^.Info);
        tmpP := tmpP^.adr;
        continue;
      end;
      
      NearP := searchNearLine(head, x,y);
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
      prevP := tmpP;
      tmpP := tmpP^.Adr;
    end;
    tmp := tmp^.Adr;

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
      changeLineCoords(UndoRec.adr^.Info.PointHead, UndoRec.st);
    end;
    chChangeText:
    begin
      UndoRec.adr^.Info.Txt := UndoRec.text;
    end;
    chCanvasSize:
    begin
      EditorForm.changeCanvasSize(UndoRec.w, UndoRec.h, false);
    end;
    NonDeleted: ;
  end;


end;



end.
