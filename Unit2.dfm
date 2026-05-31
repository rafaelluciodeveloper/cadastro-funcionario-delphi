object FrmRelatorio: TFrmRelatorio
  Left = 200
  Top = 50
  Width = 680
  Height = 760
  Caption = 'Pr'#233'-visualiza'#231#227'o do Relat'#243'rio'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object QuickRep1: TQuickRep
    Left = 0
    Top = 0
    Width = 635
    Height = 898
    Frame.Color = clBlack
    Frame.DrawTop = False
    Frame.DrawBottom = False
    Frame.DrawLeft = False
    Frame.DrawRight = False
    Options = [FirstPageHeader, LastPageFooter]
    Page.Columns = 1
    Page.Orientation = poPortrait
    Page.PaperSize = A4
    Page.Values = (
      100.000000000000000000
      2970.000000000000000000
      100.000000000000000000
      2100.000000000000000000
      100.000000000000000000
      100.000000000000000000
      0.000000000000000000)
    PrinterSettings.Copies = 1
    PrinterSettings.Duplex = False
    PrinterSettings.OutputBin = First
    PrintIfEmpty = False
    SnapToGrid = True
    Units = MM
    Zoom = 80
    object TitleBand1: TQRBand
      Left = 30
      Top = 30
      Width = 575
      Height = 76
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        251.330000000000000000
        1901.525000000000000000)
      BandType = rbTitle
      object QRLblTitulo: TQRLabel
        Left = 0
        Top = 8
        Width = 575
        Height = 32
        Size.Values = (
          105.824000000000000000
          0.000000000000000000
          26.456000000000000000
          1901.525000000000000000)
        Alignment = taCenter
        AlignToBand = True
        AutoSize = False
        AutoStretch = False
        Caption = 'RELAT'#211'RIO DE FUNCION'#193'RIOS'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -24
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = True
        FontSize = 18
      end
      object QRLblSubtitulo: TQRLabel
        Left = 0
        Top = 44
        Width = 575
        Height = 18
        Size.Values = (
          59.526000000000000000
          0.000000000000000000
          145.508000000000000000
          1901.525000000000000000)
        Alignment = taCenter
        AlignToBand = True
        AutoSize = False
        AutoStretch = False
        Caption = 'Cadastro Geral de Funcion'#225'rios'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = [fsItalic]
        ParentFont = False
        Transparent = True
        WordWrap = True
        FontSize = 11
      end
      object QRShapeTitulo: TQRShape
        Left = 0
        Top = 68
        Width = 575
        Height = 3
        Size.Values = (
          9.921000000000000000
          0.000000000000000000
          224.876000000000000000
          1901.525000000000000000)
        Shape = qrsHorLine
      end
    end
    object PageHeaderBand1: TQRBand
      Left = 30
      Top = 106
      Width = 575
      Height = 36
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        119.052000000000000000
        1901.525000000000000000)
      BandType = rbPageHeader
      object QRLblSistema: TQRLabel
        Left = 4
        Top = 8
        Width = 300
        Height = 16
        Size.Values = (
          52.912000000000000000
          13.228000000000000000
          26.456000000000000000
          992.100000000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Sistema de Cadastro de Funcion'#225'rios'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = True
        FontSize = 9
      end
      object QRSysDataHeader: TQRSysData
        Left = 320
        Top = 8
        Width = 251
        Height = 16
        Size.Values = (
          52.912000000000000000
          1058.240000000000000000
          26.456000000000000000
          830.057000000000000000)
        Alignment = taRightJustify
        AlignToBand = False
        AutoSize = False
        Color = clWhite
        Data = qrsDateTime
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        Text = 'Emitido em: '
        Transparent = True
        FontSize = 9
      end
      object QRShapeHeader: TQRShape
        Left = 0
        Top = 28
        Width = 575
        Height = 2
        Size.Values = (
          6.614000000000000000
          0.000000000000000000
          92.596000000000000000
          1901.525000000000000000)
        Shape = qrsHorLine
      end
    end
    object ColumnHeaderBand1: TQRBand
      Left = 30
      Top = 142
      Width = 575
      Height = 30
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        99.210000000000000000
        1901.525000000000000000)
      BandType = rbColumnHeader
      object QRShapeColBg: TQRShape
        Left = 0
        Top = 2
        Width = 575
        Height = 26
        Size.Values = (
          85.982000000000000000
          0.000000000000000000
          6.614000000000000000
          1901.525000000000000000)
        Brush.Color = 14869218
        Pen.Style = psClear
        Shape = qrsRectangle
      end
      object QRLblColCodigo: TQRLabel
        Left = 4
        Top = 8
        Width = 28
        Height = 16
        Size.Values = (
          52.912000000000000000
          13.228000000000000000
          26.456000000000000000
          92.596000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'C'#243'd.'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
      object QRLblColNome: TQRLabel
        Left = 36
        Top = 8
        Width = 135
        Height = 16
        Size.Values = (
          52.912000000000000000
          119.052000000000000000
          26.456000000000000000
          446.445000000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Nome'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
      object QRLblColCPF: TQRLabel
        Left = 175
        Top = 8
        Width = 78
        Height = 16
        Size.Values = (
          52.912000000000000000
          578.725000000000000000
          26.456000000000000000
          257.946000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'CPF'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
      object QRLblColCargo: TQRLabel
        Left = 257
        Top = 8
        Width = 130
        Height = 16
        Size.Values = (
          52.912000000000000000
          849.899000000000000000
          26.456000000000000000
          429.910000000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Cargo'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
      object QRLblColSalario: TQRLabel
        Left = 391
        Top = 8
        Width = 65
        Height = 16
        Size.Values = (
          52.912000000000000000
          1293.037000000000000000
          26.456000000000000000
          214.955000000000000000)
        Alignment = taRightJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Sal'#225'rio'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
      object QRLblColAdmissao: TQRLabel
        Left = 460
        Top = 8
        Width = 50
        Height = 16
        Size.Values = (
          52.912000000000000000
          1521.220000000000000000
          26.456000000000000000
          165.350000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Admiss'#227'o'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
      object QRLblColAtivo: TQRLabel
        Left = 514
        Top = 8
        Width = 22
        Height = 16
        Size.Values = (
          52.912000000000000000
          1699.798000000000000000
          26.456000000000000000
          72.754000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Ativo'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
      object QRLblColCertificado: TQRLabel
        Left = 540
        Top = 8
        Width = 33
        Height = 16
        Size.Values = (
          52.912000000000000000
          1785.780000000000000000
          26.456000000000000000
          109.131000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Cert.'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
    end
    object DetailBand1: TQRBand
      Left = 30
      Top = 172
      Width = 575
      Height = 22
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = True
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      BeforePrint = DetailBand1BeforePrint
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        72.754000000000000000
        1901.525000000000000000)
      BandType = rbDetail
      object QRDBCodigo: TQRDBText
        Left = 4
        Top = 4
        Width = 28
        Height = 14
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          46.298000000000000000
          13.228000000000000000
          13.228000000000000000
          92.596000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataField = 'Codigo'
        Transparent = False
        WordWrap = True
        FontSize = 9
      end
      object QRDBNome: TQRDBText
        Left = 36
        Top = 4
        Width = 135
        Height = 14
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          46.298000000000000000
          119.052000000000000000
          13.228000000000000000
          446.445000000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataField = 'Nome'
        Transparent = False
        WordWrap = True
        FontSize = 9
      end
      object QRDBCPF: TQRDBText
        Left = 175
        Top = 4
        Width = 78
        Height = 14
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          46.298000000000000000
          578.725000000000000000
          13.228000000000000000
          257.946000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataField = 'CPF'
        Transparent = False
        WordWrap = True
        FontSize = 9
      end
      object QRDBCargo: TQRDBText
        Left = 257
        Top = 4
        Width = 130
        Height = 14
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          46.298000000000000000
          849.899000000000000000
          13.228000000000000000
          429.910000000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataField = 'Cargo'
        Transparent = False
        WordWrap = True
        FontSize = 9
      end
      object QRDBSalario: TQRDBText
        Left = 391
        Top = 4
        Width = 65
        Height = 14
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          46.298000000000000000
          1293.037000000000000000
          13.228000000000000000
          214.955000000000000000)
        Alignment = taRightJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataField = 'Salario'
        Transparent = False
        WordWrap = True
        FontSize = 9
      end
      object QRDBAdmissao: TQRDBText
        Left = 460
        Top = 4
        Width = 50
        Height = 14
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          46.298000000000000000
          1521.220000000000000000
          13.228000000000000000
          165.350000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataField = 'DataAdmissao'
        Transparent = False
        WordWrap = True
        FontSize = 9
      end
      object QRLblAtivoValor: TQRLabel
        Left = 514
        Top = 4
        Width = 22
        Height = 14
        Size.Values = (
          46.298000000000000000
          1699.798000000000000000
          13.228000000000000000
          72.754000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = ''
        Color = clWhite
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
      object QRLblCertificadoValor: TQRLabel
        Left = 540
        Top = 4
        Width = 33
        Height = 14
        Size.Values = (
          46.298000000000000000
          1785.780000000000000000
          13.228000000000000000
          109.131000000000000000)
        Alignment = taCenter
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = ''
        Color = clWhite
        Transparent = True
        WordWrap = False
        FontSize = 9
      end
    end
    object PageFooterBand1: TQRBand
      Left = 30
      Top = 194
      Width = 575
      Height = 36
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        119.052000000000000000
        1901.525000000000000000)
      BandType = rbPageFooter
      object QRShapeFooter: TQRShape
        Left = 0
        Top = 2
        Width = 575
        Height = 2
        Size.Values = (
          6.614000000000000000
          0.000000000000000000
          6.614000000000000000
          1901.525000000000000000)
        Shape = qrsHorLine
      end
      object QRLblRodape: TQRLabel
        Left = 4
        Top = 12
        Width = 300
        Height = 14
        Size.Values = (
          46.298000000000000000
          13.228000000000000000
          39.684000000000000000
          992.100000000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Sistema de Cadastro de Funcion'#225'rios'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsItalic]
        ParentFont = False
        Transparent = True
        WordWrap = True
        FontSize = 8
      end
      object QRLblPaginaTxt: TQRLabel
        Left = 420
        Top = 12
        Width = 80
        Height = 14
        Size.Values = (
          46.298000000000000000
          1388.940000000000000000
          39.684000000000000000
          264.560000000000000000)
        Alignment = taRightJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'P'#225'gina:'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        Transparent = True
        WordWrap = True
        FontSize = 8
      end
      object QRSysDataPage: TQRSysData
        Left = 505
        Top = 12
        Width = 60
        Height = 14
        Size.Values = (
          46.298000000000000000
          1670.035000000000000000
          39.684000000000000000
          198.420000000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        Color = clWhite
        Data = qrsPageNumber
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Text = ''
        Transparent = True
        FontSize = 8
      end
    end
    object SummaryBand1: TQRBand
      Left = 30
      Top = 230
      Width = 575
      Height = 54
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        178.578000000000000000
        1901.525000000000000000)
      BandType = rbSummary
      object QRLblTotalTxt: TQRLabel
        Left = 10
        Top = 18
        Width = 280
        Height = 20
        Size.Values = (
          66.140000000000000000
          33.070000000000000000
          59.526000000000000000
          925.960000000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Total de funcion'#225'rios cadastrados:'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = True
        FontSize = 11
      end
      object QRExprTotal: TQRExpr
        Left = 295
        Top = 18
        Width = 80
        Height = 20
        Size.Values = (
          66.140000000000000000
          975.565000000000000000
          59.526000000000000000
          264.560000000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        Expression = 'COUNT'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = True
        FontSize = 11
        ResetAfterPrint = False
      end
    end
  end
end
