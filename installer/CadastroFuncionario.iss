; ============================================================================
;  Inno Setup - Cadastro de Funcionarios (Delphi 7 + ZeosLib + PostgreSQL)
;  Cenario A: PostgreSQL instalado na propria maquina (app conecta localhost).
;
;  Pre-requisitos para compilar este instalador:
;    - Inno Setup 6+  (https://jrsoftware.org/isdl.php)
;    - Project1.exe ja compilado (Release) na pasta do projeto.
;    - libpq.dll/msvcp140.dll/vcruntime140.dll (32-bit) em ClientDir.
;    - (Opcional) o instalador do PostgreSQL em installer\postgres\ para
;      bundlar o servidor. Veja a secao [Tasks]/[Run].
; ============================================================================

#define AppName     "Cadastro de Funcionarios"
#define AppVersion  "1.0.0"
#define AppExe      "Project1.exe"
#define Publisher   "Rafael Lucio"

; Ajuste estes caminhos conforme sua maquina de build:
#define ProjDir     "C:\Users\rafae\Workspace\cadastro-funcionario-delphi"
#define ClientDir   "C:\Users\rafae\pg32client"
; Nome do instalador do PostgreSQL (coloque o .exe baixado em installer\postgres\):
#define PgSetup     "postgresql-18.4-1-windows-x64.exe"

[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#Publisher}
DefaultDirName={autopf}\CadastroFuncionario
DefaultGroupName=Cadastro de Funcionarios
DisableProgramGroupPage=yes
OutputDir={#ProjDir}\installer\Output
OutputBaseFilename=CadastroFuncionario-Setup
Compression=lzma2
SolidCompression=yes
; O app e' 32-bit; instale em Arquivos de Programas (x86) em Windows 64-bit.
ArchitecturesInstallIn64BitMode=

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na area de trabalho"; GroupDescription: "Atalhos:"
Name: "instalarpg";  Description: "Instalar o PostgreSQL 18 (servidor local)"; GroupDescription: "Banco de dados:"; Check: PostgresNaoInstalado

[Files]
; --- Aplicacao ---
Source: "{#ProjDir}\{#AppExe}";        DestDir: "{app}"; Flags: ignoreversion
; --- Cliente PostgreSQL 32-bit + runtime VC++ (ao lado do .exe) ---
Source: "{#ClientDir}\libpq.dll";      DestDir: "{app}"; Flags: ignoreversion
Source: "{#ClientDir}\msvcp140.dll";   DestDir: "{app}"; Flags: ignoreversion
Source: "{#ClientDir}\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
; OBS: config.ini NAO e' instalado aqui. O app cria automaticamente em
;      %APPDATA%\CadastroFuncionario\config.ini no primeiro start (por usuario,
;      pasta gravavel sem admin). O modelo de referencia esta em installer\config.ini.
; --- (Opcional) instalador do PostgreSQL para o servidor local ---
Source: "{#ProjDir}\installer\postgres\{#PgSetup}"; DestDir: "{tmp}"; Flags: deleteafterinstall skipifsourcedoesntexist; Tasks: instalarpg

[Icons]
Name: "{group}\{#AppName}";        Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}";  Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
; Instala o PostgreSQL em modo silencioso (senha do superusuario = postgres, porta 5432).
Filename: "{tmp}\{#PgSetup}"; \
  Parameters: "--mode unattended --unattendedmodeui none --superpassword postgres --serverport 5432"; \
  StatusMsg: "Instalando PostgreSQL (pode demorar alguns minutos)..."; \
  Flags: waituntilterminated; Tasks: instalarpg
; Abre o app ao final.
Filename: "{app}\{#AppExe}"; Description: "Executar o Cadastro de Funcionarios agora"; \
  Flags: postinstall nowait skipifsilent

[Code]
// Detecta se o PostgreSQL ja esta instalado (servico ou chave de registro),
// para deixar a tarefa "instalarpg" desmarcada quando ja existir.
function PostgresNaoInstalado: Boolean;
begin
  Result := not (
    RegKeyExists(HKLM, 'SOFTWARE\PostgreSQL\Installations') or
    RegKeyExists(HKLM, 'SOFTWARE\WOW6432Node\PostgreSQL\Installations')
  );
end;
