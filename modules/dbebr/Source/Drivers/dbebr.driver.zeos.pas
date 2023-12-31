{
  DBE Brasil � um Engine de Conex�o simples e descomplicado for Delphi/Lazarus

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{ @abstract(DBEBr Framework)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <https://www.isaquepinheiro.com.br>)
}

unit dbebr.driver.zeos;

{$ifdef fpc}
  {$mode delphi}{$H+}
{$endif}

interface

uses
  Classes,
  SysUtils,
  DB,
  Variants,
  ZAbstractConnection,
  ZConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZSqlProcessor,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  // Classe de conex�o concreta com dbExpress
  TDriverZeos = class(TDriverConnection)
  protected
    FConnection: TZConnection;
    FSQLScript: TZSQLProcessor;
  public
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName); override;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure ExecuteDirect(const ASQL: string); overload; override;
    procedure ExecuteDirect(const ASQL: string;
      const AParams: TParams); overload; override;
    procedure ExecuteScript(const AScript: string); override;
    procedure AddScript(const AScript: string); override;
    procedure ExecuteScripts; override;
    function IsConnected: Boolean; override;
    function InTransaction: Boolean; override;
    function CreateQuery: IDBQuery; override;
    function CreateResultSet(const ASQL: String): IDBResultSet; override;
  end;

  TDriverQueryZeos = class(TDriverQuery)
  private
    FSQLQuery: TZReadOnlyQuery;
  protected
    procedure SetCommandText(ACommandText: string); override;
    function GetCommandText: string; override;
  public
    constructor Create(AConnection: TZConnection);
    destructor Destroy; override;
    procedure ExecuteDirect; override;
    function ExecuteQuery: IDBResultSet; override;
  end;

  TDriverResultSetZeos = class(TDriverResultSet<TZReadOnlyQuery>)
  public
    constructor Create(ADataSet: TZReadOnlyQuery); override;
    destructor Destroy; override;
    function NotEof: Boolean; override;
    function GetFieldValue(const AFieldName: string): Variant; overload; override;
    function GetFieldValue(const AFieldIndex: Integer): Variant; overload; override;
    function GetFieldType(const AFieldName: string): TFieldType; overload; override;
    function GetField(const AFieldName: string): TField; override;
  end;

implementation

{ TDriverZeos }

constructor TDriverZeos.Create(const AConnection: TComponent;
  const ADriverName: TDriverName);
begin
  inherited;
  FConnection := AConnection as TZConnection;
  FDriverName := ADriverName;
  FSQLScript := TZSQLProcessor.Create(nil);
  try
    FSQLScript.Connection := FConnection;
  except
    FSQLScript.Free;
    raise;
  end;
end;

destructor TDriverZeos.Destroy;
begin
  FConnection := nil;
  FSQLScript.Free;
  inherited;
end;

procedure TDriverZeos.Disconnect;
begin
  inherited;
  FConnection.Connected := False;
end;

procedure TDriverZeos.ExecuteDirect(const ASQL: string);
begin
  inherited;
  FConnection.ExecuteDirect(ASQL);
end;

procedure TDriverZeos.ExecuteDirect(const ASQL: string; const AParams: TParams);
var
  LExeSQL: TZReadOnlyQuery;
  LFor: Integer;
begin
  LExeSQL := TZReadOnlyQuery.Create(nil);
  try
    LExeSQL.Connection := FConnection;
    LExeSQL.SQL.Text   := ASQL;
    for LFor := 0 to AParams.Count - 1 do
    begin
      LExeSQL.ParamByName(AParams[LFor].Name).DataType := AParams[LFor].DataType;
      LExeSQL.ParamByName(AParams[LFor].Name).Value    := AParams[LFor].Value;
    end;
    try
      LExeSQL.Prepare;
      LExeSQL.ExecSQL;
    except
      raise;
    end;
  finally
    LExeSQL.Free;
  end;
end;

procedure TDriverZeos.ExecuteScript(const AScript: string);
begin
  inherited;
  FSQLScript.Script.Text := AScript;
  FSQLScript.Execute;
end;

procedure TDriverZeos.ExecuteScripts;
begin
  inherited;
  try
    FSQLScript.Execute;
  finally
    FSQLScript.Script.Clear;
  end;
end;

