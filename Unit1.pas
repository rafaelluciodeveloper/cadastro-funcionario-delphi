unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBTables, Grids, DBGrids, DBCtrls, StdCtrls, Mask, ExtCtrls,
  ComCtrls, ShellAPI;

type
  TForm1 = class(TForm)
    PanelTopo: TPanel;
    LblTitulo: TLabel;
    GroupBoxDados: TGroupBox;
    LblCodigo: TLabel;
    LblNome: TLabel;
    LblCPF: TLabel;
    LblEmail: TLabel;
    LblTelefone: TLabel;
    LblCargo: TLabel;
    LblSalario: TLabel;
    LblData: TLabel;
    DBEditCodigo: TDBEdit;
    DBEditNome: TDBEdit;
    DBEditCPF: TDBEdit;
    DBEditEmail: TDBEdit;
    DBEditTelefone: TDBEdit;
    DBEditCargo: TDBEdit;
    DBEditSalario: TDBEdit;
    DBEditData: TDBEdit;
    DBCheckAtivo: TDBCheckBox;
    LblCertificado: TLabel;
    ComboCertificado: TDBComboBox;
    PanelBusca: TPanel;
    LblLocalizar: TLabel;
    EditLocalizar: TEdit;
    BtnBuscar: TButton;
    BtnLimpar: TButton;
    PanelBotoes: TPanel;
    BtnNovo: TButton;
    BtnEditar: TButton;
    BtnSalvar: TButton;
    BtnCancelar: TButton;
    BtnExcluir: TButton;
    BtnRelatorio: TButton;
    BtnImportar: TButton;
    BtnExemplo: TButton;
    BtnAssinarXML: TButton;
    BevelBotoes: TBevel;
    BtnSair: TButton;
    DBGrid1: TDBGrid;
    StatusBar1: TStatusBar;
    Table1: TTable;
    DataSource1: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Table1BeforePost(DataSet: TDataSet);
    procedure Table1AfterScroll(DataSet: TDataSet);
    procedure Table1AfterPost(DataSet: TDataSet);
    procedure Table1AfterDelete(DataSet: TDataSet);
    procedure DataSource1StateChange(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure BtnEditarClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);
    procedure BtnRelatorioClick(Sender: TObject);
    procedure BtnImportarClick(Sender: TObject);
    procedure BtnExemploClick(Sender: TObject);
    procedure BtnAssinarXMLClick(Sender: TObject);
    procedure BtnBuscarClick(Sender: TObject);
    procedure BtnLimparClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure EditLocalizarChange(Sender: TObject);
  private
    FImportando: Boolean;
    procedure CriarTabelaSeNaoExiste;
    procedure ConfigurarCampos;
    procedure AtualizarStatus;
    procedure AtualizarBotoes;
    procedure CarregarCertificados;
    procedure MigrarTabelaSeNecessario(const DataDir: string);
  end;

var
  Form1: TForm1;

implementation

uses Unit2, Unit3;

{$R *.dfm}

const
  CERT_NAME_FRIENDLY_DISPLAY_TYPE = 5;
  CERT_NAME_SIMPLE_DISPLAY_TYPE   = 4;

type
  HCERTSTORE     = Pointer;
  PCCERT_CONTEXT = Pointer;

function CertOpenSystemStoreA(hProv: Pointer;
  szSubsystemProtocol: PAnsiChar): HCERTSTORE;
  stdcall; external 'Crypt32.dll' name 'CertOpenSystemStoreA';

function CertCloseStore(hCertStore: HCERTSTORE; dwFlags: DWORD): BOOL;
  stdcall; external 'Crypt32.dll' name 'CertCloseStore';

