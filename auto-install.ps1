# Script d'installation avec Winget
# Tu peux l'exécuter avec PowerShell (Run as Administrator recommandé)

# --- Liste des applications ---
$apps = @{
    "Google Drive"        = "Google.DriveFS"
    "Opera"               = "Opera.Opera"
    "NVDA"                = "nvaccess.nvda"
    "Docker Desktop"      = "Docker.DockerDesktop"
    "Visual Studio Code"  = "Microsoft.VisualStudioCode"
    "Node.js"             = "OpenJS.NodeJS"
    "Git"                 = "Git.Git"
    "Discord"             = "Discord.Discord"
    "Zoom"                = "Zoom.Zoom"
    "MAMP"                = "MAMP.MAMP"
    "Python"              = "Python.Python.3"
}

Write-Host "=== Script d'installation avec Winget ===`n"
Write-Host "Tape les numéros séparés par des virgules pour installer plusieurs programmes."
Write-Host "Exemple: 1,3,5`n"

# Affiche la liste des applis
$i = 1
$choices = @{}
foreach ($app in $apps.Keys) {
    Write-Host "$i. $app"
    $choices[$i] = $app
    $i++
}

# Demande à l'utilisateur son choix
$selection = Read-Host "`nTon choix"
$selection = $selection -split "," | ForEach-Object { $_.Trim() }

# Installation
foreach ($num in $selection) {
    if ($choices.ContainsKey([int]$num)) {
        $appName = $choices[[int]$num]
        $wingetId = $apps[$appName]
        Write-Host "`n>>> Installation de $appName ..."
        winget install --id $wingetId --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host "Option invalide : $num"
    }
}

Write-Host "`n=== Installation terminée ==="
Pause
