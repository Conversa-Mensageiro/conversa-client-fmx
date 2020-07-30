unit Conversa.Mensagem.Item.Texto.Frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Conversa.Mensagem.Item.Base.Frame,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts;

type
  TConversaMensagemItemTextoFrame = class(TConversaMensagemItemBaseFrame)
    lblTextoMensagem: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure CalcularRectConteudo;

    function CalcularDimensaoConteudo: TSizeF; override;

    function PrepararConteudo: TConversaMensagemItemBaseFrame; override;
  end;

var
  ConversaMensagemItemTextoFrame: TConversaMensagemItemTextoFrame;

implementation

{$R *.fmx}

{ TConversaMensagemItemBaseFrame1 }

procedure TConversaMensagemItemTextoFrame.Button1Click(Sender: TObject);
begin
  CalcularRectConteudo;
end;

function TConversaMensagemItemTextoFrame.CalcularDimensaoConteudo: TSizeF;
var
  R: TRectF;
begin
  Result := TSizeF.Create(100, 50);
  if Assigned(lblTextoMensagem.Canvas) then
  begin
    R := RectF(0, 0, 10000, 20);
    lblTextoMensagem.Canvas.MeasureText(R, lblTextoMensagem.Text, True, [TFillTextFlag.RightToLeft], TTextAlign.Leading, TTextAlign.Center);
    Result := R.Size;
  end;
  Result.cx := Result.cx + lytConteudo.Margins.Left + lytConteudo.Margins.Right;
  Result.cy := Result.cy + lytConteudo.Margins.Top + lytConteudo.Margins.Bottom;
end;

procedure TConversaMensagemItemTextoFrame.CalcularRectConteudo;
begin
  AjustarDimensoes;
end;

constructor TConversaMensagemItemTextoFrame.Create(AOwner: TComponent);
begin
  inherited;
  lytNomeUsuario.Visible := False;
end;

function TConversaMensagemItemTextoFrame.PrepararConteudo: TConversaMensagemItemBaseFrame;
begin
  lblTextoMensagem.Text := FConteudo;
  Result := inherited;
end;

end.
