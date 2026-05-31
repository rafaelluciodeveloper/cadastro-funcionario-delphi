object FrmAssinarXML: TFrmAssinarXML
  Left = 250
  Top = 100
  Width = 620
  Height = 540
  Caption = 'Assinar XML eSocial'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTopo: TPanel
    Left = 0
    Top = 0
    Width = 612
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    Color = clNavy
    TabOrder = 0
    object LblTitulo: TLabel
      Left = 0
      Top = 0
      Width = 612
      Height = 44
      Align = alClient
      Alignment = taCenter
      Caption = 'ASSINADOR DE XML eSOCIAL'
      Color = clNavy
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
  end
  object GroupCert: TGroupBox
    Left = 0
    Top = 44
    Width = 612
    Height = 80
    Align = alTop
    Caption = ' Certificado Digital '
    TabOrder = 1
    object LblCert: TLabel
      Left = 12
      Top = 22
      Width = 145
      Height = 13
      Caption = 'Selecione um certificado:'
    end
    object ComboCert: TComboBox
      Left = 12
      Top = 40
      Width = 490
      Height = 21
      ItemHeight = 13
      Style = csDropDownList
      TabOrder = 0
    end
    object BtnRecarregar: TButton
      Left = 510
      Top = 40
      Width = 90
      Height = 23
      Caption = '&Recarregar'
      TabOrder = 1
      OnClick = BtnRecarregarClick
    end
  end
  object GroupArquivo: TGroupBox
    Left = 0
    Top = 124
    Width = 612
    Height = 80
    Align = alTop
    Caption = ' Arquivo XML '
    TabOrder = 2
    object LblArquivo: TLabel
      Left = 12
      Top = 22
      Width = 140
      Height = 13
      Caption = 'Caminho do arquivo XML:'
    end
    object EditArquivo: TEdit
      Left = 12
      Top = 40
      Width = 490
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object BtnProcurar: TButton
      Left = 510
      Top = 39
      Width = 90
      Height = 23
      Caption = '&Procurar...'
      TabOrder = 1
      OnClick = BtnProcurarClick
    end
  end
  object GroupResultado: TGroupBox
    Left = 0
    Top = 204
    Width = 612
    Height = 257
    Align = alClient
    Caption = ' Log da Opera'#231#227'o '
    TabOrder = 3
    object MemoLog: TMemo
      Left = 2
      Top = 15
      Width = 608
      Height = 240
      Align = alClient
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object PanelBotoes: TPanel
    Left = 0
    Top = 461
    Width = 612
    Height = 52
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object BtnAssinar: TButton
      Left = 360
      Top = 12
      Width = 120
      Height = 30
      Caption = '&Assinar'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = BtnAssinarClick
    end
    object BtnFechar: TButton
      Left = 490
      Top = 12
      Width = 110
      Height = 30
      Cancel = True
      Caption = '&Fechar'
      TabOrder = 1
      OnClick = BtnFecharClick
    end
  end
  object OpenDlg: TOpenDialog
    Left = 12
    Top = 12
  end
end
