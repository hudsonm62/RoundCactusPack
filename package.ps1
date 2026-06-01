param(
    [Parameter(Mandatory)]
    [string]$Version,

    [string]$Name = "Round Cactus",
    [string]$SrcPath = (Join-Path $PSScriptRoot "src"),
    [switch]$FailIfExists = $false
)

# 1. Copy repo files to src
(
    (Join-Path $PSScriptRoot "LICENSE"),
    (Join-Path $PSScriptRoot "README.md")
) | ForEach-Object {
    $DestName = Split-Path $_ -Leaf # file name only

    # remove existing in pack
    Remove-Item (Join-Path $SrcPath $DestName) -ErrorAction Ignore
    $dest = Join-Path $SrcPath $DestName
    Copy-Item $_ -Destination $dest -Force -ErrorAction Stop
    Write-Information -InformationAction Continue "Copied '$_' to src."
}

# 2. Zip up src
$OutFileName = "$Name v$Version.zip"
$OutputFile = Join-Path $PSScriptRoot $OutFileName

$Existing = Test-Path $OutputFile
if($FailIfExists -and $Existing) {
    throw "Output file already exists: $OutputFile"
}
if($Existing) {
    Write-Information -InformationAction Continue "Output file already exists, deleting: $OutputFile"
    Remove-Item $OutputFile -Force -ErrorAction Stop
}

# zip up everything with src contents as root
try { [System.IO.Compression.ZipFile] | out-null } catch { Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop }
[System.IO.Compression.ZipFile]::CreateFromDirectory($SrcPath, $OutputFile)
return Get-Item $OutputFile -Force -ErrorAction Stop