function CertEnumCertificatesInStore(hCertStore: HCERTSTORE;
  pPrevCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT;
  stdcall; external 'Crypt32.dll' name 'CertEnumCertificatesInStore';

function CertGetNameStringA(pCertContext: PCCERT_CONTEXT; dwType: DWORD;
  dwFlags: DWORD; pvTypePara: Pointer; pszNameString: PAnsiChar;
  cchNameString: DWORD): DWORD;
  stdcall; external 'Crypt32.dll' name 'CertGetNameStringA';

procedure TForm1.FormCreate(Sender: TObject);
var
  DataDir: string;
begin
  DataDir := ExtractFilePath(Application.ExeName) + 'Dados';
  if not DirectoryExists(DataDir) then
    ForceDirectories(DataDir);

  Table1.DatabaseName := DataDir;
  Table1.TableName    := 'Funcionarios.db';
  Table1.TableType    := ttParadox;

  CriarTabelaSeNaoExiste;

  Table1.Open;
  MigrarTabelaSeNecessario(DataDir);
  if Table1.FindField('Certificado') <> nil then
    ComboCertificado.DataField := 'Certificado';
  ConfigurarCampos;
  CarregarCertificados;
  AtualizarStatus;
  AtualizarBotoes;
end;

procedure TForm1.MigrarTabelaSeNecessario(const DataDir: string);
begin
  if Table1.FindField('Certificado') <> nil then Exit;

  if MessageDlg('A tabela precisa ser atualizada para incluir o campo ' +
                'Certificado Digital.'#13#10#13#10 +
                'Os dados existentes ser'#227'o apagados. Use os bot'#245'es ' +
                '"Gerar Exemplo" e "Importar CSV" para recriar.'#13#10#13#10 +
                'Continuar?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
  begin
    Application.Terminate;
    Exit;
  end;

  Table1.Close;
  DeleteFile(DataDir + '\Funcionarios.db');
  DeleteFile(DataDir + '\Funcionarios.PX');
  DeleteFile(DataDir + '\Funcionarios.XG0');
  DeleteFile(DataDir + '\Funcionarios.YG0');
  DeleteFile(DataDir + '\Funcionarios.MB');
  CriarTabelaSeNaoExiste;
  Table1.Open;
end;

procedure TForm1.CarregarCertificados;
var
  hStore: HCERTSTORE;
  pCert: PCCERT_CONTEXT;
  Buf: array[0..255] of AnsiChar;
  Nome: string;
begin
  ComboCertificado.Items.Clear;
  ComboCertificado.Items.Add('');

  hStore := CertOpenSystemStoreA(nil, 'MY');
  if hStore = nil then Exit;
  try
    pCert := CertEnumCertificatesInStore(hStore, nil);
    while pCert <> nil do
    begin
      FillChar(Buf, SizeOf(Buf), 0);
      if CertGetNameStringA(pCert, CERT_NAME_FRIENDLY_DISPLAY_TYPE, 0, nil,
                            @Buf[0], SizeOf(Buf)) <= 1 then
        CertGetNameStringA(pCert, CERT_NAME_SIMPLE_DISPLAY_TYPE, 0, nil,
                           @Buf[0], SizeOf(Buf));
      Nome := string(PAnsiChar(@Buf[0]));
      if (Nome <> '') and (ComboCertificado.Items.IndexOf(Nome) < 0) then
        ComboCertificado.Items.Add(Nome);

      pCert := CertEnumCertificatesInStore(hStore, pCert);
    end;
  finally
    CertCloseStore(hStore, 0);
  end;
end;

procedure TForm1.CriarTabelaSeNaoExiste;
begin
  if Table1.Exists then Exit;

  with Table1 do
  begin
    with FieldDefs do
    begin
      Clear;
      Add('Codigo',       ftAutoInc,  0,  True);
      Add('Nome',         ftString,   60, True);
      Add('CPF',          ftString,   14, False);
      Add('Cargo',        ftString,   40, False);
      Add('Salario',      ftCurrency, 0,  False);
      Add('DataAdmissao', ftDate,     0,  False);
      Add('Email',        ftString,   80, False);
      Add('Telefone',     ftString,   20, False);
      Add('Ativo',        ftBoolean,  0,  False);
      Add('Certificado',  ftString,   100, False);
    end;

    with IndexDefs do
    begin
      Clear;
      Add('',        'Codigo', [ixPrimary, ixUnique]);
      Add('IdxNome', 'Nome',   [ixCaseInsensitive]);
    end;

    CreateTable;
  end;
end;

procedure TForm1.ConfigurarCampos;
begin
  Table1.FieldByName('Codigo').DisplayLabel       := 'Cod.';
  Table1.FieldByName('Nome').DisplayLabel         := 'Nome';
  Table1.FieldByName('CPF').DisplayLabel          := 'CPF';
  Table1.FieldByName('Cargo').DisplayLabel        := 'Cargo';
  Table1.FieldByName('Salario').DisplayLabel      := 'Salario';
  Table1.FieldByName('DataAdmissao').DisplayLabel := 'Admissao';
  Table1.FieldByName('Email').DisplayLabel        := 'E-mail';
  Table1.FieldByName('Telefone').DisplayLabel     := 'Telefone';
  Table1.FieldByName('Ativo').DisplayLabel        := 'Ativo';
  Table1.FieldByName('Certificado').DisplayLabel  := 'Certificado';

  TCurrencyField(Table1.FieldByName('Salario')).DisplayFormat := 'R$ #,##0.00';
  TDateField(Table1.FieldByName('DataAdmissao')).DisplayFormat := 'dd/mm/yyyy';

  Table1.FieldByName('CPF').EditMask          := '000\.000\.000\-00;1;_';
  Table1.FieldByName('Telefone').EditMask     := '!\(00\) 00000\-0000;1;_';
  Table1.FieldByName('DataAdmissao').EditMask := '00/00/0000;1;_';

  Table1.FieldByName('Codigo').DisplayWidth       := 5;
  Table1.FieldByName('Nome').DisplayWidth         := 30;
  Table1.FieldByName('CPF').DisplayWidth          := 14;
  Table1.FieldByName('Cargo').DisplayWidth        := 20;
  Table1.FieldByName('Salario').DisplayWidth      := 12;
  Table1.FieldByName('DataAdmissao').DisplayWidth := 10;
  Table1.FieldByName('Email').DisplayWidth        := 25;
  Table1.FieldByName('Telefone').DisplayWidth     := 15;
  Table1.FieldByName('Ativo').DisplayWidth        := 5;
  Table1.FieldByName('Certificado').DisplayWidth  := 20;
end;

procedure TForm1.Table1BeforePost(DataSet: TDataSet);
begin
  if Trim(DataSet.FieldByName('Nome').AsString) = '' then
  begin
    if not FImportando then
      MessageDlg('O campo Nome '#233' obrigat'#243'rio.', mtWarning, [mbOK], 0);
    Abort;
  end;

  if DataSet.State = dsInsert then
  begin
    if DataSet.FieldByName('DataAdmissao').IsNull then
      DataSet.FieldByName('DataAdmissao').AsDateTime := Date;
    if DataSet.FieldByName('Ativo').IsNull then
      DataSet.FieldByName('Ativo').AsBoolean := True;
  end;
end;

procedure TForm1.Table1AfterScroll(DataSet: TDataSet);
begin
  AtualizarStatus;
end;

procedure TForm1.Table1AfterPost(DataSet: TDataSet);
begin
  AtualizarStatus;
  AtualizarBotoes;
end;

procedure TForm1.Table1AfterDelete(DataSet: TDataSet);
begin
  AtualizarStatus;
  AtualizarBotoes;
end;

procedure TForm1.DataSource1StateChange(Sender: TObject);
begin
  AtualizarBotoes;
end;

procedure TForm1.AtualizarBotoes;
var
  Editando, TemRegistro: Boolean;
begin
  Editando    := Table1.State in [dsEdit, dsInsert];
  TemRegistro := Table1.Active and (Table1.RecordCount > 0);

  BtnNovo.Enabled      := not Editando;
  BtnEditar.Enabled    := (not Editando) and TemRegistro;
  BtnSalvar.Enabled    := Editando;
  BtnCancelar.Enabled  := Editando;
  BtnExcluir.Enabled   := (not Editando) and TemRegistro;
  BtnRelatorio.Enabled := (not Editando) and TemRegistro;
  BtnImportar.Enabled  := not Editando;
  BtnExemplo.Enabled   := not Editando;
  BtnAssinarXML.Enabled := not Editando;

  GroupBoxDados.Enabled := Editando;
  DBGrid1.Enabled       := not Editando;
  PanelBusca.Enabled    := not Editando;
end;

procedure TForm1.AtualizarStatus;
begin
  StatusBar1.Panels[0].Text := ' Total de registros: ' + IntToStr(Table1.RecordCount);
  if Table1.RecordCount > 0 then
    StatusBar1.Panels[1].Text := ' Registro atual: ' + IntToStr(Table1.RecNo)
  else
    StatusBar1.Panels[1].Text := ' Nenhum registro';
  StatusBar1.Panels[2].Text := ' Banco: Paradox (BDE)';
end;

procedure TForm1.BtnNovoClick(Sender: TObject);
begin
  Table1.Append;
  DBEditNome.SetFocus;
end;

procedure TForm1.BtnEditarClick(Sender: TObject);
begin
  Table1.Edit;
  DBEditNome.SetFocus;
end;

procedure TForm1.BtnSalvarClick(Sender: TObject);
begin
  Table1.Post;
end;

procedure TForm1.BtnCancelarClick(Sender: TObject);
begin
  Table1.Cancel;
end;

procedure TForm1.BtnExcluirClick(Sender: TObject);
begin
  if Table1.RecordCount = 0 then Exit;
  if MessageDlg('Confirma a exclus'#227'o do registro selecionado?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    Table1.Delete;
end;

procedure TForm1.BtnRelatorioClick(Sender: TObject);
begin
  if Table1.RecordCount = 0 then
  begin
    MessageDlg('N'#227'o h'#225' funcion'#225'rios cadastrados para imprimir.',
               mtInformation, [mbOK], 0);
    Exit;
  end;
  FrmRelatorio.PrepararRelatorio(Table1);
  FrmRelatorio.QuickRep1.Preview;
end;

procedure TForm1.BtnImportarClick(Sender: TObject);
var
  Dialog: TOpenDialog;
  Linhas, Campos: TStringList;
  i, Importados, Erros: Integer;
  Linha: string;

  procedure SplitPorPontoEVirgula(const S: string; Lista: TStringList);
  var
    Resto: string;
    P: Integer;
  begin
    Lista.Clear;
    Resto := S;
    while True do
    begin
      P := Pos(';', Resto);
      if P = 0 then
      begin
        Lista.Add(Resto);
        Break;
      end;
      Lista.Add(Copy(Resto, 1, P - 1));
      Resto := Copy(Resto, P + 1, Length(Resto));
    end;
  end;

  function ParseSalario(const S: string): Currency;
  var Tmp: string;
  begin
    Tmp := Trim(S);
    if DecimalSeparator <> ',' then
      Tmp := StringReplace(Tmp, ',', DecimalSeparator, [rfReplaceAll]);
    Result := StrToCurr(Tmp);
  end;

  function ParseDataBR(const S: string): TDateTime;
  var
    P1, P2, Dia, Mes, Ano: Integer;
    Resto: string;
  begin
    P1 := Pos('/', S);
    Resto := Copy(S, P1 + 1, Length(S));
    P2 := Pos('/', Resto);
    Dia := StrToInt(Copy(S, 1, P1 - 1));
    Mes := StrToInt(Copy(Resto, 1, P2 - 1));
    Ano := StrToInt(Copy(Resto, P2 + 1, Length(Resto)));
    Result := EncodeDate(Ano, Mes, Dia);
  end;

  function ParseBool(const S: string): Boolean;
  var V: string;
  begin
    V := UpperCase(Trim(S));
    Result := (V = 'SIM') or (V = 'S') or (V = 'TRUE') or (V = '1');
  end;

begin
  Dialog := TOpenDialog.Create(Self);
  try
    Dialog.Title  := 'Selecione o arquivo CSV';
    Dialog.Filter := 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*';
    Dialog.DefaultExt := 'csv';
    Dialog.InitialDir := ExtractFilePath(Application.ExeName);
    if not Dialog.Execute then Exit;

    Linhas := TStringList.Create;
    Campos := TStringList.Create;
    try
      Linhas.LoadFromFile(Dialog.FileName);
      if Linhas.Count < 2 then
      begin
        MessageDlg('Arquivo vazio ou cont'#233'm apenas cabe'#231'alho.',
                   mtWarning, [mbOK], 0);
        Exit;
      end;

      Importados := 0;
      Erros := 0;

      Screen.Cursor := crHourGlass;
      FImportando := True;
      Table1.DisableControls;
      try
        for i := 1 to Linhas.Count - 1 do
        begin
          Linha := Trim(Linhas[i]);
          if Linha = '' then Continue;

          SplitPorPontoEVirgula(Linha, Campos);
          if (Campos.Count < 8) or (Trim(Campos[0]) = '') then
          begin
            Inc(Erros);
            Continue;
          end;

          try
            Table1.Append;
            Table1.FieldByName('Nome').AsString  := Trim(Campos[0]);
            Table1.FieldByName('CPF').AsString   := Trim(Campos[1]);
            Table1.FieldByName('Cargo').AsString := Trim(Campos[2]);
            if Trim(Campos[3]) <> '' then
              Table1.FieldByName('Salario').AsCurrency := ParseSalario(Campos[3]);
            if Trim(Campos[4]) <> '' then
              Table1.FieldByName('DataAdmissao').AsDateTime := ParseDataBR(Campos[4]);
            Table1.FieldByName('Email').AsString    := Trim(Campos[5]);
            Table1.FieldByName('Telefone').AsString := Trim(Campos[6]);
            Table1.FieldByName('Ativo').AsBoolean   := ParseBool(Campos[7]);
            if (Campos.Count >= 9) and (Trim(Campos[8]) <> '') then
              Table1.FieldByName('Certificado').AsString := Trim(Campos[8]);
            Table1.Post;
            Inc(Importados);
          except
            if Table1.State in [dsInsert, dsEdit] then
              Table1.Cancel;
            Inc(Erros);
          end;
        end;
      finally
        Table1.EnableControls;
        FImportando := False;
        Screen.Cursor := crDefault;
      end;

      Table1.First;
      AtualizarStatus;
      AtualizarBotoes;
      MessageDlg(Format('Importa'#231#227'o conclu'#237'da.'#13#10 +
                        'Registros importados: %d'#13#10 +
                        'Linhas com erro: %d', [Importados, Erros]),
                 mtInformation, [mbOK], 0);
    finally
      Campos.Free;
      Linhas.Free;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TForm1.BtnAssinarXMLClick(Sender: TObject);
begin
  FrmAssinarXML.ShowModal;
end;

procedure TForm1.BtnExemploClick(Sender: TObject);
var
  Lista: TStringList;
  Path: string;
begin
  Lista := TStringList.Create;
  try
    Lista.Add('Nome;CPF;Cargo;Salario;DataAdmissao;Email;Telefone;Ativo;Certificado');
    Lista.Add('JOAO DA SILVA;123.456.789-00;DESENVOLVEDOR;3500,50;15/03/2020;joao.silva@empresa.com;(11) 98765-4321;Sim;JOAO DA SILVA:12345678901');
    Lista.Add('MARIA SOUZA;987.654.321-00;ANALISTA DE SISTEMAS;4200,00;22/07/2019;maria.souza@empresa.com;(11) 91234-5678;Sim;');
    Lista.Add('PEDRO SANTOS;456.789.123-00;GERENTE DE PROJETOS;7800,75;10/01/2018;pedro.santos@empresa.com;(11) 99876-5432;Sim;PEDRO SANTOS:98765432109');
    Lista.Add('ANA OLIVEIRA;789.123.456-00;DESIGNER GRAFICO;3200,00;05/06/2021;ana.oliveira@empresa.com;(11) 92345-6789;Sim;');
    Lista.Add('CARLOS LIMA;321.654.987-00;ASSISTENTE ADMINISTRATIVO;2500,00;18/11/2022;carlos.lima@empresa.com;(11) 93456-7890;Nao;');
    Lista.Add('FERNANDA COSTA;654.321.987-00;CONTADORA;5500,00;01/04/2017;fernanda.costa@empresa.com;(11) 94567-8901;Sim;FERNANDA COSTA:11122233344');
    Lista.Add('RICARDO ALMEIDA;147.258.369-00;ENGENHEIRO DE SOFTWARE;9200,00;14/09/2016;ricardo.almeida@empresa.com;(11) 95678-9012;Sim;RICARDO ALMEIDA:55566677788');
    Lista.Add('JULIANA FERREIRA;963.852.741-00;RECURSOS HUMANOS;4800,00;28/02/2020;juliana.ferreira@empresa.com;(11) 96789-0123;Sim;');
    Lista.Add('BRUNO MENDES;852.741.963-00;SUPORTE TECNICO;2800,00;12/10/2021;bruno.mendes@empresa.com;(11) 97890-1234;Sim;');
    Lista.Add('CAMILA RIBEIRO;741.852.963-00;COORDENADORA DE MARKETING;6300,00;03/05/2019;camila.ribeiro@empresa.com;(11) 98901-2345;Nao;');

    Path := ExtractFilePath(Application.ExeName) + 'funcionarios_exemplo.csv';
    Lista.SaveToFile(Path);

    if MessageDlg('Arquivo de exemplo criado em:'#13#10 + Path + #13#10#13#10 +
                  'Deseja abrir a pasta?',
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      ShellExecute(Handle, 'open',
                   PChar(ExtractFilePath(Path)), nil, nil, SW_SHOWNORMAL);
  finally
    Lista.Free;
  end;
end;

procedure TForm1.EditLocalizarChange(Sender: TObject);
begin
  if Trim(EditLocalizar.Text) = '' then Exit;
  Table1.Locate('Nome', EditLocalizar.Text, [loCaseInsensitive, loPartialKey]);
end;

procedure TForm1.BtnBuscarClick(Sender: TObject);
begin
  if Trim(EditLocalizar.Text) = '' then
  begin
    MessageDlg('Digite parte do nome para localizar.', mtInformation, [mbOK], 0);
    EditLocalizar.SetFocus;
    Exit;
  end;
  if not Table1.Locate('Nome', EditLocalizar.Text,
                       [loCaseInsensitive, loPartialKey]) then
    ShowMessage('Nenhum registro encontrado.');
end;

procedure TForm1.BtnLimparClick(Sender: TObject);
begin
  EditLocalizar.Clear;
  Table1.First;
end;

procedure TForm1.BtnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Table1.State in [dsInsert, dsEdit] then
  begin
    case MessageDlg('Existem altera'#231#245'es n'#227'o salvas. Deseja salvar antes de sair?',
                    mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:    Table1.Post;
      mrNo:     Table1.Cancel;
      mrCancel: CanClose := False;
    end;
  end;
end;

end.
