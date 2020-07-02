[CmdletBinding()] 
param(   
    [string]
    [ValidateNotNullOrEmpty()]
    $Subscription,
    [string]
    $Tenant,
    [string]
    [ValidateNotNullOrEmpty()]
    $ClientId,
    [string]
    [ValidateNotNullOrEmpty()]
    $ClientSecret,
    [string]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('DataBricks','AzureApi')]
    $Application
)

    $azAccount = (az account show) | ConvertFrom-Json -AsHashtable
    if ($null -eq $azAccount)
    {
        az login --service-principal -u $ClientId -p $ClientSecret --tenant $Tenant
    }

    if ($Application -eq 'DataBricks')
    {
        $Response= az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d
    }
    elseif ($Application -eq 'AzureApi')
    {
        $Response= az account get-access-token --resource https://management.core.windows.net/
    }    
    
    $accessToken = ($Response| ConvertFrom-Json).accessToken

return @{'accessToken' = "$accessToken"} | ConvertTo-Json