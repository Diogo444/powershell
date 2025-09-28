# Script d'auto‑installation d’applications (PowerShell + Winget)

Ce script PowerShell propose un menu d’applications et les installe via Winget en mode silencieux quand c’est possible. En cas d’échec du mode silencieux, il bascule automatiquement en mode interactif pour l’application concernée.

## Prérequis

- Windows 10/11 avec Winget disponible (`App Installer` depuis Microsoft Store).
- PowerShell 5.1+ ou PowerShell 7+.
- Démarrer PowerShell « en tant qu’administrateur » (clic droit → Exécuter en tant qu’administrateur).
- Autoriser l’exécution de scripts dans votre profil utilisateur (à faire une fois) :

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Utilisation

1. Clonez/téléchargez ce dépôt.
2. Ouvrez PowerShell en tant qu’administrateur.
3. Placez‑vous dans le dossier du script.
4. Lancez :

```powershell
./auto-install.ps1
```

5. Saisissez les numéros des applications à installer, séparés par des virgules (ex : `1,3,5`).
6. Le script tente une installation silencieuse via Winget. Si elle échoue, il relance l’installation en mode interactif. À la fin, une pause affiche le récapitulatif.

## Ce que fait le script

- Affiche un menu basé sur une liste ordonnée d’applications (`$Apps`).
- Installe via Winget avec les options :
  - `-e --id <Id> --accept-package-agreements --accept-source-agreements --silent`
  - `--source <Source>` si précisé.
  - `--override <Arguments>` quand des paramètres d’installateur sont nécessaires (table `$InstallerOverrides`).
- En cas d’échec (code retour ≠ 0), retente en mode interactif (`-i`).
- Arrête l’exécution à la première erreur non gérée (`$ErrorActionPreference = "Stop"`).

Applications proposées par défaut :
- Google Drive (Drive for desktop)
- Opera
- NVDA
- Docker Desktop
- Visual Studio Code
- Node.js (latest)
- Git
- Discord
- Zoom
- MAMP
- Python 3.x
- WhatsApp
- VLC media player
- Microsoft 365
- 7-Zip
- WinRar

Fichier principal : `auto-install.ps1`

## Ajouter ou modifier des applications

La liste se trouve dans la table ordonnée `$Apps`. Chaque entrée a :
- un nom lisible (affiché dans le menu)
- un `Id` Winget
- une `Source` (généralement `winget`)

Exemple :

```powershell
$Apps = [ordered]@{
    "Visual Studio Code" = @{ Id = "Microsoft.VisualStudioCode"; Source = "winget" }
    "Node.js (latest)"   = @{ Id = "OpenJS.NodeJS";            Source = "winget" }
    # Ajoutez vos apps ici…
}
```

Comment trouver un `Id` Winget :

```powershell
winget search vscode
winget show --id Microsoft.VisualStudioCode
```

- Choisissez l’ID exact et stable (option `-e` « exact » est utilisée dans le script).
- Vous pouvez utiliser un autre paquet pour une variante (ex. Node LTS : `OpenJS.NodeJS.LTS`).

## Paramètres silencieux (overrides)

La table `$InstallerOverrides` permet d’ajouter des paramètres pour les installateurs qui en ont besoin (Inno Setup, MSI, NSIS, etc.). Ces paramètres sont passés à Winget via `--override`.

Exemple :

```powershell
$InstallerOverrides = @{
    "Git.Git"   = "/VERYSILENT /NORESTART"  # Inno Setup
    "Zoom.Zoom" = "/qn /norestart"          # MSI
    # Ajoutez d’autres overrides si nécessaire
}
```

Quand un `Id` figure dans cette table, le script l’utilise automatiquement pour l’installation silencieuse. Si malgré tout l’installation échoue, un essai interactif est lancé.

## Conseils et dépannage

- Winget introuvable : installez/mettez à jour « App Installer » depuis Microsoft Store, puis vérifiez `winget --version`.
- Exécution de scripts bloquée : relancez PowerShell après avoir exécuté `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`.
- Droits administrateur : certaines applications requièrent des privilèges élevés. Ouvrez toujours PowerShell en tant qu’administrateur.
- Réseaux/Proxy/Entreprise : la source Winget peut être restreinte. Vérifiez `winget source list` et l’accès réseau.
- Versions spécifiques : ce script ne passe pas `--version`. Pour figer une branche/édition, choisissez un autre `Id` approprié si disponible (ex. `Python.Python.3` vs une déclinaison spécifique), ou adaptez le script pour accepter une version.

## Structure du code (vue d’ensemble)

- Table `$Apps` : définit le menu (nom → `{ Id; Source }`).
- Table `$InstallerOverrides` : définit les arguments supplémentaires pour certaines installations.
- Fonction `Install-App` : construit et exécute la commande Winget puis renvoie le code retour.
- Boucle principale : lit les choix de l’utilisateur, tente l’installation silencieuse puis bascule en interactif si besoin.
