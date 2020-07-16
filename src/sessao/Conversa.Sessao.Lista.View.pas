// Daniel Araujo - 12/07/2020
unit Conversa.Sessao.Lista.View;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Objects,
  FMX.TabControl,
  FMX.Types,

  Conversa.Conexao.Banco_Dados,
  Conversa.Sessao.Lista.Controller,
  Conversa.Sessao.Item.View;

type
  TConversaSessaoListaView = class(TFrame)
    lytConversaSessaoListaView: TLayout;
    rctgConversaSessaoListaView: TRectangle;
    lytSessoes: TLayout;
    tbcSessoes: TTabControl;
  private
    { Private declarations }
    FSessaoListaController: TConversaSessaoListaController;
    FSessoes: TDictionary<Integer, TConversaSessaoItemView>;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AConexaoBancoDados: TConversaConexaoBancoDados); reintroduce; overload;
    destructor Destroy; override;
    procedure CarregarListaSessoesAtivas;
    procedure IniciarSessao(iID: Integer);
  end;

var
  ConversaSessaoListaView: TConversaSessaoListaView;

implementation

{$R *.fmx}

{ TConversaSessaoListaView }

constructor TConversaSessaoListaView.Create(AOwner: TComponent; AConexaoBancoDados: TConversaConexaoBancoDados);
begin
  inherited Create(AOwner);
  Parent := TFmxObject(AOwner);
  Align := TAlignLayout.Client;

  FSessaoListaController := TConversaSessaoListaController.Create(Self, AConexaoBancoDados);
  FSessoes := TDictionary<Integer, TConversaSessaoItemView>.Create;
end;

destructor TConversaSessaoListaView.Destroy;
begin
  FSessoes.DisposeOf;
  inherited;
end;

procedure TConversaSessaoListaView.CarregarListaSessoesAtivas;
begin
  FSessaoListaController.CarregarSessoesAtivas;
  FSessaoListaController.qrySessoesAtivas.First;
  while not FSessaoListaController.qrySessoesAtivas.Eof do
  try
    IniciarSessao(FSessaoListaController.qrySessoesAtivas.FieldByName('id').AsInteger);
  finally
    FSessaoListaController.qrySessoesAtivas.Next;
  end;
end;

procedure TConversaSessaoListaView.IniciarSessao(iID: Integer);
var
  tbciSessao: TTabItem;
begin
  tbciSessao := tbcSessoes.Add(TTabItem);
  TConversaSessaoItemView.Create(tbciSessao).lytSessaoClient.Parent := tbciSessao;
  tbcSessoes.ActiveTab := tbciSessao;
end;

end.
