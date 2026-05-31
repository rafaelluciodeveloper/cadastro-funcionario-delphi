unit Unit2;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, DB,
  QuickRpt, QRCtrls, ExtCtrls, StdCtrls;

type
  TFrmRelatorio = class(TForm)
    QuickRep1: TQuickRep;
    TitleBand1: TQRBand;
    QRLblTitulo: TQRLabel;
    QRLblSubtitulo: TQRLabel;
    QRShapeTitulo: TQRShape;
    PageHeaderBand1: TQRBand;
    QRLblSistema: TQRLabel;
    QRSysDataHeader: TQRSysData;
    QRShapeHeader: TQRShape;
    ColumnHeaderBand1: TQRBand;
    QRShapeColBg: TQRShape;
    QRLblColCodigo: TQRLabel;
    QRLblColNome: TQRLabel;
    QRLblColCPF: TQRLabel;
    QRLblColCargo: TQRLabel;
    QRLblColSalario: TQRLabel;
    QRLblColAdmissao: TQRLabel;
    QRLblColAtivo: TQRLabel;
    QRLblColCertificado: TQRLabel;
    DetailBand1: TQRBand;
    QRDBCodigo: TQRDBText;
    QRDBNome: TQRDBText;
    QRDBCPF: TQRDBText;
    QRDBCargo: TQRDBText;
    QRDBSalario: TQRDBText;
    QRDBAdmissao: TQRDBText;
    QRLblAtivoValor: TQRLabel;
    QRLblCertificadoValor: TQRLabel;
    PageFooterBand1: TQRBand;
    QRShapeFooter: TQRShape;
    QRLblRodape: TQRLabel;
    QRLblPaginaTxt: TQRLabel;
    QRSysDataPage: TQRSysData;
    SummaryBand1: TQRBand;
    QRLblTotalTxt: TQRLabel;
    QRExprTotal: TQRExpr;
    procedure DetailBand1BeforePrint(Sender: TQRCustomBand;
      var PrintBand: Boolean);
  public
    procedure PrepararRelatorio(ATable: TDataSet);
  end;

var
  FrmRelatorio: TFrmRelatorio;

implementation

{$R *.dfm}

procedure TFrmRelatorio.PrepararRelatorio(ATable: TDataSet);
var
  i: Integer;
begin
  QuickRep1.DataSet := ATable;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TQRDBText then
      TQRDBText(Components[i]).DataSet := ATable;
end;

procedure TFrmRelatorio.DetailBand1BeforePrint(Sender: TQRCustomBand;
  var PrintBand: Boolean);
begin
  if QuickRep1.DataSet = nil then Exit;
  if QuickRep1.DataSet.FieldByName('Ativo').AsBoolean then
    QRLblAtivoValor.Caption := 'Sim'
  else
    QRLblAtivoValor.Caption := 'N'#227'o';

  if Trim(QuickRep1.DataSet.FieldByName('Certificado').AsString) <> '' then
    QRLblCertificadoValor.Caption := 'Sim'
  else
    QRLblCertificadoValor.Caption := 'N'#227'o';
end;

end.
