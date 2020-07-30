unit Conversa.Sessao.Item.Controller;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,

  Conversa.Comando,
  Conversa.Consulta,
  Conversa.WebSocket,
  Conversa.Base.Controller;

type
  TConversaSessaoItemController = class(TConversaBaseController)
  private
    { Private declarations }
    //FUserID: Integer;
    FSenha: String;
    FUsuario: string;
    FUsuario_ID: Double;
    procedure AoReceber(W: TWebSocketClient; S: String);
    procedure SetSenha(const Value: String);
    procedure SetUsuario(const Value: string);
    procedure SetUsuario_ID(const Value: Double);
    function DadosAutenticacao: TJSONObject;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); reintroduce;
    property Usuario_ID: Double read FUsuario_ID write SetUsuario_ID;
    property Usuario: string read FUsuario write SetUsuario;
    property Senha: String read FSenha write SetSenha;
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TDataModule1 }

constructor TConversaSessaoItemController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  WebSocket := TWebSocketClient.Create(Self);
  WebSocket.Conectar('ws://localhost:82');
  WebSocket.AoReceber(AoReceber);
  WebSocket.AoAutenticar(DadosAutenticacao);
  WebSocket.AoErro(
    procedure (Erro: TClass; Mensagem: String)
    begin
      if Erro = ErroAutenticar then
        raise Exception.Create(Mensagem)
      else
      if Erro = ErroReconectar then
        raise Exception.Create(Mensagem)
    end
  );

end;

function TConversaSessaoItemController.DadosAutenticacao: TJSONObject;
begin
  Result := TJSONObject.Create.AddPair('usuario', FUsuario).AddPair('senha',   FSenha);
end;

procedure TConversaSessaoItemController.SetSenha(const Value: String);
begin
  FSenha := Value;
end;

procedure TConversaSessaoItemController.SetUsuario(const Value: string);
begin
  FUsuario := Value;
end;

procedure TConversaSessaoItemController.SetUsuario_ID(const Value: Double);
begin
  FUsuario_ID := Value;
end;

procedure TConversaSessaoItemController.AoReceber(W: TWebSocketClient; S: String);
var
  cmdNotificacao: TComando;
begin
  cmdNotificacao := TComando.Create;
  try
    cmdNotificacao.Texto := S;
    //ShowMessage(cmdNotificacao.Texto);
  finally
    FreeAndNil(cmdNotificacao);
  end;
end;

end.
