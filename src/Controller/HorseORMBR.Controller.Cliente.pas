unit HorseORMBR.Controller.Cliente;

interface

uses
  Horse,
  GBJSOn.Interfaces,
  System.JSON,
  HorseORMBR.Model.Cliente,
  HorseORMBR.DAO.Cliente,
  System.Generics.Collections,
  HorseORMBR.DAO.dataModule;

procedure ClienteRegistry;

implementation

procedure Update(Req : THorseRequest; Res : THorseResponse);
var
  LCliente : TCliente;
  LDAO : TDAOCliente;
  LDM : TDMConection;
  Lid : Integer;
begin
  LDM := TDMConection.Create(nil);
  Lid := Req.Params.Field('id').asInteger;
  try
    LDAO := TDAOCliente.Create(LDM.FDConnection);
    try
      LCliente := LDAO.find(LID);  //carrego Objeto
      LDAO.Modify(LCliente);       //armazena estado

      TGBJSONDefault.Serializer<TCliente>.JsonObjectToObject(LCliente,Req.Body<TJSONObject>);
      LDAO.Update(LCliente);
      LCliente.free;
      Res.Status(204);
    finally
      LDAO.free;
    end;
  finally
    LDM.free;
  end;
end;


procedure Delete(Req : THorseRequest; Res : THorseResponse);
var
  LCliente : TCliente;
  LDAO : TDAOCliente;
  LDM : TDMConection;
  Lid : Integer;
begin
  LDM := TDMConection.Create(nil);
  Lid := Req.Params.Field('id').asInteger;
  try
    LDAO := TDAOCliente.Create(LDM.FDConnection);
    try
      LCliente := LDAO.find(Lid);
      LDAO.delete(LCliente);
      LCliente.free;
      Res.Status(204);
    finally
      LDAO.free;
    end;
  finally
    LDM.free;
  end;
end;


procedure Insert(Req : THorseRequest; Res : THorseResponse);
var
  LCliente : TCliente;
  LDAO : TDAOCliente;
  LDM : TDMConection;
begin
  LDM := TDMConection.Create(nil);
  try
    LDAO := TDAOCliente.Create(LDM.FDConnection);
    try
      LCliente := TGBJSONDefault.Serializer<TCliente>.JsonStringToObject(Req.Body);
      LDAO.Insert(LCliente);
      LCliente.free;
    finally
      LDAO.free;
    end;
  finally
    LDM.free;
  end;
end;

procedure Find(Req : THorseRequest; Res : THorseResponse);
var
  LCliente : TCliente;
  Lid : Integer;
  LDAO : TDAOCliente;
  LDM : TDMConection;
begin
  Lid := Req.Params.Field('id').asInteger;
  LDM := TDMConection.Create(nil);
  try
    LDAO := TDAOCliente.Create(LDM.FDConnection);
    try
      LCliente := LDAO.find(Lid);
      Res.Send(TGBJSONDefault.Deserializer.ObjectToJsonObject(LCliente));
      LCliente.free;
    finally
      LDAO.free;
    end;
  finally
    LDM.free;
  end;
end;

procedure ListAll(Req : THorseRequest; Res : THorseResponse);
var
  LClientes : TObjectList<TCliente>;
  LDAO : TDAOCliente;
  LDM : TDMConection;
begin
  LDM := TDMConection.Create(nil);
  try
    LDAO := TDAOCliente.Create(LDM.FDConnection);
    try
      LClientes := LDAO.ListAll;
      Res.Send(TGBJSONDefault.Deserializer<TCliente>
               .ListToJSONArray(LClientes));
      LClientes.free;
    finally
      LDAO.free;
    end;
  finally
    LDM.free;
  end;
end;

procedure ClienteRegistry;
begin
  THorse
    .Get('cliente', ListAll)
    .Get('cliente/:id', Find)
    .Post('cliente', insert)
    .Delete('cliente/:id', Delete)
    .Put('cliente/:id', Update);
end;

end.
