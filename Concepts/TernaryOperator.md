# Ternary operator

- PowerShell 7.0 introduces a new syntax using the ternary operator.

    ```ps1
    <condition> ? <if-true> : <if-false>
    ```

- This operator behaves like simplified <b>if-else</b> statement.
- The <b> `<condition>` </b> expression is evaluated and the result is converted to a boolean to determine which branch should be evaluated next: 
    
    - The `<if-true>` expression is executed if the `<condition>` expression is true
    - The `<if-false>` expression is executed if the `<condition>` expression is false

    <br/>
    For example: 
    <br/><br/>

    ```ps1
        $message = (Test-Path $path) ? "Path exists" : "Path not found"
        Write-Output $message
    ```

    In this example, the value of <b>$message</b> variable is <b>Path exists</b> when <b>Test-Path</b> returns <b>$true</b>. When <b>Test-Path</b> returns <b>$false</b>, the value of <b>$message</b> is <b>Path not found</b>.

    Another example: 

    ```ps1
        $service = Get-Service BITS
        $service.Status -eq 'Running' ? (Stop-Service $service) : (Start-Service $service)
    ```

    In this example, if the service is running, it's stopped, and if its status is not Running, it's started.


- If a `<condition>`, `<if-true>`, or `<if-false>` expression calls a command, you must wrap it in parentheses. If you don't, PowerShell raises an argument exception for the command in the `<condition>` expression and parsing exceptions for the `<if-true>` and `<if-false>` expressions.

    For example, PowerShell raises exceptions for these ternaries:

    ```ps1
        Test-Path .vscode   ? Write-Host 'exists'   : Write-Host 'not found'
        (Test-Path .vscode) ? Write-Host 'exists'   : Write-Host 'not found'
        (Test-Path .vscode) ? (Write-Host 'exists') : Write-Host 'not found'
    ```

    ```ps1
    OUTPUT
            Test-Path: A positional parameter cannot be found that accepts argument '?'.
            ParserError:
            Line |
               1 |  (Test-Path .vscode) ? Write-Host 'exists'   : Write-Host 'not found'
                 |                       ~
                 | You must provide a value expression following the '?' operator.
            ParserError:
            Line |
               1 |  (Test-Path .vscode) ? (Write-Host 'exists') : Write-Host 'not found'
                 |                                               ~
                 | You must provide a value expression following the ':' operator.
    ```

    And this example parses:

    ```ps1
        (Test-Path .vscode) ? (Write-Host 'exists') : (Write-Host 'not found')
    ```

    ```ps1
        OUTPUT
        
        exists
    ```

- You can also use it for calculation : 


    ```ps1
        $widgetArray = @(
        [PSCustomObject]@{
            Name   = "widget001"
            Price  = 5.00
            OnSale = $true
        },
        [PSCustomObject]@{
            Name   = "widget002"
            Price  = 13.00
            OnSale = $true
        },
        [PSCustomObject]@{
            Name   = "widget003"
            Price  = 20.00
            OnSale = $false
        }
    )

    foreach ($widget in $widgetArray) {
        [PSCustomObject]@{
            "Name"          = $widget.Name
            "Over10Dollars" = ($widget.Price -gt 10) ? $true : $false
            "OnSale"        = ($widget.OnSale) ? 'On Sale' : 'Not on Sale'
            "SalePrice"     = ($widget.OnSale) ? $widget.Price * 0.85 : "---"
        }
    }
    ```

    ```ps1

    OUTPUT 

            Name     Over10Dollars OnSale      SalePrice
            ----     ------------- ------      ---------
            Widget01         False OnSale           4.25
            Widget02          True OnSale          11.05
            Widget03          True Not On Sale       ---
    ```