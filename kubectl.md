# Kubectl - tips and tricks

This is less of a blog post, and more of a set notes designed to remind me (and help others) when they're trying to use/configure kubectl

### Change the default editor (Windows)
The documentation states that if you want to change the editor for `kubectl edit` then you add the environment variable `KUBE_EDITOR`.
Whilst this is correct, its not totally complete.

Take the following example:

```powershell
PS> $env:KUBE_EDITOR = "notepad++.exe"
```

This doesn't work out of the box, as notepad++ isn't on the path. Options are:
1. Add _notepad++_ to the path
2. Specify the path to _notepad++.exe_

Sadly the latter doesn't work, as the path contains spaces it requires quotes.

```powershell
PS> $env:KUBE_EDITOR = "c:\Program Files\Notepad++\notepad++.exe"
PS> kubectl edit ...
'c:\Program' is not recognized as an internal or external command, operable program or batch file.
error: there was a problem with the editor "cmd /C c:\\Program Files\\Notepad++\\notepad.exe"
```

Using quotes in the path introduces a secondary level of escaping, so in effect kubectl will execute the following command (which subsequently fails):

```powershell
PS> $env:KUBE_EDITOR = "'c:\Program Files\Notepad++\notepad++.exe'"
PS> kubectl edit ...
The filename, directory name, or volume label syntax is incorrect.
error: there was a problem with the editor "cmd /C 'c:\\Program Files\\Notepad++\\notepad++.exe'"

PS> $env:KUBE_EDITOR = '"c:\Program Files\Notepad++\notepad++.exe"'
PS> kubectl edit ...
'\\\"c:\Program Files\Notepad++\notepad++.exe\\\"' is not recognozied as an internal or external command, operable program or batch file.
error there was a problem with the editor "cmd /C \\\"c:\\Program Files\\Notepad++\\notepad++.exe\\\"
```

So in short, specifying the full path to the executable isn't supported (at least if there are spaces in the path).

So add the application to the path:

```powershell
PS> $env:PATH="${env:PATH};c:\Program Files\Notepad++"
PS> $env:KUBE_EDITOR = "notepad++.exe"
PS> kubectl edit ...
Edit cancelled, no changes made.
```
Notepad++ did open (or at least does if it's not open elsewhere). However if it's configured to share the same instance, then the instance launched by kubectl instructs the other instance and then exits. The exit is considered by kubectl as 'edits are complete' and tries to apply them... but we've not had time to make any changes.

So finally this configuration seems to work well, at least for me:

```powershell
PS> $env:PATH="${env:PATH};c:\Program Files\Notepad++"
PS> $env:KUBE_EDITOR = "notepad++.exe -multiInst -notabbar -nosession -noPlugin"
PS> kubectl edit ...
... edited
PS>
```
This works regardless of whether notepad++ is already open or not. 

Of course you'll want to set these environment variables to be persistent, so via the Windows environment variable editor.

### Getting the latest config map
You can use kubectl to get the config maps for any given deployment, but how will you know which one is the latest one; the one in use now?

You can use this command:

```powershell
PS> kubectl get configmaps --sort-by.metadata.creationTimestamp
```

Sadly there is no --descending operator, so the latest one will be at the end of the list, not the start.