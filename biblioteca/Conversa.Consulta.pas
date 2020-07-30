// Eduardo - 12/07/2020
(*
 - Exemplo de preparo da consulta
var
  consulta: TConsulta;
begin
  consulta := TConsulta.Create;
  try
    consulta.IgualNumero('id', 1);
    consulta.Contem('nome', 'eduardo%');
    consulta.EntreData('cast(data as date)', '2020-07-09', '2020-07-12');
  finally
    FreeAndNil(consulta);
  end;
end;

 - Exemplo do objeto JSON montado
{
  "campo": "id",
  "tipo": "numero",
  "operador": "igual",
  "valor": 1
},
{
  "campo": "nome",
  "tipo": "texto",
  "operador": "contem",
  "valor": "eduardo%"
},
{
  "campo": "cast(data as date)",
  "tipo": "data",
  "operador": "entre",
  "valor": ["2020-07-09", "2020-07-12"]
}

- Exemplo da pesquisa SQL pronta

id = 1 and nome like 'eduardo%' and cast(data as date) between '2020-07-09' and '2020-07-12'

*)
unit Conversa.Consulta;

interface

uses
  System.JSON;

type
  TConsulta = class
  private
    FjaConsulta: TJSONArray;
    function ObtemOperadorSQL(sOperador: String): String;
  public
    function IgualTexto(sCampo: String; sValor: String): TConsulta; overload;
    function IgualNumero(sCampo: String; dValor: Double): TConsulta; overload;
    function IgualData(sCampo: String; dValor: TDateTime): TConsulta; overload;
    function Contem(sCampo: String; sValor: String): TConsulta;
    function EntreNumero(sCampo: String; dInicio, dFim: Double): TConsulta; overload;
    function EntreData(sCampo: String; dInicio, dFim: TDateTime): TConsulta; overload;
    function EmTexto(sCampo: String; sItems: TArray<String>): TConsulta; overload;
    function EmNumero(sCampo: String; dItems: TArray<Double>): TConsulta; overload;
    function EmData(sCampo: String; dItems: TArray<TDateTime>): TConsulta; overload;
    function ENulo(sCampo: String): TConsulta;
    function Texto: String;
    function ParaArray(jaArray: TJSONArray): TConsulta;
    constructor Create(jaConsulta: TJSONArray = nil);
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  System.DateUtils,
  System.StrUtils;

{ TConsulta }

constructor TConsulta.Create(jaConsulta: TJSONArray = nil);
begin
  if Assigned(jaConsulta) then
    FjaConsulta := TJSONArray(jaConsulta.Clone)
  else
    FjaConsulta := TJSONArray.Create;
end;

destructor TConsulta.Destroy;
begin
  if Assigned(FjaConsulta) then
    FreeAndNil(FjaConsulta);
  inherited;
end;

function TConsulta.ObtemOperadorSQL(sOperador: String): String;
begin
  case IndexStr(sOperador, ['igual', 'contem', 'entre', 'em', 'nulo']) of
    0: Result := '=';
    1: Result := 'like';
    2: Result := 'between';
    3: Result := 'in';
    4: Result := 'is null';
  end;
end;

function TConsulta.ParaArray(jaArray: TJSONArray): TConsulta;
var
  jvItem: TJSONValue;
begin
  Result := Self;

  for jvItem in FjaConsulta do
    jaArray.AddElement(TJSONValue(jvItem.Clone));
end;

function TConsulta.IgualTexto(sCampo, sValor: String): TConsulta;
begin
  Result := Self;

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'texto')
      .AddPair('operador', 'igual')
      .AddPair('valor', TJSONString.Create(sValor))
  );
end;

function TConsulta.IgualNumero(sCampo: String; dValor: Double): TConsulta;
begin
  Result := Self;

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'numero')
      .AddPair('operador', 'igual')
      .AddPair('valor', TJSONNumber.Create(dValor))
  );
end;

function TConsulta.IgualData(sCampo: String; dValor: TDateTime): TConsulta;
begin
  Result := Self;

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'data')
      .AddPair('operador', 'igual')
      .AddPair('valor', TJSONString.Create(DateToISO8601(dValor)))
  );
end;

function TConsulta.Contem(sCampo, sValor: String): TConsulta;
begin
  Result := Self;

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'texto')
      .AddPair('operador', 'contem')
      .AddPair('valor', TJSONString.Create(sValor))
  );
end;

function TConsulta.EntreNumero(sCampo: String; dInicio, dFim: Double): TConsulta;
begin
  Result := Self;

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'numero')
      .AddPair('operador', 'entre')
      .AddPair('valor', TJSONArray.Create(TJSONNumber.Create(dInicio), TJSONNumber.Create(dFim)))
  );
end;

