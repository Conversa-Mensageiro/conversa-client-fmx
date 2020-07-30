// Daniel Araujo - 11/07/2020
unit Conversa.Base.Controller;

interface

uses
  System.SysUtils,
  System.Classes,
  Conversa.WebSocket;

type
  TConversaBaseController = class(TDataModule)
  private
    { Private declarations }
    FWebSocket: TWebSocketClient;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); reintroduce; overload;
    constructor Create(AOwner: TComponent; AWebSocket: TWebSocketClient); reintroduce; overload;
    property WebSocket: TWebSocketClient read FWebSocket write FWebSocket;
  end;

var
  ConversaBaseController: TConversaBaseController;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

constructor TConversaBaseController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RemoveDataModule(Self);
end;

constructor TConversaBaseController.Create(AOwner: TComponent; AWebSocket: TWebSocketClient);
begin
  FWebSocket := AWebSocket;
  inherited Create(AOwner);
  RemoveDataModule(Self);
end;

end.
