// Daniel Araujo - 12/07/2020
unit Conversa.Sessao.Item.View;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Types,

  Conversa.Conexao.Banco_Dados,
  Conversa.Lista.View;

type
  TConversaSessaoItemView = class(TForm)
    lytConversaSessaoItemView: TLayout;
    rctgConversaSessaoItemView: TRectangle;
    tbcSessao: TTabControl;
    tiConversasLista: TTabItem;
    tiConversasItem: TTabItem;
    lytSessaoClient: TLayout;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FConversaListaView: TConversaListaView;
    FConexaoBancoDados: TConversaConexaoBancoDados;
  public
    { Public declarations }
    constructor Create(AOwner: TTabItem); reintroduce; overload;
  end;

var
  ConversaSessaoItemView: TConversaSessaoItemView;

implementation

{$R *.fmx}

{ TConversaSessaoItemView }

constructor TConversaSessaoItemView.Create(AOwner: TTabItem);
begin
  inherited Create(AOwner);

  if Assigned(AOwner) then
  begin
    Parent := TFmxObject(AOwner);
    lytConversaSessaoItemView.Parent := TFmxObject(AOwner);
  end
  else
    ShowModal;
end;

procedure TConversaSessaoItemView.FormCreate(Sender: TObject);
begin
  FConexaoBancoDados := TConversaConexaoBancoDados.Create(Self);


  FConversaListaView := TConversaListaView.Create(Self, FConexaoBancoDados);
  FConversaListaView.Parent := tiConversasLista;
  FConversaListaView.lytForm_Conversas.Parent := tiConversasLista;
  FConversaListaView.CarregarConversas;

  tbcSessao.ActiveTab := tiConversasLista;
end;

end.
