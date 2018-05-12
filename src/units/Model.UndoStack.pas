unit Model.UndoStack;

interface

uses SD_Types; // in SD_Types - declaration of Stack type
 procedure CreateStack(var adr: PUndoStack);
 procedure UndoStackPush(var Vertex: PUndoStack; info: TUndoStackInfo);
 function undoStackPop(var Vertex: PUndoStack; var rec: TUndoStackInfo):boolean;
 function isStackEmpty(Vertex: PUndoStack): Boolean;
 procedure UndoStackClear(var vertex: PUndoStack);

implementation
uses vcl.dialogs;

procedure CreateStack(var adr: PUndoStack);
begin
  new(adr);
  adr^.Prev := nil;
  adr^.Inf.ChangeType := NonDeleted;
end;

procedure UndoStackPush(var Vertex: PUndoStack; info: TUndoStackInfo);
var
  tmp: PUndoStack;
begin
  if Info.ChangeType = NonDeleted then
  begin
    ShowMessage('Error');
  end
  else
  begin
    new(tmp);
    tmp^.Prev := vertex;
    vertex := tmp;
    tmp^.Inf := info;
  end;
end;

function undoStackPop(var Vertex: PUndoStack; var rec: TUndoStackInfo):boolean;
var
  tmp: PUndoStack;
begin
  Result := true;
  if (vertex^.Inf.ChangeType <> NonDeleted) then
  begin
    tmp := vertex;
    rec := tmp^.Inf;
    Vertex := tmp^.Prev;
    Dispose(tmp);
  end
  else
    Result := false;
end;

function isStackEmpty(Vertex: PUndoStack): Boolean;
begin
  Result := Vertex^.Inf.ChangeType = NonDeleted;
end;

procedure UndoStackClear(var vertex: PUndoStack);
var
  tmp: PUndoStack;
begin
  while vertex.Inf.ChangeType <> NonDeleted do
  begin
    tmp := vertex;
    vertex := vertex.Prev;
    Dispose(tmp);
  end;
end;

end.
