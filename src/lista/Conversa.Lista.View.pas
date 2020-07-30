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
  Conversa.Sessao.Item.Controller,
  Conversa.Lista.Item.Frame,
  Conversa.Lista.Controller;

type
  TConversaListaView = class(TForm)
    lytForm_Conversas: TLayout;
    rctgBackground: TRectangle;
    vsbItems: TVertScrollBox;
    lytItems: TLayout;
    Button1: TButton;
    lytBarraTopo: TLayout;
    rctBarraTopo: TRectangle;
    lytClientBarraTopo: TLayout;
    lytFotoPerfilConta: TLayout;
    Circle1: TCircle;
    lytPesquisa: TLayout;
    RoundRect1: TRoundRect;
    lytEdtPesquisa: TLayout;
    edtPesquisa: TEdit;
    lbEditPesquisaPrompt: TLabel;
    SpeedButton1: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vsbItemsResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edtPesquisaEnter(Sender: TObject);
    procedure edtPesquisaExit(Sender: TObject);
    procedure edtPesquisaChange(Sender: TObject);
  private
    { Private declarations }
    FConversaListaController: TConversaListaController;
    FConversas: TDictionary<Double, TConversaItemFrame>;
    FAoAbrirBatePapo: TProc<Double>;
    procedure CorrigirPosicaoLayoutItems;
    procedure CorrigirAlturaLayoutItems;
    procedure LimparLista;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; ASessaoController: TConversaSessaoItemController); reintroduce; overload;
    procedure CarregarConversas;
    function AoAbrirBatePapo(pAoAbrirConversa: TProc<Double>): TConversaListaView;
  end;

var
  ConversaListaView: TConversaListaView;

implementation

{$R *.fmx}

{ TForm1 }

constructor TConversaListaView.Create(AOwner: TComponent; ASessaoController: TConversaSessaoItemController);
begin
  inherited Create(AOwner);
  FConversaListaController := TConversaListaController.Create(Self, ASessaoController.WebSocket);
end;

procedure TConversaListaView.edtPesquisaChange(Sender: TObject);
begin
  lbEditPesquisaPrompt.Visible := edtPesquisa.Text.Trim.IsEmpty;
end;

procedure TConversaListaView.edtPesquisaEnter(Sender: TObject);
begin
  lbEditPesquisaPrompt.Visible := False;
end;

procedure TConversaListaView.edtPesquisaExit(Sender: TObject);
begin
  lbEditPesquisaPrompt.Visible := edtPesquisa.Text.Trim.IsEmpty;
end;

function TConversaListaView.AoAbrirBatePapo(pAoAbrirConversa: TProc<Double>): TConversaListaView;
begin
  Result := Self;
  FAoAbrirBatePapo := pAoAbrirConversa;
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
  with FConversaListaController.cdsConversa do
  try
    WSOpen;
    First;
    while not Eof do
    try
      cifItem            := TConversaItemFrame.Create(lytItems);
      cifItem.Parent     := lytItems;
      cifItem.Position.Y := - lytItems.Height; //lytItems.Height + (cifItem.Height * 2);
      cifItem.Align      := TAlignLayout.Top;
      cifItem.Name       := 'Conversa_'+ FieldByName('id').AsString;

      cifItem
        .ID(FieldByName('id').AsFloat)
        .Descricao(FieldByName('descricao').AsString)
        .Mensagem(FieldByName('conteudo').AsString)
        .DataConversa(FieldByName('msg_incluido_em').AsDateTime)
        .Qtd(FieldByName('qtd').AsInteger)
        .AoAbrirBatePapo(FAoAbrirBatePapo);

      FConversas.Add(FieldByName('id').AsFloat, cifItem);
    finally
      Next;
    end;
      CorrigirPosicaoLayoutItems;
      CorrigirAlturaLayoutItems;
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
  FConversas.Clear;
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
