$emacsDir = "$env:APPDATA\.emacs.d"

if (Test-Path -Path $emacsDir) { Remove-Item -Recurse -Force $emacsDir }

New-Item -ItemType Directory $emacsDir

New-Item "$emacsDir\early-init.el" -ItemType SymbolicLink -Target "$(Get-Location)\early-init.el"
New-Item "$emacsDir\init.el" -ItemType SymbolicLink -Target "$(Get-Location)\init.el"
New-Item "$emacsDir\load-env-vars.el" -ItemType SymbolicLink -Target "$(Get-Location)\load-env-vars.el"

.\get-grammars.ps1

emacs.exe --no-init-file --load .\gen-env-file.el
