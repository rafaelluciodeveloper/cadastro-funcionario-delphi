---
name: delphi-7
description: Helper para projetos Delphi 7 com BDE, Paradox, QuickReport e CryptoAPI. Ativa quando o usuário edita .pas, .dpr ou .dfm; quando menciona Delphi 7, BDE, Paradox, QuickReport ou Rave; ou quando trabalha em projeto com Borland Delphi 7. Cobre gotchas de versão (APIs/propriedades inexistentes), regras de encoding ANSI/CRLF, padrões BDE/QR, e fix de assinatura digital SHA-256.
---

# Delphi 7 — Skill

Ativa quando o usuário trabalha em projetos Delphi 7. Captura conhecimento acumulado sobre gotchas de versão, encoding, e padrões específicos da era Borland (2002).

## Quando usar

- Editando arquivos `.pas`, `.dpr`, `.dfm`
- Usuário menciona Delphi 7, BDE, Paradox, QuickReport, Rave, eSocial+Delphi
- Trabalhando em pasta com `Project*.dpr` + IDE Borland Delphi 7

## Regras CRÍTICAS (não negociáveis)

### 1. SEMPRE converter LF→CRLF + Windows-1252 após Write/Edit

O Write/Edit tool grava com line endings LF (Unix). Delphi 7 IDE falha ao parsear `.dpr` com erro genérico `Error in module : Call to Application.CreateForm is missing or incorrect` — mesmo com sintaxe correta.

**Sempre rodar após Write/Edit de qualquer .pas/.dpr/.dfm:**

```powershell
$p = '<caminho>'
$bytes = [System.IO.File]::ReadAllBytes($p)
$text = [System.Text.Encoding]::GetEncoding(1252).GetString($bytes)
$text = $text -replace "`r`n","`n" -replace "`n","`r`n"
[System.IO.File]::WriteAllBytes($p, [System.Text.Encoding]::GetEncoding(1252).GetBytes($text))
```

Aplicar a `.pas`, `.dpr`, `.dfm`, `.inc`, `.pp`. **Não** aplicar a binários (`.res`, `.dcu`).

### 2. Acentos em DFM via escape #xxx

DFMs são ANSI Windows-1252. Caracteres acentuados precisam de escape decimal:

| Char | Esc | Char | Esc | Char | Esc |
|---|---|---|---|---|---|
| á | #225 | é | #233 | í | #237 |
| à | #224 | ê | #234 | ó | #243 |
| ã | #227 | ô | #244 | õ | #245 |
| â | #226 | ú | #250 | ç | #231 |
| Á | #193 | É | #201 | Í | #205 |
| Ó | #211 | Ú | #218 | Ç | #199 |
| Ã | #195 | õ | #245 | | |

**Exemplo:**
```dfm
Caption = 'Funcion'#225'rios cadastrados na empresa S'#227'o Paulo Ltda.'
```

## APIs/propriedades INEXISTENTES no Delphi 7

Lista do que falha ao usar features de versões posteriores:

### TStringList
- `StrictDelimiter` (D2007+) — sem ele, `DelimitedText` quebra também em espaços
  - **Workaround**: split manual com `Pos` + `Copy`:
    ```pascal
    function SplitChar(const S: string; Sep: Char; Lista: TStringList);
    var P: Integer; Resto: string;
    begin
      Lista.Clear; Resto := S;
      while True do begin
        P := Pos(Sep, Resto);
        if P = 0 then begin Lista.Add(Resto); Break; end;
        Lista.Add(Copy(Resto, 1, P-1));
        Resto := Copy(Resto, P+1, Length(Resto));
      end;
    end;
    ```

### BDE TTable
- `FindNearest` é **procedure** (sem retorno bool) — para busca com feedback usar:
  ```pascal
  if Table.Locate('Campo', valor, [loCaseInsensitive, loPartialKey]) then ...
  ```

### Rave Reports 5
- `TBaseReport.Page` (contador página corrente) — não existe nessa versão
  - **Workaround**: variável `NumPagina: Integer` incrementada em cada `NewPage`/`DesenharCabecalho`

### QuickReport 5 (versão D7) — propriedades inexistentes em DFM

Quando aparecer `Error reading XXX.YYY: Property YYY does not exist`, **remover** a propriedade do DFM:

