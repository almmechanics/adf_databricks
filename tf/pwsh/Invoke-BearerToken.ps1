[CmdletBinding()] 
param(   
    [string]
    [ValidateNotNullOrEmpty()]
    $token,
    [string]
    [ValidateNotNullOrEmpty()]
    $azToken,
    [string]
    [ValidateNotNullOrEmpty()]
    $ResourceID,
    [string]
    [ValidateNotNullOrEmpty()]
    $location
)

$bearer = (invoke-restmethod -Headers @{'Authorization'='Bearer {0}'-f $token; 'X-Databricks-Azure-SP-Management-Token'=('{0}'-f $aztoken) ; 'X-Databricks-Azure-Workspace-Resource-Id'=$ResourceID} -uri ('https://{0}.azuredatabricks.net/api/2.0/token/create' -f $location) -method post).token_value                                                            
$return = @{'bearer' = $bearer} 
Write-Verbose $return
return ($return | ConvertTo-Json -depth 99)