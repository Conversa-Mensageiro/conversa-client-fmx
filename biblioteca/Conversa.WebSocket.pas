{
 * Simple WebSocket client for Delphi
 * http://www.websocket.org/echo.html
 * Author: Lucas Rubian Schatz
 * Copyright 2018, Indy Working Group.
}

unit Conversa.WebSocket;

interface

uses
  System.Classes,
  System.SysUtils,
  IdSSLOpenSSL,
  IdTCPClient,
  IdGlobal,
  IdCoderMIME,
  IdHash,
  IdHashSHA,
  System.Math,
  System.Threading,
  DateUtils,
  System.SyncObjs,
  IdURI,
  IdStack,
  System.JSON,
  Conversa.Comando;

type
  TSWSCDataEvent = procedure(Sender: TObject; const Text: string) of object;
  TSWSCErrorEvent = procedure(Sender: TObject; exception: Exception; const Text: string; var forceDisconnect) of object;
  TOpCode = (TOContinuation, TOTextFrame, TOBinaryFrame, TOConnectionClose, TOPing, TOPong);

const
  TOpCodeByte: Array[TopCode] of Byte = ($0, $1, $2, $8, $9, $A);

type
  ErroAutenticar = class(Exception);
  ErroReconectar = class(EIdSocketError);

  TWebSocketClient = class(TIdTCPClient)
  private
    SecWebSocketAcceptExpectedResponse: String;
    FHeartBeatInterval: Cardinal;
    FURL: String;
    FOnUpgrade: TNotifyEvent;
    FonHeartBeatTimer: TNotifyEvent;
    FonError: TSWSCErrorEvent;
    FonPing: TSWSCDataEvent;
    FonConnectionDataEvent: TSWSCDataEvent;
    FMetodoReceber: TProc<TWebSocketClient, String>;
    FMetodoAutenticar: TFunc<TJSONObject>;
    FMetodoErro: TProc<TClass, String>;
    FUpgraded: Boolean;
    FAutenticado: Boolean;
    FIDUsuario: Int64;
    FResultado: String;
    FTerminou: Boolean;
    function Gatilho(s: String): Boolean;
  protected
    lInternalLock: TCriticalSection;
    lClosingEventLocalHandshake: Boolean;
    lSyncFunctionEvent: TSimpleEvent;
    lSyncFunctionTrigger: TFunc<String, Boolean>;
    function GetABit(const aValue: Cardinal; const Bit: Byte): Boolean;
    function SetABit(const aValue: Cardinal; const Bit: Byte): Cardinal;
    function ClearABit(const aValue: Cardinal; const Bit: Byte): Cardinal;
    procedure ReadFromWebSocket; virtual;
    function EncodeFrame(pMsg: String; pOpCode: TOpCode = TOpCode.TOTextFrame): TIdBytes;
    function VerifyHeader(pHeader: TStrings): Boolean;
    procedure StartHeartBeat;
    procedure SendCloseHandShake;
    function GenerateWebSocketKey: String;
  published
    property OnConnectionDataEvent: TSWSCDataEvent read FonConnectionDataEvent write FonConnectionDataEvent;
    property OnPing: TSWSCDataEvent read FonPing write FonPing;
    property OnError: TSWSCErrorEvent read FonError write FonError;
    property OnHeartBeatTimer: TNotifyEvent read FonHeartBeatTimer write FonHeartBeatTimer;
    property OnUpgrade: TnotifyEvent read FOnUpgrade write FOnUpgrade;
    property HeartBeatInterval: Cardinal read FHeartBeatInterval write FHeartBeatInterval;
    property URL: String read FURL write FURL;
    property IDUsuario: Int64 read FIDUsuario write FIDUsuario;
  public
    procedure Conectar(sURL: String);
    procedure Close;
    function Conectado: Boolean;
    function AoReceber(M: TProc<TWebSocketClient, String>): TWebSocketClient;
    function AoAutenticar(M: TFunc<TJSONObject>): TWebSocketClient;
    function AoErro(M: TProc<TClass, String>): TWebSocketClient;
    procedure Enviar(sMsg: String);
    function EnviaAguarda(sMsg: String): String;
    procedure Autenticacao;
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
end;

implementation

function TWebSocketClient.ClearABit(const aValue: Cardinal; const Bit: Byte): Cardinal;
begin
  Result := aValue and not (1 shl Bit);
