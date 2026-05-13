
Function Get-Weather {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, HelpMessage = "Enter the city name")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Delhi", "Mumbai", "Kolkata", "Chennai", "Bangalore", "Lucknow", "Hyderabad")]
        [string]$City,

        [switch]$Celcius,
        [switch]$Fahrenheit
    )
    
    $RawWeatherData = Invoke-WeatherApi -City $City

    if ($RawWeatherData) {
        
        $Current = $RawWeatherData.current_condition[0]
        
        # Agar dono me se koi switch present nahi hai, toh default Celcius dikhayenge
        if ($Celcius.IsPresent -or (!$Celcius.IsPresent -and !$Fahrenheit.IsPresent)) {
            [PSCustomObject]@{
                City        = $City.ToUpper()
                Temperature = "$($Current.temp_c) °C"
                Condition   = $Current.weatherDesc[0].value
                Humidity    = "$($Current.humidity) %"
                WindSpeed   = "$($Current.windspeedKmph) km/h"
            }
        }

        if ($Fahrenheit.IsPresent) {
            [PSCustomObject]@{
                City        = $City.ToUpper()
                Temperature = "$($Current.temp_f) °F"
                Condition   = $Current.weatherDesc[0].value
                Humidity    = "$($Current.humidity) %"
                WindSpeed   = "$($Current.windspeedKmph) km/h"
            }
        }
    }
    else {
        Write-Warning "Weather data not found."
    }
}
