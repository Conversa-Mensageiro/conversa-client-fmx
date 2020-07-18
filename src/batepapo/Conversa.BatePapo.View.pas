// Daniel Araujo - 09/07/2020
unit Conversa.BatePapo.View;

interface

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.Ani,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Effects,
  FMX.Filter.Effects,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,

  Conversa.BatePapo.Controller;

type
  TConversaBatePapoView = class(TForm)
    lytForm: TLayout;
    rctgForm: TRectangle;
    lytTopTitle: TLayout;
    rctgTitle: TRectangle;
    lytBtnVoltar: TLayout;
    btnVoltar: TSpeedButton;
    lytInformacoesChat_Client: TLayout;
    lytFotoChat: TLayout;
    crclFotoChat: TCircle;
    lytInformacoesChat: TLayout;
    lblChat_Title: TLabel;
    lytBotoesTopo_Direita: TLayout;
    btnMaisOpcoes: TSpeedButton;
    btnLigacao: TSpeedButton;
    btnVideoChamada: TSpeedButton;
    lytButtonInput: TLayout;
    Rectangle1: TRectangle;
    Button1: TButton;
    Layout1: TLayout;
    Circle1: TCircle;
    Circle2: TCircle;
    MinhaNovaAnimacao: TFloatAnimation;
    MaskToAlphaEffect1: TMaskToAlphaEffect;
    lytInputEdit: TLayout;
    RoundRect1: TRoundRect;
    Layout2: TLayout;
    Edit1: TEdit;
    Layout3: TLayout;
    SpeedButton1: TSpeedButton;
    Layout4: TLayout;
    Layout5: TLayout;
    lblChat_Info: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Circle1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure MinhaNovaAnimacaoProcess(Sender: TObject);
    procedure MinhaNovaAnimacaoFinish(Sender: TObject);
  private
    { Private declarations }
    FController: TConversaBatePapoController;
    FID: Double;
    FX,FY:Single;
    FCircle: TCircle;
    FFloatAnimation: TFloatAnimation;
    procedure FloatAnimation1Finish(Sender: TObject);
    procedure FloatAnimation1Process(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; dIDConversa: Double); reintroduce; overload;
  end;

var
  ConversaBatePapoView: TConversaBatePapoView;

implementation

{$R *.fmx}

constructor TConversaBatePapoView.Create(AOwner: TComponent; dIDConversa: Double);
begin
  inherited Create(AOwner);
  FController := TConversaBatePapoController.Create(Self, nil);
  FID := dIDConversa;
end;

procedure TConversaBatePapoView.FormCreate(Sender: TObject);
begin
  FCircle := TCircle.Create(crclFotoChat);
  FCircle.ClipChildren := True;
  crclFotoChat.ClipChildren := True;
  FCircle.Visible := False;
  FCircle.Fill.Color := $FE87CEEB;
  FCircle.Opacity := 1;

  FFloatAnimation := TFloatAnimation.Create(FCircle);
  FCircle.AddObject(FFloatAnimation);
  FFloatAnimation.Duration := 0.300000001490116100;
  FFloatAnimation.OnProcess := FloatAnimation1Process;
  FFloatAnimation.OnFinish := FloatAnimation1Finish;
  FFloatAnimation.PropertyName := 'Size.Height';
  FFloatAnimation.StartValue := 0.000000000000000000;
  FFloatAnimation.StopValue := 500.000000000000000000;
  FFloatAnimation.Trigger := 'IsVisible=true';

  lblChat_Title.Text := 'Conversa 1';
  lblChat_Info.Text  := 'Online';
end;

procedure TConversaBatePapoView.Circle1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Circle2.Parent := TControl(Sender);
  Circle2.Position.X := X-(Circle2.Width/2);
  FX := X;
  Circle2.Position.Y := Y-(Circle2.Height/2);
  FY := Y;
  Circle2.Width := 0;
  Circle2.Height := 0;
  Circle2.Visible := True;
  MinhaNovaAnimacao.StopValue := Max(TControl(Sender).Width,TControl(Sender).Height)*2;
end;

procedure TConversaBatePapoView.FloatAnimation1Finish(Sender: TObject);
begin
  FCircle.Visible := False;
end;

procedure TConversaBatePapoView.FloatAnimation1Process(Sender: TObject);
begin
  FCircle.Width := FCircle.Height;
  FCircle.Position.X := FX-(FCircle.Width/2);;
  FCircle.Position.Y := FY-(FCircle.Height/2);;
end;


procedure TConversaBatePapoView.MinhaNovaAnimacaoFinish(Sender: TObject);
begin
  Circle2.Visible := False;
end;

procedure TConversaBatePapoView.MinhaNovaAnimacaoProcess(Sender: TObject);
begin
  Circle2.Width := Circle2.Height;
  Circle2.Position.X := FX-(Circle2.Width/2);;
  Circle2.Position.Y := FY-(Circle2.Height/2);;
end;

end.
