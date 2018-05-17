unit Model.UndoStack;

interface

uses Data.Types; // in SD_Types - declaration of Stack type
 procedure CreateStack(var adr: PUndoStack);
 procedure UndoStackPush(var Vertex: PUndoStack; info: TUndoStackInfo);
 function undoStackPop(var Vertex: PUndoStack; var rec: TUndoStackInfo):boolean;
 function isStackEmpty(Vertex: PUndoStack): Boolean;
 procedure UndoStackClear(var vertex: PUndoStack);

implementation
uses vcl.dialogs;

// Создание стека
procedure CreateStack(var adr: PUndoStack);
begin
  new(adr);
  adr^.Prev := nil;
  adr^.Inf.ChangeType := NonDeleted; // Всегда самый последний элемент, нельзя удалять
end;

// Добавление элемента в стек и перемещение вершины на новый элемент
procedure UndoStackPush(var Vertex: PUndoStack; info: TUndoStackInfo);
var
  tmp: PUndoStack;
begin
  if Info.ChangeType = NonDeleted then
  begin
    ShowMessage('Error'); // NonDelete - только самый последний элемент стека
  end
  else
  begin
    new(tmp);
    tmp^.Prev := vertex;
    vertex := tmp;  // Перемещение вершины
    tmp^.Inf := info;
  end;
end;

// Если стек пуст, возвращает false, иначе
// Извлекает из стека одного элеменат, возвращает запись в переменную rec
// И перемещение вершины стека на предыдущий элемент
function undoStackPop(var Vertex: PUndoStack; var rec: TUndoStackInfo):boolean;
var
  tmp: PUndoStack;
begin
  Result := true;
  if (vertex^.Inf.ChangeType <> NonDeleted) then // Если стек не пуст
  begin
    tmp := vertex;
    rec := tmp^.Inf;
    Vertex := tmp^.Prev; // Перемещение вершины
    Dispose(tmp);
  end
  else
    Result := false;
end;


// Возвращает true если стек пуст
function isStackEmpty(Vertex: PUndoStack): Boolean;
begin
  Result := Vertex^.Inf.ChangeType = NonDeleted;
end;

// Очистка стека
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
