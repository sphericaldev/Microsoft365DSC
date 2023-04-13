function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.Boolean]
        $CortanaEnabled,

        [Parameter()]
        [System.Boolean]
        $M365WebEnableUsersToOpenFilesFrom3PStorage,

        [Parameter()]
        [System.Boolean]
        $MicrosoftVivaBriefingEmail,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsWebExperience,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsDigestEmail,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsOutlookAddInAndInlineSuggestions,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsScheduleSendSuggestions,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity
    )

    if ($PSBoundParameters.ContainsKey('Ensure') -and $Ensure -eq 'Absent')
    {
        throw 'This resource is not able to remove Org Settings settings and therefore only accepts Ensure=Present.'
    }

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters `
        -ProfileName 'v1.0'

    $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
        -InboundParameters $PSBoundParameters

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $nullReturn = @{
        IsSingleInstance = $IsSingleInstance
        Ensure           = 'Absent'
    }

    try
    {
        $OfficeOnlineId = 'c1f33bc0-bdb4-4248-ba9b-096807ddb43e'
        $M365WebEnableUsersToOpenFilesFrom3PStorageValue = Get-MgServicePrincipal -Filter "appId eq '$OfficeOnlineId'" -Property 'AccountEnabled'

        $CortanaId = '0a0a29f9-0a25-49c7-94bf-c53c3f8fa69d'
        $CortanaEnabledValue = Get-MgServicePrincipal -Filter "appId eq '$CortanaId'" -Property 'AccountEnabled'

        # Microsoft Viva Briefing Email
        $vivaBriefingEmailValue = $false
        $currentBriefingConfig = Get-DefaultTenantBriefingConfig
        if ($currentBriefingConfig.PrivacyMode -eq 'opt-in')
        {
            $vivaBriefingEmailValue = $true
        }

        # Viva Insightss settings
        $currentVivaInsightsSettings = Get-DefaultTenantMyAnalyticsFeatureConfig

        return @{
            IsSingleInstance                             = 'Yes'
            CortanaEnabled                               = $CortanaEnabledValue.AccountEnabled
            M365WebEnableUsersToOpenFilesFrom3PStorage   = $M365WebEnableUsersToOpenFilesFrom3PStorageValue.AccountEnabled
            MicrosoftVivaBriefingEmail                   = $vivaBriefingEmailValue
            VivaInsightsWebExperience                    = $currentVivaInsightsSettings.IsDashboardEnabled
            VivaInsightsDigestEmail                      = $currentVivaInsightsSettings.IsDigestEmailEnabled
            VivaInsightsOutlookAddInAndInlineSuggestions = $currentVivaInsightsSettings.IsAddInEnabled
            VivaInsightsScheduleSendSuggestions          = $currentVivaInsightsSettings.IsScheduleSendEnabled
            Ensure                                       = 'Present'
            Credential                                   = $Credential
            ApplicationId                                = $ApplicationId
            TenantId                                     = $TenantId
            ApplicationSecret                            = $ApplicationSecret
            CertificateThumbprint                        = $CertificateThumbprint
            Managedidentity                              = $ManagedIdentity.IsPresent
        }
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error retrieving data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return $nullReturn
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.Boolean]
        $CortanaEnabled,

        [Parameter()]
        [System.Boolean]
        $M365WebEnableUsersToOpenFilesFrom3PStorage,

        [Parameter()]
        [System.Boolean]
        $MicrosoftVivaBriefingEmail,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsWebExperience,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsDigestEmail,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsOutlookAddInAndInlineSuggestions,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsScheduleSendSuggestions,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity
    )

    if ($PSBoundParameters.ContainsKey('Ensure') -and $Ensure -eq 'Absent')
    {
        throw 'This resource is not able to remove the Org settings and therefore only accepts Ensure=Present.'
    }

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Write-Verbose -Message 'Setting configuration of Office 365 Settings'
    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters `
        -ProfileName 'v1.0'

    $OfficeOnlineId = 'c1f33bc0-bdb4-4248-ba9b-096807ddb43e'
    $M365WebEnableUsersToOpenFilesFrom3PStorageValue = Get-MgServicePrincipal -Filter "appId eq '$OfficeOnlineId'" -Property 'AccountEnabled, Id'
    if ($M365WebEnableUsersToOpenFilesFrom3PStorage -ne $M365WebEnableUsersToOpenFilesFrom3PStorageValue.AccountEnabled)
    {
        Write-Verbose -Message "Setting the Microsoft 365 On the Web setting to {$M365WebEnableUsersToOpenFilesFrom3PStorage}"
        Update-MgServicePrincipal -ServicePrincipalId $($M365WebEnableUsersToOpenFilesFrom3PStorageValue.Id) `
            -AccountEnabled:$M365WebEnableUsersToOpenFilesFrom3PStorage
    }

    $CortanaId = '0a0a29f9-0a25-49c7-94bf-c53c3f8fa69d'
    $CortanaEnabledValue = Get-MgServicePrincipal -Filter "appId eq '$CortanaId'" -Property 'AccountEnabled, Id'
    if ($CortanaEnabled -ne $CortanaEnabledValue.AccountEnabled)
    {
        Write-Verbose -Message "Setting the Cortana setting to {$CortanaEnabled}"
        Update-MgServicePrincipal -ServicePrincipalId $($CortanaEnabledValue.Id) `
            -AccountEnabled:$CortanaEnabled
    }

    # Microsoft Viva Briefing Email
    Write-Verbose -Message "Updating Microsoft Viva Briefing Email settings."
    $briefingValue = 'opt-out'
    if ($MicrosoftVivaBriefingEmail)
    {
        $briefingValue = 'opt-in'
    }
    Set-DefaultTenantBriefingConfig -PrivacyMode $briefingValue | Out-Null

    # Viva Insights
    Write-Verbose -Message "Updating Viva Insights settings."
    Set-DefaultTenantMyAnalyticsFeatureConfig -Feature "Dashboard" -IsEnabled $VivaInsightsWebExperience | Out-Null
    Set-DefaultTenantMyAnalyticsFeatureConfig -Feature "Digest-email" -IsEnabled $VivaInsightsDigestEmail | Out-Null
    Set-DefaultTenantMyAnalyticsFeatureConfig -Feature "Add-In" -IsEnabled $VivaInsightsOutlookAddInAndInlineSuggestions | Out-Null
    Set-DefaultTenantMyAnalyticsFeatureConfig -Feature "Scheduled-send" -IsEnabled $VivaInsightsScheduleSendSuggestions | Out-Null
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.Boolean]
        $CortanaEnabled,

        [Parameter()]
        [System.Boolean]
        $M365WebEnableUsersToOpenFilesFrom3PStorage,

        [Parameter()]
        [System.Boolean]
        $MicrosoftVivaBriefingEmail,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsWebExperience,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsDigestEmail,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsOutlookAddInAndInlineSuggestions,

        [Parameter()]
        [System.Boolean]
        $VivaInsightsScheduleSendSuggestions,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity
    )
    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Write-Verbose -Message 'Testing configuration for Org Settings.'

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

    Write-Verbose -Message "Test-TargetResource returned $TestResult"

    return $TestResult
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity
    )
    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters `
        -ProfileName 'v1.0'

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try
    {
        $Params = @{
            IsSingleInstance      = 'Yes'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificateThumbprint = $CertificateThumbprint
            Managedidentity       = $ManagedIdentity.IsPresent
        }

        $Results = Get-TargetResource @Params

        $dscContent = ''
        if ($Results.Ensure -eq 'Present')
        {
            $Results = Update-M365DSCExportAuthenticationResults -ConnectionMode $ConnectionMode `
                -Results $Results
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential
            $dscContent += $currentDSCBlock

            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
        }
        Write-Host $Global:M365DSCEmojiGreenCheckMark

        return $dscContent
    }
    catch
    {
        Write-Host $Global:M365DSCEmojiRedX

        New-M365DSCLogEntry -Message 'Error during Export:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return ''
    }
}

Export-ModuleMember -Function *-TargetResource
