# Cadastro de Funcionários — Delphi 7 (BDE + Paradox)

Sistema CRUD de cadastro de funcionários desenvolvido em **Borland Delphi 7**, como
estudo das tecnologias da época. Esta branch (`main`) é a versão **original**, que
usa **Paradox** como banco de dados via **BDE (Borland Database Engine)**.

> O mesmo projeto existe em outras branches trocando apenas a camada de banco:
> - **`main`** — Paradox + BDE (esta)
> - **`feat/firebird`** — Firebird 3 Embedded via ZeosLib
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
| Banco | Paradox (`.DB`) via BDE |
| Relatórios | QuickReport 5.0 (paleta QReport, requer `dclqrt70.bpl` instalado) |
| Assinatura digital | `Crypt32.dll` + `Advapi32.dll` + `Msxml2.DOMDocument.6.0` |
| Encoding dos fontes | ANSI Windows-1252 (CP1252), quebras de linha CRLF |
| Idioma da UI | Português brasileiro |

---

## Estrutura

```
Project1.dpr                 Projeto principal (cria os 3 forms)
Unit1.pas / .dfm             TForm1 — tela de CRUD principal
Unit2.pas / .dfm             TFrmRelatorio — relatório QuickReport
Unit3.pas / .dfm             TFrmAssinarXML — assinador XML do eSocial
installer/CadastroFuncionario.iss   Script do instalador (Inno Setup)
```

### Schema da tabela `Funcionarios`

| Campo | Tipo | Tam | Notas |
|---|---|---|---|
| Codigo | ftAutoInc | — | PK |
| Nome | ftString | 60 | obrigatório |
| CPF | ftString | 14 | máscara `000.000.000-00` |
| Cargo | ftString | 40 | |
| Salario | ftCurrency | — | exibido como `R$ #,##0.00` |
| DataAdmissao | ftDate | — | máscara `00/00/0000` |
| Email | ftString | 80 | |
| Telefone | ftString | 20 | máscara `(00) 00000-0000` |
| Ativo | ftBoolean | — | DBCheckBox |
| Certificado | ftString | 100 | nome do certificado digital |

A tabela é **criada automaticamente** na primeira execução. Se o schema antigo
não tiver o campo `Certificado`, o app oferece recriar a tabela.

---

## Onde ficam os dados

A partir da versão preparada para instalador, o banco Paradox e os arquivos de
controle do BDE ficam em uma pasta **gravável pelo usuário**:

```
%APPDATA%\CadastroFuncionario\
```

O `NetDir` e o `PrivateDir` do Paradox são apontados para essa pasta em tempo de
execução (`Session.NetFileDir` / `Session.PrivateDir`), evitando o erro
*"Network initialization failed"* quando o app é instalado em `Arquivos de Programas`.

---

## Como rodar (desenvolvimento)

1. **Instalar o QuickReport no IDE** (uma única vez):
   `Component → Install Packages → Add →`
   `C:\Program Files (x86)\Borland\Delphi7\Bin\dclqrt70.bpl`
2. Ter o **BDE instalado** na máquina (já vem ao instalar o Delphi 7).
3. Abrir `Project1.dpr` no Delphi 7 e pressionar **F9**.
4. Na primeira execução, a pasta de dados e a tabela são criadas em `%APPDATA%\CadastroFuncionario`.
5. Use **Gerar Exemplo** → cria um CSV de teste; **Importar CSV** → popula 10 funcionários.
6. **Relatório** abre o preview do QuickReport.
7. **Assinar XML** abre o assinador eSocial (requer certificado ICP-Brasil instalado
   no Windows Cert Store "MY").

---

## Gerar o instalador (Inno Setup)

O instalador empacota o app **+ o BDE** (numa subpasta `BDE\` do app) e registra o
BDE no Windows. Não instala servidor de banco (Paradox é arquivo local).

1. Instale o **Inno Setup 6+** — <https://jrsoftware.org/isdl.php>
2. Compile o `Project1.exe` em **Release** (em *Project → Options → Packages*,
   deixe **"Build with runtime packages" desmarcado** — o `.exe` fica autossuficiente).
3. Confira os caminhos no topo de `installer/CadastroFuncionario.iss`
   (`ProjDir` e `BdeSrc`).
4. Abra o `.iss` no Inno Setup e clique em **Build**.
5. O instalador sai em `installer/Output/CadastroFuncionario-Setup.exe`.

### O que o instalador faz
- Copia `Project1.exe` para `{app}` e o conjunto BDE (Paradox) para `{app}\BDE`.
- Registra o BDE em `HKLM\SOFTWARE\Borland\Database Engine` apontando para `{app}\BDE`
  — **somente se ainda não houver um BDE instalado** (não atropela outro app).
- Cria atalhos no Menu Iniciar e (opcional) na área de trabalho.
- Requer **privilégios de administrador** (grava em `Arquivos de Programas` e no `HKLM`).

> O que **não** precisa distribuir: runtime do QuickReport e VCL (linkados no `.exe`),
> MSXML e Crypt32 (já fazem parte do Windows).

---

## Notas para quem for editar os fontes

- Os arquivos `.pas`/`.dfm`/`.dpr` são **ANSI Windows-1252 com quebras CRLF**.
  Salvar como UTF-8 ou com quebras LF faz o IDE acusar erros estranhos
  (ex.: *"Call to Application.CreateForm is missing or incorrect"*).
- Caracteres acentuados em `.dfm` precisam ser escapados (`'Funcion'#225'rios'`).
- A assinatura SHA-256 do eSocial exige reabrir o container do certificado no provider
  `Microsoft Enhanced RSA and AES` (certificados ICP-Brasil A1 vêm em provider legado
  que não suporta SHA-256). Detalhe implementado em `Unit3.pas`.

---

## Licença / contexto

Projeto de estudo, sem fins comerciais.
