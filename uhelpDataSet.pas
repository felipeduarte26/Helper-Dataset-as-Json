unit uhelpDataSet;


interface

uses
  System.JSON,
  System.JSON.Types,
  REST.Json,
  System.JSON.Writers,
  System.JSON.Readers,
  System.JSON.Builders,
  System.Classes,
  Data.DB,
  System.SysUtils,
  DBCommon,
  FireDAC.Comp.Client;



type
  TDatasetHelper = class helper for TDataSet
  public
    function AsJSON: TJSONObject;

  end;

implementation

{ TDatasetHelper }

function TDatasetHelper.AsJSON: TJSONObject;
var StringWriter: TStringWriter;
    Writer: TJsonTextWriter;
    tableName :string;
    I : Integer;
    ArrayJson:Boolean;
begin
      Result := nil;

      if(Assigned(Self) and Self.IsEmpty = False)then
      begin

         tableName := GetTableNameFromSQL((Self as TFDQuery).SQL.Text);
         ArrayJson := Self.RecordCount > 1;

         StringWriter := TStringWriter.Create();
         try
            Writer := TJsonTextWriter.Create(StringWriter);
            try
               Writer.WriteStartObject;

               if(ArrayJson)then
               begin
                 Writer.WritePropertyName(tableName);
                 Writer.WriteStartArray;
               end;

               Self.First;
               while Not Self.Eof do
               begin

                  if(ArrayJson)then
                    Writer.WriteStartObject;

                  for I := 0 to Pred(Self.Fields.Count)do
                  begin
                      Writer.WritePropertyName(Self.Fields.Fields[I].FieldName.ToUpper.Trim);

                      if(Self.Fields.Fields[i].IsNull = False)then
                      begin

                          case Self.Fields.Fields[I].DataType of

                             ftString, ftWideString, ftWideMemo, ftMemo:Writer.WriteValue(Self.Fields.Fields[I].AsString);
                             ftLargeint, ftInteger, ftSmallint, ftAutoInc : Writer.WriteValue(Self.Fields.Fields[I].AsInteger);
                             ftFloat, ftCurrency, ftBCD, ftSingle : Writer.WriteValue(Self.Fields.Fields[I].AsFloat);

                             ftDate, ftDateTime:
                             begin
                               if(Self.Fields.Fields[I].AsFloat > 0)then
                                Writer.WriteValue(Self.Fields.Fields[I].AsDateTime)
                               else
                                Writer.WriteNull;
                             end;
                          end;
                      end else
                       Writer.WriteNull;
                  end;

                  if(ArrayJson)then
                    Writer.WriteEndObject;

                  Self.Next;
               end;

               if(ArrayJson)then
                 Writer.WriteEndArray;

               Writer.WriteEndObject;
               Result := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(StringWriter.ToString),0) as TJSONObject;
            finally
              FreeAndNil(Writer);
            end;
         finally
           FreeAndNil(StringWriter);
         end;
      end;
end;
end.
