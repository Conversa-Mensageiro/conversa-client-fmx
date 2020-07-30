// Daniel Araujo - 17/07/2020
unit Conversa.BatePapo.Controller;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Data.DB,
  Datasnap.DBClient,

  Conversa.Consulta,
  Conversa.DataSet,
  Conversa.Base.Controller;

type
  TConversaBatePapoController = class(TConversaBaseController)
    cdsMensagem: TClientDataSet;
    cdsMensagemid: TFloatField;
    cdsMensagemmensagem_id: TFloatField;
    cdsMensagemusuario_id: TFloatField;
    cdsMensagemconversa_id: TFloatField;
    cdsMensagemconteudo: TBlobField;
    cdsMensagemresposta: TIntegerField;
    cdsMensagemconfirmacao: TIntegerField;
    cdsMensagemincluido_id: TFloatField;
    cdsMensagemincluido_em: TDateTimeField;
    cdsMensagemalterado_id: TIntegerField;
    cdsMensagemalterado_em: TDateTimeField;
    cdsMensagemexcluido_id: TIntegerField;
    cdsMensagemexcluido_em: TDateTimeField;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ObterMensagens(iIDConversa: Double);
  end;

var
  ConversaBatePapoController: TConversaBatePapoController;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TConversaBatePapoController.DataModuleCreate(Sender: TObject);
begin
  cdsMensagem.WSCreate(WebSocket, 'mensagem');
end;

procedure TConversaBatePapoController.ObterMensagens(iIDConversa: Double);
begin
  cdsMensagem.WSOpen(TConsulta.Create.IgualNumero('conversa_id', iIDConversa));
end;

end.
