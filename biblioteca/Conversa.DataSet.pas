// Eduardo - 06/07/2020

unit Conversa.DataSet;

interface

uses
  System.SysUtils,
  System.JSON,
  Data.DB,
  Datasnap.DBClient,
  Conversa.Consulta,
  Conversa.Comando,
  Conversa.WebSocket;

type
  TClientDataSet = class(Datasnap.DBClient.TClientDataSet)
  private
    FWSState: TDataSetState;
    FFieldCount: Integer;
    aChanged: TArray<Boolean>;
    aOnValidate: TArray<TFieldNotifyEvent>;
    FNotAdd: Integer;
    FTabela: String;
    FWebSocket: TWebSocketClient;
    procedure LoadFromJSONArray(aJSON : TJSONArray);
    procedure FieldOnValidate(Sender: TField);
    function MetodoIncluir(oJSON: TJSONObject): TJSONObject;
    function MetodoObter(consulta: TConsulta): TJSONArray;
    function MetodoAlterar(oJSON: TJSONObject): TJSONObject;
    procedure MetodoExcluir;
  public
    function WSCreate(WS: TWebSocketClient; sTabela: String): TClientDataSet;
    function WSOpen(consulta: TConsulta = nil): TClientDataSet;
    function WSClose: TClientDataSet;
    function WSAppend: TClientDataSet;
    function WSEdit: TClientDataSet;
    function WSPost: TClientDataSet;
    function WSCancel: TClientDataSet;
    function WSDelete: TClientDataSet;
    property WSState: TDataSetState read FWSState;
  end;

const
  sl = sLineBreak;

implementation

uses
  REST.Response.Adapter,
  System.RTTI,
  System.Generics.Collections,
  System.DateUtils,
  System.NetEncoding,
  IdURI;

{ TClientDataSet }

function TClientDataSet.WSCreate(WS: TWebSocketClient; sTabela: String): TClientDataSet;
var
  I: Integer;
begin
  if not Self.ProviderName.IsEmpty then
    raise Exception.Create(Self.Name +': recurso disponível somente para ClientDataSet temporário!');

  if sTabela.IsEmpty then
    raise Exception.Create('Tabela não informada!');

  Result := Self;

  // Armazena a quantidade de fields do ClientDataSet
  FFieldCount := Self.FieldCount;
  FNotAdd     := 0;
  FTabela     := sTabela;
  FWebSocket  := WS;

  // Se não tem fields não cria agora
  if FFieldCount = 0 then
    Exit;

  // Cria o DataSet
  Self.CreateDataSet;

  // Cria arrays para armazenar os dados dos fields
  SetLength(aOnValidate, FFieldCount);
  SetLength(aChanged,    FFieldCount);

  // Sobrescreve eventos dos fields
  for I := 0 to Pred(FFieldCount) do
  begin
    // Armazena os eventos originais do field e sobescreve
    aOnValidate[I] := Self.Fields[I].OnValidate;
    Self.Fields[I].OnValidate := FieldOnValidate;
  end;
end;

function TClientDataSet.MetodoIncluir(oJSON: TJSONObject): TJSONObject;
var
  cmdRequisicao: TComando;
  cmdRetorno: TComando;
begin
  cmdRequisicao := TComando.Create;
  try
    cmdRequisicao.Recurso := FTabela +'.incluir';
    cmdRequisicao.Dados.AddElement(TJSONObject(oJSON.Clone));
    cmdRetorno := TComando.Create(FWebSocket.EnviaAguarda(cmdRequisicao.Texto));
    try
      // Trata erro
      if not cmdRetorno.Erro.Classe.IsEmpty then
        raise Exception.Create('Erro ao inserir!'+ sl + cmdRetorno.Erro.Classe + sl + cmdRetorno.Erro.Mensagem);
      Result := TJSONObject(cmdRetorno.Dados.Items[0].Clone);
    finally
      FreeAndNil(cmdRetorno);
    end;
  finally
    FreeAndNil(cmdRequisicao);
  end;
