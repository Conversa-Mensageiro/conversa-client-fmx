inherited ConversaDispositivoController: TConversaDispositivoController
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  object qryDispositivo: TFDQuery
    Connection = ConversaConexaoBancoDados.conConversa
    SQL.Strings = (
      'SELECT dispositivo.id'
      '     , dispositivo.usuario_id'
      '     , dispositivo.status'
      '     , dispositivo.sessao'
      '     , dispositivo.tipo'
      '     , dispositivo_tipo.descricao AS tipo_descricao'
      '     , dispositivo.numero'
      '     , dispositivo.plataforma'
      '     , dispositivo_plataforma.descricao as plataforma_descricao'
      '     , dispositivo.plataforma_versao'
      '     , dispositivo.arquitetura'
      '     , arquitetura.descricao AS arquitetura_descricao'
      '     , dispositivo.arquitetura2'
      '     , arquitetura2.descricao AS arquitetura2_descricao'
      '     , dispositivo.linguagem'
      '     , dispositivo.fuso_horario'
      '     , dispositivo.conexao_rede'
      
        '     , dispositivo_conexao_rede.descricao AS conexao_rede_descri' +
        'cao'
      '     , dispositivo.dados_movel'
      
        '     , dispositivo_dados_movel.descricao AS dados_movel_descrica' +
        'o'
      '     , dispositivo.endereco_ip'
      '     , dispositivo.endereco_mac'
      '     , dispositivo.operadora_movel'
      
        '     , dispositivo_operadora_movel.descricao AS dispositivo_oper' +
        'adora_movel'
      '     , dispositivo.dispositivo_intel'
      '     , dispositivo.tela_fisica'
      '     , dispositivo.tela_logica'
      '  FROM dispositivo'
      '  LEFT'
      '  JOIN dispositivo_tipo'
      '    ON dispositivo_tipo.id = dispositivo.tipo'
      '  LEFT'
      '  JOIN dispositivo_plataforma'
      '    ON dispositivo_plataforma.id = dispositivo.plataforma'
      '  LEFT'
      '  JOIN dispositivo_arquitetura AS arquitetura'
      '    ON arquitetura.id = dispositivo.plataforma'
      '  LEFT'
      '  JOIN dispositivo_arquitetura AS arquitetura2'
      '    ON arquitetura2.id = dispositivo.plataforma'
      '  LEFT'
      '  JOIN dispositivo_linguagem'
      '    ON dispositivo_linguagem.id = dispositivo.linguagem'
      '  LEFT'
      '  JOIN dispositivo_conexao_rede'
      '    ON dispositivo_conexao_rede.id = conexao_rede'
      '  LEFT'
      '  JOIN dispositivo_dados_movel'
      '    ON dispositivo_dados_movel.id = dados_movel'
      '  LEFT'
      '  JOIN dispositivo_operadora_movel'
      '    ON dispositivo_operadora_movel.id = operadora_movel')
    Left = 96
    Top = 48
  end
end
