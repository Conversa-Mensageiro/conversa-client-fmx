inherited ConversaSessaoListaController: TConversaSessaoListaController
  OldCreateOrder = True
  object cdsSessoesAtivas: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 88
    Top = 56
    object qrySessoesAtivasid: TIntegerField
      FieldName = 'id'
      Origin = 'id'
    end
    object qrySessoesAtivasnome: TStringField
      FieldName = 'nome'
      Origin = 'nome'
      Required = True
      Size = 200
    end
    object qrySessoesAtivasapelido: TStringField
      FieldName = 'apelido'
      Origin = 'apelido'
      Required = True
      Size = 50
    end
    object qrySessoesAtivasemail: TStringField
      FieldName = 'email'
      Origin = 'email'
      Required = True
      Size = 100
    end
    object qrySessoesAtivasusuario: TStringField
      FieldName = 'usuario'
      Origin = 'usuario'
      Required = True
      Size = 50
    end
    object qrySessoesAtivassenha: TStringField
      FieldName = 'senha'
      Origin = 'senha'
      Required = True
      Size = 50
    end
    object qrySessoesAtivasconectado: TIntegerField
      FieldName = 'conectado'
      Origin = 'conectado'
    end
    object qrySessoesAtivasactive: TIntegerField
      FieldName = 'active'
      Origin = 'active'
    end
  end
end
