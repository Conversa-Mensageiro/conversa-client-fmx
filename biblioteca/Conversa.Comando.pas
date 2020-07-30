// Eduardo - 09/07/2020
(*
   - Exemplo de uma chamada do cliente para o servidor ou do servidor para o cliente
{
  "recurso": "conversa.mensagem", // (classe, tabela, diretorio) local do recurso - obrigatorio
  "dados": [                      // lista dos dados da requisicao - opcional
    {
      "campo": "id",
      "operador": "=",
      "valor": 1
    },
    {
      "campo": "nome",
      "operador": "like",
      "valor": "eduardo%"
    },
  ]
}

   - Toda requisição do cliente para o servidor deve haver uma resposta
   - Nenhuma requisição do servidor ao cliente deve ter resposta
{
  "recurso": "conversa.mensagem", // (classe, tabela, diretorio) local do recurso que foi solicitado (não alterado) - obrigatorio
  "dados": [3, 2, 1]              // lista dos dados da resposta - opcional
}

  - Caso ocorra erro no servidor, será retornado
{
  "recurso": "conversa.mensagem", // (classe, tabela, diretorio) local do recurso que foi solicitado (não alterado) - obrigatorio
  "erro": [                       // par identificador do erro, o servidor não tratará erros vindos do usuário
    {
      "classe": "TException",           // classe do erro
      "mensagem": "Access Violation."   // mensagem de erro
    }
  ]
}
*)

unit Conversa.Comando;

interface

uses
  System.JSON,
  System.SysUtils,
  System.Generics.Collections;

type
  TErro = record
    Classe: String;
    Mensagem: String;
  end;

  TComando = class
  private
    FjaDados: TJSONArray;
    FRecurso: String;
    FResposta: Boolean;
    function GetTexto: String;
    procedure SetTexto(const Valor: String);
    function GetDados: TJSONArray;
    procedure SetRecurso(const Value: String);
  public
    Erro: TErro;
    property Texto: String read GetTexto write SetTexto;
    property Recurso: String read FRecurso write SetRecurso;
    property Dados: TJSONArray read GetDados;
    constructor Create(sTexto: String = ''); overload;
    constructor Create(Clone: TComando); overload;
    destructor Destroy; override;
  end;

implementation

{ TProtocolo }

constructor TComando.Create(sTexto: String = '');
begin
  FResposta := False;
  if not sTexto.IsEmpty then
    SetTexto(sTexto);
end;

constructor TComando.Create(Clone: TComando);
begin
  Self.Recurso := Clone.Recurso;
  FResposta := True;
end;

destructor TComando.Destroy;
begin
  if Assigned(FjaDados) then
    FreeAndNil(FjaDados);
  inherited;
end;

function TComando.GetDados: TJSONArray;
begin
  if not Assigned(FjaDados) then
    FjaDados := TJSONArray.Create;
  Result := FjaDados;
end;

function TComando.GetTexto: String;
var
  joComando: TJSONObject;
begin
  joComando := TJSONObject.Create;
  try
    joComando.AddPair('recurso', FRecurso);

    if Erro.Classe.IsEmpty and Erro.Mensagem.IsEmpty then
      joComando.AddPair('dados', TJSONArray(GetDados.Clone))
    else
      joComando.AddPair('erro',
        TJSONObject.Create
          .AddPair('classe',   Erro.Classe)
          .AddPair('mensagem', Erro.Mensagem)
      );

    Result := joComando.ToJSON;
  finally
    FreeAndNil(joComando);
  end;
end;

procedure TComando.SetRecurso(const Value: String);
begin
  if FResposta then
    raise Exception.Create('Alteração de recurso não disponível na resposta!');
  FRecurso := Value;
end;

procedure TComando.SetTexto(const Valor: String);
var
  oComando: TJSONObject;
begin
  oComando := TJSONObject(TJSONObject.ParseJSONValue(Valor));
  try
    if not Assigned(oComando) then
      raise Exception.Create('Erro ao converter os dados para JSON: '+ Valor);

    try
      if not Assigned(oComando.GetValue('recurso')) then
        raise Exception.Create('Erro ao obter o recurso!');
    except on E: Exception do
      begin
        if Assigned(oComando) then
          FreeAndNil(oComando);
      end;
    end;

    FRecurso := oComando.GetValue('recurso').Value;

    if Assigned(oComando.GetValue('erro')) then
    begin
      Erro.Classe   := oComando.GetValue<String>('erro.classe');
      Erro.Mensagem := oComando.GetValue<String>('erro.mensagem');
      Exit;
    end;

    if Assigned(FjaDados) then
      FreeAndNil(FjaDados);

    if Assigned(oComando.GetValue('dados')) and (oComando.GetValue('dados') is TJSONArray) then
      FjaDados := TJSONArray(oComando.GetValue('dados').Clone)
    else
      FjaDados := TJSONArray.Create;
  finally
    FreeAndNil(oComando);
  end;
end;

end.
