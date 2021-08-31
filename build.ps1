<# 
    Shift Media Project提供のFFMpegや依存モジュールを
    Visual Studio Build Toolsを使ってビルドするバッチ
#>


param (
  [switch]$Clean = $false,
  [ValidateSet("build" , "rebuild", "clean")]$BuildType = "build",
  [ValidateSet("Debug" , "Release", "DebugDLL","ReleaseDLL","ReleaseDLLStaticDeps")]$ObjType = "Release",
  [ValidateSet("x86" , "x64")]$CpuType = "x64"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent


try {
  if($clean) {
    "msvc,sourceディレクトリを削除する"
    Remove-Item ".\msvc" -Force -Recurse -Confirm:$False
    Remove-Item ".\source" -Force -Recurse -Confirm:$False
  }

  "作業ディレクトリの作成"
  if (!(Test-Path '.\msvc')) {
    New-Item '.\msvc' -ItemType Directory
  }

  if (!(Test-Path '.\msvc\include')) {
    New-Item '.\msvc\include' -ItemType Directory
  }

  if (!(Test-Path '.\msvc\include\gl')) {
    New-Item '.\msvc\include\gl' -ItemType Directory
  }

  if (!(Test-Path '.\msvc\include\KHR')) {
    New-Item '.\msvc\include\KHR' -ItemType Directory
  }


  if (!(Test-Path '.\source')) {
    New-Item '.\source' -ItemType Directory
  }

  "FFmpegのレポジトリを取得する"
  Set-Location ".\source"
 
  if (!(Test-Path ".\FFmpeg")) {
    Start-Process  "git"  -ArgumentList "clone https://github.com/ShiftMediaProject/FFmpeg.git" -Wait -NoNewWindow
  }
  else {
    Set-Location ".\FFmpeg"
    Start-Process  "git"  -ArgumentList "pull" -Wait -NoNewWindow
    Set-Location '..\'
  }

  "依存ライブラリを取得する"
  Set-Location ".\FFmpeg\SMP"
  Start-Process "cmd" -ArgumentList "/c project_get_dependencies.bat < ..\..\..\y.txt" -Wait -NoNewWindow
  Set-Location "..\..\..\"

  "openglヘッダファイルを取得する"
  Set-Location ".\msvc\include\gl"
  Invoke-WebRequest "https://www.khronos.org/registry/OpenGL/api/GL/glext.h" -OutFile '.\glext.h' -ErrorAction Stop
  Invoke-WebRequest "https://www.khronos.org/registry/OpenGL/api/GL/wglext.h" -OutFile '.\wglext.h' -ErrorAction Stop
  Set-Location "..\KHR"
  Invoke-WebRequest "https://www.khronos.org/registry/EGL/api/KHR/khrplatform.h" -OutFile '.\khrplatform.h' -ErrorAction Stop
  Set-Location "..\..\..\"

  Set-Location ".\source"

  "nvcodecのヘッダファイルを取得する"
  if (!(Test-Path(".\nv-codec-headers"))) {
    Start-Process "git" -ArgumentList "clone https://github.com/FFmpeg/nv-codec-headers" -Wait -NoNewWindow
  }
  else {
    Set-Location '.\nv-codec-headers'
    Start-Process "git" -ArgumentList "pull" -NoNewWindow
    Set-Location '..\'
  }
  Copy-Item -Path ".\nv-codec-headers\include\ffnvcodec" "..\msvc\include" -Force -Recurse

  "AMFのヘッダファイルを取得する"
  if (!(Test-Path(".\AMF"))) {
    Start-Process "git" -ArgumentList "clone https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git" -NoNewWindow -Wait
  }
  else {
    Set-Location '.\AMF'
    Start-Process "git" -ArgumentList "pull" -Wait -NoNewWindow
    Set-Location '..\'
  }
  Copy-Item -Path ".\AMF\amf\public\include" "..\msvc\include\AMF" -Force -Recurse

  "NASM を取得する"
  if (!(Test-Path(".\VSNASM"))) {
    Start-Process "git" -ArgumentList "clone https://github.com/ShiftMediaProject/VSNASM.git" -NoNewWindow -Wait
  }
  else {
    Set-Location ".\VSNASM"
    Start-Process  "git"  -ArgumentList "pull" -Wait -NoNewWindow
    Set-Location '..\'
  }

  "NASMのインストール"
  Set-Location ".\VSNASM"
  Start-Process "cmd" -ArgumentList "/c install_script.bat < ..\..\y.txt" -Wait -Verb runAs
  Set-Location '..\'

  "YASM を取得する"
  if (!(Test-Path(".\VSYASM"))) {
    Start-Process "git" -ArgumentList "clone https://github.com/ShiftMediaProject/VSYASM.git" -NoNewWindow -Wait
  }
  else {
    Set-Location ".\VSYASM"
    Start-Process  "git"  -ArgumentList "pull" -Wait -NoNewWindow
    Set-Location '..\'
  }

  "YASMのインストール"
  Set-Location ".\VSYASM"
  Start-Process "cmd" -ArgumentList "/c install_script.bat < ..\..\y.txt" -Wait -Verb runAs
  Set-Location '..\'

  "ffmpegをビルドする"
  Set-Location ".\FFmpeg\SMP"
  Start-Process "msbuild" -ArgumentList "ffmpeg_deps.sln /t:$($BuildType) /p:Configuration=`"$($ObjType)`";Platform=`"$($CpuType)`"" -NoNewWindow -Wait
  Set-Location "..\..\..\"

  "## 終了 ##"
  
}
catch {
  "## エラー発生 ##"
  $_
}
finally {
  Set-Location $ScriptDir
}