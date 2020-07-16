inherited ConversaListaController: TConversaListaController
  OldCreateOrder = True
  object qryConversa: TFDQuery
    Connection = ConversaConexaoBancoDados.conConversa
    SQL.Strings = (
      'SELECT conversa.id'
      '     , conversa.descricao'
      '     , conversa.tipo'
      '     , mensagem.id AS mensagem_id'
      '     , mensagem.conteudo'
      '     , mensagem.data'
      '     , qtd_sem_ler.qtd'
      '     , mensagem_confirmacao.tipo AS tipo_confirmacao'
      '  FROM conversa'
      '  LEFT'
      '  JOIN mensagem'
      '    ON mensagem.id = (SELECT msg.id'
      '                        FROM mensagem AS msg'
      '                       WHERE msg.conversa_id = conversa.id'
      '                       ORDER'
      '                          BY msg.data DESC'
      '                       LIMIT 1)'
      '  LEFT'
      '  JOIN mensagem_confirmacao'
      '    ON mensagem_confirmacao.id = (SELECT confirmacao.id'
      
        '                                    FROM mensagem_confirmacao as' +
        ' confirmacao'
      
        '                                   WHERE confirmacao.mensagem_id' +
        ' = mensagem.id'
      
        '                                     -- AND confirmacao.tipo IN(' +
        '1, 2, 3, 4, 5)'
      '                                   ORDER'
      '                                      BY confirmacao.tipo'
      '                                   LIMIT 1)'
      '  LEFT'
      '  JOIN (SELECT msg_qtd.conversa_id'
      '             , COUNT(1) AS qtd'
      '          FROM mensagem AS msg_qtd'
      '          LEFT'
      '          JOIN mensagem_confirmacao AS confirmacao'
      '            ON confirmacao.mensagem_id = msg_qtd.id'
      '           AND confirmacao.tipo        = 2 /* 2-Leitura */'
      '         GROUP'
      '            BY msg_qtd.conversa_id) AS qtd_sem_ler'
      '    ON qtd_sem_ler.conversa_id = conversa.id')
    Left = 88
    Top = 56
    object qryConversaid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryConversadescricao: TStringField
      FieldName = 'descricao'
      Origin = 'descricao'
      Required = True
      Size = 100
    end
    object qryConversatipo: TIntegerField
      FieldName = 'tipo'
      Origin = 'tipo'
      Required = True
    end
    object qryConversamensagem_id: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'mensagem_id'
      Origin = 'id'
      ProviderFlags = []
      ReadOnly = True
    end
    object qryConversaconteudo: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'conteudo'
      Origin = 'conteudo'
      ProviderFlags = []
      ReadOnly = True
      Size = 8000
    end
    object qryConversadata: TDateTimeField
      AutoGenerateValue = arDefault
      FieldName = 'data'
      Origin = 'data'
      ProviderFlags = []
      ReadOnly = True
    end
    object qryConversaqtd: TLargeintField
      AutoGenerateValue = arDefault
      FieldName = 'qtd'
      Origin = 'qtd'
      ProviderFlags = []
      ReadOnly = True
    end
    object qryConversatipo_confirmacao: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'tipo_confirmacao'
      Origin = 'tipo'
      ProviderFlags = []
      ReadOnly = True
    end
  end
end
