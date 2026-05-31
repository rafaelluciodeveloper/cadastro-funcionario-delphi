; ============================================================================
;  Inno Setup - Cadastro de Funcionarios (Delphi 7 + ZeosLib + Firebird 3)
;  Firebird EMBEDDED: nao instala servidor. O engine vai junto do app e o
;  banco .fdb e' criado em %APPDATA%\CadastroFuncionario no 1o start.
;
;  Pre-requisitos para compilar este instalador:
;    - Inno Setup 6+  (https://jrsoftware.org/isdl.php)
;    - Project1.exe ja compilado (Release), sem runtime packages.
;    - Firebird 3 (32-bit) extraido em FbDir (ex.: C:\Firebird3_x86).
; ============================================================================

#define AppName     "Cadastro de Funcionarios"
#define AppVersion  "1.0.0"
#define AppExe      "Project1.exe"
#define Publisher   "Rafael Lucio"

; Ajuste conforme sua maquina de build:
#define ProjDir     "C:\Users\rafae\Workspace\cadastro-funcionario-delphi"
#define FbDir       "C:\Firebird3_x86"

[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#Publisher}
DefaultDirName={autopf}\CadastroFuncionario
DefaultGroupName=Cadastro de Funcionarios
DisableProgramGroupPage=yes
OutputDir={#ProjDir}\installer\Output
OutputBaseFilename=CadastroFuncionario-Setup-Firebird
Compression=lzma2
SolidCompression=yes
; App 32-bit: instala em Arquivos de Programas (x86) no Windows 64-bit.
ArchitecturesInstallIn64BitMode=

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na area de trabalho"; GroupDescription: "Atalhos:"

[Files]
; --- Aplicacao ---
Source: "{#ProjDir}\{#AppExe}";          DestDir: "{app}"; Flags: ignoreversion

; --- Firebird 3 Embedded (conjunto minimo) -------------------------------
;   A fbclient.dll localiza plugins\, intl\, ICU e firebird.msg relativos a si.
Source: "{#FbDir}\fbclient.dll";         DestDir: "{app}"; Flags: ignoreversion
Source: "{#FbDir}\firebird.msg";         DestDir: "{app}"; Flags: ignoreversion
Source: "{#FbDir}\firebird.conf";        DestDir: "{app}"; Flags: ignoreversion
Source: "{#FbDir}\plugins.conf";         DestDir: "{app}"; Flags: ignoreversion
Source: "{#FbDir}\ib_util.dll";          DestDir: "{app}"; Flags: ignoreversion
; ICU (charsets/collations) - icudt52.dll e' stub; os dados estao no .dat
Source: "{#FbDir}\icudt52.dll";          DestDir: "{app}"; Flags: ignoreversion
Source: "{#FbDir}\icudt52l.dat";         DestDir: "{app}"; Flags: ignoreversion
Source: "{#FbDir}\icuin52.dll";          DestDir: "{app}"; Flags: ignoreversion
Source: "{#FbDir}\icuuc52.dll";          DestDir: "{app}"; Flags: ignoreversion
; Runtime do Visual C++ 2010 (o Firebird 3 depende dele)
Source: "{#FbDir}\msvcr100.dll";         DestDir: "{app}"; Flags: ignoreversion
Source: "{#FbDir}\msvcp100.dll";         DestDir: "{app}"; Flags: ignoreversion
; Motor embedded
Source: "{#FbDir}\plugins\engine12.dll"; DestDir: "{app}\plugins"; Flags: ignoreversion
; Modulo de charsets de 1 byte
Source: "{#FbDir}\intl\fbintl.dll";      DestDir: "{app}\intl"; Flags: ignoreversion
Source: "{#FbDir}\intl\fbintl.conf";     DestDir: "{app}\intl"; Flags: ignoreversion

; OBS: config.ini NAO e' instalado. O app cria em
;      %APPDATA%\CadastroFuncionario\config.ini no 1o start (por usuario).
;      O banco .fdb tambem nasce nessa pasta (gravavel sem admin).
;      Modelo de referencia: installer\config.ini.

[Icons]
Name: "{group}\{#AppName}";       Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "Executar o Cadastro de Funcionarios agora"; \
  Flags: postinstall nowait skipifsilent
