unit SD_Types;

interface
type
  TDrawMode = (Draw, NoDraw, DrawLine);
  TFileMode = (FSvg, FBrakh, FBmp, FPng);
  TLineType = (LLine);
  TEditMode = (NoEdit, Move, TSide, BSide, RSide, LSide, Vert1, Vert2, Vert3, Vert4, LineMove);
  TType = (Def,MetaVar,MetaConst, Line, None);
  //TFigureType = (rect, line);

  // СПИСОК ТОЧЕК НАЧАЛО
  TPointsInfo = record
    x,y: integer;
  end;
  PPointsList = ^TPointsList;
  TPointsList = record
    Info: TPointsInfo;
    Adr:PPointsList;
  end;
  // СПИСОК ТОЧЕК КОНЕЦ

  // СПИСОК  ОБЪЕКТОВ НАЧАЛО
  TFigureInfo = record
    case tp:TType of
    Def, MetaConst, MetaVar: (x1,x2,y1,y2: integer;Txt: string[255];);
    Line: (PointHead: PPointsList; LT: TLineType);
    None: (Check:string[5];Width, Height: Integer;);
  end;
  PFigList = ^FigList;
  FigList = record
    Info: TFigureInfo;
    Adr: PFigList;
  end;
  // СПИСОК ОБЪЕКТОВ КОНЕЦ


  TFigureInFile = record
    case tp:TType of
    Def, MetaConst, MetaVar: (Txt: string[255];x1,x2,y1,y2: integer);
    Line: (Point:String[255]; LT: TLineType);
    None: (Check:string[5];Width, Height: Integer;);
  end;

  // UNDO STACK
  TChangeType = (chDelete, chInsert, chAddPoint,  chFigMove, chPointMove, chChangeText, NonDeleted);
  TUndoStackInfo = record
    adr: PFigList;
  Case ChangeType : TChangeType of
    chDelete: (PrevFigure: PFigList); // Удаление фигуры
    chAddPoint: (PrevPointAdr: PPointsList); // Добавление точки в линии
    chInsert: (); // Добавление фигуры
    chFigMove: (PrevInfo: TFigureInfo); // Перемещение/изменение размеров фигур. PrevInfo - координаты "бэкапа"
    chPointMove: (st: string[255]);
    chChangeText: (text: string[255]);
    NonDeleted: (); // Используется для обозначения последний записи стека, которую нельзя pop
  end;

  PUndoStack = ^TUndoStack;
  TUndoStack = record
    Inf: TUndoStackInfo;
    Prev: PUndoStack;
  end;

  // VIRTUAL KEYS:

implementation

end.

