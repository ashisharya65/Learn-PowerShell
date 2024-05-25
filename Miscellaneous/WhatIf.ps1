function new-widget {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(mandatory)]
        [string] $shape,

        [parameter(mandatory)]
        [string] $color,

        [parameter(mandatory)]
        [string] $quantity
    )

    $widgetobj = [pscustomobject]@{
        Shape = $shape
        Color = $color
        Quantity = $quantity
    }

    if($PSCmdlet.ShouldProcess("Creating a widget","widget.txt","Creating widget")){
        Add-Content -path widget.txt -value $widgetobj
    }   
}