# ===========================================
# Installateur multi-apps via WinGet (silencieux)
# ===========================================

# Réglages d’exécution : stop sur erreur non gérée
$ErrorActionPreference = "Stop"

# --- Liste des apps (Nom lisible -> ID Winget, Source optionnelle) ---
# Remarque: pour Node.js, tu peux prendre la LTS si tu préfères: OpenJS.NodeJS.LTS
$Apps = [ordered]@{
    "Google Drive (Drive for desktop)" = @{ Id = "Google.GoogleDrive"; Source = "winget" }          # ancien "Google.GoogleDrive" à éviter
    "Opera"                            = @{ Id = "Opera.Opera"; Source = "winget" }
    "NVDA"                             = @{ Id = "NVAccess.NVDA"; Source = "winget" }
    "Docker Desktop"                   = @{ Id = "Docker.DockerDesktop"; Source = "winget" }
    "Visual Studio Code"               = @{ Id = "Microsoft.VisualStudioCode"; Source = "winget" }
    "Node.js (latest)"                 = @{ Id = "OpenJS.NodeJS"; Source = "winget" }
    "Git"                              = @{ Id = "Git.Git"; Source = "winget" }
    "Discord"                          = @{ Id = "Discord.Discord"; Source = "winget" }
    "Zoom"                             = @{ Id = "Zoom.Zoom"; Source = "winget" }
    "MAMP"                             = @{ Id = "MAMP.MAMP"; Source = "winget" }
    "Python 3.x"                       = @{ Id = "Python.Python.3"; Source = "winget" }       # ex: Python.Python.3.12 si tu veux figer
}

# --- Overrides silencieux par type d’installeur (au cas où Winget n’en met pas assez) ---
# NOTE: Winget gère déjà pas mal de silencieux, ceci sert pour les EXE tatillons.
$InstallerOverrides = @{
    "Git.Git"      = "/VERYSILENT /NORESTART"   # Inno Setup
    "Zoom.Zoom"    = "/qn /norestart"           # MSI
    # Ajoute ici si un EXE réclame /S ou autre
}

Write-Host "=== Script d'installation avec Winget ===`n"
Write-Host "Tape les numéros séparés par des virgules pour installer plusieurs programmes."
Write-Host "Exemple: 1,3,5`n"

# Afficher menu
$index = 1
$Menu = @{}
foreach ($k in $Apps.Keys) {
    "{0}. {1}" -f $index, $k | Write-Host
    $Menu[$index] = $k
    $index++
}

# Choix
$raw = Read-Host "`nTon choix"
$choices = $raw -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }

# Fonction d'install
function Install-App {
    param(
        [Parameter(Mandatory=$true)][string]$Id,
        [string]$Source = "winget",
        [string]$Override = $null
    )

    # Construire la ligne d’arguments
    $args = @("install","-e","--id",$Id,"--accept-package-agreements","--accept-source-agreements","--silent")
    if ($Source) { $args += @("--source",$Source) }
    if ($Override) { $args += @("--override",$Override) }

    # Lancer et récupérer le code retour
    $proc = Start-Process -FilePath "winget" -ArgumentList $args -Wait -PassThru
    return $proc.ExitCode
}

foreach ($n in $choices) {
    if (-not $Menu.ContainsKey($n)) { Write-Host "Option invalide: $n"; continue }

    $display = $Menu[$n]
    $meta = $Apps[$display]
    $id = $meta.Id
    $source = $meta.Source

    Write-Host "`n>>> Installation de $display ..." -ForegroundColor Cyan

    # 1) Tentative silencieuse + override connu si défini
    $override = $null
    if ($InstallerOverrides.ContainsKey($id)) { $override = $InstallerOverrides[$id] }
    $code = Install-App -Id $id -Source $source -Override $override

    if ($code -eq 0) {
        Write-Host ">>> $display installé avec succès ✅"
        continue
    }

    # 2) Fallback: tentative interactive (-i) si silencieux échoue (utile pour certains EXE comme Drive)
    Write-Host ">>> Silencieux KO (code $code). Tentative interactive..." -ForegroundColor Yellow
    $argsInteractive = @("install","-e","--id",$id,"--accept-package-agreements","--accept-source-agreements","-i")
    if ($source) { $argsInteractive += @("--source",$source) }
    $proc2 = Start-Process winget -ArgumentList $argsInteractive -Wait -PassThru

    if ($proc2.ExitCode -eq 0) {
        Write-Host ">>> $display installé (mode interactif) ✅"
    } else {
        Write-Host ">>> Échec de l'installation de $display (codes $code / $($proc2.ExitCode)) ❌"
    }
}

Write-Host "`n=== Installation terminée ==="
Pause