- `PrevFormStyle`, `PreviewWidth`, `PreviewHeight` (em `TQuickRep`)
- `PreCaption` (em `TQRBand`)
- `XLColumn` (em todos os controles QR)
- `VertAlignment` (em `TQRShape`)
- `Functions.Strings`, `Functions.DATA`, `Functions.Status`
- `PrinterSettings.FirstPage`, `PrinterSettings.LastPage`
- `OutputBin = Auto` → trocar por `OutputBin = First`

### TQRDBText
- Não herda `DataSet` automaticamente do `TQuickRep` pai. Atribuir em runtime:
  ```pascal
  for i := 0 to FrmReport.ComponentCount - 1 do
    if FrmReport.Components[i] is TQRDBText then
      TQRDBText(FrmReport.Components[i]).DataSet := MeuDataSet;
  ```

## Padrões de dimensões em QuickReport DFM

Com `Zoom = 80`:
- **px = mm × 3.024** (pixels no DFM)
- **Size.Values = px × 3.307** (≈ mm × 10)

A4 portrait com 10mm margens cada lado:
- `Page.Values = (100, 2970, 100, 2100, 100, 100, 0)` — em 0.1mm
- `QuickRep1.Width = 635` (210mm × 3.024)
- `QuickRep1.Height = 898` (297mm × 3.024)
- Band `Left = 30`, `Width = 575` (190mm)
- Band `Size.Values = (height_sv, 1901.525)` — width em Size.Values

Para componentes, `Size.Values` tem 4 valores: `(Height, Left, Top, Width)`.

## Criação de tabela Paradox em runtime

Padrão para banco BDE com Paradox:

```pascal
procedure CriarTabelaSeNaoExiste;
begin
  if Table1.Exists then Exit;
  with Table1 do
  begin
    with FieldDefs do
    begin
      Clear;
      Add('Codigo', ftAutoInc, 0, True);
      Add('Nome',   ftString,  60, True);
      // ... outros campos
    end;
    with IndexDefs do
    begin
      Clear;
      Add('', 'Codigo', [ixPrimary, ixUnique]);
      Add('IdxNome', 'Nome', [ixCaseInsensitive]);
    end;
    CreateTable;
  end;
end;
```

DatabaseName aceita caminho direto (sem alias):
```pascal
Table1.DatabaseName := ExtractFilePath(Application.ExeName) + 'Dados';
Table1.TableName := 'Funcionarios.db';
Table1.TableType := ttParadox;
```

## Migração de schema Paradox

BDE não tem ALTER TABLE simples. Padrão: detectar campo faltando e recriar:

```pascal
Table1.Open;
if Table1.FindField('NovoCampo') = nil then
begin
  Table1.Close;
  if MessageDlg('Atualizar tabela? Dados perdidos.', mtWarning,
                [mbYes, mbNo], 0) <> mrYes then begin
    Application.Terminate; Exit;
  end;
  DeleteFile(DataDir + '\Funcionarios.db');
  DeleteFile(DataDir + '\Funcionarios.PX');   // índice primário
  DeleteFile(DataDir + '\Funcionarios.XG0');  // índice secundário
  DeleteFile(DataDir + '\Funcionarios.YG0');  // index data
  DeleteFile(DataDir + '\Funcionarios.MB');   // memo (se houver)
  CriarTabelaSeNaoExiste;
  Table1.Open;
end;
```

## TDBComboBox + schema variável

Não setar `DataField` no DFM se o campo pode não existir ainda. Setar via código após migração:

```pascal
// DFM: object Combo: TDBComboBox  (sem DataField)
// Pas:
if Table1.FindField('Certificado') <> nil then
  ComboCertificado.DataField := 'Certificado';
```

## Windows Crypt32 / Cert Store (assinatura digital)

Para enumerar certificados instalados no Windows:

```pascal
const
  CERT_NAME_FRIENDLY_DISPLAY_TYPE = 5;
  CERT_NAME_SIMPLE_DISPLAY_TYPE   = 4;
type
  HCERTSTORE     = Pointer;
  PCERT_CONTEXT  = ^TCertContext;
  TCertContext = record
    dwCertEncodingType: DWORD;
    pbCertEncoded: PByte;
    cbCertEncoded: DWORD;
    pCertInfo: Pointer;
    hCertStore: HCERTSTORE;
  end;

function CertOpenSystemStoreA(hProv: Pointer; szSubsystemProtocol: PAnsiChar): HCERTSTORE;
  stdcall; external 'Crypt32.dll';
function CertEnumCertificatesInStore(hStore: HCERTSTORE; pPrev: PCERT_CONTEXT): PCERT_CONTEXT;
  stdcall; external 'Crypt32.dll';
function CertGetNameStringA(pCert: PCERT_CONTEXT; dwType, dwFlags: DWORD;
  pvTypePara: Pointer; pszName: PAnsiChar; cchName: DWORD): DWORD;
  stdcall; external 'Crypt32.dll';
function CertCloseStore(hStore: HCERTSTORE; dwFlags: DWORD): BOOL;
  stdcall; external 'Crypt32.dll';
```

