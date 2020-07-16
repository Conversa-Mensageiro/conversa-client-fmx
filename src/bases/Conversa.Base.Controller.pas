// Daniel Araujo - 11/07/2020
unit Conversa.Base.Controller;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Comp.Client,
  Conversa.Conexao.Banco_Dados;

type
  TConversaBaseController = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
    ConexaoBancoDados: TConversaConexaoBancoDados;
    constructor Create(AOwner: TComponent); reintroduce; overload;
    constructor Create(AOwner: TComponent; AConexao: TConversaConexaoBancoDados); reintroduce; overload;
  end;

var
  ConversaBaseController: TConversaBaseController;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

constructor TConversaBaseController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RemoveDataModule(Self);
end;

constructor TConversaBaseController.Create(AOwner: TComponent; AConexao: TConversaConexaoBancoDados);
var
  iComponent: Integer;
  Component: TComponent;
begin
  inherited Create(AOwner);
  ConexaoBancoDados := AConexao;

  for iComponent := 0 to Pred(ComponentCount) do
  begin
    Component := Components[iComponent];
    if Assigned(Component) and Component.InheritsFrom(FireDAC.Comp.Client.TFDQuery) then
      FireDAC.Comp.Client.TFDQuery(Component).Connection := ConexaoBancoDados.conConversa;
  end;
end;

end.
