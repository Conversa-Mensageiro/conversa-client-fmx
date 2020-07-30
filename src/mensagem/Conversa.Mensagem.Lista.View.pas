unit Conversa.Mensagem.Lista.View;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,

  Conversa.Mensagem.Item.Base.Frame, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Objects;

type
  TConversaMensagemListaView = class(TForm)
    sbvConversaMensagemListaView: TVertScrollBox;
    lytConversaMensagemListaView: TLayout;
    lytItems: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lytConversaMensagemListaViewResize(Sender: TObject);
    procedure sbvConversaMensagemListaViewResize(Sender: TObject);
    procedure sbvConversaMensagemListaViewVScrollChange(Sender: TObject);
    procedure sbvConversaMensagemListaViewViewportPositionChange(
      Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF;
      const ContentSizeChanged: Boolean);
    procedure lytItemsResized(Sender: TObject);
  private
    { Private declarations }
    FMensagens: TList<TConversaMensagemItemBaseFrame>;
    FLast: Extended;
    procedure CalcularPosicaoConteudo(iHeight: Extended);
    procedure CalcularTamanhoConteudo;
  public
    { Public declarations }
    function Add(Value: TConversaMensagemItemBaseFrame): TConversaMensagemListaView;
  end;

var
  ConversaMensagemListaView: TConversaMensagemListaView;

implementation

{$R *.fmx}

procedure TConversaMensagemListaView.FormCreate(Sender: TObject);
begin
  FMensagens := TList<TConversaMensagemItemBaseFrame>.Create;
  lytItems.Height := 0;
  FLast := 0;
end;

procedure TConversaMensagemListaView.FormDestroy(Sender: TObject);
begin
  FMensagens.DisposeOf;
end;

procedure TConversaMensagemListaView.lytConversaMensagemListaViewResize(Sender: TObject);
var
  Item: TConversaMensagemItemBaseFrame;
begin
  if Assigned(FMensagens) then
    for Item in FMensagens do
      if Assigned(Item) then
        TConversaMensagemItemBaseFrame(Item).AjustarDimensoes;

  CalcularTamanhoConteudo;
end;

procedure TConversaMensagemListaView.lytItemsResized(Sender: TObject);
begin
  CalcularTamanhoConteudo;
end;

procedure TConversaMensagemListaView.sbvConversaMensagemListaViewResize(Sender: TObject);
begin
  lytItems.Position.X := 0;
  lytItems.Width := sbvConversaMensagemListaView.Width;
  if lytItems.Height < sbvConversaMensagemListaView.Height then
    lytItems.Position.Y := sbvConversaMensagemListaView.Height - lytItems.Height
  else
  begin
    if (lytItems.Position.Y > 0) and ((lytItems.Position.Y + lytItems.Height) > sbvConversaMensagemListaView.Height) then
      lytItems.Position.Y := 0
    else
    if (lytItems.Position.Y < 0) and ((lytItems.Position.Y + lytItems.Height) < sbvConversaMensagemListaView.Height) then
      lytItems.Position.Y := sbvConversaMensagemListaView.Height - lytItems.Height;
  end;
end;

procedure TConversaMensagemListaView.sbvConversaMensagemListaViewViewportPositionChange(
  Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF;
  const ContentSizeChanged: Boolean);
begin
//  CalcularPosicaoConteudo(0);
end;

procedure TConversaMensagemListaView.sbvConversaMensagemListaViewVScrollChange(
  Sender: TObject);
begin
//  CalcularPosicaoConteudo(0);
end;

function TConversaMensagemListaView.Add(Value: TConversaMensagemItemBaseFrame): TConversaMensagemListaView;
var
  bNeedScroll: Boolean;
  eScroll: Extended;
begin
  Result := Self;
  Value.Name := 'TConversaMensagemListaView_'+  Value.ID.ToString;
  FMensagens.Add(Value);

  if lytItems.Position.X <> 0 then
    lytItems.Position.X := 0;
  if lytItems.Width <> sbvConversaMensagemListaView.Width then
    lytItems.Width := sbvConversaMensagemListaView.Width;

  bNeedScroll := lytItems.BoundsRect.Bottom = sbvConversaMensagemListaView.Height;

  eScroll := Value.Height;
  lytItems.Height := lytItems.Height + Value.Height;
  if (lytItems.Height < sbvConversaMensagemListaView.Height) or (lytItems.Position.Y > 0) then
  begin
    if (sbvConversaMensagemListaView.Height - lytItems.Height) > 0 then
      lytItems.Position.Y := (sbvConversaMensagemListaView.Height - lytItems.Height)
    else
    begin
      bNeedScroll := False;
      eScroll := eScroll + (sbvConversaMensagemListaView.Height - lytItems.Height);
      lytItems.Position.Y := 0;
    end;
  end;

  if not bNeedScroll then
  begin
    sbvConversaMensagemListaView.ScrollBy(0, - eScroll);
  end;

  CalcularTamanhoConteudo;
end;

procedure TConversaMensagemListaView.CalcularTamanhoConteudo;
var
  Item: TConversaMensagemItemBaseFrame;
  eHeightConteudo: Extended;
begin
  Exit;
  if not Assigned(FMensagens) then
    Exit;

  eHeightConteudo := 0;
  for Item in FMensagens do
    if Assigned(Item) then
      eHeightConteudo := eHeightConteudo + Item.Height + Item.Margins.Top + Item.Margins.Bottom;

  CalcularPosicaoConteudo(eHeightConteudo - lytItems.Height);
  lytItems.Height := eHeightConteudo;
end;

procedure TConversaMensagemListaView.CalcularPosicaoConteudo(iHeight: Extended);
begin
//  lytItems.Position.X := 0;
//  lytItems.Width  := sbvConversaMensagemListaView.Width;
//
//  if not sbvConversaMensagemListaView.ViewportPosition.IsZero then
//    Exit;
//
//  if lytItems.Position.Y > 0 then
//    lytItems.Position.Y := lytItems.Position.Y - iHeight;
//    //lytItems.Position.Y := sbvConversaMensagemListaView.Height - lytItems.Height;
//
//  if lytItems.Position.Y < 0 then
//    lytItems.Position.Y := 0;
//
//  if lytItems.Position.Y = 0 then
//    sbvConversaMensagemListaView.ScrollBy(0, -iHeight);
//
//  FLast := sbvConversaMensagemListaView.ViewportPosition.Y;
end;

end.
