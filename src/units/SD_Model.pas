unit SD_Model;
// MODEL par in MVC:
// responsible for processing information
interface

uses SD_types, vcl.graphics, SD_View,vcl.dialogs, SD_InitData, math, SVGUtils;
function isHorisontalIntersection(head: PFigList; blocked: PPointsList): boolean;
 function getClickFigure(x,y:integer; head: PFigList):PFigList;
 procedure removeFigure(head: PFigList; adr: PFigList);
 procedure selectFigure(canvas: TCanvas; head:PFigList);
 function readFile(const head:PFigList; filedir:string):boolean;
 procedure saveToFile(Head: PFigList; filedir: string);
 procedure removeAllList(head:PFigList);
 procedure ChangeCoords(F: PFigList; EM: TEditMode; x,y:integer; var TmpX, TmpY: integer);
 procedure checkLineCoords(head: PPointsList);
 procedure addNewPoint(var head: PPointsList; x,y:integer);
 procedure createFigList(var head: PFigList);
 function addLine(head: PFigList; x,y: integer):PFigList;
 function searchNearFigure(head: PFigList; var x,y: integer):PPointsList;
 function addFigure(head: PFigList; x,y: integer; ftype: TType; Text:String = 'Kek'):PFigList;
 function nearRound(x:integer):integer;
 procedure roundCoords(var x,y:integer);
 function getEditMode(status: TDrawMode; x,y: Integer; head: PFigList) :TEditMode;
 procedure checkFigureCoord(R: PFigList);

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
      if tmp^.info.PointHead = nil then exit;

      tmpP := tmp^.Info.PointHead^.adr;
      while (tmpP <> nil) and (tmpP^.adr <> nil) do
      begin

        ti1 := tmpP^.Info;
        ti2 := tmpP^.adr.Info;
        if (nearRound(ti1.x) = nearRound( blocked.Info.x ))
        and (nearRound(ti2.x) = nearRound( blocked.Info.x ))
        and (nearRound( blocked.Info.y ) < max(nearRound(ti1.y), nearRound(ti2.y)))
        and (nearRound( blocked.Info.y ) > min(nearRound(ti1.y), nearRound(ti2.y)))
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
        { ToDo: KEK }
        if (searchNearFigure(FigHead, x,y) <> nil) then
        begin
          CurrFigure := temp;
          Result := LineMove;
          Exit;
        end;

        tmpPoint := tmpPoint^.Adr;
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
        if (nearRound(MaxX) = nearRound(x))
            and
           (nearRound(y) > nearRound(minY))
            and
           (nearRound(y) < nearRound(maxY)) then
        begin
          x := MaxX;
          Result := tmpP;
          exit;

        end;

        if (nearRound(MinX) = nearRound(x))
            and
           (nearRound(y) > nearRound(minY))
            and
           (nearRound(y) < nearRound(maxY)) then
        begin
          x := MinX;
          Result := tmpP;

          exit;
        end;

        if (nearRound(MaxY) = nearRound(y))
            and
           (nearRound(x) > nearRound(minx))
            and
           (nearRound(x) < nearRound(maxx)) then
        begin
          y := MaxY;
          Result := tmpP;
          exit;
        end;

        if (nearRound(MinY) = nearRound(Y))
            and
           (nearRound(X) > nearRound(minX))
            and
           (nearRound(X) < nearRound(maxX)) then
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

procedure addNewPoint(var head: PPointsList; x,y:integer);
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
    except on E: Exception do

    end;
  end;
  new(tmp^.adr);
  tmp := tmp^.adr;
  tmp^.Info.x := x;
  tmp^.Info.y := y;

  tmp^.Adr := nil;
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
    tmp := head^.Info.PointHead^.adr;
    while tmp <> nil do
    begin
      drawSelectLineVertex(canvas,tmp^.info);
      tmp := tmp^.Adr;
    end;
  end;
end;


procedure saveToFile(Head: PFigList; filedir: string);
var f: file of TFigureInFile;
  temp: PFigList;
  tmpPoints: PPointsList;
  tempRec: TFigureInFile;
  st: string[255];
