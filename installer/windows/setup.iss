[Setup]
AppName=MediMind Portal
AppVersion={#AppVersion}
AppPublisher=MediMind
AppPublisherURL=https://medimind.et
DefaultDirName={autopf}\MediMind Portal
DefaultGroupName=MediMind Portal
OutputBaseFilename=MediMindPortal-{#AppVersion}-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\medimind_portal.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\MediMind Portal"; Filename: "{app}\medimind_portal.exe"
Name: "{group}\Uninstall MediMind Portal"; Filename: "{uninstallexe}"
Name: "{autodesktop}\MediMind Portal"; Filename: "{app}\medimind_portal.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\medimind_portal.exe"; Description: "Launch MediMind Portal"; Flags: nowait postinstall skipifsilent
