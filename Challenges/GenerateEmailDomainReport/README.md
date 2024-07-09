# Problem Statement

## Objective

Develop a PowerShell script that processes a text file containing information about individuals, including their country and email addresses. The script should generate a report that shows the count of email addresses by domain (Gmail, Hotmail, Yahoo, Others) for specific countries (UK, USA, Canada).

## Requirements

1. **Parameters**:
   - **FilePath**: The path to the text file containing the input data.

2. **Input**:
   You have a text file containing information about individuals, including their country and email addresses. Each line in the text     
  file contains data in the below format: 

    ```ps1
      Johnetta,Abdallah,Orange,USA,NC,johnetta_abdallah@aol.com 
      Louvenia,Abney,SK,Canada,S6V 6A4,louvenia_abney@hotmail.com
    ```

4. **Output**:
  The goal is to process this file and generate a report that shows the count of email addresses by domain (Gmail, Hotmail, Yahoo, Others)   for specific countries (UK, USA, Canada).

    ```ps1
        Country Gmail Hotmail Yahoo Others
        ------- ----- ------- ----- ------
        Canada     63      60    57    302
        UK        122     105   116    130
        USA        66      70    84    267
    ```

## Example Usage

```powershell
.\Solution.ps1 
```