begin
  AssignFile(f, filedir);
  rewrite(f);
  tempRec.tp := TTYPE(4);
  EditorForm.getCanvasSIze(tempRec.Width,tempRec.Height);
  tempRec.Check := 'BRAKH';
  Write(f, tempRec);
  temp := head^.adr;
  while temp <> nil do
  begin
    tempRec.tp := temp^.Info.tp;
    if tempRec.tp = Line then
    begin
      tmpPoints := temp^.Info.PointHead^.adr;
      st := '';
      while tmpPoints <> nil do
      begin
        st := st + ShortString('"' + IntToStr(tmpPoints.Info.x) + '/' + IntToStr(tmpPoints.Info.y) +'"');
        tmpPoints := tmpPoints^.Adr;
      end;
      //showMessage(String(st));
      tempRec.Point := st;
      tempRec.LT := temp^.Info.LT;
      tempRec.tp := Line;
    end
    else
    begin
      tempRec.txt := temp^.Info.Txt;
      tempRec.x1 := temp^.Info.x1;
      tempRec.x2 := temp^.Info.x2;
      tempRec.y1 := temp^.Info.y1;
      tempRec.y2 := temp^.Info.y2;
    end;

    write(f, tempRec);
    temp:=temp^.adr;
  end;
  close(F);
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

function readFile(const head:PFigList; filedir:string):boolean;
var
  f: file of TFigureInFile;
  OTemp: PFigList;
  tmp: TFigureInFile;
  ptemp: PPointsList;
  xy: string;
begin
  Result := false;
  AssignFile(f, filedir);
  if fileExists(filedir) then
  begin
    Reset(f);

    //ShowMessage(objfile);
    //Writeln('Read file ' + ObjFile);
    OTemp := Head;
    read(f, tmp);
    if tmp.Check <> 'BRAKH' then
    begin
      close(f);
      ShowMessage(rsInvalidFile);
      exit;
    end;
    EditorForm.changeCanvasSize(tmp.Width,tmp.Height);
    head^.Adr := nil;
    while not EOF(f) do
    begin
      new(OTemp^.adr);
      OTemp:=OTemp^.adr;
      OTemp^.adr:=nil;
      try
        read(f, tmp);
        OTemp^.Info.tp := tmp.tp;
        if tmp.tp = line then
        begin
          //showMessage(tmp.Point);
          OTemp^.Info.tp := line;
          Otemp^.Info.LT := tmp.LT;
          new(OTemp^.Info.PointHead);
          ptemp := OTemp^.Info.PointHead;
          ptemp^.Adr := nil;
          if tmp.Point <> '' then
          begin
            Delete(tmp.Point,1,1);
            tmp.Point := tmp.Point + '"';
          end;
          while (length(tmp.Point) <> 0) and (tmp.Point <> '"') do
          begin
            xy := copy(tmp.point,1, pos('"', tmp.Point)-1);
            Delete(tmp.point,1, pos('"', tmp.Point)+1);
            if (tmp.Point <> '') or (xy <> '') then
            begin
              new(ptemp^.Adr);
              ptemp := ptemp^.Adr;
              ptemp^.Adr := nil;
              ptemp^.Info.x := strtoint(copy(xy, 1,pos('/', xy)-1));
              ptemp^.Info.y := strtoint(copy(xy, pos('/', xy)+1, length(xy)));
            end;
          end;
          result := true;
        end
        else
        begin
          OTemp^.info.txt := tmp.Txt;
          otemp^.info.x1 := tmp.x1;
          otemp^.info.x2 := tmp.x2;
          otemp^.info.y1 := tmp.y1;
          otemp^.info.y2 := tmp.y2;
        end;
      except on E: Exception do
        ShowMessage('Файл поврежден!');
      end;
      //ShowMessage(otemp^.Info.obType);
      //OTemp^.Info
      close(f);
    end;

  end
  else
  begin
    Rewrite(f);
    //Writeln('Create File');
    close(f);
    result := true;
  end;
  EditorForm.SD_Resize;
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
      except on E: Exception do

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

end.