end;

function TClientDataSet.MetodoObter(consulta: TConsulta): TJSONArray;
var
  cmdRequisicao: TComando;
  cmdRetorno: TComando;
begin
  cmdRequisicao := TComando.Create;
  try
    cmdRequisicao.Recurso := FTabela +'.obter';
    if Assigned(consulta) then
      consulta.ParaArray(cmdRequisicao.Dados);
    cmdRetorno := TComando.Create(FWebSocket.EnviaAguarda(cmdRequisicao.Texto));
    try
      // Trata erro
      if not cmdRetorno.Erro.Classe.IsEmpty then
        raise Exception.Create('Erro ao obter!'+ sl + cmdRetorno.Erro.Classe + sl + cmdRetorno.Erro.Mensagem);
      Result := TJSONArray(cmdRetorno.Dados.Clone);
    finally
      FreeAndNil(cmdRetorno);
    end;
  finally
    FreeAndNil(cmdRequisicao);
  end;
end;

function TClientDataSet.MetodoAlterar(oJSON: TJSONObject): TJSONObject;
var
  cmdRequisicao: TComando;
  cmdRetorno: TComando;
begin
  cmdRequisicao := TComando.Create;
  try
    cmdRequisicao.Recurso := FTabela +'.alterar';
    oJSON.AddPair('id', TJSONNumber.Create(Self.FieldByName('id').AsInteger));
    cmdRequisicao.Dados.AddElement(TJSONObject(oJSON.Clone));
    cmdRetorno := TComando.Create(FWebSocket.EnviaAguarda(cmdRequisicao.Texto));
    try
      // Trata erro
      if not cmdRetorno.Erro.Classe.IsEmpty then
        raise Exception.Create('Erro ao alterar!'+ sl + cmdRetorno.Erro.Classe + sl + cmdRetorno.Erro.Mensagem);
      Result := TJSONObject(cmdRetorno.Dados.Items[0].Clone);
    finally
      FreeAndNil(cmdRetorno);
    end;
  finally
    FreeAndNil(cmdRequisicao);
  end;
end;

procedure TClientDataSet.MetodoExcluir;
var
  cmdRequisicao: TComando;
  cmdRetorno: TComando;
begin
  cmdRequisicao := TComando.Create;
  try
    cmdRequisicao.Recurso := FTabela +'.excluir';
    cmdRequisicao.Dados.AddElement(TJSONObject.Create.AddPair('id', TJSONNumber.Create(Self.FieldByName('id').AsInteger)));
    cmdRetorno := TComando.Create(FWebSocket.EnviaAguarda(cmdRequisicao.Texto));
    try
      // Trata erro
      if not cmdRetorno.Erro.Classe.IsEmpty then
        raise Exception.Create('Erro ao excluir!'+ sl + cmdRetorno.Erro.Classe + sl + cmdRetorno.Erro.Mensagem);
    finally
      FreeAndNil(cmdRetorno);
    end;
  finally
    FreeAndNil(cmdRequisicao);
  end;
end;

procedure TClientDataSet.FieldOnValidate(Sender: TField);
var
  I: Integer;
begin
  // Obtem a posição dos dados do field nos arrays
  I := Sender.Index;
  // Se tem evento de validação para ser executado, executa
  if Assigned(aOnValidate[I]) then
    aOnValidate[I](Sender);
  // Define que os dados do field foram alterados
  aChanged[I] := True;
end;

procedure TClientDataSet.LoadFromJSONArray(aJSON : TJSONArray);
var
  adJSON : TCustomJSONDataSetAdapter;
begin
  // Cria adaptador
  adJSON := TCustomJSONDataSetAdapter.Create(nil);
  try
    // Informa o ClientDataSet que vai receber os dados
    adJSON.Dataset := TDataSet(Self);
    // Executa
    adJSON.UpdateDataSet(aJSON);
  finally
    // Limpa da memória
    FreeAndNil(adJSON);
  end;
