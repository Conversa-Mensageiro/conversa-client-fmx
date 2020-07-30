// Daniel Araujo - 11/07/2020
unit Conversa.Dispositivo.Controller;

interface

uses
  System.Classes,
  System.StrUtils,
  System.SysUtils,

  FMX.ZDeviceInfo,
  Conversa.Base.Controller;

const
  sl = sLineBreak;

type
  TConversaDispositivoController = class(TConversaBaseController)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
//    FSQL: String;
//    function GetTipo(sTabela, sDescricao: String; iTipo: Integer = 0): Integer;
  public
    { Public declarations }
    procedure ObterInformacoes;
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TConversaDispositivoController }

procedure TConversaDispositivoController.DataModuleCreate(Sender: TObject);
begin
//  FSQL := qryDispositivo.SQL.Text;
end;

procedure TConversaDispositivoController.ObterInformacoes;
var
  Dispositivo: TZDeviceInfo;
begin
  // Cadastrar as informações do dispositivo
  Dispositivo := TZDeviceInfo.Create;
  try
    // Procura pelo Número do Dispositivo
//    qryDispositivo.Close;
//    qryDispositivo.Open(FSQL + sl +' WHERE dispositivo.numero = '+ QuotedStr(Dispositivo.DeviceID));
//
//    // Se não encontrou, então grava o dispositivo
//    if qryDispositivo.IsEmpty then
//    begin
//      qryDispositivo.Append;
//      qryDispositivo.FieldByName('id').AsInteger := ConversaConexaoBancoDados.GetId('dispositivo');
//      qryDispositivo.FieldByName('tipo').AsInteger := GetTipo('dispositivo_tipo', Dispositivo.Device);
//      qryDispositivo.FieldByName('numero').AsString := Dispositivo.DeviceID;
//      qryDispositivo.FieldByName('plataforma').AsInteger := GetTipo('dispositivo_plataforma', Dispositivo.Platform);
//      qryDispositivo.FieldByName('plataforma_versao').AsString := Dispositivo.PlatformVer;
//      qryDispositivo.FieldByName('arquitetura').AsInteger := GetTipo('dispositivo_arquitetura', Dispositivo.Architecture, 1);
//      qryDispositivo.FieldByName('arquitetura2').AsInteger := GetTipo('dispositivo_arquitetura', Dispositivo.Architecture2, 2);
//      qryDispositivo.FieldByName('linguagem').AsInteger := GetTipo('dispositivo_linguagem', Dispositivo.LangID);
//      qryDispositivo.FieldByName('fuso_horario').AsFloat := Dispositivo.TimeZone;
//      qryDispositivo.FieldByName('conexao_rede').AsInteger := GetTipo('dispositivo_conexao_rede', Dispositivo.NetworkConnectionType.GetDesc);
//      qryDispositivo.FieldByName('dados_movel').AsInteger := GetTipo('dispositivo_dados_movel', Dispositivo.MobileDataType.GetDesc);
//      qryDispositivo.FieldByName('endereco_ip').AsString := Dispositivo.IPAddress;
//      qryDispositivo.FieldByName('endereco_mac').AsString := Dispositivo.MacAddress;
//      qryDispositivo.FieldByName('operadora_movel').AsInteger := GetTipo('dispositivo_operadora_movel', Dispositivo.MobileOperator);
//      qryDispositivo.FieldByName('dispositivo_intel').AsString := Dispositivo.IsIntel.ToString;
//      qryDispositivo.FieldByName('tela_fisica').AsString := Dispositivo.ScreenPhis;
//      qryDispositivo.FieldByName('tela_logica').AsString := Dispositivo.ScreenLogic;
//      qryDispositivo.Post;
//    end;
  finally
    Dispositivo.DisposeOf;
  end;
end;

//function TConversaDispositivoController.GetTipo(sTabela, sDescricao: String; iTipo: Integer = 0): Integer;
//begin
//  Result := 0;
////  with TFDQuery.Create(Self) do
////  try
////    Connection := ConversaConexaoBancoDados.conConversa;
////    Open(
////    sl +' SELECT id '+
////    sl +'      , descricao '+
////    sl +'   FROM '+ sTabela +
////    sl +'  WHERE descricao = '+ QuotedStr(sDescricao)+
////    IfThen(iTipo > 0,
////    sl +'    AND tipo = '+ iTipo.ToString
////    )
////    );
////    if IsEmpty then
////    begin
////      Append;
////      FieldByName('id').AsInteger       := ConversaConexaoBancoDados.GetId(sTabela);
////      FieldByName('descricao').AsString := sDescricao;
////      Post;
////    end;
////    Result := FieldByName('id').AsInteger;
////  finally
////    DisposeOf;
////  end;
//end;

end.
