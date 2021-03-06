﻿namespace RemObjects.Elements.RTL;

interface

type
  PlatformImmutableStack<T> = public {$IF COOPER}java.util.Stack<T>{$ELSEIF ECHOES}System.Collections.Generic.Stack<T>{$ELSEIF ISLAND}RemObjects.Elements.System.Stack<T>{$ELSEIF TOFFEE}Foundation.NSArray<T>{$ENDIF};
  PlatformStack<T> = public {$IF COOPER}java.util.Stack<T>{$ELSEIF ECHOES}System.Collections.Generic.Stack<T>{$ELSEIF ISLAND}RemObjects.Elements.System.Stack<T>{$ELSEIF TOFFEE}Foundation.NSMutableArray<T>{$ENDIF};

  ImmutableStack<T> = public class mapped to PlatformImmutableStack<T>
  public
    constructor; mapped to constructor();

    method Contains(Item: T): Boolean;
    method Peek: T;
    method ToArray: array of T;

    property Count: Integer read {$IF COOPER}mapped.size{$ELSEIF ECHOES OR TOFFEE OR ISLAND}mapped.Count{$ENDIF};

    method UniqueCopy: ImmutableStack<T>;
    method UniqueMutableCopy: Stack<T>;
    method MutableVersion: Stack<T>;
  end;

  Stack<T> = public class(ImmutableStack<T>) mapped to PlatformStack<T>
  public
    constructor; mapped to constructor();

    method Clear;
    method Pop: T;
    method Push(Item: T);
  end;

implementation

method ImmutableStack<T>.Contains(Item: T): Boolean;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.Contains(Item);
  {$ELSE}
  exit Foundation.NSMutableArray(mapped).containsObject(NullHelper.coalesce(Item, NSNull.null));
  {$ENDIF}
end;

method ImmutableStack<T>.Peek: T;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.Peek;
  {$ELSE}
  var n := Foundation.NSMutableArray(mapped).lastObject;
  if n = nil then raise new StackEmptyException;
  if n = NSNull.null then n := nil;
  result := n;
  {$ENDIF}
end;

method ImmutableStack<T>.ToArray: array of T;
begin
  {$IF COOPER}
  exit ListHelpers.ToArrayReverse<T>(mapped, new T[Count]);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToArray;
  {$ELSEIF TOFFEE}
  exit ListHelpers.ToArrayReverse<T>(self);
  {$ENDIF}
end;

method ImmutableStack<T>.UniqueCopy: ImmutableStack<T>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := UniqueMutableCopy();
  {$ELSEIF TOFFEE}
  result := mapped.copy;
  {$ENDIF}
end;

method ImmutableStack<T>.UniqueMutableCopy: Stack<T>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := new Stack<T>();
  for each k in mapped do
    result.Push(k);
  {$ELSEIF TOFFEE}
  result := mapped.mutableCopy;
  {$ENDIF}
end;

method ImmutableStack<T>.MutableVersion: Stack<T>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := self;
  {$ELSEIF TOFFEE}
  if self is NSMutableArray then
    result := self as NSMutableArray<T>
  else
    result := mapped.mutableCopy;
  {$ENDIF}
end;

method Stack<T>.Clear;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  mapped.Clear;
  {$ELSE}
  mapped.removeAllObjects;
  {$ENDIF}
end;

method Stack<T>.Pop: T;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.Pop;
  {$ELSE}
  var n := Foundation.NSMutableArray(mapped).lastObject;
  if n = nil then raise new StackEmptyException;
  if n = NSNull.null then n := nil;
  mapped.removeLastObject;
  result := n;
  {$ENDIF}
end;

method Stack<T>.Push(Item: T);
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  mapped.Push(Item);
  {$ELSE}
  Foundation.NSMutableArray(mapped).addObject(NullHelper.coalesce(Item, NSNull.null));
  {$ENDIF}
end;

end.