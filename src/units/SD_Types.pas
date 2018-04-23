unit SD_Types;

interface
type
  TDrawMode = (Draw, NoDraw, DrawLine);
  TFileMode = (FSvg, FBrakh, FBmp);
  TLineType = (LLine);
  TEditMode = (NoEdit, Move, TSide, BSide, RSide, LSide, Vert1, Vert2, Vert3, Vert4);
  TType = (Def,MetaVar,MetaConst, Line, None);
  //TFigureType = (rect, line);

  // яохянй рнвей мювюкн
  TPointsInfo = record
    x,y: integer;
  end;
  PPointsList = ^TPointsList;
  TPointsList = record
    Info: TPointsInfo;
    Adr:PPointsList;
  end;
  // яохянй рнвей йнмеж

  // яохянй  назейрнб мювюкн
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
  // яохянй назейрнб йнмеж


  TFigureInFile = record
    case tp:TType of
    Def, MetaConst, MetaVar: (Txt: string[255];x1,x2,y1,y2: integer);
    Line: (Point:String[255]; LT: TLineType);
    None: (Check:string[5];Width, Height: Integer;);
  end;

implementation

end.
