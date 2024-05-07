
# Getting All services
$Services = Get-Service

# Group-Object with no Parameters
$Services | Group-Object

# Grouping objects by a single property
$services | Group-Object -Property Status

# Filtering Group-Object Output
$services | Group-Object -Property Status | Where-Object { $_.Name -eq 'Stopped' } | Select-Object -ExpandProperty Group

# Grouping objects by multiple properties
$services | Group-Object -Property Status, StartType


