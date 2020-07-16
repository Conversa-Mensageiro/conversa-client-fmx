// Daniel Araujo - 12/07/2020
unit Conversa.Sessao.Lista.Controller;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,

  Conversa.Base.Controller,
  Conversa.Conexao.Banco_Dados;

type
  TConversaSessaoListaController = class(TConversaBaseController)
    qrySessoesAtivas: TFDQuery;
    qrySessoesAtivasid: TFDAutoIncField;
    qrySessoesAtivasnome: TStringField;
    qrySessoesAtivasapelido: TStringField;
    qrySessoesAtivasemail: TStringField;
    qrySessoesAtivasusuario: TStringField;
    qrySessoesAtivassenha: TStringField;
    qrySessoesAtivasconectado: TIntegerField;
    qrySessoesAtivasactive: TIntegerField;
  private
  public
    { Public declarations }
    procedure CarregarSessoesAtivas;
  end;

var
  ConversaSessaoListaController: TConversaSessaoListaController;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TConversaSessaoListaController }

procedure TConversaSessaoListaController.CarregarSessoesAtivas;
begin
  qrySessoesAtivas.Connection := ConexaoBancoDados.conConversa;
  qrySessoesAtivas.Close;
  qrySessoesAtivas.Open;
end;

end.
