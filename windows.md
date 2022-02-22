# 🐳 Windows

## 🍯 Network

### 💐 Changer d'adresse IP avec PowerShell - *netsh*

1. Obtenir le nom de l'interface que l'on souhaite modifier

    ```PowerShell
    netsh interface ip show config
    ```
2. Modifier l'adresse de l'interface

- Utiliser DHCP

    ```Powershell
    netsh interface ip set address "Wi-Fi" dhcp
    ```

- Définir une IP statique
    
    ```PowerShell
    netsh interface ip set address name="Wi-Fi" static 192.168.20.10 255.255.255.0 192.168.50.1
    ```

### 🌸 Changer de DNS avec PowerShell - *netsh*

On utilisera les résolveurs publiques de la [FDN](https://www.fdn.fr/actions/dns/).

- DNS Primaire

    ```PowerShell
    netsh interface ip set dns name="Wi-Fi" static 80.67.169.12
    ```

- DNS Secondaire

    ```PowerShell
    netsh interface ip set dns name="Wi-Fi" 80.67.169.40 index=2
    ```    

## 🍮 Git-Bash dans Windows Terminal

Git Bash est très pratique, mais il est encore plus pratique d'avoir tous ses terminaux dans un seul !

**Création d'un profile pour avoir une commande git-bash dans Windows Terminal.**

```json
{
                "acrylicOpacity": 0.75,
                "antialiasingMode": "aliased",
                "backgroundImage": "C:\\Users\\AIS\\Pictures\\backgrounds\\cat_250_33.gif",
                "backgroundImageAlignment": "bottomRight",
                "backgroundImageOpacity": 0.20000000000000001,
                "backgroundImageStretchMode": "none",
                "bellStyle": "none",
                "closeOnExit": "always",
                "colorScheme": "MonaLisa",
                "commandline": "\"%PROGRAMFILES%\\Git\\usr\\bin\\bash.exe\" --login -i -l",
                "cursorShape": "bar",
                "experimental.retroTerminalEffect": true,
                "font": 
                {
                    "face": "Consolas"
                },
                "guid": "{5c633424-fda5-4457-8891-c27af7195a8e}",
                "icon": "%PROGRAMFILES%\\Git\\mingw64\\share\\git\\git-for-windows.ico",
                "name": "GitNap",
                "padding": "50",
                "startingDirectory": "%USERPROFILE%",
                "tabTitle": "GitNap",
                "useAcrylic": false
            }
```

Et choisir `%USERPROFILE%` dans les options de répertoire de démarrage pour le profile.
