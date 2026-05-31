# Cadastro de Funcionários — Delphi 7

Sistema CRUD desenvolvido para aprender/explorar Delphi 7 com tecnologias da época: BDE + Paradox, QuickReport 5, MSXML + CryptoAPI para assinatura digital eSocial.

## Stack

| Camada | Tecnologia |
|---|---|
| IDE | Borland Delphi 7 |
| Banco | Paradox (.DB) via BDE |
| Relatórios | QuickReport 5.0 (paleta QReport, requer `dclqrt70.bpl` instalado) |
| Assinatura digital | `Crypt32.dll` + `Advapi32.dll` + `Msxml2.DOMDocument.6.0` |
| Encoding fonte | ANSI Windows-1252 (CP1252) |
| Idioma UI | Português brasileiro |

## Estrutura

```
Project1.dpr           Projeto principal (cria 3 forms)
Unit1.pas/dfm          TForm1 — CRUD principal
Unit2.pas/dfm          TFrmRelatorio — QuickReport (A4 portrait, 8 colunas)
Unit3.pas/dfm          TFrmAssinarXML — Assinador XML eSocial
Dados/Funcionarios.db  Tabela Paradox (criada na 1ª execução automaticamente)
funcionarios_exemplo.csv  Gerado pelo botão "Gerar Exemplo"
```

## Schema da tabela `Funcionarios`

| Campo | Tipo | Tam | Notas |
|---|---|---|---|
| Codigo | ftAutoInc | — | PK |
| Nome | ftString | 60 | obrigatório |
| CPF | ftString | 14 | EditMask `000\.000\.000\-00` |
| Cargo | ftString | 40 | |
| Salario | ftCurrency | — | DisplayFormat `R$ #,##0.00` |
| DataAdmissao | ftDate | — | EditMask `00/00/0000` |
| Email | ftString | 80 | |
| Telefone | ftString | 20 | EditMask `!\(00\) 00000\-0000` |
| Ativo | ftBoolean | — | DBCheckBox |
| Certificado | ftString | 100 | Nome do cert digital (combo Win Cert Store) |

Migração de schema: detectada via `Table1.FindField('Certificado') = nil`. Se faltar, prompt + recria tabela.

## Regras CRÍTICAS de edição de fontes

### 1. Line endings — sempre CRLF + Windows-1252

Após qualquer Write/Edit em `.pas`/`.dpr`/`.dfm`, rodar:

```powershell
$p = '<caminho>'
$bytes = [System.IO.File]::ReadAllBytes($p)
$text = [System.Text.Encoding]::GetEncoding(1252).GetString($bytes)
$text = $text -replace "`r`n","`n" -replace "`n","`r`n"
[System.IO.File]::WriteAllBytes($p, [System.Text.Encoding]::GetEncoding(1252).GetBytes($text))
```

Sem CRLF a IDE retorna `Error in module : Call to Application.CreateForm is missing or incorrect` mesmo com sintaxe correta.

### 2. Acentos em DFM via escape #xxx

DFMs são ANSI. Caracteres acentuados precisam ser escapados:

- á=#225 à=#224 ã=#227 â=#226
- é=#233 ê=#234
- í=#237
- ó=#243 ô=#244 õ=#245
- ú=#250
- ç=#231
- Á=#193 É=#201 Í=#205 Ó=#211 Ú=#218 Ç=#199

Exemplo: `Caption = 'Funcion'#225'rios cadastrados'`

### 3. APIs/propriedades INEXISTENTES no Delphi 7

**TStringList:**
- `StrictDelimiter` (D2007+) — usar split manual com `Pos` + `Copy`

**BDE TTable:**
- `FindNearest` é **procedure** sem retorno — usar `Locate('Campo', valor, [loCaseInsensitive, loPartialKey])` para busca com bool

**Rave Reports 5.0:**
- `TBaseReport.Page` (contador página atual) — não existe, usar variável própria

**QuickReport 5 (DFM) — propriedades que não existem, remover se aparecerem:**
- `PrevFormStyle`, `PreviewWidth`, `PreviewHeight` em `TQuickRep`
- `PreCaption` em bandas
- `XLColumn` em controles
- `VertAlignment` em `TQRShape`
- `Functions.Strings/DATA/Status`
- `OutputBin = Auto` (usar `First`)

### 4. Dimensões QR a Zoom=80

- `pixels = mm * 3.024`
- `Size.Values = pixels * 3.307` (ou `mm * 10`)
- Band Width A4 portrait 10mm margens = 575 px
- `QuickRep1.Width` deve bater com tamanho da página em px (A4 portrait = 635)

### 5. CryptoAPI + SHA-256 (eSocial)

Certificados ICP-Brasil A1 vêm em `PROV_RSA_FULL` legacy que **NÃO suporta SHA-256**.

Fix obrigatório (`Unit3.pas`): após `CryptAcquireCertificatePrivateKey`, ler `CERT_KEY_PROV_INFO_PROP_ID` e re-abrir mesmo container com:
```
CryptAcquireContextW(hProv, container,
    'Microsoft Enhanced RSA and AES Cryptographic Provider',
    PROV_RSA_AES, CRYPT_SILENT)
```

### 6. TDBComboBox + migração de schema

Não setar `DataField` no DFM se o campo pode não existir ainda (migração). Setar via código depois de garantir que o campo está disponível:
```pascal
if Table1.FindField('Certificado') <> nil then
  ComboCertificado.DataField := 'Certificado';
```

### 7. TQRDBText não herda DataSet automático

Em Delphi 7 QR 5, atribuir `DataSet` em cada `TQRDBText` manualmente no runtime:
```pascal
for i := 0 to ComponentCount - 1 do
  if Components[i] is TQRDBText then
    TQRDBText(Components[i]).DataSet := ATable;
```

## Como rodar

1. Instalar QuickReport no IDE (uma vez): `Component → Install Packages → Add → C:\Program Files (x86)\Borland\Delphi7\Bin\dclqrt70.bpl`
2. Abrir `Project1.dpr` no Delphi 7
3. F9 — cria pasta `Dados\` + tabela na primeira execução
4. Botão **Gerar Exemplo** → cria CSV de teste
5. Botão **Importar CSV** → popula 10 funcionários
6. Botão **Relatório** → preview QR
7. Botão **Assinar XML** → assinador eSocial (precisa cert ICP-Brasil instalado no Windows Cert Store "MY")

## Features

- ✅ CRUD com painel lateral de botões (Novo/Editar/Salvar/Cancelar/Excluir)
- ✅ Máscaras de entrada (CPF, Telefone, Data)
- ✅ Busca incremental por nome (`Locate` com `loPartialKey`)
- ✅ Relatório QuickReport A4 portrait com cabeçalho cinza, totais, paginação
- ✅ Import/Export CSV (separador `;` BR, encoding ANSI, salário com vírgula decimal)
- ✅ Combo de certificados digitais via Win Cert Store
- ✅ Assinatura XML eSocial completa: XMLDSig + c14n inclusive (W3C 2001) + RSA-SHA-256

## Localização

Original em `C:\Program Files (x86)\Borland\Delphi7\Projects\CadastroFuncionario\` (não-gravável sem admin).
Movido para `C:\Users\rafae\Documents\CadastroFuncionario\` em 2026-05-30.
