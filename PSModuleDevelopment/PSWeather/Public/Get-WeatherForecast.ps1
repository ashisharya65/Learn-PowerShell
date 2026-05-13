Function Get-WeatherForecast {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, HelpMessage = "Enter the city name")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Delhi", "Mumbai", "Kolkata", "Chennai", "Bangalore", "Lucknow", "Hyderabad")]
        [string]$City,

        # Kitne din ka forecast chahiye? (Max 3 din ka hi aata hai is API se)
        [ValidateRange(1, 3)]
        [int]$Days = 3,

        [switch]$Celcius,
        [switch]$Fahrenheit
    )
    
    $RawWeatherData = Invoke-WeatherApi -City $City

    if ($RawWeatherData) {
        
        # 'weather' property mein agle 3 din ka data hota hai.
        # Hum Select-Object se utne hi din le rahe hain jitne user ne mange hain.
        $ForecastArray = $RawWeatherData.weather | Select-Object -First $Days

        foreach ($Day in $ForecastArray) {
            
            # Agar -Fahrenheit mention kiya hai, toh F dikhayega, warna default ya -Celcius mein C aayega.
            $UseFahrenheit = $Fahrenheit.IsPresent -and -not $Celcius.IsPresent
            
            $MaxTemp = if ($UseFahrenheit) { "$($Day.maxtempF) °F" } else { "$($Day.maxtempC) °C" }
            $MinTemp = if ($UseFahrenheit) { "$($Day.mintempF) °F" } else { "$($Day.mintempC) °C" }

            [PSCustomObject]@{
                City     = $City.ToUpper()
                Date     = $Day.date
                MaxTemp  = $MaxTemp
                MinTemp  = $MinTemp
                SunHours = "$($Day.sunHour) hrs"
            }
        }
    }
    else {
        Write-Warning "Forecast data not found."
    }
}
