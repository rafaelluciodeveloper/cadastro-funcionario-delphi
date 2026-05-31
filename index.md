# Cadastro de Funcionários

Sistema CRUD em Delphi 7 com banco Paradox (BDE), relatórios QuickReport e assinatura digital de XML eSocial via Windows CryptoAPI.

## Visão geral

Projeto de aprendizado que demonstra como construir, do zero, um sistema típico de RH brasileiro usando o stack original do Delphi 7 (2002) — sem libs modernas, só componentes nativos da paleta.

## Stack técnico

- **IDE**: Borland Delphi 7
- **Banco**: Paradox 7 via BDE (Borland Database Engine)
- **Relatórios**: QuickReport 5.0
- **Assinatura digital**: Crypt32.dll + Advapi32.dll + MSXML 6.0
- **Encoding**: ANSI Windows-1252

## Módulos

### Unit1 — Formulário Principal (`TForm1`)

CRUD de funcionários. Layout clássico:

```
┌────────────────────────────────────────┬──────────┐
│  TÍTULO (Panel azul)                   │  Novo    │
├────────────────────────────────────────┤  Editar  │
│  GroupBox "Dados do Funcionário"       │  Salvar  │
│  ┌ Código  Nome              CPF  ┐    │  Cancelar│
│  └ Email   Telefone   Cargo       │    │  Excluir │
│  ┌ Salário Data    ☑Ativo  Cert ┐ │    │ ──────── │
│  └────────────────────────────────┘    │  Relator.│
├────────────────────────────────────────┤  Import. │
│  Localizar [____] [Buscar] [Limpar]    │  Exemplo │
├────────────────────────────────────────┤  Assinar │
│  DBGrid (lista de funcionários)        │ ──────── │
│                                         │  Sair    │
├────────────────────────────────────────┴──────────┤
│  Total: N  |  Atual: N  |  Paradox (BDE)         │
└────────────────────────────────────────────────────┘
```

**Componentes BDE**: `TTable` (TableType=ttParadox), `TDataSource`

**Data-aware**: `TDBGrid`, `TDBEdit`, `TDBCheckBox`, `TDBComboBox`

**State machine**: `DataSource1.OnStateChange` → `AtualizarBotoes` habilita/desabilita botões conforme `Table1.State in [dsEdit, dsInsert]`

### Unit2 — Relatório (`TFrmRelatorio`)

QuickReport A4 portrait com 6 bandas:

1. **TitleBand** (1ª pág apenas) — Título + subtítulo italic + linha
2. **PageHeaderBand** (todas) — Nome sistema + data/hora + linha
3. **ColumnHeaderBand** — Fundo cinza + 8 títulos bold
4. **DetailBand** — 6 `TQRDBText` + 2 `TQRLabel` (Ativo, Certificado mostram Sim/Não via `BeforePrint`)
5. **PageFooterBand** — Linha + rodapé + "Página: N"
6. **SummaryBand** (última pág) — "Total: " + `TQRExpr` com `COUNT`

**Colunas**: Código, Nome, CPF, Cargo, Salário, Admissão, Ativo, Cert.

**Margens**: 10mm padrão A4

### Unit3 — Assinador XML eSocial (`TFrmAssinarXML`)

Janela modal pra assinar XMLs de eventos eSocial com certificado digital.

**Fluxo**:
1. Lista certs do Windows Cert Store "MY" (`CertOpenSystemStoreA` + `CertEnumCertificatesInStore`)
2. Usuário escolhe cert + arquivo XML
3. `CryptAcquireCertificatePrivateKey` pega chave privada do cert
4. **Upgrade obrigatório** do provider pra `PROV_RSA_AES` (legacy `PROV_RSA_FULL` não suporta SHA-256)
5. Carrega XML com MSXML2.DOMDocument 6.0
6. **Canonicaliza** via implementação própria de Canonical XML 1.0 (W3C):
   - Sort de namespaces (default primeiro)
   - Sort de atributos por (namespaceURI, localName)
   - Escape de texto/atributos
   - Empty elements → `<x></x>`
   - Skip do elemento `<Signature>` (transform enveloped-signature)
7. UTF-8 encode
8. SHA-256 do canonical UTF-8
9. RSA sign com a chave privada
10. Inverte bytes (CryptoAPI little-endian → XMLDSig big-endian)
11. Base64 de hash, assinatura e cert
12. Monta `<Signature>` no padrão XMLDSig do eSocial:
    - `CanonicalizationMethod`: `xml-c14n-20010315`
    - `SignatureMethod`: `rsa-sha256`
    - `Reference URI=""`
    - 2 Transforms: enveloped-signature + xml-c14n
    - `DigestMethod`: SHA-256
    - `KeyInfo > X509Data > X509Certificate`
