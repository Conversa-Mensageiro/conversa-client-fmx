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

  Conversa.Sessao.Lista.Controller,
  Conversa.Sessao.Item.View;

type
  TConversaSessaoListaView = class(TFrame)
    lytConversaSessaoListaView: TLayout;
    rctgConversaSessaoListaView: TRectangle;
    lytSessoes: TLayout;
  private
    { Private declarations }
    FSessaoListaController: TConversaSessaoListaController;
    FSessoes: TDictionary<Integer, TConversaSessaoItemView>;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); reintroduce; overload;
    destructor Destroy; override;
    procedure CarregarListaSessoesAtivas;
  end;

var
  ConversaSessaoListaView: TConversaSessaoListaView;

implementation

{$R *.fmx}

{ TConversaSessaoListaView }

constructor TConversaSessaoListaView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent := TFmxObject(AOwner);
  Align := TAlignLayout.Client;

  FSessaoListaController := TConversaSessaoListaController.Create(Self);
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
  with FSessaoListaController.cdsSessoesAtivas do
  begin
    First;
    while not Eof do
    try
      with TConversaSessaoItemView.Create(Self) do
      try
        Controller.Usuario_ID := FieldByName('id').AsFloat;
        Controller.Usuario    := FieldByName('usuario').AsString;
        Controller.Senha      := FieldByName('senha').AsString;
        Name := 'TConversaSessaoItemView_'+ FieldByName('id').AsString;
        ConversaListaView.CarregarConversas;
      finally
        lytConversaSessaoItemView.Parent := Self.lytSessoes;
      end;
    finally
      Next;
    end;
  end;
end;

end.
