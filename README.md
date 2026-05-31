# Cadastro de Funcionários — Delphi 7 (PostgreSQL + ZeosLib)

Sistema CRUD de cadastro de funcionários desenvolvido em **Borland Delphi 7**.
Esta branch (`feat/postgresql`) usa **PostgreSQL** como banco, acessado pela
biblioteca de componentes **ZeosLib** (sem BDE).

> O mesmo projeto existe em outras branches trocando apenas a camada de banco:
> - **`main`** — Paradox + BDE (versão original)
> - **`feat/firebird`** — Firebird 3 Embedded via ZeosLib
> - **`feat/postgresql`** — PostgreSQL via ZeosLib (esta)

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
| Banco | PostgreSQL (servidor — testado no PG 18) |
| Acesso a dados | ZeosLib (`TZConnection` + `TZTable`), protocolo `postgresql` (Zeos 8) |
| Cliente | `libpq.dll` **32-bit** (+ runtime VC++) |
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

### Schema da tabela `funcionarios`

| Campo | Tipo PostgreSQL | Notas |
|---|---|---|
| codigo | integer (PK) | autoinc via `SEQUENCE gen_funcionarios_id` + `DEFAULT nextval(...)` |
| nome | varchar(60) | obrigatório |
| cpf | varchar(14) | máscara `000.000.000-00` |
| cargo | varchar(40) | |
| salario | numeric(15,2) | exibido como `R$ #,##0.00` |
| dataadmissao | date | máscara `00/00/0000` |
| email | varchar(80) | |
| telefone | varchar(20) | máscara `(00) 00000-0000` |
| ativo | boolean | nativo do PostgreSQL |
| certificado | varchar(100) | nome do certificado digital |

O **banco `funcionarios`**, a sequence e a tabela são **criados automaticamente** no
primeiro start: o app conecta no banco padrão `postgres` e executa `CREATE DATABASE`
caso ainda não exista. A migração de schema (adicionar `certificado`) usa
`ALTER TABLE ADD COLUMN` — sem perder dados.

---

## Onde ficam os dados e a configuração

O banco fica **no servidor PostgreSQL**. O app guarda apenas a configuração de conexão
em uma pasta gravável pelo usuário:

```
%APPDATA%\CadastroFuncionario\config.ini
```

`config.ini` (criado no 1º start):

```ini
[Banco]
Host=localhost
Porta=5432
Usuario=postgres
Senha=postgres
Database=funcionarios
LibPq=             ; vazio = usa libpq.dll ao lado do .exe
```

> Para apontar a outro servidor/credenciais, basta editar esse arquivo — sem recompilar.

---

## Pré-requisitos

- **Delphi 7** com o **ZeosLib** instalado e no *Library Path* (build do Zeos para D7).
- **QuickReport** instalado no IDE (`dclqrt70.bpl`).
- **Servidor PostgreSQL** acessível (local ou na rede). O usuário configurado precisa de
  permissão `CREATEDB` para a criação automática do banco (o superusuário `postgres` tem).
- **`libpq.dll` 32-bit** — ⚠️ o Delphi 7 gera `.exe` **32-bit** e **não carrega a
  `libpq.dll` 64-bit** que vem no PostgreSQL moderno. O servidor pode continuar 64-bit
  (a conexão é via TCP); apenas o cliente carregado no app precisa ser 32-bit.

### Como obter a `libpq.dll` 32-bit
O servidor PG 18 só traz a `libpq.dll` 64-bit. Para o cliente 32-bit, use o
**driver ODBC do PostgreSQL (psqlODBC) x86**, que já vem com uma `libpq.dll` 32-bit
moderna (suporta `scram-sha-256`) + dependências:

1. Baixe `psqlodbc_x86.msi` em <https://www.postgresql.org/ftp/odbc/releases/>.
2. Extraia sem instalar:
   `msiexec /a "psqlodbc_x86.msi" /qb TARGETDIR="C:\pgextract"`
3. Copie o `libpq.dll` (32-bit) + `msvcp140.dll` + `vcruntime140.dll` da pasta
   `...\PFiles\psqlODBC\1600\bin` para a pasta de cliente (ex.: `C:\Users\<você>\pg32client`).
