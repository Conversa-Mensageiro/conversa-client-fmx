object ConversaConexaoBancoDados: TConversaConexaoBancoDados
  OldCreateOrder = False
  Height = 150
  Width = 215
  object conConversa: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\danie\Downloads\Telegram Desktop\conversa-clie' +
        'nt-fmx-2020-07-14-00-29\deploy\Win32\base_dados\conversa.db'
      'LockingMode=Normal'
      'SharedCache=False'
      'DriverID=SQLite')
    Connected = True
    LoginPrompt = False
    Left = 80
    Top = 56
  end
end
