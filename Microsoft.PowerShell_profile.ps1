$GitPath = "C:\Program Files\Git"

# Aliases
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
function Start-PythonIdle {
  cmd /c start /b py -m idlelib
}

Set-Alias -Name idle -Value Start-PythonIdle -Description "Python IDLE"

# UV
if (Get-Command -Name uv -ErrorAction SilentlyContinue) {
  function Export-Uv-Requirements {
    uv export --no-emit-project --no-dev --no-hashes ${Args}
  }
  Set-Alias -Name "uvreq" -Value Export-Uv-Requirements -Description "Export UV Requirements"

  (& uv --generate-shell-completion powershell) | Out-String | Invoke-Expression
}

if (Get-Command -Name uvx -ErrorAction SilentlyContinue) {
  (& uvx --generate-shell-completion powershell) | Out-String | Invoke-Expression
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Oh My Posh
Try {
  $env:VIRTUAL_ENV_DISABLE_PROMPT = 1
  $Theme = "$env:USERPROFILE\.config\oh-my-posh\themes\iceman.omp.json"
  oh-my-posh init pwsh --config $Theme | Invoke-Expression
}
Catch {
  $env:VIRTUAL_ENV_DISABLE_PROMPT = 0
}