end;

function TClientDataSet.WSOpen(consulta: TConsulta = nil): TClientDataSet;
var
  I,J          : Integer;
  DField       : TField;
  aJSONTBL     : TJSONArray;
  oJSONROW     : TJSONObject;
  oJSONCEL     : TJSONPair;
  RBeforePost  : TDataSetNotifyEvent;
  ROnNewRecord : TDataSetNotifyEvent;
  ROnPosError  : TDataSetErrorEvent;
  aOnChange    : Array of TFieldNotifyEvent;
  aOnSetText   : Array of TFieldSetTextEvent;
  aOnValidate  : Array of TFieldNotifyEvent;
begin
  Result := Self;

  // Se estiver ativo, limpa os dados atuais
  if Self.Active then
    Self.EmptyDataSet;

  // Executa chamada e obtem o retorno
  try
    aJSONTBL := MetodoObter(consulta);
  finally
    FreeAndNil(consulta);
  end;
  try
    // Se o ClientDataSet não possui campos
    if FFieldCount = 0 then
    begin
      // Carrega campos da consulta
      Self.LoadFromJSONArray(aJSONTBL);

      // Posiciona no primeiro registro
      if not Self.IsEmpty then
        Self.First;

      // Coloca o ClientDataSet em estado de Navegacao
      Self.FWSState := dsBrowse;

      // Sai da função
      Exit;
    end;

    // Remove eventos do dataset
    RBeforePost      := Self.BeforePost;
    ROnNewRecord     := Self.OnNewRecord;
    ROnPosError      := Self.OnPostError;
    Self.BeforePost  := nil;
    Self.OnNewRecord := nil;
    Self.OnPostError := nil;
    try
      // Cria arrays para armazenar os eventos dos fields
      SetLength(aOnChange   ,FFieldCount);
      SetLength(aOnSetText  ,FFieldCount);
      SetLength(aOnValidate ,FFieldCount);

      // Sobrescreve eventos dos fields
      for I := 0 to Pred(FFieldCount) do
      begin
        DField            := Self.Fields[I];
        aOnChange[I]      := DField.OnChange;
        aOnSetText[I]     := DField.OnSetText;
        aOnValidate[I]    := DField.OnValidate;
        DField.OnChange   := nil;
        DField.OnSetText  := nil;
        DField.OnValidate := nil;
      end;

      // Desativa os controles para não executar os eventos do DataSource
      Self.DisableControls;
      try
        // Passar por todas as linhas da tabela
        for I := 0 to Pred(aJSONTBL.Count) do
        begin
          // Insere no dataset
          Self.Append;

          // Obtem a linha
          oJSONROW := TJSONObject(aJSONTBL.Items[I]);

          // Passa por todas as colunas
          for J := 0 to Pred(oJSONROW.Count) do
          begin
            // Obtem a célula
            oJSONCEL := oJSONROW.Pairs[J];

            // Obtem o field do dataset correspondente ao nome do par JSON
            DField := Self.FindField(oJSONCEL.JsonString.Value);

            // Se existe o field
            if DField <> nil then
            begin
              // Veifica se não é nulo
              if not (oJSONCEL.JsonValue is TJSONNull) then
              begin
                // Formata o valor de acordo com o tipo do field
                if DField is TNumericField then
                  DField.AsFloat := StrToFloat(oJSONCEL.JsonValue.Value)
                else
                if not(DField is TTimeField) and
                  ((DField is TDateTimeField) or (DField is TSQLTimeStampField)) then
                  DField.Value := ISO8601ToDate(oJSONCEL.JsonValue.Value)
                else
                if DField is TBlobField then
                  //TBlobField(DField).Value := TNetEncoding.Base64.DecodeStringToBytes(oJSONCEL.JsonValue.Value)
                  TBlobField(DField).AsString := oJSONCEL.JsonValue.Value
                else
                  DField.AsString := oJSONCEL.JsonValue.Value;
              end;
            end;
          end;
        end;
      finally
        // Reinsere evento original dos fields
        for I := 0 to Pred(FFieldCount) do
        begin
          DField            := Self.Fields[I];
          DField.OnChange   := aOnChange[I];
          DField.OnSetText  := aOnSetText[I];
          DField.OnValidate := aOnValidate[I];
        end;

        // Ativa os controles
        Self.EnableControls;

        // Passa pelo StateChange do DataSource
        Self.First;
      end;
    finally
      // Reatribui eventos do dataset
      Self.BeforePost  := RBeforePost;
      Self.OnNewRecord := ROnNewRecord;
      Self.OnPostError := ROnPosError;
    end;
    // Coloca o ClientDataSet em estado de Navegacao
    Self.FWSState := dsBrowse;
  finally
    FreeAndNil(aJSONTBL);
  end;
