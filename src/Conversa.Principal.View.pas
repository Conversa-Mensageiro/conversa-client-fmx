// Daniel Araujo - 09/07/2020
unit Conversa.Principal.View;

interface

uses
  System.Actions,
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.ActnList,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.MultiView,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Types,

  Conversa.Conexao.Banco_Dados,
  Conversa.Dispositivo.Controller,
  Conversa.Sessao.Lista.View;

type
  TPrincipalView = class(TForm)
    lytForm: TLayout;
    lytBarraTopo: TLayout;
    rctBackground: TRectangle;
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
    MultiView1: TMultiView;
    lytMenu: TLayout;
    Rectangle1: TRectangle;
    tmrMultiView_Open: TTimer;
    lytInformacoesUsuario_Client: TLayout;
    lytInformacoesUsuario: TLayout;
    lytNomeUsuario: TLayout;
    lblNomeUsuario: TLabel;
    lytFotoChat: TLayout;
    crclFotoConversa: TCircle;
    lytClientSessoes: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure edtPesquisaEnter(Sender: TObject);
    procedure edtPesquisaExit(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure tmrMultiView_OpenTimer(Sender: TObject);
  private
    { Private declarations }
    FConexaoBancoDados: TConversaConexaoBancoDados;
    FSessoesLista: TConversaSessaoListaView;
  public
    { Public declarations }
  end;

var
  PrincipalView: TPrincipalView;

implementation

{$R *.fmx}
{$R *.XLgXhdpiTb.fmx ANDROID}

{ TPrincipalView }

procedure TPrincipalView.edtPesquisaEnter(Sender: TObject);
begin
  lbEditPesquisaPrompt.Visible := False;
end;

procedure TPrincipalView.edtPesquisaExit(Sender: TObject);
begin
  lbEditPesquisaPrompt.Visible := edtPesquisa.Text.Trim.IsEmpty;
end;

procedure TPrincipalView.FormCreate(Sender: TObject);
begin
  FConexaoBancoDados := TConversaConexaoBancoDados.Create(Self);
  FSessoesLista := TConversaSessaoListaView.Create(lytClientSessoes, FConexaoBancoDados);
  FSessoesLista.CarregarListaSessoesAtivas;
  MultiView1.Mode := TMultiViewMode.NavigationPane;
  MultiView1.NavigationPaneOptions.CollapsedWidth := 60;
end;

procedure TPrincipalView.SpeedButton1Click(Sender: TObject);
begin
  MultiView1.ShowMaster;
end;

procedure TPrincipalView.tmrMultiView_OpenTimer(Sender: TObject);
var
  ptMouse: TPointF;
begin
  ptMouse := Screen.MousePos;

  ptMouse := ScreenToClient(ptMouse);

  if MultiView1.PointInObject(ptMouse.X, ptMouse.Y) and not MultiView1.Presenter.Opened then
    MultiView1.ShowMaster
  else
  if not MultiView1.PointInObject(ptMouse.X, ptMouse.Y) and MultiView1.Presenter.Opened then
    MultiView1.HideMaster;
end;

end.