Padrão: abrir store `'MY'` (pessoal do usuário) e iterar:

```pascal
hStore := CertOpenSystemStoreA(nil, 'MY');
pCert := CertEnumCertificatesInStore(hStore, nil);
while pCert <> nil do begin
  CertGetNameStringA(pCert, CERT_NAME_FRIENDLY_DISPLAY_TYPE, 0, nil, @Buf, SizeOf(Buf));
  // usar Buf como nome do cert
  pCert := CertEnumCertificatesInStore(hStore, pCert);
end;
CertCloseStore(hStore, 0);
```

## CryptoAPI + SHA-256 — fix obrigatório PROV_RSA_AES

**Problema:** Certificados ICP-Brasil A1 são instalados em `PROV_RSA_FULL` (legacy CSP) que **não suporta SHA-256**. `CryptCreateHash` com `CALG_SHA_256` retorna erro `0x80090008` (NTE_BAD_ALGID = `2148073480`).

**Fix:** Após `CryptAcquireCertificatePrivateKey`, ler o container do cert e re-abrir com `PROV_RSA_AES`:

```pascal
const
  CERT_KEY_PROV_INFO_PROP_ID = 2;
  PROV_RSA_AES = 24;
  CRYPT_SILENT = $00000040;
  MS_ENH_RSA_AES_PROV_NAME = 'Microsoft Enhanced RSA and AES Cryptographic Provider';
type
  PCryptKeyProvInfo = ^TCryptKeyProvInfo;
  TCryptKeyProvInfo = record
    pwszContainerName: PWideChar;
    pwszProvName: PWideChar;
    dwProvType, dwFlags, cProvParam: DWORD;
    rgProvParam: Pointer;
    dwKeySpec: DWORD;
  end;

function CertGetCertificateContextProperty(pCert: PCERT_CONTEXT; dwPropId: DWORD;
  pvData: Pointer; var pcbData: DWORD): BOOL;
  stdcall; external 'Crypt32.dll';
function CryptAcquireContextW(var phProv: HCRYPTPROV; pszContainer, pszProvider: PWideChar;
  dwProvType, dwFlags: DWORD): BOOL;
  stdcall; external 'Advapi32.dll' name 'CryptAcquireContextW';

// Após CryptAcquireCertificatePrivateKey:
cbInfo := 0;
CertGetCertificateContextProperty(pCert, CERT_KEY_PROV_INFO_PROP_ID, nil, cbInfo);
GetMem(pInfo, cbInfo);
try
  CertGetCertificateContextProperty(pCert, CERT_KEY_PROV_INFO_PROP_ID, pInfo, cbInfo);
  if CryptAcquireContextW(hProvAES, pInfo^.pwszContainerName,
                          PWideChar(WideString(MS_ENH_RSA_AES_PROV_NAME)),
                          PROV_RSA_AES, CRYPT_SILENT) then
  begin
    if fCallerFree then CryptReleaseContext(hProv, 0);
    hProv := hProvAES;
    KeySpec := pInfo^.dwKeySpec;
    fCallerFree := True;
  end;
finally
  FreeMem(pInfo);
end;
```

## Permissões de arquivo

Pasta padrão `C:\Program Files (x86)\Borland\Delphi7\Projects\` **requer admin** para gravação. Sempre sugerir mover para `C:\Users\<user>\Documents\` antes de tentar editar arquivos lá.

## QuickReport — habilitar paleta

QR vem com o Delphi 7 mas não é instalado por padrão. Para usar:
1. `Component → Install Packages...`
2. `Add` → `C:\Program Files (x86)\Borland\Delphi7\Bin\dclqrt70.bpl`
3. Aparece aba `QReport` na paleta

## Arquivos auxiliares do BDE/Paradox

Quando deletar uma tabela Paradox, deletar TODOS:
- `Funcionarios.db`  — dados
- `Funcionarios.PX`  — índice primário
- `Funcionarios.XG0` / `.YG0` — índice secundário
- `Funcionarios.MB`  — campos memo (se houver)
- `Funcionarios.VAL` — validações
