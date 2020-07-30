inherited ConversaBatePapoController: TConversaBatePapoController
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  object cdsMensagem: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 104
    Top = 56
    object cdsMensagemid: TFloatField
      FieldName = 'id'
    end
    object cdsMensagemmensagem_id: TFloatField
      FieldName = 'mensagem_id'
    end
    object cdsMensagemusuario_id: TFloatField
      FieldName = 'usuario_id'
    end
    object cdsMensagemconversa_id: TFloatField
      FieldName = 'conversa_id'
    end
    object cdsMensagemconteudo: TBlobField
      FieldName = 'conteudo'
    end
    object cdsMensagemresposta: TIntegerField
      FieldName = 'resposta'
    end
    object cdsMensagemconfirmacao: TIntegerField
      FieldName = 'confirmacao'
    end
    object cdsMensagemincluido_id: TFloatField
      FieldName = 'incluido_id'
    end
    object cdsMensagemincluido_em: TDateTimeField
      FieldName = 'incluido_em'
    end
    object cdsMensagemalterado_id: TIntegerField
      FieldName = 'alterado_id'
    end
    object cdsMensagemalterado_em: TDateTimeField
      FieldName = 'alterado_em'
    end
    object cdsMensagemexcluido_id: TIntegerField
      FieldName = 'excluido_id'
    end
    object cdsMensagemexcluido_em: TDateTimeField
      FieldName = 'excluido_em'
    end
  end
end
