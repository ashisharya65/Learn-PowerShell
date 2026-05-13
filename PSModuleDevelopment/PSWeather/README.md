# PSWeather

**PSWeather** is a simple PowerShell module to fetch current weather and short-term weather forecasts for major Indian cities. It utilizes a public weather API to provide real-time details like temperature, humidity, wind speed, and weather conditions.

## Features

- Fetch **Current Weather** conditions.
- Fetch **Weather Forecast** for up to the next 3 days.
- Supports outputs in both **Celsius (°C)** (default) and **Fahrenheit (°F)**.
- Validates inputs against predefined major cities.

## Supported Cities

Currently, the module supports the following cities:
- Delhi
- Mumbai
- Kolkata
- Chennai
- Bangalore
- Lucknow
- Hyderabad

## Installation

1. Clone or download this repository to your local machine.
2. Navigate to the module directory in your terminal.
3. Import the module into your PowerShell session:

```powershell
Import-Module .\PSWeather.psd1 -Force
```

## Available Commands

### 1. `Get-Weather`

Retrieves the current weather condition of a specified city.

#### Syntax
```powershell
Get-Weather -City <String> [-Celcius] [-Fahrenheit]
```

#### Examples

**Get default current weather (in Celsius):**
```powershell
Get-Weather -City Delhi
```

**Get current weather in Fahrenheit:**
```powershell
Get-Weather -City Mumbai -Fahrenheit
```

### 2. `Get-WeatherForecast`

Retrieves the weather forecast for a specified city for up to 3 days.

#### Syntax
```powershell
Get-WeatherForecast -City <String> [-Days <Int32>] [-Celcius] [-Fahrenheit]
```

#### Examples

**Get 3-day forecast (default) in Celsius:**
```powershell
Get-WeatherForecast -City Bangalore
```

**Get a 2-day forecast in Fahrenheit:**
```powershell
Get-WeatherForecast -City Hyderabad -Days 2 -Fahrenheit
```

## Requirements
- PowerShell 5.1 or PowerShell 7+ (Core)
- Active Internet connection to fetch API data.

## Author
Created by Ashish Arya.
