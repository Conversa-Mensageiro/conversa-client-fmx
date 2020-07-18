program Conversa;

uses
  System.StartUpCopy,
  FMX.Forms,
  Conversa.Principal.View in 'src\Conversa.Principal.View.pas' {PrincipalView},
  Conversa.Lista.Item.Frame in 'src\lista\Conversa.Lista.Item.Frame.pas' {ConversaItemFrame: TFrame},
  Conversa.Lista.View in 'src\lista\Conversa.Lista.View.pas' {ConversaListaView},
  Conversa.BatePapo.View in 'src\batepapo\Conversa.BatePapo.View.pas' {ConversaBatePapoView},
  Conversa.Conexao.Banco_Dados in 'src\conexao_basedados\Conversa.Conexao.Banco_Dados.pas' {ConversaConexaoBancoDados: TDataModule},
  Conversa.Lista.Controller in 'src\lista\Conversa.Lista.Controller.pas' {ConversaListaController: TDataModule},
  Conversa.Base.Controller in 'src\bases\Conversa.Base.Controller.pas' {ConversaBaseController: TDataModule},
  Conversa.Dispositivo.Controller in 'src\dispositivo\Conversa.Dispositivo.Controller.pas' {ConversaDispositivoController: TDataModule},
  FMX.ZDeviceInfo in 'src\dispositivo\lib\FMX.ZDeviceInfo.pas',
  Conversa.Sessao.Lista.Controller in 'src\sessao\Conversa.Sessao.Lista.Controller.pas' {ConversaSessaoListaController: TDataModule},
  Conversa.Sessao.Lista.View in 'src\sessao\Conversa.Sessao.Lista.View.pas' {ConversaSessaoListaView},
  Conversa.Sessao.Item.View in 'src\sessao\Conversa.Sessao.Item.View.pas' {ConversaSessaoItemView},
  Conversa.BatePapo.Controller in 'src\batepapo\Conversa.BatePapo.Controller.pas' {ConversaBatePapoController: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.CreateForm(TPrincipalView, PrincipalView);
  Application.Run;
end.
