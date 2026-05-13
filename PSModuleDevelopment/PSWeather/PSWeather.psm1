
# 1. Load Private Scripts
$privateFiles = Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue
foreach ($file in $privateFiles) {
    . $file.FullName
}

# 2. Load Public Scripts
$publicFiles = Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue
foreach ($file in $publicFiles) {
    . $file.FullName
}

# 3. Export Public Functions
if ($publicFiles) {
    $PublicFunctions = $publicFiles.BaseName
    Export-ModuleMember -Function $PublicFunctions
}