end;

procedure TWebSocketClient.Close;
begin
  if not Self.Conectado then
    Exit;
  Self.lInternalLock.Enter;
  try
    if Self.Conectado then
    begin
      Self.SendCloseHandShake;
      Self.IOHandler.InputBuffer.Clear;
      Self.IOHandler.CloseGracefully;
      Self.Disconnect;
      if Assigned(self.OnDisconnected) then
        Self.OnDisconnected(Self);
    end;
  finally
    Self.lInternalLock.Leave;
  end
end;

function TWebSocketClient.GenerateWebSocketKey: String;
var
  rand: TidBytes;
  I: Integer;
begin
  SetLength(rand, 16);
  for I := low(rand) to High(rand) do
    rand[i] := byte(random(255));

  Result := TIdEncoderMIME.EncodeBytes(rand);
  Self.SecWebSocketAcceptExpectedResponse := Result +'258EAFA5-E914-47DA-95CA-C5AB0DC85B11';

  with TIdHashSHA1.Create do
  try
    SecWebSocketAcceptExpectedResponse := TIdEncoderMIME.EncodeBytes(HashString(Self.SecWebSocketAcceptExpectedResponse));
  finally
    Free;
  end;
end;

function TWebSocketClient.Conectado: Boolean;
begin
  Result := False;
  try
    Result := inherited Connected;
  except
  end
end;

procedure TWebSocketClient.Conectar(sURL: String);
var
  URI: TIdURI;
  lSecure: Boolean;
begin
  uri := nil;
  try
    FAutenticado := False;
    lClosingEventLocalHandshake := false;
    URI := TIdURI.Create(sURL);
    Self.URL := sURL;
    Self.Host := URI.Host;
    URI.Protocol := ReplaceOnlyFirst(URI.Protocol.ToLower, 'ws', 'http');

    if URI.Path = '' then
      URI.Path := '/';
    lSecure := uri.Protocol = 'https';

    if URI.Port.IsEmpty then
    begin
      if lSecure then
        Self.Port := 443
      else
        Self.Port := 80;
    end
    else
      Self.Port := StrToInt(URI.Port);

    if lSecure and (Self.IOHandler = nil) then
    begin
      Self.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
      (Self.IOHandler as TIdSSLIOHandlerSocketOpenSSL).SSLOptions.Mode := TIdSSLMode.sslmClient;
      (Self.IOHandler as TIdSSLIOHandlerSocketOpenSSL).SSLOptions.SSLVersions := [TIdSSLVersion.sslvTLSv1, TIdSSLVersion.sslvTLSv1_1, TIdSSLVersion.sslvTLSv1_2]; //depending on your server, change this at your code;
    end;

    if Self.Conectado then
      raise Exception.Create('Already connected, verify');

    inherited Connect;

    if not URI.Port.IsEmpty then
      URI.Host := URI.Host+':'+URI.Port;
    Self.Socket.WriteLn(Format('GET %s HTTP/1.1', [uri.path + uri.Document]));
    Self.Socket.WriteLn(Format('Host: %s', [URI.Host]));
    Self.Socket.WriteLn('User-Agent: Delphi WebSocket Simple Client');
    Self.Socket.WriteLn('Connection: keep-alive, Upgrade');
    Self.Socket.WriteLn('Upgrade: websocket');
    Self.Socket.WriteLn('Sec-WebSocket-Version: 13');
    Self.Socket.WriteLn(Format('Sec-WebSocket-Key: %s', [GenerateWebSocketKey]));
    Self.Socket.WriteLn('');

    ReadFromWebSocket;
    StartHeartBeat;
  finally
    URI.Free;
  end;
end;

procedure TWebSocketClient.SendCloseHandShake;
begin
  Self.lClosingEventLocalHandshake := True;
  Self.Socket.Write(Self.EncodeFrame('', TOpCode.TOConnectionClose));
  TThread.Sleep(200);
end;

constructor TWebSocketClient.Create(AOwner: TComponent);
begin
  inherited;
  lInternalLock := TCriticalSection.Create;
  Randomize;
  Self.HeartBeatInterval := 30000;
  FTerminou := False;
end;

destructor TWebSocketClient.Destroy;
begin
  FTerminou := True;
  lInternalLock.Free;
  if Assigned(Self.IOHandler) then
    Self.IOHandler.Free;
  inherited;
end;

