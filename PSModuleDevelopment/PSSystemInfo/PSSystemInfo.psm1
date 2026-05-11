
# 1. Load all Private functions
$privateFiles = Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue
foreach ($file in $privateFiles) {
    . $file.FullName
}

# 2. Load all Public functions
$publicFiles = Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue
foreach ($file in $publicFiles) {
    . $file.FullName
}

# 3. Explicitly export ONLY the public functions
if ($null -ne $publicFiles) {
    $publicFunctions = $publicFiles.BaseName
    Export-ModuleMember -Function $publicFunctions
}
