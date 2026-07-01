; LabTrack - Windows installer (Inno Setup).
; Per-user install: requires no administrator rights and no code-signing
; certificate. Installs to %LOCALAPPDATA%\Programs\LabTrack, adds a Start Menu
; entry (and optional desktop shortcut), and registers a clean uninstaller.

#define MyAppName "LabTrack"
; Overridable from the build script via ISCC /DMyAppVersion=x.y.z (the #ifndef
; guard lets the command-line value win; otherwise this default is used).
#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
#define MyAppPublisher "Su Lab"
#define MyAppExeName "labtrack.exe"
#define SourceDir "E:\Users\Wei\Documents\Project management\labtrack\build\windows\x64\runner\Release"
#define IconFile "E:\Users\Wei\Documents\Project management\labtrack\windows\runner\resources\app_icon.ico"

[Setup]
; A stable AppId so future versions upgrade in place rather than installing twice.
AppId={{A7F3C1E2-9B4D-4E6A-8C12-3F5D7E9A1B2C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; Show the Welcome page at the start of the wizard (hidden by default in the
; modern wizard style); its message is customised in [Messages] below.
DisableWelcomePage=no
; Always show the "Select Destination Location" page so the user can choose the
; install folder.
DisableDirPage=no
; Require the user to read and accept the privacy policy before installing; if
; they decline, the Next button stays disabled and they can only cancel/quit.
LicenseFile=privacy_policy.txt
; Per-user, never elevates.
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=E:\Users\Wei\Documents\Project management\labtrack\build\installer
OutputBaseFilename=labtrack-setup-{#MyAppVersion}
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppName} Setup

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

; Relabel the License Agreement page as the Privacy Policy.
[Messages]
WizardLicense=Privacy Policy
LicenseLabel=Please read the following Privacy Policy.
LicenseLabel3=Please read the following Privacy Policy. You must accept its terms before continuing with the installation.
LicenseAccepted=I &accept the Privacy Policy
LicenseNotAccepted=I &do not accept the Privacy Policy

; Friendly Welcome page introducing the app (%n = line break).
WelcomeLabel1=Welcome to LabTrack
WelcomeLabel2=LabTrack is a local-first laboratory management app for projects, experiments, tasks, strains, reagents, cultures, primers, protocols and reports - built for the Su Lab (MBBE, University of Hawaii at Manoa).%n%nYour data stays on this device unless you choose to turn on optional cloud sync. This wizard will guide you through a quick, per-user installation that needs no administrator rights.%n%nClick Next to continue.

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; The entire Flutter Release bundle: labtrack.exe, the Flutter engine + plugin
; DLLs, and the data\ folder (flutter_assets, icudtl.dat, ...).
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
