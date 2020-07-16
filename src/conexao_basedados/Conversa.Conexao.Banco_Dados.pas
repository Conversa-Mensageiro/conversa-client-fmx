// Daniel Araujo - 10/07/2020
unit Conversa.Conexao.Banco_Dados;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Error,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Pool,
  FireDAC.UI.Intf;

const
  sl = sLineBreak;

type
  TConversaConexaoBancoDados = class(TDataModule)
    conConversa: TFDConnection;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); reintroduce; overload;
    procedure ConfigurarConexao(conDB: TFDConnection);
    function GetId(sTabela: String): Integer;
  end;

var
  ConversaConexaoBancoDados: TConversaConexaoBancoDados;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TConversaConexaoBancoDados }

constructor TConversaConexaoBancoDados.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RemoveDataModule(Self);
end;

procedure TConversaConexaoBancoDados.ConfigurarConexao(conDB: TFDConnection);
begin
  conDB.Connected := False;
  conDB.Params.Database := ExtractFilePath(ParamStr(0)) +'base_dados\conversa.db';
  conDB.Connected := True;
end;

function TConversaConexaoBancoDados.GetId(sTabela: String): Integer;
begin
  System.TMonitor.Enter(Self);
  try
    with TFDQuery.Create(Self) do
    try
      Connection := conConversa;
      Open(
      sl +' SELECT id '+
      sl +'      , tabela '+
      sl +'      , valor '+
      sl +'   FROM sistema_sequencia_id'+
      sl +'  WHERE tabela = '+ QuotedStr(sTabela)
      );

      if IsEmpty then
      begin
        Append;
        FieldByName('tabela').AsString := sTabela;
        FieldByName('valor').AsInteger := -1;
        Post;
//        ApplyUpdates(0);
      end;

      Result := FieldByName('valor').AsInteger;

      Edit;
      FieldByName('valor').AsInteger := FieldByName('valor').AsInteger - 1;
      Post;
//      ApplyUpdates(0);
    finally
      DisposeOf;
    end;
  finally
    System.TMonitor.Exit(Self);
  end;
end;

end.
