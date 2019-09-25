try {
    if ( -not (Test-Path "Thirdparty\ACT\Advanced Combat Tracker.exe" )) {
        echo 'Error: Please copy "Advanced Combat Tracker.exe" into "Thirdparty\ACT" directory.'
        exit 1
    }


    if ( -not (Test-Path "Thirdparty\FFXIV_ACT_Plugin\SDK\FFXIV_ACT_Plugin.Common.dll" )) {
        echo 'Error: Please unpack the FFXIV ACT SDK into the "Thirdparty\FFXIV_ACT_Plugin\SDK" directory.'
        exit 1
    }

    # This assumes Visual Studio 2019 is installed in C:. You might have to change this depending on your system.
    $ENV:PATH = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin;${ENV:PATH}";

    echo "==> Building..."

    msbuild -t:Rebuild -p:Configuration=Release -p:Platform=x64 "OverlayPlugin.sln"
    if (-not $?) { exit 1 }

    echo "==> Building CEF archives..."

    cd out\Release\libs\x64

    $text = [System.IO.File]::ReadAllText("$PWD\README.txt");
    $regex = [regex]::New("CEF Version:\s*([0-9.]+)");
    $m = $regex.Match($text);

    if (-not $m) {
        echo "Error: Version number not found in CEF's README.txt!"
        exit 1
    }

    $version = $m.Groups[1]
    $archive = "..\..\..\CefSharp-$version-x64.7z"

    if (Test-Path $archive) { rm $archive }
    7z a $archive "-x!*.xml" "-x!*.pdb" .

    # Rename the archive here so I don't have to before uploading.
    # If you're wondering why I change the extension: People don't read. This seems like the easiest way to force them to.
    mv $archive "..\..\..\CefSharp-$version-x64.DO_NOT_DOWNLOAD"

    cd ..\..\libs\x86

    $archive = "..\..\..\CefSharp-$version-x86.7z"

    if (Test-Path $archive) { rm $archive }
    7z a $archive "-x!*.xml" "-x!*.pdb" .

    mv $archive "..\..\..\CefSharp-$version-x86.DO_NOT_DOWNLOAD"

    cd ..\..
} catch {
    Write-Error $Error[0]
}
