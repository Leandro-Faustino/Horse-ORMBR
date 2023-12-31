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

unit dbebr.factory.ibobjects;

interface

uses
  DB,
  Classes,
  SysUtils,
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  // F�brica de conex�o concreta com dbExpress
  TFactoryIBObjects = class(TFactoryConnection)
  public
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName); overload;
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName;
      const AMonitorCallback: TMonitorProc); overload;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure Rollback; override;
    procedure ExecuteDirect(const ASQL: string); override;
    procedure ExecuteDirect(const ASQL: string;
      const AParams: TParams); override;
    procedure ExecuteScript(const AScript: string); override;
    procedure AddScript(const AScript: string); override;
    procedure ExecuteScripts; override;
    function InTransaction: Boolean; override;
    function IsConnected: Boolean; override;
    function GetDriverName: TDriverName; override;
    function CreateQuery: IDBQuery; override;
    function CreateResultSet(const ASQL: String): IDBResultSet; override;
  end;

implementation

uses
  dbebr.driver.ibobjects,
  dbebr.driver.ibobjects.transaction;

{ TFactoryIBObjects }

procedure TFactoryIBObjects.Connect;
begin
  if not IsConnected then
    FDriverConnection.Connect;
end;

constructor TFactoryIBObjects.Create(const AConnection: TComponent;
  const ADriverName: TDriverName);
begin
  inherited;
  FDriverConnection  := TDriverIBObjects.Create(AConnection, ADriverName);
  FDriverTransaction := TDriverIBObjectsTransaction.Create(AConnection);
end;

constructor TFactoryIBObjects.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  Create(AConnection, ADriverName);
  FMonitorCallback := AMonitorCallback;
end;

function TFactoryIBObjects.CreateQuery: IDBQuery;
begin
  Result := FDriverConnection.CreateQuery;
end;

function TFactoryIBObjects.CreateResultSet(const ASQL: String): IDBResultSet;
begin
  Result := FDriverConnection.CreateResultSet(ASQL);
end;

destructor TFactoryIBObjects.Destroy;
begin
  FDriverTransaction.Free;
  FDriverConnection.Free;
  inherited;
end;

procedure TFactoryIBObjects.Disconnect;
begin
  inherited;
  if IsConnected then
    FDriverConnection.Disconnect;
end;

procedure TFactoryIBObjects.ExecuteDirect(const ASQL: string);
begin
  inherited;
end;

procedure TFactoryIBObjects.ExecuteDirect(const ASQL: string;
  const AParams: TParams);
begin
  inherited;
end;

procedure TFactoryIBObjects.ExecuteScript(const AScript: string);
begin
  inherited;
end;

procedure TFactoryIBObjects.ExecuteScripts;
begin
  inherited;
end;

function TFactoryIBObjects.GetDriverName: TDriverName;
begin
  inherited;
  Result := FDriverConnection.DriverName;
end;

function TFactoryIBObjects.IsConnected: Boolean;
begin
  inherited;
  Result := FDriverConnection.IsConnected;
end;

function TFactoryIBObjects.InTransaction: Boolean;
begin
  Result := FDriverTransaction.InTransaction;
end;

procedure TFactoryIBObjects.StartTransaction;
begin
  inherited;
  FDriverTransaction.StartTransaction;
end;

procedure TFactoryIBObjects.AddScript(const AScript: string);
begin
  inherited;
  FDriverConnection.AddScript(AScript);
end;

procedure TFactoryIBObjects.Commit;
begin
  FDriverTransaction.Commit;
  inherited;
end;

procedure TFactoryIBObjects.Rollback;
begin
  FDriverTransaction.Rollback;
  inherited;
end;

end.