function TConsulta.EntreData(sCampo: String; dInicio, dFim: TDateTime): TConsulta;
begin
  Result := Self;

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'data')
      .AddPair('operador', 'entre')
      .AddPair('valor', TJSONArray.Create(TJSONString.Create(DateToISO8601(dInicio)), TJSONString.Create(DateToISO8601(dFim))))
  );
end;

function TConsulta.EmTexto(sCampo: String; sItems: TArray<String>): TConsulta;
var
  jaItems: TJSONArray;
  sItem: String;
begin
  Result := Self;

  jaItems := TJSONArray.Create;
  for sItem in sItems do
    jaItems.AddElement(TJSONString.Create(sItem));

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'texto')
      .AddPair('operador', 'em')
      .AddPair('valor', jaItems)
  );
end;

function TConsulta.EmNumero(sCampo: String; dItems: TArray<Double>): TConsulta;
var
  jaItems: TJSONArray;
  dItem: Double;
begin
  Result := Self;

  jaItems := TJSONArray.Create;
  for dItem in dItems do
    jaItems.AddElement(TJSONNumber.Create(dItem));

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'numero')
      .AddPair('operador', 'em')
      .AddPair('valor', jaItems)
  );
end;

function TConsulta.EmData(sCampo: String; dItems: TArray<TDateTime>): TConsulta;
var
  jaItems: TJSONArray;
  dItem: TDateTime;
begin
  Result := Self;

  jaItems := TJSONArray.Create;
  for dItem in dItems do
    jaItems.AddElement(TJSONString.Create(DateToISO8601(dItem)));

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'data')
      .AddPair('operador', 'em')
      .AddPair('valor', jaItems)
  );
end;

function TConsulta.ENulo(sCampo: String): TConsulta;
begin
  Result := Self;

  FjaConsulta.AddElement(
    TJSONObject.Create
      .AddPair('campo', sCampo)
      .AddPair('tipo', 'nulo')
      .AddPair('operador', 'nulo')
      .AddPair('valor', TJSONNull.Create)
  );
end;

function TConsulta.Texto: String;
var
  jvItem: TJSONValue;
  jvaItem: TJSONValue;
  sCampo: String;
  sOperador: String;
  sValor: String;
begin
  for jvItem in FjaConsulta do
  begin
    sCampo := TJSONString(TJSONObject(jvItem).GetValue('campo')).Value;
    sOperador := ObtemOperadorSQL(TJSONString(TJSONObject(jvItem).GetValue('operador')).Value);
    sValor := EmptyStr;
    case IndexStr(TJSONString(TJSONObject(jvItem).GetValue('tipo')).Value, ['texto', 'numero', 'data', 'nulo']) of
      0:
      begin
        if TJSONObject(jvItem).GetValue('valor') is TJSONString then
          sValor := QuotedStr(TJSONString(TJSONObject(jvItem).GetValue('valor')).Value)
        else
        if TJSONObject(jvItem).GetValue('valor') is TJSONArray then
        begin
          for jvaItem in TJSONArray(TJSONObject(jvItem).GetValue('valor')) do
            sValor := IfThen(not sValor.IsEmpty, sValor +',') + QuotedStr(TJSONString(jvaItem).Value);
          sValor := '('+ sValor +')';
        end;
      end;
      1:
      begin
        if TJSONObject(jvItem).GetValue('valor') is TJSONNumber then
          sValor := ReplaceStr(FloatToStr(TJSONNumber(TJSONObject(jvItem).GetValue('valor')).AsDouble), ',', '.')
        else
        if TJSONObject(jvItem).GetValue('valor') is TJSONArray then
        begin
          for jvaItem in TJSONArray(TJSONObject(jvItem).GetValue('valor')) do
            sValor := IfThen(not sValor.IsEmpty, sValor +',') + ReplaceStr(FloatToStr(TJSONNumber(jvaItem).AsDouble), ',', '.');
          sValor := '('+ sValor +')';
        end;
      end;
      2:
      begin
        if TJSONObject(jvItem).GetValue('valor') is TJSONString then
          sValor := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', ISO8601ToDate(TJSONString(TJSONObject(jvItem).GetValue('valor')).Value)))
        else
        if TJSONObject(jvItem).GetValue('valor') is TJSONArray then
        begin
          for jvaItem in TJSONArray(TJSONObject(jvItem).GetValue('valor')) do
            sValor := IfThen(not sValor.IsEmpty, sValor +',') + QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', ISO8601ToDate(TJSONString(jvaItem).Value)));
          sValor := '('+ sValor +')';
        end;
      end;
      3:
      begin
        sValor := 'is null';
      end;
    end;
    Result := IfThen(not Result.IsEmpty, Result +' and ') + sCampo +' '+ sOperador +' '+ sValor;
  end;
end;

end.
