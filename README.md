# Cadastro de Funcionários — Delphi 7 (Firebird Embedded + ZeosLib)

Sistema CRUD de cadastro de funcionários desenvolvido em **Borland Delphi 7**.
Esta branch (`feat/firebird`) usa **Firebird 3 Embedded** como banco, acessado pela
biblioteca de componentes **ZeosLib** (sem BDE).

> O mesmo projeto existe em outras branches trocando apenas a camada de banco:
> - **`main`** — Paradox + BDE (versão original)
> - **`feat/firebird`** — Firebird 3 Embedded via ZeosLib (esta)
> - **`feat/postgree`** — PostgreSQL via ZeosLib

---

## Funcionalidades

- ✅ CRUD completo (Novo / Editar / Salvar / Cancelar / Excluir) com painel lateral
- ✅ Máscaras de entrada para CPF, Telefone e Data
- ✅ Busca incremental por nome (`Locate` com `loPartialKey`)
- ✅ Relatório em **QuickReport** (A4 retrato, cabeçalho, totais e paginação)
- ✅ Importação/Exportação **CSV** (separador `;`, encoding ANSI, salário com vírgula)
- ✅ Combo de **certificados digitais** lido do Windows Cert Store
- ✅ **Assinatura digital XML do eSocial**: XMLDSig + c14n inclusive (W3C 2001) + RSA-SHA-256

---

## Stack

| Camada | Tecnologia |
|---|---|
| IDE | Borland Delphi 7 |
| Banco | Firebird 3 **Embedded** (arquivo `.fdb`) |
| Acesso a dados | ZeosLib (`TZConnection` + `TZTable`), protocolo `firebird` (Zeos 8) |
| Relatórios | QuickReport 5.0 (paleta QReport, requer `dclqrt70.bpl` instalado) |
| Assinatura digital | `Crypt32.dll` + `Advapi32.dll` + `Msxml2.DOMDocument.6.0` |
| Encoding dos fontes | ANSI Windows-1252 (CP1252), quebras de linha CRLF |
| Idioma da UI | Português brasileiro |

---

## Estrutura

```
Project1.dpr                 Projeto principal (cria os 3 forms)
Unit1.pas / .dfm             TForm1 — tela de CRUD principal (conexão ZeosLib)
Unit2.pas / .dfm             TFrmRelatorio — relatório QuickReport
Unit3.pas / .dfm             TFrmAssinarXML — assinador XML do eSocial
installer/CadastroFuncionario.iss   Script do instalador (Inno Setup)
installer/config.ini         Modelo de configuração
```

### Schema da tabela `FUNCIONARIOS`

| Campo | Tipo Firebird | Notas |
|---|---|---|
| codigo | INTEGER (PK) | autoinc via `SEQUENCE GEN_FUNCIONARIOS_ID` + trigger `BEFORE INSERT` |
| nome | VARCHAR(60) | obrigatório |
| cpf | VARCHAR(14) | máscara `000.000.000-00` |
| cargo | VARCHAR(40) | |
| salario | NUMERIC(15,2) | exibido como `R$ #,##0.00` |
| dataadmissao | DATE | máscara `00/00/0000` |
| email | VARCHAR(80) | |
| telefone | VARCHAR(20) | máscara `(00) 00000-0000` |
| ativo | BOOLEAN | nativo do Firebird 3 |
| certificado | VARCHAR(100) | nome do certificado digital |

O banco `.fdb`, a sequence, a tabela e a trigger são **criados automaticamente** na
primeira execução. A migração de schema (adicionar `certificado`) usa
`ALTER TABLE ADD` — **sem perder dados**.

---

## Onde ficam os dados e a configuração

Tudo em uma pasta **gravável pelo usuário** (não em `Arquivos de Programas`):

```
%APPDATA%\CadastroFuncionario\
├── Funcionarios.fdb     banco Firebird (criado no 1º start)
└── config.ini           parâmetros de conexão (criado no 1º start)
```

`config.ini`:

```ini
[Banco]
DatabaseDir=        ; vazio = banco em %APPDATA%\CadastroFuncionario
FbClient=           ; vazio = usa fbclient.dll ao lado do .exe
```

---

## Pré-requisitos

