# Set Global Module Verbose
$VerbosePreference = 'Continue' 

# Load Localization Data 
Import-LocalizedData LocalizedData -filename UpdateServices.strings.psd1 -ErrorAction SilentlyContinue
Import-LocalizedData USLocalizedData -filename UpdateServices.strings.psd1 -UICulture en-US -ErrorAction SilentlyContinue

<#
    .SYNOPSIS
    Simplifies writing a terminating error

    .PARAMETER ErrorType
    A descriptive value that specifies the type of error

    .PARAMETER FormatArgs
    Optional arguments to specify formatting of the error
    
    .PARAMETER ErrorCategory
    Optional value to set the error category
    
    .PARAMETER TargetObject
    The object that was being processed when the error occurred
#>
function New-TerminatingError
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ErrorRecord])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ErrorType,

        [parameter(Mandatory = $false)]
        [String[]]
        $FormatArgs,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.ErrorCategory]
        $ErrorCategory = [System.Management.Automation.ErrorCategory]::OperationStopped,

        [parameter(Mandatory = $false)]
        [Object]
        $TargetObject = $null
    )

    $errorMessage = $LocalizedData.$ErrorType
    
    if(!$errorMessage)
    {
        $errorMessage = ($LocalizedData.NoKeyFound -f $ErrorType)

        if(!$errorMessage)
        {
            $errorMessage = ("No Localization key found for key: {0}" -f $ErrorType)
        }
    }

    $errorMessage = ($errorMessage -f $FormatArgs)

    $callStack = Get-PSCallStack 

    # Get Name of calling script
    if($callStack[1] -and $callStack[1].ScriptName)
    {
        $scriptPath = $callStack[1].ScriptName

        $callingScriptName = $scriptPath.Split('\')[-1].Split('.')[0]
    
        $errorId = "$callingScriptName.$ErrorType"
    }
    else
    {
        $errorId = $ErrorType
    }


    Write-Verbose -Message "$($USLocalizedData.$ErrorType -f $FormatArgs) | ErrorType: $errorId"

    $exception = New-Object System.Exception $errorMessage;
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $ErrorCategory, $TargetObject

    return $errorRecord
}