13. Anexa Signature como filho da raiz
14. Salva como `<original>_assinado.xml` na mesma pasta

## Banco de dados

Tabela `Funcionarios.db` criada em runtime via `TTable.CreateTable` se não existir. Pasta `Dados\` ao lado do executável.

| Campo | Tipo | Tam | Uso |
|---|---|---|---|
| Codigo | ftAutoInc | — | PK auto-incremento |
| Nome | ftString | 60 | Validado não-vazio em `BeforePost` |
| CPF | ftString | 14 | Formato `000.000.000-00` |
| Cargo | ftString | 40 | |
| Salario | ftCurrency | — | Exibido como `R$ 0,00` |
| DataAdmissao | ftDate | — | `dd/mm/yyyy`, default = hoje no insert |
| Email | ftString | 80 | |
| Telefone | ftString | 20 | `(99) 99999-9999` |
| Ativo | ftBoolean | — | Default = True no insert |
| Certificado | ftString | 100 | Nome do cert digital, vazio = sem cert |

**Índices**: primário em Codigo + secundário `IdxNome` (case-insensitive, mantido por compatibilidade)

## Formato CSV (import/export)

Separador `;` (padrão Brasil — vírgula é decimal), encoding ANSI:

```
Nome;CPF;Cargo;Salario;DataAdmissao;Email;Telefone;Ativo;Certificado
JOAO DA SILVA;123.456.789-00;DESENVOLVEDOR;3500,50;15/03/2020;joao@empresa.com;(11) 98765-4321;Sim;JOAO DA SILVA:12345678901
```

- Salário com vírgula decimal
- Data `dd/mm/yyyy`
- Ativo: `Sim`/`Não`/`S`/`N`/`1`/`0`/`True`/`False`
- Certificado opcional (linha pode ter 8 ou 9 colunas)

## Convenções de código

- Nomes em português (CarregarCertificados, AtualizarBotoes, ConfigurarCampos)
- Métodos auxiliares em `private`
- Eventos `On*` em `published` (default da classe)
- Acentos via escape `#xxx` em DFMs
- Strings literais com `#xxx` no meio quando necessário: `'Funcion'#225'rio'`

## Conhecimento acumulado

Ver [CLAUDE.md](CLAUDE.md) para a lista completa de gotchas do Delphi 7 (StrictDelimiter inexistente, propriedades QR que mudam entre versões, fix do PROV_RSA_AES, etc.) — descobertos durante o desenvolvimento e documentados para não repetir.

## Como rodar

1. **Instalar QuickReport** no IDE (1x): `Component → Install Packages → Add → C:\Program Files (x86)\Borland\Delphi7\Bin\dclqrt70.bpl`
2. Abrir `Project1.dpr` no Delphi 7
3. `F9` (Run)
4. Na 1ª execução, cria a tabela vazia
5. Botão **Gerar Exemplo** + **Importar CSV** popula 10 funcionários de teste

## Pré-requisitos do sistema

- Windows com BDE instalado (vem com Delphi 7)
- Driver Paradox no BDE Administrator
- Pra assinatura XML: certificado ICP-Brasil A1 instalado no Windows Cert Store "MY"

## Histórico

Iniciado em 2026-05-30 a partir de projeto template vazio. Evoluído iterativamente:

1. CRUD básico com BDE + DBNavigator
2. Refatorado pra usar botões reais (padrão Delphi clássico)
3. Adicionadas máscaras (CPF, Telefone, Data)
4. Relatório Rave → substituído por QuickReport
5. Múltiplas iterações de layout do relatório
6. Import/Export CSV
7. Integração com Windows Cert Store
8. Migração de schema (campo Certificado)
9. Assinador XML eSocial com c14n completo
10. Fix do provider PROV_RSA_AES pra SHA-256

## Estrutura de arquivos

```
CadastroFuncionario/
├── CLAUDE.md                 Instruções pra Claude (gotchas, regras de edição)
├── index.md                  Este arquivo
├── Project1.dpr              Programa principal
├── Project1.res              Recursos (ícone, etc.)
├── Project1.cfg              Config compilador (gerado pelo IDE)
├── Project1.dof              Opções do projeto (gerado pelo IDE)
├── Unit1.pas + Unit1.dfm     Form principal CRUD
├── Unit2.pas + Unit2.dfm     Form do relatório QuickReport
├── Unit3.pas + Unit3.dfm     Form do assinador XML
├── Dados/                    Pasta do banco (criada em runtime)
│   └── Funcionarios.db       Tabela Paradox
└── .claude/
    └── skills/
        └── delphi-7/         Skill reutilizável de Delphi 7
            └── SKILL.md
```