- **Delphi 7** com o **ZeosLib** instalado e no *Library Path* (build do Zeos para D7).
- **QuickReport** instalado no IDE (`dclqrt70.bpl`).
- **Runtime do Firebird 3 Embedded (32-bit)** — o Delphi 7 gera `.exe` 32-bit, então
  o cliente também precisa ser 32-bit. Em desenvolvimento, o projeto usa a pasta
  `C:\Firebird3_x86` (ZIP do Firebird 3 32-bit extraído inteiro). Em produção, esses
  arquivos vão junto do `.exe` (ver instalador).

> Conjunto mínimo do Firebird Embedded: `fbclient.dll`, `firebird.msg`, `firebird.conf`,
> `plugins.conf`, `ib_util.dll`, ICU (`icudt52.dll` + **`icudt52l.dat`** + `icuin52.dll`
> + `icuuc52.dll`), `msvcr100.dll` + `msvcp100.dll` (runtime VC++ 2010 que o FB3 exige),
> `plugins\engine12.dll` e `intl\fbintl.dll` + `intl\fbintl.conf`.

---

## Como rodar (desenvolvimento)

1. Garanta o **ZeosLib no Library Path** do Delphi 7 (pasta de build dos `.dcu` + `src\*`).
2. **Instale o QuickReport no IDE** (uma vez):
   `Component → Install Packages → Add → ...\Delphi7\Bin\dclqrt70.bpl`
3. Tenha o `C:\Firebird3_x86` (Firebird 3 32-bit extraído inteiro) — o código usa essa
   pasta como fallback quando não há `fbclient.dll` ao lado do `.exe`.
4. Abra `Project1.dpr` e pressione **F9**. Na primeira execução são criados o `.fdb`
   e o `config.ini` em `%APPDATA%\CadastroFuncionario`.
5. **Gerar Exemplo** → cria CSV; **Importar CSV** → popula 10 funcionários.
6. **Relatório** abre o preview do QuickReport.
7. **Assinar XML** abre o assinador eSocial (requer certificado ICP-Brasil no Cert Store "MY").

### Observações de conexão (ZeosLib)
- `Protocol = 'firebird'` (Zeos 8 unifica os protocolos; em Zeos 7.x seria `'firebird-3.0'`).
- `HostName` vazio = modo **Embedded** (sem servidor).
- `ClientCodepage = 'NONE'` (charset NONE): grava os bytes como recebidos — ideal para
  app ANSI/Win1252 e evita depender do `fbintl` para charsets de 1 byte no Embedded.

---

## Gerar o instalador (Inno Setup)

A versão Embedded é **autossuficiente**: o instalador empacota o app **+ o runtime do
Firebird Embedded** junto do `.exe`. **Não instala servidor** nem precisa de rede.

1. Instale o **Inno Setup 6+** — <https://jrsoftware.org/isdl.php>
2. Compile o `Project1.exe` em **Release** (em *Project → Options → Packages*,
   deixe **"Build with runtime packages" desmarcado**).
3. Confira os caminhos no topo de `installer/CadastroFuncionario.iss`
   (`ProjDir` e `FbDir`, que aponta para o `C:\Firebird3_x86`).
4. Abra o `.iss` no Inno Setup e clique em **Build**.
5. O instalador sai em `installer/Output/CadastroFuncionario-Setup.exe`.

### O que o instalador faz
- Copia `Project1.exe` para `{app}` e o runtime do Firebird Embedded para o mesmo `{app}`
  (a `fbclient.dll` localiza `plugins\`, `intl\`, ICU e `firebird.msg` relativos a si).
- O `config.ini` e o banco `.fdb` **não** vão no pacote — nascem em `%APPDATA%` no 1º start.
- Cria atalhos no Menu Iniciar e (opcional) na área de trabalho.

> Não precisa distribuir: BDE (foi removido nesta versão), DCUs/BPLs do ZeosLib e
> runtime do QuickReport (linkados no `.exe`), MSXML e Crypt32 (já fazem parte do Windows).

---

## Notas para quem for editar os fontes

- Os arquivos `.pas`/`.dfm`/`.dpr` são **ANSI Windows-1252 com quebras CRLF**.
  Salvar como UTF-8 ou com LF faz o IDE acusar erros estranhos.
- Caracteres acentuados em `.dfm` precisam ser escapados (`'Funcion'#225'rios'`).
- Identificadores no Firebird são MAIÚSCULOS; `FieldByName` é case-insensitive, então
  `'Nome'` casa com `NOME`.
- A assinatura SHA-256 do eSocial exige reabrir o container do certificado no provider
  `Microsoft Enhanced RSA and AES` (detalhe em `Unit3.pas`).

---

## Licença / contexto

Projeto de estudo, sem fins comerciais.
