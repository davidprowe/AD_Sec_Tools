<##############################################################################
Setup

Your working folder path should include your MigrationTableCSV files, a copy
of this script, a copy of the GPOMigration.psm1 module file, and the GPO
backup folder from the export.

This example assumes that a backup will run under a source credential and server,
and the import will run under a destination credential and server.  Between these
two operations you will need to copy your working folder from one environment to
the other.

NOTE: Before running you will need at least one MigrationTableCSV file using
this format:
Source,Destination,Type
"OldDomain.FQDN","NewDomain.FQDN","Domain"
"OldDomainNETBIOSName","NewDomainNETBIOSName","Domain"
"\\foo\server","\\baz\server","UNC"

Modify the following to your needs:
 working folder path
 GPO backup folder path
 destination domains and servers
 MigTableCSV files
##############################################################################>
function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}
$scriptPath = Get-ScriptDirectory
$adplatformsourcedir = split-path -Path $scriptPath -Parent
import-module ($scriptPath+'\GPOMigration\gpomigration.psm1') -force

Import-Module GroupPolicy
Import-Module ActiveDirectory

# This path must be absolute, not relative
$Path        = $scriptPath  # Current folder specified in Set-Location above
$BackupPath  = $scriptPath+ "\GPO"

###############################################################################
# IMPORT
###############################################################################
$domain = "ad:"
cd $domain

$DestDomain  = (Get-ADDomain).dnsroot
$DestServer  = (Get-ADDomain).pdcemulator
$MigTableCSVPath = $scriptPath + '\adatum_to_anything.csv'
$csv = import-csv $MigTableCSVPath
$csv.destination = (Get-ADDomain).dnsroot
$csv|export-csv -NoTypeInformation -Path $MigTableCSVPath

Start-GPOImport `
    -DestDomain $DestDomain `
    -DestServer $DestServer `
    -Path $Path `
    -BackupPath $BackupPath `
    -MigTableCSVPath $MigTableCSVPath `
    #-CopyACL






<#

###############################################################################
# DEV to QA
###############################################################################
$DestDomain  = 'qa.wingtiptoys.com'
$DestServer  = 'dc1.qa.wingtiptoys.com'
$MigTableCSVPath = '.\MigTable_DEV_to_QA.csv'

Start-GPOImport `
    -DestDomain $DestDomain `
    -DestServer $DestServer `
    -Path $Path `
    -BackupPath $BackupPath `
    -MigTableCSVPath $MigTableCSVPath `
    -CopyACL

###############################################################################
# DEV to PROD
###############################################################################
$DestDomain  = 'prod.wingtiptoys.com'
$DestServer  = 'dc1.prod.wingtiptoys.com'
$MigTableCSVPath = '.\MigTable_DEV_to_PROD.csv'

Start-GPOImport `
    -DestDomain $DestDomain `
    -DestServer $DestServer `
    -Path $Path `
    -BackupPath $BackupPath `
    -MigTableCSVPath $MigTableCSVPath `
    -CopyACL

###############################################################################
# END
###############################################################################

#>