function TWebSocketClient.EncodeFrame(pMsg: String; pOpCode: TOpCode): TIdBytes;
var
  FIN: Cardinal;
  MASK: Cardinal;
  MaskingKey: Array[0..3] of cardinal;
  EXTENDED_PAYLOAD_LEN: Array[0..3] of Cardinal;
  Buffer: TidBytes;
  I: Integer;
  xor1: Char;
  xor2: Char;
  ExtendedPayloadLength: Integer;
begin
  FIN := 0;
  FIN := SetABit(FIN,7) or TOpCodeByte[pOpCode];

  MASK  := SetABit(0,7);

  ExtendedPayloadLength := 0;
  if pMsg.Length <= 125 then
    MASK := Integer(MASK) + pMsg.Length
  else
  if pMsg.Length < intPower(2, 16) then
  begin
    MASK := MASK + 126;
    ExtendedPayloadLength := 2;
    EXTENDED_PAYLOAD_LEN[1] := Byte(pmsg.Length);
    EXTENDED_PAYLOAD_LEN[0] := Byte(pmsg.Length shr 8);
  end
  else
  begin
    mask := mask + 127;
    ExtendedPayloadLength := 4;
    EXTENDED_PAYLOAD_LEN[3] := Byte(pmsg.Length);
    EXTENDED_PAYLOAD_LEN[2] := Byte(pmsg.Length shr 8);
    EXTENDED_PAYLOAD_LEN[1] := Byte(pmsg.Length shr 16);
    EXTENDED_PAYLOAD_LEN[0] := Byte(pmsg.Length shr 32);
  end;
  MaskingKey[0] := Random(255);
  MaskingKey[1] := Random(255);
  MaskingKey[2] := Random(255);
  MaskingKey[3] := Random(255);

  SetLength(Buffer, 1 + 1 + ExtendedPayloadLength + 4 + pMsg.Length);
  Buffer[0] := FIN;
  Buffer[1] := MASK;
  for I := 0 to ExtendedPayloadLength-1 do
    Buffer[1 + 1 + i] := EXTENDED_PAYLOAD_LEN[i];

  for I := 0 to 3 do
    Buffer[1 + 1 + ExtendedPayloadLength + i] := MaskingKey[i];
  for I := 0 to pMsg.Length - 1 do
  begin
    {$IF DEFINED(iOS) or DEFINED(ANDROID)}
    xor1 := pMsg[i];
    {$ELSE}
    xor1 := pMsg[i + 1];
    {$ENDIF}
    xor2 := Chr(MaskingKey[((i) mod 4)]);
    xor2 := Chr(Ord(xor1) xor Ord(xor2));
    Buffer[1 + 1 + ExtendedPayloadLength + 4 + i] := Ord(xor2);
  end;
  Result := Buffer;
end;

function TWebSocketClient.GetABit(const aValue: Cardinal; const Bit: Byte): Boolean;
begin
  Result := (aValue and (1 shl Bit)) <> 0;
end;

procedure TWebSocketClient.ReadFromWebSocket;
var
  lSpool: string;
  b:Byte;
  T: ITask;
  lPos:Integer;
  lSize:int64;
  lOpCode:Byte;
  linFrame:Boolean;
  lMasked:boolean;
  lForceDisconnect:Boolean;
  lHeader:TStringlist;
