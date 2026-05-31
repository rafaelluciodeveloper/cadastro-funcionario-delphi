; ============================================================================
;  Inno Setup - Cadastro de Funcionarios (Delphi 7 + BDE + Paradox)
;  Versao ORIGINAL (branch main). Precisa do BDE (Borland Database Engine)
;  instalado e registrado na maquina destino.
;
;  Estrategia: empacota o BDE numa subpasta {app}\BDE e registra no Windows
;  (apenas se ainda nao houver BDE instalado, para nao atropelar outro app).
;  O banco Paradox e o NetDir nascem em %APPDATA%\CadastroFuncionario
;  (gravavel sem admin; o NetDir e' setado no codigo via Session.NetFileDir).
;
;  Pre-requisitos para compilar:
;    - Inno Setup 6+  (https://jrsoftware.org/isdl.php)
;    - Project1.exe ja compilado (Release), sem runtime packages.
;    - BDE instalado em BdeSrc (origem dos arquivos a empacotar).
; ============================================================================

#define AppName     "Cadastro de Funcionarios"
#define AppVersion  "1.0.0"
#define AppExe      "Project1.exe"
#define Publisher   "Rafael Lucio"

; Ajuste conforme sua maquina de build:
#define ProjDir     "C:\Users\rafae\Workspace\cadastro-funcionario-delphi"
#define BdeSrc      "C:\Program Files (x86)\Common Files\Borland Shared\BDE"

[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#Publisher}
DefaultDirName={autopf}\CadastroFuncionario
DefaultGroupName=Cadastro de Funcionarios
DisableProgramGroupPage=yes
OutputDir={#ProjDir}\installer\Output
OutputBaseFilename=CadastroFuncionario-Setup-Paradox
Compression=lzma2
SolidCompression=yes
; Precisa de admin: grava em Arquivos de Programas e no HKLM (registro do BDE).
PrivilegesRequired=admin
; App 32-bit: mantem modo 32-bit (registro vai p/ WOW6432Node no Win64,
; que e' de onde o app 32-bit le o BDE).
ArchitecturesInstallIn64BitMode=

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na area de trabalho"; GroupDescription: "Atalhos:"

[Files]
; --- Aplicacao ---
Source: "{#ProjDir}\{#AppExe}";        DestDir: "{app}"; Flags: ignoreversion

; --- BDE (conjunto para Paradox/dBASE) em {app}\BDE -----------------------
Source: "{#BdeSrc}\idapi32.dll";  DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\idapi32.cfg";  DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\idr20009.dll"; DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\blw32.dll";    DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\idpdx32.dll";  DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\idasci32.dll"; DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\idbat32.dll";  DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\iddr32.dll";   DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\idqbe32.dll";  DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\iddbas32.dll"; DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\disp.dll";     DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\disp.pak";     DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\charset.cvb";  DestDir: "{app}\BDE"; Flags: ignoreversion
; Drivers de idioma (Latin/Western)
Source: "{#BdeSrc}\usa.btl";      DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\europe.btl";   DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\ceeurope.btl"; DestDir: "{app}\BDE"; Flags: ignoreversion
Source: "{#BdeSrc}\other.btl";    DestDir: "{app}\BDE"; Flags: ignoreversion

[Registry]
; Registra o BDE apontando para {app}\BDE - somente se ainda nao existir BDE.
Root: HKLM; Subkey: "SOFTWARE\Borland\Database Engine"; ValueType: string; \
  ValueName: "CONFIGFILE01"; ValueData: "{app}\BDE\IDAPI32.CFG"; \
  Flags: uninsdeletevalue; Check: BdeNaoInstalado
Root: HKLM; Subkey: "SOFTWARE\Borland\Database Engine"; ValueType: string; \
  ValueName: "DLLPath"; ValueData: "{app}\BDE"; \
  Flags: uninsdeletevalue; Check: BdeNaoInstalado

[Icons]
Name: "{group}\{#AppName}";       Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "Executar o Cadastro de Funcionarios agora"; \
  Flags: postinstall nowait skipifsilent

[Code]
// Retorna True se NAO houver um BDE ja instalado/registrado na maquina.
// Assim nao sobrescrevemos a configuracao de um BDE existente de outro app.
function BdeNaoInstalado: Boolean;
begin
  Result := not (
    RegKeyExists(HKLM, 'SOFTWARE\Borland\Database Engine') or
    RegKeyExists(HKLM, 'SOFTWARE\WOW6432Node\Borland\Database Engine')
  );
end;
