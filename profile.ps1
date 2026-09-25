# Shared profile: loaded by every PowerShell 7 host (console, VS Code) and by
# Windows PowerShell 5.1 through its own one-line loader.
# Keep this file ASCII-only: 5.1 reads BOM-less files with the ANSI code page.

# Cache the output of '<tool> init' style commands; regenerate when the executable changes
function Import-CachedInit {
  param([string]$Name, [string]$Command, [string[]]$Arguments)
  $Exe = Get-Command -Name $Command -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $Exe) { return }
  $CacheDir = Join-Path $env:LOCALAPPDATA "PowerShell\init-cache"
  $CacheFile = Join-Path $CacheDir "$Name.ps1"
  if (-not (Test-Path $CacheFile) -or (Get-Item $CacheFile).LastWriteTime -lt (Get-Item $Exe.Source).LastWriteTime) {
    New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    & $Exe.Source @Arguments | Out-File -FilePath $CacheFile -Encoding utf8
  }
  . $CacheFile
}

# Aliases
$GitPath = "C:\Program Files\Git"
$Commands = @(
  @{ Alias = "vi"; Name = "nvim.exe"; Description = "Neovim" },
  @{ Alias = "vim"; Name = "nvim.exe"; Description = "Neovim" },
  @{ Alias = "grep"; Name = "${GitPath}\usr\bin\grep.exe"; Description = "Grep" }
)

Foreach ($Command in $Commands) {
  if (Get-Command -Name $Command.Name -ErrorAction SilentlyContinue) {
    Set-Alias -Name $Command.Alias -Value $Command.Name -Description $Command.Description
  }
}

# Python
if (Get-Command -Name pyw -ErrorAction SilentlyContinue) {
  function Start-PythonIdle {
    Start-Process -FilePath pyw -ArgumentList "-m", "idlelib"
  }
  Set-Alias -Name idle -Value Start-PythonIdle -Description "Python IDLE"
}

# UV
if (Get-Command -Name uv -ErrorAction SilentlyContinue) {
  function Export-UvRequirements {
    uv export --no-emit-project --no-dev --no-hashes @args
  }
  Set-Alias -Name "uvreq" -Value Export-UvRequirements -Description "Export UV Requirements"
}
Import-CachedInit uv uv "--generate-shell-completion", "powershell"
Import-CachedInit uvx uvx "--generate-shell-completion", "powershell"

# Chocolatey profile
if ($env:ChocolateyInstall) {
  $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
  if (Test-Path -Path $ChocolateyProfile) {
    Import-Module $ChocolateyProfile
  }
}

# Oh My Posh
$Theme = "$env:USERPROFILE\.config\oh-my-posh\themes\iceman.omp.json"
if ((Get-Command -Name oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path -Path $Theme)) {
  $env:VIRTUAL_ENV_DISABLE_PROMPT = 1
  oh-my-posh init pwsh --config $Theme | Invoke-Expression
}
else {
  Remove-Item -Path Env:VIRTUAL_ENV_DISABLE_PROMPT -ErrorAction SilentlyContinue
}

# Exit on Ctrl+d
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

# Zoxide: must come last, after anything that redefines the prompt function
Import-CachedInit zoxide zoxide "init", "powershell"

Remove-Variable -Name GitPath, Commands, Command, Theme, ChocolateyProfile -ErrorAction SilentlyContinue