end;

function TClientDataSet.WSClose: TClientDataSet;
begin
  Result  := Self;
  if Self.Active then
    Self.EmptyDataSet;
end;

function TClientDataSet.WSAppend: TClientDataSet;
begin
  Result := Self;
  Self.Append;
  Self.FWSState := dsInsert;
  // Inicializa informação sobre alteração dos dados
  Finalize(aChanged);
  SetLength(aChanged, FFieldCount);
end;

function TClientDataSet.WSEdit: TClientDataSet;
begin
  Result := Self;
  Self.Edit;
  Self.FWSState := dsEdit;
  // Inicializa informação sobre alteração dos dados
  Finalize(aChanged);
  SetLength(aChanged, FFieldCount);
end;

function TClientDataSet.WSPost: TClientDataSet;
var
  I           : Integer;
  oJSON       : TJSONObject;
  oRETURN     : TJSONObject;
  RField      : TField;
  RBeforePost : TDataSetNotifyEvent;
  ROnPosError : TDataSetErrorEvent;
  ROnChange   : TFieldNotifyEvent;
  ROnSetText  : TFieldSetTextEvent;
  ROnValidate : TFieldNotifyEvent;
  OleData     : OleVariant;
begin
  Result := Self;

  // Se estiver inserindo ou editando
  if FWSState in [dsInsert, dsEdit] then
  begin
    try
      // Executa validação dos dados
      Self.Post;
    except on E: Exception do
      begin
        // Volta para edicao, caso der erro, ja estara em edicao
        Self.Edit;

        // Retorna mensagem de erro original
        raise EAbort.Create(E.Message);
      end;
    end;
  end
  else
  begin
    // Se não for tratado, o registro não será gravado e o usuário não será avisado
    raise Exception.Create(Self.Name +': Registro não está em edição!');
  end;

  // Executa evento antes de enviar os dados ao servidor
  OleData := Self.Data;
  if Assigned(Self.BeforeApplyUpdates) then
    Self.BeforeApplyUpdates(Self, OleData);

  oJSON := TJSONObject.Create;
  try
    // Obtem os dados do cds
    for I := 0 to Pred(FFieldCount) do
    begin
      // Será enviado ao Servidor apenas fields do tipo fkData
      if Self.Fields[I].FieldKind <> fkData then
        Continue;

      // Se o campo não é Update, Where e nem Key, não será enviado ao Servidor
      if (Self.Fields[I].ProviderFlags * [pfInUpdate, pfInWhere, pfInKey]) = [] then
        Continue;

      // Inserção envia todos os campos
      if (FWSState = dsEdit)                                              and  // Se for edição
         (not aChanged[Self.Fields[I].Index])                               and  // Se o campo não foi alterado
         (not ((Self.Fields[I].ProviderFlags * [pfInWhere, pfInKey]) = [])) then // Se não é where nem key
        Continue;

      // Converter para tipo correto
      if Self.Fields[I].IsNull then
        oJSON.AddPair(Self.Fields[I].FieldName, TJSONNull.Create)
      else
      if Self.Fields[I] is TStringField then
        oJSON.AddPair(Self.Fields[I].FieldName, Self.Fields[I].AsString)
      else
      if Self.Fields[I] is TNumericField then
        oJSON.AddPair(Self.Fields[I].FieldName, TJSONNumber.Create(Self.Fields[I].AsFloat))
      else
      if (Self.Fields[I] is TDateTimeField) or (Self.Fields[I] is TSQLTimeStampField) then
        oJSON.AddPair(Self.Fields[I].FieldName, DateToISO8601(Self.Fields[I].AsDateTime))
      else
      if Self.Fields[I] is TBlobField then
        oJSON.AddPair(Self.Fields[I].FieldName, TBlobField(Self.Fields[I]).AsString)
      else
        raise Exception.Create(Self.Name +': Tipo do campo não esperado!'+ sl +'Campo: '+ Self.Fields[I].FieldName +' - Tipo: '+ TRTTIEnumerationType.GetName(Self.Fields[I].DataType));
    end;

    // Envia ao servidor
    try
      case FWSState of
        dsInsert: oRETURN := MetodoIncluir(oJSON);
        dsEdit:   oRETURN := MetodoAlterar(oJSON)
      end;

      // Passa por todos os campos informando que não estão mais alterados
      Finalize(aChanged);
      SetLength(aChanged, FFieldCount);

      // Se for inserção, o servidor irá retornar o registro para os campos auto incremento do banco
      if FWSState = dsInsert then
      begin
        // Armazena eventos originais
        RBeforePost      := Self.BeforePost;
        ROnPosError      := Self.OnPostError;
        Self.BeforePost  := nil;
        Self.OnPostError := nil;
        try
          // Insere os dados no cds
          Self.Edit;

          // Passar por todas os campos retornados pelo servidor
          for I := 0 to Pred(oRETURN.Count) do
          begin
            // Atribui field
            RField := Self.FindField(oRETURN.Pairs[I].JSONString.Value);
            if RField <> nil then
            begin
              // Armazena evntos do field
              ROnChange         := RField.OnChange;
              ROnSetText        := RField.OnSetText;
              ROnValidate       := RField.OnValidate;
              RField.OnChange   := nil;
              RField.OnSetText  := nil;
              RField.OnValidate := nil;
              try
                RField.AsString := oRETURN.Pairs[I].JSONValue.Value;
              finally
                // Reatribui os eventos do field
                RField.OnChange   := ROnChange;
                RField.OnSetText  := ROnSetText;
                RField.OnValidate := ROnValidate;
              end;
            end;
          end;

          // Posta informações
          Self.Post;
        finally
          // Reatribui eventos do dataset
          Self.BeforePost  := RBeforePost;
          Self.OnPostError := ROnPosError;
        end;
      end;

      // Informa que o processo requisitado foi concluído
      Self.FWSState := dsBrowse;
    finally
      FreeAndNil(oRETURN);
    end;
  finally
    FreeAndNil(oJSON);
  end;

  // Executa evento depois de enviar os dados ao servidor
  OleData := Self.Data;
  if Assigned(Self.AfterApplyUpdates) then
    Self.AfterApplyUpdates(Self, OleData);
end;

function TClientDataSet.WSCancel: TClientDataSet;
begin
  Result := Self;

  // Cancela as alterações do registro atual
  Self.Cancel;

  // Atualiza o tipo de requisição do usuário
  Self.FWSState := dsBrowse;
end;

function TClientDataSet.WSDelete: TClientDataSet;
begin
  Result := Self;

  MetodoExcluir;

  // Deleta o registro do cds
  Self.Delete;

  // Atualiza o tipo de requisição do usuário
  Self.FWSState := dsBrowse;
end;

end.