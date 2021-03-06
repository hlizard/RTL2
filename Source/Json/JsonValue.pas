﻿namespace RemObjects.Elements.RTL;

interface

type
  JsonValue<T> = public abstract class(JsonNode)
  public
    constructor(aValue: not nullable T);

    [ToString]
    method ToString: String; override;
    {$IF TOFFEE}
    method isEqual(obj: id): Boolean; override;
    {$ELSE}
    method &Equals(Obj: Object): Boolean; override;
    {$ENDIF}
    {$IF COOPER}
    method hashCode: Integer; override;
    {$ENDIF}
    {$IF ECHOES OR ISLAND}
    method GetHashCode: Integer; override;
    {$ENDIF}
    {$IF TOFFEE}
    method hash: Foundation.NSUInteger; override;
    {$ENDIF}

    property Value: not nullable T;
    operator Implicit(aValue: JsonValue<T>): T;
  end;

  JsonStringValue = public class(JsonValue<not nullable String>)
  public
    method ToJson: String; override;
    operator Implicit(aValue: not nullable String): JsonStringValue;
    operator Equal(aLeft: JsonStringValue; aRight: Object): Boolean;
    operator Equal(aLeft: Object; aRight: JsonStringValue): Boolean;

    //property StringValue: String read Value write Value; override;
  end;

  JsonIntegerValue = public class(JsonValue<Int64>)
  public
    method ToJson: String; override;
    operator Implicit(aValue: Int64): JsonIntegerValue;
    operator Implicit(aValue: Int32): JsonIntegerValue;
    operator Implicit(aValue: JsonIntegerValue): JsonFloatValue;

    {$IF NOT COOPER}
    //75131: Can't declare multiple cast operators on Java
    operator Implicit(aValue: JsonIntegerValue): not nullable Int32;
    operator Implicit(aValue: JsonIntegerValue): not nullable Double;
    operator Implicit(aValue: JsonIntegerValue): not nullable Single;
    {$ENDIF}
    //operator Explicit(aValue: JsonIntegerValue): JsonFloatValue;
    //property IntegerValue: Integer read Value write Value; override;
    //property FloatValue: Double read Value write inherited IntegerValue; override;
    //property StringValue: String read ToJson write ToJson; override;
  end;

  JsonFloatValue = public class(JsonValue<Double>)
  public
    method ToJson: String; override;
    operator Implicit(aValue: Double): JsonFloatValue;
    operator Implicit(aValue: Single): JsonFloatValue;
    operator Implicit(aValue: JsonFloatValue): Single;
    //property FloatValue: Double read Value write Value; override;
    //property IntegerValue: Int64 read Value write Value; override;
    //property StringValue: String read ToJson write ToJson; override;
  end;

  JsonBooleanValue = public class(JsonValue<Boolean>)
  public
    method ToJson: String; override;
    operator Implicit(aValue: Boolean): JsonBooleanValue;
    //property BooleanValue: Boolean read Value write Value; override;
    //property StringValue: String read ToJson write ToJson; override;
  end;

  JsonNullValue = public class(JsonValue<Boolean>)
  public
    method ToJson: String; override;
    class property Null: JsonNullValue := new JsonNullValue(false); lazy;
  end;

implementation

{ JsonValue<T> }

constructor JsonValue<T>(aValue: not nullable T);
begin
  Value := aValue;
end;

method JsonValue<T>.ToString: String;
begin
  result := Value.ToString;
end;

{$IF TOFFEE}
method JsonValue<T>.isEqual(Obj: id): Boolean;
begin
  if (Obj = nil) or (not (Obj is JsonValue<T>)) then
    exit false;

  exit self.Value.Equals(JsonValue<T>(Obj).Value);
end;

{$ELSE}
method JsonValue<T>.&Equals(Obj: Object): Boolean;
begin
  if (Obj = nil) or (not (Obj is JsonValue<T>)) then
    exit false;

  exit self.Value.Equals(JsonValue<T>(Obj).Value);
end;
{$ENDIF}
{$IF TOFFEE}
method JsonValue<T>.hash: Foundation.NSUInteger;
begin
  exit if self.Value = nil then -1 else self.Value.GetHashCode;
end;
{$ENDIF}
{$IF COOPER}
method JsonValue<T>.hashCode: Integer;
begin
  exit if self.Value = nil then -1 else self.Value.GetHashCode;
