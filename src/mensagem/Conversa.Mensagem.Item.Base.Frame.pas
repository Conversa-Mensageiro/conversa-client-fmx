unit Conversa.Mensagem.Item.Base.Frame;

interface

uses
  System.SysUtils,
  System.Math,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation;

type
  TPosicao = (Esquerda, Direita);
  TConversaMensagemItemBaseFrame = class(TFrame)
    lytConversaMensagemItemBaseFrame: TLayout;
    rctgBalaoMensagem: TRectangle;
    lytCorpoMensagem: TLayout;
    lytNomeUsuario: TLayout;
    lblNomeUsuario: TLabel;
    lytConteudo: TLayout;
    lytResposta: TLayout;
    rctgResposta: TRectangle;
    lytNomeUsuarioResposta: TLayout;
    lblNomeUsuarioResposta: TLabel;
    lytRespostaMensagem: TLayout;
    lblRespostaMensagem: TLabel;
    lytBalaoMensagem: TLayout;
    lytInformacoes: TLayout;
    lblDataHoraMensagem: TLabel;
    procedure lytConversaMensagemItemBaseFrameResized(Sender: TObject);
  private
    { Private declarations }
    FPosicao: TPosicao;
    FContentSize: TSizeF;
  protected
    FID: Double;
    FNomeUsuario: String;
    FDataHora: TDateTime;
    FConteudo: String;

    function GetRespostaRect: TRectF;
    procedure SetContentSize(Value: TSizeF);

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function SetPosicao(Value: TPosicao): TConversaMensagemItemBaseFrame; virtual;
    function GetPosicao: TPosicao;

    function ID: Double; overload; virtual;
    function ID(Value: Double): TConversaMensagemItemBaseFrame; overload; virtual;
    function NomeUsuario: string; overload; virtual;
    function NomeUsuario(Value: String): TConversaMensagemItemBaseFrame; overload; virtual;
    function Conteudo: string; overload; virtual;
    function Conteudo(Value: String): TConversaMensagemItemBaseFrame; overload; virtual;
    function DataHora: TDateTime; overload; virtual;
    function DataHora(Value: TDateTime): TConversaMensagemItemBaseFrame; overload; virtual;

    function NomeUsuarioVisivel: Boolean; overload; virtual;
    function NomeUsuarioVisivel(const Value: Boolean): TConversaMensagemItemBaseFrame; overload; virtual;
    function BalaoVisivel: Boolean; overload; virtual;
    function BalaoVisivel(const Value: Boolean): TConversaMensagemItemBaseFrame; overload; virtual;

    function AjustarDimensoes: TConversaMensagemItemBaseFrame;
    function AjustarDimensaoCorpoMensagem: TConversaMensagemItemBaseFrame;

    function ObterDataHoraFormatado: String;

    function CalcularDimensaoCorpoMensagem: TSizeF; virtual;
    function CalcularDimensaoNomeUsuario: TSizeF; virtual;
    function CalcularDimensaoConteudo: TSizeF; virtual;
    function CalcularDimensaoDataHora: TSizeF; virtual;

    function PrepararConteudo: TConversaMensagemItemBaseFrame; overload; virtual;
  end;

implementation

{$R *.fmx}

{ TConversaMensagemItemFrame }

constructor TConversaMensagemItemBaseFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  lytResposta.Visible := False;
  Parent     := TFmxObject(AOwner);
  Align      := TAlignLayout.Bottom;
  Position.Y := TLayout(Parent).Height + Self.Height;
  Visible    := True;
  SetPosicao(TPosicao.Direita);
end;

function TConversaMensagemItemBaseFrame.GetPosicao: TPosicao;
begin
  Result := FPosicao;
end;

function TConversaMensagemItemBaseFrame.GetRespostaRect: TRectF;
begin
  Result := TControl(lytResposta).ClipRect;
end;

function TConversaMensagemItemBaseFrame.SetPosicao(Value: TPosicao): TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  FPosicao := Value;
  if FPosicao = TPosicao.Direita then
    lytCorpoMensagem.Align := TAlignLayout.Right
  else
  if FPosicao = TPosicao.Esquerda then
    lytCorpoMensagem.Align := TAlignLayout.Left;
end;

procedure TConversaMensagemItemBaseFrame.SetContentSize(Value: TSizeF);
begin
  FContentSize := Value;
end;

function TConversaMensagemItemBaseFrame.ID: Double;
begin
  Result := FID;
end;

function TConversaMensagemItemBaseFrame.ID(Value: Double): TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  FID := Value;
end;

procedure TConversaMensagemItemBaseFrame.lytConversaMensagemItemBaseFrameResized(
  Sender: TObject);
begin
  AjustarDimensoes;
end;

function TConversaMensagemItemBaseFrame.NomeUsuario: string;
begin
  Result := FNomeUsuario;
end;

