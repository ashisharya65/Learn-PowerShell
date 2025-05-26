function Get-ReverseStr {
    param(
        [Parameter(position = 0, ValueFromPipeline)]
        [string] $forward
    )
    
    $reversestr = ""

    foreach ($s in $forward.ToCharArray()) {
        $currentchar = [string]$s
        $reversestr = $currentchar + $reversestr
    }
    return $reversestr
}

Get-ReverseStr 'strops'