end;
{$ENDIF}
{$IF ECHOES OR ISLAND}
method JsonValue<T>.GetHashCode: Integer;
begin
  exit if self.Value = nil then -1 else self.Value.GetHashCode;
end;
{$ENDIF}

operator JsonValue<T>.Implicit(aValue: JsonValue<T>): T;
begin
  result := aValue:Value;
end;

{operator JsonValue<T>.Explicit(aValue: JsonValue<T>): T;
begin
  result := aValue:Value;
end;}

{ JsonStringValue }

method JsonStringValue.ToJson: String;
begin
  var sb := new StringBuilder;

  for i: Int32 := 0 to Value.Length-1 do begin
    var c := Value[i];
    case c of
      '\': sb.Append("\\");
      '"': sb.Append('\"');
      #8: sb.Append('\b');
      #9: sb.Append('\t');
      #10: sb.Append('\n');
      #12: sb.Append('\f');
      #13: sb.Append('\r');
      #32..#33,
      #35..#91,
      #93..#127: sb.Append(c);
      else sb.Append('\u'+Convert.ToHexString(Int32(c), 4));
    end;
  end;

  result := JsonConsts.STRING_QUOTE+sb.ToString()+JsonConsts.STRING_QUOTE;
end;

operator JsonStringValue.Implicit(aValue: not nullable String): JsonStringValue;
begin
  result := new JsonStringValue(aValue);
end;

operator JsonStringValue.&Equal(aLeft: JsonStringValue; aRight: Object): Boolean;
begin
  if not assigned(aLeft) and not assigned(aRight) then exit true;
  if not assigned(aLeft) then exit false;
  if not assigned(aRight) then exit false;
  if aRight is String then exit aLeft.Value = aRight as String;
  if aRight is JsonStringValue then exit aLeft.Value = (aRight as JsonStringValue).Value;
end;

operator JsonStringValue.&Equal(aLeft: Object; aRight: JsonStringValue): Boolean;
begin
  result := aRight = aLeft;
end;

{ JsonIntegerValue }

method JsonIntegerValue.ToJson: String;
begin
  result := Convert.ToString(Value);
end;

operator JsonIntegerValue.Implicit(aValue: Int64): JsonIntegerValue;
begin
  result := new JsonIntegerValue(aValue);
end;

operator JsonIntegerValue.Implicit(aValue: Int32): JsonIntegerValue;
begin
  result := new JsonIntegerValue(aValue);
end;

operator JsonIntegerValue.Implicit(aValue: JsonIntegerValue): JsonFloatValue;
begin
  result := new JsonFloatValue(aValue.Value);
end;

{$IF NOT COOPER}
operator JsonIntegerValue.Implicit(aValue: JsonIntegerValue): not nullable Int32;
begin
  result := aValue.Value;
end;

operator JsonIntegerValue.Implicit(aValue: JsonIntegerValue): not nullable Double;
begin
  result := aValue.Value;
end;

operator JsonIntegerValue.Implicit(aValue: JsonIntegerValue): not nullable Single;
begin
  result := aValue.Value;
end;
{$ENDIF}

{operator JsonIntegerValue.Explicit(aValue: JsonIntegerValue): JsonFloatValue;
begin
  result := new JsonFloatValue(aValue.Value);
end;}

{ JsonFloatValue }

method JsonFloatValue.ToJson: String;
begin
  result := Convert.ToStringInvariant(Value).Replace(",","");
  if not result.Contains(".") and not result.Contains("E") and not result.Contains("N") and not result.Contains("I") then result := result+".0";
end;

operator JsonFloatValue.Implicit(aValue: Double): JsonFloatValue;
begin
  result := new JsonFloatValue(aValue);
end;

operator JsonFloatValue.Implicit(aValue: Single): JsonFloatValue;
begin
  result := new JsonFloatValue(aValue);
end;

operator JsonFloatValue.Implicit(aValue: JsonFloatValue): Single;
begin
  result := aValue.Value;
end;

{ JsonBooleanValue }

method JsonBooleanValue.ToJson: String;
begin
  result := if Value as Boolean then JsonConsts.TRUE_VALUE else JsonConsts.FALSE_VALUE;
end;

operator JsonBooleanValue.Implicit(aValue: Boolean): JsonBooleanValue;
begin
  result := new JsonBooleanValue(aValue);
end;

{ JsonNullValue }

method JsonNullValue.ToJson: String;
begin
  result := JsonConsts.NULL_VALUE;
end;

end.