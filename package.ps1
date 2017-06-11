.\pli-tools.ps1

Create-LuaInstaller -version "5.3.4" `
-sourceLocation "N:\lua-temp\lua-5.3.4\src" `
-binBasePath  "bin" ` #Bin Root
-version = 5.3.4
-outDir $PWD\test