function TConversaMensagemItemBaseFrame.NomeUsuario(Value: String): TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  FNomeUsuario := Value;
  lblNomeUsuario.Text := FNomeUsuario;
end;

function TConversaMensagemItemBaseFrame.Conteudo: string;
begin
  Result := FConteudo;
end;

function TConversaMensagemItemBaseFrame.Conteudo(Value: String): TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  FConteudo := Value;
end;

function TConversaMensagemItemBaseFrame.DataHora: TDateTime;
begin
  Result := FDataHora;
end;

function TConversaMensagemItemBaseFrame.DataHora(Value: TDateTime): TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  FDataHora := Value;
  lblDataHoraMensagem.Text := ObterDataHoraFormatado;
end;

function TConversaMensagemItemBaseFrame.NomeUsuarioVisivel: Boolean;
begin
  Result := lytNomeUsuario.Visible;
end;

function TConversaMensagemItemBaseFrame.NomeUsuarioVisivel(const Value: Boolean): TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  lytNomeUsuario.Visible := Value;
end;

function TConversaMensagemItemBaseFrame.BalaoVisivel: Boolean;
begin
  Result := lytBalaoMensagem.Visible;
end;

function TConversaMensagemItemBaseFrame.BalaoVisivel(const Value: Boolean): TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  lytBalaoMensagem.Visible := False;
end;

function TConversaMensagemItemBaseFrame.AjustarDimensoes: TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  Self.Height := CalcularDimensaoCorpoMensagem.Height;
  AjustarDimensaoCorpoMensagem;
end;

function TConversaMensagemItemBaseFrame.AjustarDimensaoCorpoMensagem: TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  lytCorpoMensagem.Width := CalcularDimensaoCorpoMensagem.Width;
end;

function TConversaMensagemItemBaseFrame.CalcularDimensaoCorpoMensagem: TSizeF;
var
  szNome    : TSizeF;
  szConteudo: TSizeF;
  szDataHora: TSizeF;
begin
  szNome     := CalcularDimensaoNomeUsuario;
  szConteudo := CalcularDimensaoConteudo;
  szDataHora := CalcularDimensaoDataHora;
  Result.cx  := Max(Max(szNome.cx, szDataHora.cx), szConteudo.cx);
  Result.cy  := szConteudo.Height;

  if lytNomeUsuario.Visible then
    Result.cy := Result.cy + szNome.Height;
  if lblDataHoraMensagem.Visible then
    Result.cy := Result.cy + szDataHora.Height;

  Result.cx := Result.cx + lytInformacoes.Margins.Left + lytInformacoes.Margins.Right;
  Result.cy := Result.cy + lytInformacoes.Margins.Top + lytInformacoes.Margins.Bottom;
end;

function TConversaMensagemItemBaseFrame.CalcularDimensaoConteudo: TSizeF;
begin
  Result := TSizeF.Create(100, 50);
  Result.cx := Result.cx + lytConteudo.Margins.Left + lytConteudo.Margins.Right;
  Result.cy := Result.cy + lytConteudo.Margins.Top + lytConteudo.Margins.Bottom;
end;

function TConversaMensagemItemBaseFrame.CalcularDimensaoNomeUsuario: TSizeF;
var
  R: TRectF;
begin
  if Assigned(lblNomeUsuario.Canvas) then
  begin
    R := RectF(0, 0, 10000, 20);
    lblNomeUsuario.Canvas.MeasureText(R, FNomeUsuario, False, [], TTextAlign.Leading, TTextAlign.Center);
    Result := R.Size;
  end;
  Result.cx := Result.cx + lytNomeUsuario.Margins.Left + lytNomeUsuario.Margins.Right;
  Result.cy := Result.cy + lytNomeUsuario.Margins.Top + lytNomeUsuario.Margins.Bottom;
end;

function TConversaMensagemItemBaseFrame.CalcularDimensaoDataHora: TSizeF;
var
  R: TRectF;
begin
  if Assigned(lblDataHoraMensagem.Canvas) then
  begin
    R := RectF(0, 0, 10000, 20);
    lblDataHoraMensagem.Canvas.MeasureText(R, ObterDataHoraFormatado, False, [], TTextAlign.Leading, TTextAlign.Center);
    Result := R.Size;
  end;
  Result.cx := Result.cx + lblDataHoraMensagem.Margins.Left + lblDataHoraMensagem.Margins.Right;
  Result.cy := Result.cy + lblDataHoraMensagem.Margins.Top + lblDataHoraMensagem.Margins.Bottom;
end;

function TConversaMensagemItemBaseFrame.ObterDataHoraFormatado: String;
begin
  Result := FormatDateTime('HH:mm', FDataHora);
end;

function TConversaMensagemItemBaseFrame.PrepararConteudo: TConversaMensagemItemBaseFrame;
begin
  Result := Self;
  AjustarDimensoes;
end;

end.
