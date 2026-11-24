; Inno Setup script. Compile this on Windows after:
; flutter build windows --release
;
; Requires Inno Setup 6. Compatible with Windows 10 21H2+ and Windows 11.

#define MyAppName "Typing Academy"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Typing Academy"
#define MyAppExeName "typing_academy_desktop.exe"

[Setup]
AppId={{8C1E3F2A-4B71-4D9E-9A10-TYPINGACADEMY}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Typing Academy
DefaultGroupName=Typing Academy
OutputDir=..\..\dist
OutputBaseFilename=TypingAcademySetup-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
MinVersion=10.0.19044
PrivilegesRequired=lowest

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop icon"; GroupDescription: "Additional icons:"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Typing Academy"; Flags: nowait postinstall skipifsilent