procedure TDriverZeos.AddScript(const AScript: string);
begin
  inherited;
  FSQLScript.Script.Add(AScript);
end;

procedure TDriverZeos.Connect;
begin
  inherited;
  FConnection.Connected := True;
end;

function TDriverZeos.InTransaction: Boolean;
begin
  inherited;
  Result := FConnection.InTransaction;
end;

function TDriverZeos.IsConnected: Boolean;
begin
  inherited;
  Result := FConnection.Connected = True;
end;

function TDriverZeos.CreateQuery: IDBQuery;
begin
  Result := TDriverQueryZeos.Create(FConnection);
end;

function TDriverZeos.CreateResultSet(const ASQL: String): IDBResultSet;
var
  LDBQuery: IDBQuery;
begin
  LDBQuery := TDriverQueryZeos.Create(FConnection);
  LDBQuery.CommandText := ASQL;
  Result   := LDBQuery.ExecuteQuery;
end;

{ TDriverDBExpressQuery }

constructor TDriverQueryZeos.Create(AConnection: TZConnection);
begin
  if AConnection = nil then
    Exit;

  FSQLQuery := TZReadOnlyQuery.Create(nil);
  try
    FSQLQuery.Connection := AConnection;
  except
    FSQLQuery.Free;
    raise;
  end;
end;

destructor TDriverQueryZeos.Destroy;
begin
  FSQLQuery.Free;
  inherited;
end;

function TDriverQueryZeos.ExecuteQuery: IDBResultSet;
var
  LResultSet: TZReadOnlyQuery;
  LFor: Integer;
begin
  LResultSet := TZReadOnlyQuery.Create(nil);
  try
    LResultSet.Connection := FSQLQuery.Connection;
    LResultSet.SQL.Text := FSQLQuery.SQL.Text;

    for LFor := 0 to FSQLQuery.Params.Count - 1 do
    begin
      LResultSet.Params[LFor].DataType := FSQLQuery.Params[LFor].DataType;
      LResultSet.Params[LFor].Value    := FSQLQuery.Params[LFor].Value;
    end;
    LResultSet.Open;
  except
    LResultSet.Free;
    raise;
  end;
  Result := TDriverResultSetZeos.Create(LResultSet);
  if LResultSet.RecordCount = 0 then
     Result.FetchingAll := True;
end;

function TDriverQueryZeos.GetCommandText: string;
begin
  Result := FSQLQuery.SQL.Text;
end;

procedure TDriverQueryZeos.SetCommandText(ACommandText: string);
begin
  inherited;
  FSQLQuery.SQL.Text := ACommandText;
end;

procedure TDriverQueryZeos.ExecuteDirect;
begin
  FSQLQuery.ExecSQL;
end;

{ TDriverResultSetZeos }

constructor TDriverResultSetZeos.Create(ADataSet: TZReadOnlyQuery);
begin
  FDataSet:= ADataSet;
  inherited;
end;

destructor TDriverResultSetZeos.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

function TDriverResultSetZeos.GetFieldValue(const AFieldName: string): Variant;
var
  LField: TField;
begin
  LField := FDataSet.FieldByName(AFieldName);
  Result := GetFieldValue(LField.Index);
end;

function TDriverResultSetZeos.GetField(const AFieldName: string): TField;
begin
  Result := FDataSet.FieldByName(AFieldName);
end;

function TDriverResultSetZeos.GetFieldType(const AFieldName: string): TFieldType;
begin
  Result := FDataSet.FieldByName(AFieldName).DataType;
end;

function TDriverResultSetZeos.GetFieldValue(const AFieldIndex: Integer): Variant;
begin
  if AFieldIndex > FDataSet.FieldCount -1  then
    Exit(Variants.Null);

  if FDataSet.Fields[AFieldIndex].IsNull then
     Result := Variants.Null
  else
  begin
    case FDataSet.Fields[AFieldIndex].DataType of
      ftString,
      ftWideString: Result := FDataSet.Fields[AFieldIndex].AsString;
    else
      Result := FDataSet.Fields[AFieldIndex].Value;
    end;

  end;
end;

function TDriverResultSetZeos.NotEof: Boolean;
begin
  if not FFirstNext then
     FFirstNext := True
  else
     FDataSet.Next;

  Result := not FDataSet.Eof;
end;

end.