begin
  lSpool := '';
  lPos := 0;
  lSize := 0;
  lOpCode := 0;
  lMasked := false;
  FUpgraded := false;
  lHeader := TStringList.Create;
  linFrame := false;

  try
    while Conectado and not FUpgraded do
    begin
      b := Self.Socket.ReadByte;
      lSpool := lSpool + Chr(b);
      if not FUpgraded and (b = Ord(#13)) then
      begin
        if lSpool = #10#13 then
        begin
          try
            if not VerifyHeader(lHeader) then
              raise Exception.Create('URL is not from an valid websocket server, not a valid response header found');
          finally
            lHeader.Free;
          end;
          FUpgraded := True;
          lSpool := '';
          lPos := 0;
        end
        else
        begin
          if Assigned(OnConnectionDataEvent) then
            OnConnectionDataEvent(Self, lSpool);
          lHeader.Add(lSpool.Trim);
          lSpool := '';
        end;
      end;
    end;
  except on E: Exception do
    begin
      lForceDisconnect := True;
      if Assigned(Self.OnError) then
        Self.OnError(Self, E, E.Message, lForceDisconnect);
      if lForceDisconnect then
        Self.Close;
      Exit;
    end;
  end;

  if Conectado then
    T := TTask.Run(
      procedure
      begin
        try
          while Conectado do
          begin
            if not FTerminou then
              b := Self.Socket.ReadByte;

            if FUpgraded and (lPos = 0) and GetABit(b, 7) then
            begin
              linFrame := True;
              lOpCode := ClearABit(b, 7);
              Inc(lPos);
            end
            else
            if FUpgraded and (lPos = 1) then
            begin
              lMasked := GetABit(b, 7);
              lSize := b;

              if lMasked then
                lSize := b - SetABit(0,7);

              if lSize = 0 then
                lPos := 0
              else
              if lSize = 126 then
                lsize := Self.Socket.ReadUInt16
              else
              if lSize = 127 then
                lsize := Self.Socket.ReadUInt64;

              Inc(lPos);
            end
            else
            if linFrame then
            begin
              lSpool := lSpool + Chr(b);

              if FUpgraded and (Length(lSpool) = lSize) then
              begin
                lPos := 0;
                linFrame := False;

                if lOpCode = TOpCodeByte[TOpCode.TOPing] then
                begin
                  try
                    lInternalLock.Enter;
                    Self.Socket.Write(EncodeFrame(lSpool, TOpCode.TOPong));
                  finally
                    lInternalLock.Leave;
                  end;

                  if Assigned(OnPing) then
                    OnPing(Self, lSpool);
                end
                else
                begin
                  if Assigned(Self.lSyncFunctionTrigger) and Self.lSyncFunctionTrigger(lSpool) then
                    Self.lSyncFunctionEvent.SetEvent
                  else
                  if FUpgraded and Assigned(FMetodoReceber) and (not (lOpCode = TOpCodeByte[TOpCode.TOConnectionClose]))  then
                    FMetodoReceber(Self, lSpool);
                end;

                lSpool := '';
                if lOpCode = TOpCodeByte[TOpCode.TOConnectionClose] then
                begin
                  if not Self.lClosingEventLocalHandshake then
                  begin
                    Self.Close;
                    if Assigned(Self.OnDisconnected) then
                      Self.OnDisconnected(self);
                  end;
                  Break
                end;
              end;
            end;
          end;
        except
          on E: EIdSocketError do
          begin
            try
              if Assigned(Self.IOHandler) then
                Self.IOHandler.Free;
              Self.Conectar(Self.URL);
            except on E: EIdSocketError do
              if Assigned(FMetodoErro) then
                FMetodoErro(ErroReconectar, E.Message);
            end;
          end;
          on E: Exception do
          begin
            lForceDisconnect := True;
            if Assigned(Self.OnError) then
              Self.OnError(Self, E, E.Message, lForceDisconnect);
            if lForceDisconnect then
              Self.Close;
          end;
        end;
      end);

  if (not Conectado or not FUpgraded) and (not ((lOpCode = TOpCodeByte[TOpCode.TOConnectionClose]) or lClosingEventLocalHandshake))then
    raise Exception.Create('Websocket not connected or timeout'+ QuotedStr(lSpool))
  else
  if Assigned(Self.OnUpgrade) then
    Self.OnUpgrade(Self);
end;

procedure TWebSocketClient.StartHeartBeat;
var
  TimeUltimaNotif: TDateTime;
  lForceDisconnect: Boolean;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      TimeUltimaNotif := Now;
      try
        while Self.Conectado and (Self.HeartBeatInterval > 0) do
        begin
          if MilliSecondsBetween(TimeUltimaNotif, Now) >= Floor(Self.HeartBeatInterval) then
          begin
            if Assigned(self.OnHeartBeatTimer) then
              Self.OnHeartBeatTimer(self);
            TimeUltimaNotif := Now;
          end;
          TThread.Sleep(500);
        end;
      except on E:Exception do
        begin
          lForceDisconnect := True;
          if Assigned(Self.OnError) then
            Self.OnError(Self, E, E.Message, lForceDisconnect);
          if lForceDisconnect then
            Self.Close;
        end;
      end;
    end
  ).Start;
end;

function TWebSocketClient.VerifyHeader(pHeader: TStrings): Boolean;
begin
  pHeader.NameValueSeparator := ':';
  Result := False;

  if (Pos('HTTP/1.1 101', pHeader[0]) = 0) and (Pos('HTTP/1.1', pHeader[0]) > 0) then
    raise Exception.Create(pHeader[0].SubString(9));

  if (pHeader.Values['Connection'].Trim.ToLower = 'upgrade') and (pHeader.Values['Upgrade'].Trim.ToLower = 'websocket') then
  begin
    if pHeader.Values['Sec-WebSocket-Accept'].Trim = Self.SecWebSocketAcceptExpectedResponse then
      Result := True
    else
    if pHeader.Values['Sec-WebSocket-Accept'].Trim.IsEmpty then
      Result := True
    else
      raise Exception.Create('Unexpected return key on Sec-WebSocket-Accept in handshake');
  end;
end;

function TWebSocketClient.SetABit(const aValue: Cardinal; const Bit: Byte): Cardinal;
begin
  Result := aValue or (1 shl Bit);
end;

function TWebSocketClient.AoAutenticar(M: TFunc<TJSONObject>): TWebSocketClient;
begin
  Result := Self;
  FMetodoAutenticar := M;
end;

procedure TWebSocketClient.Autenticacao;
var
  cmdRequisicao: TComando;
  cmdResposta: TComando;
  MetodoAutenticar: TFunc<TJSONObject>;
begin
  if FAutenticado or not Assigned(FMetodoAutenticar) then
    Exit;

  // Remove evento para sair do loop, armazena evento original na variavel
  MetodoAutenticar  := FMetodoAutenticar;
  FMetodoAutenticar := nil;
  try
    // Autenticação
    cmdRequisicao := TComando.Create;
    try
      cmdRequisicao.Recurso := 'autenticacao';
      cmdRequisicao.Dados.AddElement(MetodoAutenticar);
      cmdResposta := TComando.Create(EnviaAguarda(cmdRequisicao.Texto));
      try
        FAutenticado := cmdResposta.Dados.GetValue<Boolean>('[0].autenticado');
        if FAutenticado then
          FIDUsuario := cmdResposta.Dados.GetValue<Int64>('[0].id')
        else
          if Assigned(FMetodoErro) then
            FMetodoErro(ErroAutenticar, cmdResposta.Dados.GetValue<String>('[0].motivo'))
          else
            raise Exception.Create(cmdResposta.Dados.GetValue<String>('[0].motivo'));
      finally
        FreeAndNil(cmdResposta);
      end;
    finally
      FreeAndNil(cmdRequisicao);
    end;
  finally
    FMetodoAutenticar := MetodoAutenticar;
  end;
end;

function TWebSocketClient.AoErro(M: TProc<TClass, String>): TWebSocketClient;
begin
  Result := Self;
  FMetodoErro := M;
end;

function TWebSocketClient.AoReceber(M: TProc<TWebSocketClient, String>): TWebSocketClient;
begin
  Result := Self;
  FMetodoReceber := M;
end;

procedure TWebSocketClient.Enviar(sMsg: String);
begin
  Autenticacao;
  try
    lInternalLock.Enter;
    try
      if not Self.Conectado then
      begin
        try
          Self.Conectar(Self.URL);
          Autenticacao;
        except on E: EIdSocketError do
          if Assigned(FMetodoErro) then
            FMetodoErro(ErroReconectar, E.Message);
        end;
      end;
      Self.Socket.Write(EncodeFrame(sMsg));
    except on E: EIdSocketError do
      begin
        if Assigned(Self.IOHandler) then
          Self.IOHandler.Free;
        Self.Conectar(Self.URL);
      end;
    end;
  finally
    lInternalLock.Leave;
  end;
end;

function TWebSocketClient.Gatilho(s: String): Boolean;
begin
  FResultado := s;
  Result := True;
end;

function TWebSocketClient.EnviaAguarda(sMsg: String): String;
begin
  Autenticacao;
  FResultado := '';
  Self.lSyncFunctionTrigger := Gatilho;
  try
    Self.lSyncFunctionEvent := TSimpleEvent.Create;
    Self.lSyncFunctionEvent.ResetEvent;
    Self.Enviar(sMsg);
    Self.lSyncFunctionEvent.WaitFor(Self.ReadTimeout);
    Result := FResultado;
  finally
    Self.lSyncFunctionTrigger:= nil;
    Self.lSyncFunctionEvent.Free;
  end;
end;

end.
