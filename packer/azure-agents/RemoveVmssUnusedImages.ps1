[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)]
  [String]$ResourceGroupName,

  [Parameter(Mandatory=$true)]
  [String]$VMScaleSetName,

  [Parameter(Mandatory=$false)]
  [Switch]$WhatIf
)

$ScriptName = $MyInvocation.MyCommand.Name
$StartTime = Get-Date

If ($WhatIf) {
  Write-Host "[$ScriptName] WhatIf switch enabled: No changes will be made"
}

Try {
  # Find the name of the image used by the VM Scale Set
  $AgentPool = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSetName
  $ImageName = ($AgentPool.VirtualMachineProfile.StorageProfile.ImageReference.Id).Split('/')[-1]
  Write-Host "[$ScriptName] VM Scale Set $VMScaleSetName is currently using image $ImageName"

  # Get all Images in the resource group
  $Images = Get-AzImage -ResourceGroupName $ResourceGroupName
  Write-Host "[$ScriptName] Found $($Images.Count) images in resource group $ResourceGroupName"

  If ($Images.Count -le 1) {
    Write-Host "[$ScriptName] Exiting: Nothing to do!"
    Exit 0
  }

} Catch {
  Write-Host "##vso[task.LogIssue type=error;]$($_.Exception.Message)"
  Exit 1
}

# Find the latest image based on the date in the name
$LatestImage = $Images | Sort-Object { $_.Name -match '\d{4}-\d{2}-\d{2}-\d{4}'; [DateTime]::ParseExact($matches[0], 'yyyy-MM-dd-HHmm', $null) } -Descending | Select-Object -First 1
Write-Host "[$ScriptName] Latest image is $($LatestImage.Name)"

$RemovedCount = 0
Foreach ($Image in $Images) {
  If ($Image.Name -ne $LatestImage.Name) {
    Try {
      If ($WhatIf) {
        Write-Host "[$ScriptName] [WhatIf] Would have removed image: $($Image.Name)"
        $RemovedCount++

      } Else {
        Write-Host "[$ScriptName] Removing image: $($Image.Name)`n"
        Remove-AzImage -ResourceGroupName $ResourceGroupName -ImageName $Image.Name -Force
        Write-Host "[$ScriptName] Successfully removed image: $($Image.Name)"
        $RemovedCount++
      }

    } Catch {
      Write-Host "[$ScriptName] Failed to remove image: $($Image.Name)"
      Write-Host "##vso[task.LogIssue type=warning;]$($_.Exception.Message)"
      Continue
    }

  } Else {
    Write-Host "[$ScriptName] Keeping latest image: $($Image.Name)"
  }
}

If ($WhatIf) {
  Write-Host "[$ScriptName] [WhatIf] Would have removed $RemovedCount images"
} Else {
  $RunTime = New-TimeSpan -Start $StartTime -End (Get-Date)
  Write-Host "[$ScriptName] Removed $RemovedCount images"
  Write-Host "[$ScriptName] Script completed in $($RunTime.Minutes) minutes and $($RunTime.Seconds) seconds"
}

Exit 0
