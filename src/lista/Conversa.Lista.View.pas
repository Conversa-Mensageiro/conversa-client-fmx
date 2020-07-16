// Daniel Araujo - 10/07/2020
unit Conversa.Lista.View;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.ListBox,
  FMX.ListView,
  FMX.ListView.Adapters.Base,
  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  Conversa.Conexao.Banco_Dados,
  Conversa.Lista.Item.Frame,
  Conversa.Lista.Controller;

type
  TConversaListaView = class(TForm)
    lytForm_Conversas: TLayout;
    rctgBackground: TRectangle;
    vsbItems: TVertScrollBox;
    lytItems: TLayout;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vsbItemsResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FConversaListaController: TConversaListaController;
    FConversas: TDictionary<Double, TConversaItemFrame>;
    procedure CorrigirPosicaoLayoutItems;
    procedure CorrigirAlturaLayoutItems;
    procedure LimparLista;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AConexaoBancoDados: TConversaConexaoBancoDados); reintroduce; overload;
    procedure CarregarConversas;
  end;

var
  ConversaListaView: TConversaListaView;

implementation

{$R *.fmx}

{ TForm1 }

constructor TConversaListaView.Create(AOwner: TComponent; AConexaoBancoDados: TConversaConexaoBancoDados);
begin
  inherited Create(AOwner);
  FConversaListaController := TConversaListaController.Create(Self, AConexaoBancoDados);
end;

procedure TConversaListaView.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to 9 do
  begin
    CarregarConversas;
    Application.ProcessMessages;
    Sleep(1000);
  end;
end;

procedure TConversaListaView.CarregarConversas;
var
  cifItem: TConversaItemFrame;
begin
  LimparLista;
  with FConversaListaController.qryConversa do
  try
    Open;
    First;
    while not Eof do
    try
      cifItem            := TConversaItemFrame.Create(lytItems);
      cifItem.Parent     := lytItems;
      cifItem.Position.Y := lytItems.Height + (cifItem.Height * 2);
      cifItem.Align      := TAlignLayout.Top;
      FConversas.Add(FieldByName('id').AsFloat, cifItem);
      cifItem.Name       := 'Conversa_'+ FieldByName('id').AsString;

      cifItem
        .Descricao(FieldByName('descricao').AsString)
        .Mensagem(FieldByName('conteudo').AsString)
        .DataConversa(FieldByName('data').AsDateTime)
        .Qtd(FieldByName('qtd').AsInteger);

      CorrigirPosicaoLayoutItems;
      CorrigirAlturaLayoutItems;
    finally
      Next;
    end;
  finally
    Close;
  end;
end;

procedure TConversaListaView.FormCreate(Sender: TObject);
begin
  FConversas := TDictionary<Double, TConversaItemFrame>.Create;
end;

procedure TConversaListaView.FormDestroy(Sender: TObject);
begin
  FConversas.DisposeOf;
end;

procedure TConversaListaView.LimparLista;
var
  Item: Integer;
  ITemC: TConversaItemFrame;
begin
  for Item := 0 to Pred(FConversas.Count) do
  begin
    if FConversas.TryGetValue(Item, ItemC) then
      ItemC.DisposeOf;

    FConversas.Remove(ITem);
  end;
end;

procedure TConversaListaView.vsbItemsResize(Sender: TObject);
begin
  CorrigirPosicaoLayoutItems;
end;

procedure TConversaListaView.CorrigirPosicaoLayoutItems;
begin
  lytItems.Position.X := 0;
  lytItems.Position.Y := 0;
  lytItems.Width      := vsbItems.Width - 20;
end;

procedure TConversaListaView.CorrigirAlturaLayoutItems;
begin
  if FConversas.Count = 0 then
  begin
    lytItems.Height := 10;
    Exit;
  end;

  lytItems.Height := FConversas.Items[1].Height * FConversas.Count;
end;

end.
