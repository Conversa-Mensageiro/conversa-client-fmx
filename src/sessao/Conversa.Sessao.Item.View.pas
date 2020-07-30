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

  Conversa.Sessao.Item.Controller,
  Conversa.Lista.View,

  Conversa.BatePapo.View;

type
  TConversaSessaoItemView = class(TForm)
    lytConversaSessaoItemView: TLayout;
    rctgConversaSessaoItemView: TRectangle;
    tbcSessao: TTabControl;
    tiConversasLista: TTabItem;
    tiConversasItem: TTabItem;
    lytSessaoClient: TLayout;
    lytTabControl: TLayout;
    lytBatePapoClient: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure lytSessaoClientResize(Sender: TObject);
  private
    { Private declarations }
    FController: TConversaSessaoItemController;

    FBatePapo: TConversaBatePapoView;
    FConversaListaView: TConversaListaView;
    procedure AbrirBatePapo(iIDConversa: Double);
    procedure PosicionarBatePapoPrincipal;
  public
    { Public declarations }
    constructor Create(AOwner: TFmxObject); reintroduce; overload;
    property Controller: TConversaSessaoItemController read FController;
    property ConversaListaView: TConversaListaView read FConversaListaView write FConversaListaView;
  end;

var
  ConversaSessaoItemView: TConversaSessaoItemView;

implementation

{$R *.fmx}

{ TConversaSessaoItemView }

constructor TConversaSessaoItemView.Create(AOwner: TFmxObject);
begin
  inherited Create(AOwner);
  FController := TConversaSessaoItemController.Create(Self);

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
  FConversaListaView := TConversaListaView.Create(Self, FController);
  FConversaListaView.Parent := tiConversasLista;
  FConversaListaView.lytForm_Conversas.Parent := tiConversasLista;
  FConversaListaView.AoAbrirBatePapo(AbrirBatePapo);

  tbcSessao.ActiveTab := tiConversasLista;
end;

procedure TConversaSessaoItemView.lytSessaoClientResize(Sender: TObject);
begin
  PosicionarBatePapoPrincipal;
end;

procedure TConversaSessaoItemView.AbrirBatePapo(iIDConversa: Double);
begin
  if not Assigned(FBatePapo) then
  begin
    FBatePapo := TConversaBatePapoView.Create(Self, FController, iIDConversa, FController.Usuario_ID);
    FBatePapo.Parent := Self;
  end;
  PosicionarBatePapoPrincipal;
  Application.ProcessMessages;
  FBatePapo.CarregarMensagens;
end;

procedure TConversaSessaoItemView.PosicionarBatePapoPrincipal;
begin
  if not Assigned(FBatePapo) then
    Exit;

  if lytSessaoClient.Width > 600 then
  begin
    // Posiciona o BatePapo em Client
    FBatePapo.lytForm.Parent := lytSessaoClient;
    FBatePapo.lytForm.Align  := TAlignLayout.Client;
    // Posiciona o TabControl à esquerda
    lytTabControl.Align := TAlignLayout.Left;
    lytTabControl.Width := 300;
    tbcSessao.ActiveTab := tiConversasLista;
  end
  else
  begin
    // Posiciona o TabControl à esquerda
    lytTabControl.Align      := TAlignLayout.Client;
    FBatePapo.lytForm.Parent := lytBatePapoClient;
    FBatePapo.lytForm.Align  := TAlignLayout.Client;
    tbcSessao.ActiveTab := tiConversasItem;
  end;
end;

end.