4. No código, a constante `PG_LIB`/`config.ini → LibPq` aponta para esse `libpq.dll`.

---

## Como rodar (desenvolvimento)

1. Garanta o **ZeosLib no Library Path** do Delphi 7 (build dos `.dcu` + `src\*`).
2. **Instale o QuickReport no IDE** (uma vez):
   `Component → Install Packages → Add → ...\Delphi7\Bin\dclqrt70.bpl`
3. Tenha o **servidor PostgreSQL rodando** (porta 5432, senha do `postgres`) e a
   **`libpq.dll` 32-bit** disponível (ver acima).
4. Abra `Project1.dpr` e pressione **F9**. No 1º start o app cria o banco
   `funcionarios` + tabela e gera o `config.ini` em `%APPDATA%\CadastroFuncionario`.
5. **Gerar Exemplo** → cria CSV; **Importar CSV** → popula 10 funcionários.
6. **Relatório** abre o preview do QuickReport.
7. **Assinar XML** abre o assinador eSocial (requer certificado ICP-Brasil no Cert Store "MY").

### Observações de conexão (ZeosLib)
- `Protocol = 'postgresql'` (Zeos 8).
- `ClientCodepage = 'WIN1252'`: o servidor converte UTF8 ↔ WIN1252, então os acentos do
  app ANSI funcionam direto.
- Driver `ZDbcPostgreSql` incluído no `uses` para garantir que ele seja linkado no `.exe`.

---

## Gerar o instalador (Inno Setup)

O `.iss` cobre o **cenário autossuficiente**: instala o app + cliente PostgreSQL 32-bit,
e **opcionalmente instala o servidor PostgreSQL** na própria máquina (conecta em `localhost`).

1. Instale o **Inno Setup 6+** — <https://jrsoftware.org/isdl.php>
2. Compile o `Project1.exe` em **Release** (em *Project → Options → Packages*,
   deixe **"Build with runtime packages" desmarcado**).
3. Confira os caminhos no topo de `installer/CadastroFuncionario.iss`
   (`ProjDir` e `ClientDir`, que aponta para a pasta da `libpq.dll` 32-bit).
4. (Opcional) Para bundlar o servidor, coloque o instalador do PostgreSQL em
   `installer\postgres\postgresql-18-windows-x64.exe`. Se não colocar, a etapa é
   pulada e o servidor deve ser instalado separadamente.
5. Abra o `.iss` no Inno Setup e clique em **Build**.
6. O instalador sai em `installer/Output/CadastroFuncionario-Setup.exe`.

### O que o instalador faz
- Copia `Project1.exe` + `libpq.dll` (32-bit) + `msvcp140.dll` + `vcruntime140.dll` para `{app}`.
- Tarefa **opcional** "Instalar o PostgreSQL 18" — roda o servidor em modo silencioso
  (`--superpassword postgres --serverport 5432`); fica desmarcada se o PG já estiver instalado.
- O `config.ini` **não** vai no pacote — nasce em `%APPDATA%` no 1º start (por usuário).
- Cria atalhos no Menu Iniciar e (opcional) na área de trabalho.

> Não precisa distribuir: BDE (removido nesta versão), DCUs/BPLs do ZeosLib e runtime do
> QuickReport (linkados no `.exe`), MSXML e Crypt32 (já fazem parte do Windows).

---

## Notas para quem for editar os fontes

- Os arquivos `.pas`/`.dfm`/`.dpr` são **ANSI Windows-1252 com quebras CRLF**.
  Salvar como UTF-8 ou com LF faz o IDE acusar erros estranhos.
- Caracteres acentuados em `.dfm` precisam ser escapados (`'Funcion'#225'rios'`).
- Identificadores no PostgreSQL são minúsculos; `FieldByName` é case-insensitive, então
  `'Nome'` casa com `nome`.
- A assinatura SHA-256 do eSocial exige reabrir o container do certificado no provider
  `Microsoft Enhanced RSA and AES` (detalhe em `Unit3.pas`).

---

## Licença / contexto

Projeto de estudo, sem fins comerciais.
