// Daniel Araujo - 12/07/2020
unit Conversa.Sessao.Lista.Controller;

interface

uses
  System.Classes,
  System.JSON,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  Conversa.Base.Controller;

type
  TConversaSessaoListaController = class(TConversaBaseController)
    cdsSessoesAtivas: TClientDataSet;
    qrySessoesAtivasid: TIntegerField;
    qrySessoesAtivasnome: TStringField;
    qrySessoesAtivasapelido: TStringField;
    qrySessoesAtivasemail: TStringField;
    qrySessoesAtivasusuario: TStringField;
    qrySessoesAtivassenha: TStringField;
    qrySessoesAtivasconectado: TIntegerField;
    qrySessoesAtivasactive: TIntegerField;
  private
  public
    { Public declarations }
    procedure CarregarSessoesAtivas;
    function ObterInformacoesSessa: TJSONValue;
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TConversaSessaoListaController }

procedure TConversaSessaoListaController.CarregarSessoesAtivas;
begin
  with ObterInformacoesSessa do
  try
    cdsSessoesAtivas.CreateDataSet;
    cdsSessoesAtivas.Append;
    cdsSessoesAtivas.FieldByName('id').AsInteger       := GetValue<Integer>('id');
    cdsSessoesAtivas.FieldByName('nome').AsString      := GetValue<String>('nome');
    cdsSessoesAtivas.FieldByName('apelido').AsString   := GetValue<String>('apelido');
    cdsSessoesAtivas.FieldByName('email').AsString     := GetValue<String>('email');
    cdsSessoesAtivas.FieldByName('usuario').AsString   := GetValue<String>('usuario');
    cdsSessoesAtivas.FieldByName('senha').AsString     := GetValue<String>('senha');
    cdsSessoesAtivas.FieldByName('conectado').AsString := GetValue<String>('conectado');
    cdsSessoesAtivas.FieldByName('active').AsString    := GetValue<String>('active');
    cdsSessoesAtivas.Post;
  finally
    Free;
  end;
end;

function TConversaSessaoListaController.ObterInformacoesSessa: TJSONValue;
var
  sFilePath: String;
begin
  sFilePath := EmptyStr;
  if ParamCount > 0 then
    sFilePath := ParamStr(1);

  sFilePath := ExtractFilePath(ParamStr(0)) +'conversa'+sFilePath+'.json';

  with TStringList.Create do
  try
    if FileExists(sFilePath) then
      LoadFromFile(sFilePath);
    Result := TJSONObject.ParseJSONValue(Text);
  finally
    Free;
  end;
end;

end.
