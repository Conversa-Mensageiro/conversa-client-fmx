inherited ConversaListaController: TConversaListaController
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  object cdsConversa: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 80
    Top = 56
    object cdsConversaid: TIntegerField
      FieldName = 'id'
      Origin = 'id'
    end
    object cdsConversadescricao: TStringField
      FieldName = 'descricao'
      Origin = 'descricao'
      Size = 100
    end
    object cdsConversatipo: TIntegerField
      FieldName = 'tipo'
      Origin = 'tipo'
    end
    object cdsConversamensagem_id: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'mensagem_id'
      Origin = 'id'
      ProviderFlags = []
    end
    object cdsConversaconteudo: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'conteudo'
      Origin = 'conteudo'
      ProviderFlags = []
      Size = 8000
    end
    object cdsConversamsg_incluido_em: TDateTimeField
      AutoGenerateValue = arDefault
      FieldName = 'msg_incluido_em'
      Origin = 'data'
      ProviderFlags = []
    end
    object cdsConversaqtd: TLargeintField
      AutoGenerateValue = arDefault
      FieldName = 'qtd'
      Origin = 'qtd'
      ProviderFlags = []
    end
    object cdsConversatipo_confirmacao: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'tipo_confirmacao'
      Origin = 'tipo'
      ProviderFlags = []
    end
  end
end
