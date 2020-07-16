// Daniel Araujo - 10/07/2020
unit Conversa.Lista.Item.Frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, FMX.Ani, FMX.Gestures, System.DateUtils,
  FMX.TextLayout;

type
  TConversaItemFrame = class(TFrame)
    Layout1: TLayout;
    rctgBackgroundItem: TRectangle;
    lytItemConversa: TLayout;
    lytFotoChat: TLayout;
    crclFotoConversa: TCircle;
    lytInformacoesChat: TLayout;
    lytInformacoesSuperiores: TLayout;
    lytConversa: TLayout;
    lblConversa: TLabel;
    lytDataConversa: TLayout;
    lblDataConversa: TLabel;
    lytInformacoesInferiores: TLayout;
    lytMensagem: TLayout;
    lblMensagem: TLabel;
    lytContador: TLayout;
    crclContador: TCircle;
    lblContador: TLabel;
    FloatAnimation1: TFloatAnimation;
    lytCheck: TLayout;
    crclCheck: TCircle;
    FloatAnimation2: TFloatAnimation;
    GestureManager1: TGestureManager;
    Layout2: TLayout;
    Circle1: TCircle;
    FloatAnimation3: TFloatAnimation;
    procedure lblMensagemGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure Panel1Gesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
  private type
    TContadorStatus = (Nenhum, Exibindo, Exibido, Ocultando, Oculto);
  private
    { Private declarations }
    FID: Double;
    FDescricao: String;
    FDataConversa: TDateTime;
    FMensagem: String;
    FQtd: Integer;
    FContadorStatus: TContadorStatus;
    procedure ContadorExibir;
    procedure ContadorOcultar;
    function MeasureText(const sText: string; const tsTextSettings: TTextSettings): TRectF;
  public
    { Public declarations }
    function ID(Value: Double): TConversaItemFrame; overload;
    function ID: Double; overload;
    function Descricao(Value: String): TConversaItemFrame; overload;
    function Descricao: String; overload;
    function DataConversa(Value: TDateTime): TConversaItemFrame; overload;
    function DataConversa: TDateTime; overload;
    function Mensagem(Value: String): TConversaItemFrame; overload;
    function Mensagem: String; overload;
    function Qtd(Value: Integer): TConversaItemFrame; overload;
    function Qtd: Integer; overload;
    function AtualizarFotoConversa(bmp: TBitmap): TConversaItemFrame;
  end;

implementation

{$R *.fmx}

{ TConversaItemFrame }

function TConversaItemFrame.ID(Value: Double): TConversaItemFrame;
begin
  Result := Self;
  FID := Value;
end;

function TConversaItemFrame.ID: Double;
begin
  Result := FID;
end;

procedure TConversaItemFrame.lblMensagemGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  if EventInfo.GestureID = System.UITypes.igiLongTap then
  begin
    ShowMessage('Clique longo!');
  end;
end;

function TConversaItemFrame.Descricao(Value: String): TConversaItemFrame;
begin
  Result := Self;
  FDescricao := Value;
  lblConversa.Text := FDescricao;
end;

function TConversaItemFrame.Descricao: String;
begin
  Result := FDescricao;
end;

function TConversaItemFrame.DataConversa(Value: TDateTime): TConversaItemFrame;
begin
  Result := Self;
  FDataConversa := Value;
  if HoursBetween(Value, Now) < 24 then
    lblDataConversa.Text := FormatDateTime('HH:mm:ss', Value)
  else
  if HoursBetween(Value, Now) > 24 then
    lblDataConversa.Text := FormatDateTime('dd/mm HH:mm:ss', Value);

  lytDataConversa.Size.Width := MeasureText(lblDataConversa.Text, lblDataConversa.TextSettings).Width;
end;

function TConversaItemFrame.DataConversa: TDateTime;
begin
  Result := FDataConversa;
end;

function TConversaItemFrame.Mensagem(Value: String): TConversaItemFrame;
begin
  Result := Self;
  FMensagem := Value;
  lblMensagem.Text := Value;
end;

function TConversaItemFrame.Mensagem: String;
begin
  Result := FMensagem;
end;

procedure TConversaItemFrame.Panel1Gesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  if EventInfo.GestureID = System.UITypes.igiLongTap then
  begin
    ShowMessage('Clique longo!');
  end;
end;

function TConversaItemFrame.Qtd(Value: Integer): TConversaItemFrame;
begin
  Result := Self;
  FQtd := Value;
  if FQtd > 0 then
  begin
    // Altera antes de Exibir
    lblContador.Text := FQtd.ToString;
    ContadorExibir;
  end
  else
  begin
    ContadorOcultar;
    // Altera após ocultar
    lblContador.Text := FQtd.ToString;
  end;
end;

function TConversaItemFrame.Qtd: Integer;
begin
  Result := FQtd;
end;

function TConversaItemFrame.AtualizarFotoConversa(bmp: TBitmap): TConversaItemFrame;
begin
  Result := Self;
  try
    crclFotoConversa.Fill.Bitmap.Assign(bmp);
  finally
    FreeAndNil(bmp);
  end;
end;

procedure TConversaItemFrame.ContadorExibir;
begin
  if FContadorStatus in [TContadorStatus.Exibindo, TContadorStatus.Exibido] then
    Exit;

  if FContadorStatus in [TContadorStatus.Ocultando, TContadorStatus.Oculto] then
    FContadorStatus := TContadorStatus.Exibindo;

  crclContador.Visible := True;
end;

procedure TConversaItemFrame.ContadorOcultar;
begin
  if FContadorStatus in [TContadorStatus.Exibindo, TContadorStatus.Exibido] then
    Exit;

  if FContadorStatus in [TContadorStatus.Ocultando, TContadorStatus.Oculto] then
    FContadorStatus := TContadorStatus.Ocultando;

  crclContador.Visible := False;
end;

function TConversaItemFrame.MeasureText(const sText: string; const tsTextSettings: TTextSettings): TRectF;
var
  Layout: TTextLayout;
begin
  if sText.Trim.IsEmpty then
    Exit(RectF(0, 0, 0, 0))
  else
    Result := RectF(10, 10, 1000, 1000);

  Layout := TTextLayoutManager.TextLayoutByCanvas(Self.Canvas.ClassType).Create(Self.Canvas);
  try
    Layout.BeginUpdate;
    Layout.TopLeft         := Result.TopLeft;
    Layout.MaxSize         := PointF(Result.Width, Result.Height);
    Layout.Text            := sText;
    Layout.WordWrap        := False;
    Layout.HorizontalAlign := TTextAlign.Leading;
    Layout.VerticalAlign   := TTextAlign.Center;
    Layout.Font            := tsTextSettings.Font;
    Layout.Color           := tsTextSettings.FontColor;
    Layout.RightToLeft     := False{TFillTextFlag.RightToLeft in Flags};
    Layout.EndUpdate;
    Result := Layout.TextRect;
  finally
    FreeAndNil(Layout);
  end;
end;

end.
