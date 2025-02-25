Remove-Item -Recurse -Force "$env:USERPROFILE\.emacs.d"

New-Item -ItemType Directory "$env:USERPROFILE\.emacs.d"

New-Item "$env:USERPROFILE\.emacs.d\codemacs\early-init.el" -ItemType SymbolicLink -Target "$(Get-Location)\codemacs\early-init.el"
New-Item "$env:USERPROFILE\.emacs.d\codemacs\init.el" -ItemType SymbolicLink -Target "$(Get-Location)\codemacs\init.el"
New-Item "$env:USERPROFILE\.emacs.d\codemacs\load-env-vars.el" -ItemType SymbolicLink -Target "$(Get-Location)\codemacs\load-env-vars.el"

emacs.exe --no-init-file --load .\gen-env-file.el
