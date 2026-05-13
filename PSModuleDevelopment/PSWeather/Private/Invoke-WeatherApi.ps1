
Function Invoke-WeatherApi {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$City
    )

    $uri = "https://wttr.in/$($City)?format=j1"

    try {
        $Response = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction Stop
        return $Response
    }
    catch {
        Write-Error "Failed to fetch weather data for '$City'. Please check the city name or your internet connection."
    }
}
