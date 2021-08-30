<# 
    Shift Media Project提供のFFMpegや依存モジュールを
    Visual Studio Build Toolsを使ってビルドするバッチ
#>

if(!(Test-Path '.\msvc')){
  New-Item '.\msvc' -ItemType Directory
}

if(!(Test-Path '.\msvc\include')){
  New-Item '.\msvc\include' -ItemType Directory
}

if(!(Test-Path '.\msvc\include\gl')){
  New-Item '.\msvc\include\gl' -ItemType Directory
}

if(!(Test-Path '.\msvc\include\KHR')){
  New-Item '.\msvc\include\KHR' -ItemType Directory
}


if(!(Test-Path '.\source')){
  New-Item '.\source' -ItemType Directory
}

# FFmpegのレポジトリを取得する
Set-Location ".\source"
 
if(!(Test-Path ".\FFmpeg")){
  Start-Process  "git"  -ArgumentList "clone https://github.com/ShiftMediaProject/FFmpeg.git" -Wait
} else {
  Set-Location ".\FFmpeg"
  Start-Process  "git"  -ArgumentList "pull" -Wait
  Set-Location '..\'
}

# 依存ライブラリを取得する
Set-Location ".\FFmpeg\SMP"
Start-Process "cmd" -ArgumentList "/c project_get_dependencies.bat" -Wait
Set-Location "..\..\"

# openglヘッダファイルを取得する
Set-Location ".\msvc\include\gl"
Invoke-WebRequest "https://www.khronos.org/registry/OpenGL/api/GL/glext.h" -OutFile '.\glext.h' 
Invoke-WebRequest "https://www.khronos.org/registry/OpenGL/api/GL/wglext.h" -OutFile '.\wglext.h'
Set-Location "..\KHR"
Invoke-WebRequest "https://www.khronos.org/registry/EGL/api/KHR/khrplatform.h" -OutFile '.\khrplatform.h'
Set-Location "..\..\..\"

# nvcodecのヘッダファイルをコピーする
Set-Location ".\source"
if(!(Test-Path(".\nv-codec-headers"))){
  Start-Process "git" -ArgumentList "clone https://github.com/FFmpeg/nv-codec-headers" -Wait
} else {
  Set-Location '.\nv-codec-headers'
  Start-Process "git" -ArgumentList "pull"
  Set-Location '..\'
}
Copy-Item -Path ".\source\nv-codec-headers\include" ".\msvc\include" -Force -Recurse

Set-Location ".\source"

# AMFのヘッダファイルをコピーする
if(!(Test-Path(".\AMF"))){
  Start-Process "git" -ArgumentList "clone https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git" -Wait
} else {
  Set-Location '.\AMF'
  Start-Process "git" -ArgumentList "pull" -Wait
  Set-Location '..\'
}
Copy-Item -Path ".\source\AMF\amf\public\include" ".\msvc\include\AMF" -Force -Recurse

# NASM を取得する
if(!(Test-Path(".\VSNASM"))){
  Start-Process "git" -ArgumentList "clone https://github.com/ShiftMediaProject/VSNASM.git"
} else {
  Set-Location ".\VSNASM"
  Start-Process  "git"  -ArgumentList "pull" -Wait
  Set-Location '..\'
}

# NASMのインストール
Set-Location ".\VSNASM"
Start-Process "cmd" -ArgumentList "/c install_script.bat" -Wait
Set-Location '..\'

# YASM を取得する
if(!(Test-Path(".\VSYASM"))){
  Start-Process "git" -ArgumentList "clone https://github.com/ShiftMediaProject/VSYASM.git"
} else {
  Set-Location ".\VSYASM"
  Start-Process  "git"  -ArgumentList "pull" -Wait
  Set-Location '..\'
}

# YASMのインストール 
Set-Location ".\VSYASM"
Start-Process "cmd" -ArgumentList "/c install_script.bat" -Wait
Set-Location '..\'

Set-Location "..\" 

# ビルドする

Set-Location ".\source\FFmpeg\SMP"
Start-Process "msbuild" -ArgumentList "ffmpeg_deps.sln /t:build /p:Configuration=Release;Platform='x64'"
Set-Location "..\..\..\"