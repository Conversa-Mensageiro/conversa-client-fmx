program Conversa;

uses
  System.StartUpCopy,
  FMX.Forms,
  Conversa.Principal.View in 'src\Conversa.Principal.View.pas' {PrincipalView},
  Conversa.Lista.Item.Frame in 'src\lista\Conversa.Lista.Item.Frame.pas' {ConversaItemFrame: TFrame},
  Conversa.Lista.View in 'src\lista\Conversa.Lista.View.pas' {ConversaListaView},
  Conversa.BatePapo.View in 'src\batepapo\Conversa.BatePapo.View.pas' {ConversaBatePapoView},
  Conversa.Lista.Controller in 'src\lista\Conversa.Lista.Controller.pas' {ConversaListaController: TDataModule},
  Conversa.Base.Controller in 'src\bases\Conversa.Base.Controller.pas' {ConversaBaseController: TDataModule},
  Conversa.Sessao.Lista.Controller in 'src\sessao\Conversa.Sessao.Lista.Controller.pas' {ConversaSessaoListaController: TDataModule},
  Conversa.Sessao.Lista.View in 'src\sessao\Conversa.Sessao.Lista.View.pas' {ConversaSessaoListaView},
  Conversa.Sessao.Item.View in 'src\sessao\Conversa.Sessao.Item.View.pas' {ConversaSessaoItemView},
  Conversa.BatePapo.Controller in 'src\batepapo\Conversa.BatePapo.Controller.pas' {ConversaBatePapoController: TDataModule},
  Conversa.Mensagem.Lista.View in 'src\mensagem\Conversa.Mensagem.Lista.View.pas' {ConversaMensagemListaView},
  Conversa.Mensagem.Item.Base.Frame in 'src\mensagem\Conversa.Mensagem.Item.Base.Frame.pas' {ConversaMensagemItemBaseFrame: TFrame},
  Conversa.Mensagem.Item.Texto.Frame in 'src\mensagem\Conversa.Mensagem.Item.Texto.Frame.pas' {ConversaMensagemItemTextoFrame: TFrame},
  Conversa.DataSet in 'biblioteca\Conversa.DataSet.pas',
  Conversa.WebSocket in 'biblioteca\Conversa.WebSocket.pas',
  Conversa.Comando in 'biblioteca\Conversa.Comando.pas',
  Conversa.Consulta in 'biblioteca\Conversa.Consulta.pas',
  Conversa.Sessao.Item.Controller in 'src\sessao\Conversa.Sessao.Item.Controller.pas' {ConversaSessaoItemController: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.CreateForm(TPrincipalView, PrincipalView);
  Application.Run;
end.
