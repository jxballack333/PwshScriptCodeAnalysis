# Define the path to your PowerShell script and the target function name
$scriptPath = "Path\To\Your\Script.ps1"
$targetFunctionName = "YourFunctionName"

# Read the script content
$scriptContent = Get-Content -Path $scriptPath -Raw

# Create an AST from the script content
$scriptBlock = [ScriptBlock]::Create($scriptContent)
$ast = $scriptBlock.Ast

# Find all function definitions and calls
$functionDefinitions = $ast.FindAll({
    param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
}, $true)

$functionCalls = $ast.FindAll({
    param($node)
    $node -is [System.Management.Automation.Language.CommandAst]
}, $true)

# Initialize a map for function connections with script location
$functionConnections = @{}

# Map the connections for the target function
foreach ($function in $functionDefinitions) {
    if ($function.Name -eq $targetFunctionName) {
        $callerNames = @()
        $calleeNames = @()

        # Incoming Calls (Who is calling the target function)
        foreach ($call in $functionCalls) {
            if ($call.CommandElements[0].Value -eq $targetFunctionName) {
                $parent = $call
                while ($parent -and -not ($parent -is [System.Management.Automation.Language.FunctionDefinitionAst])) {
                    $parent = $parent.Parent
                }
                if ($parent -and $parent.Name) {
                    $callerNames += $parent.Name
                }
            }
        }

        # Outgoing Calls (Who the target function is calling)
        $targetFunctionBody = $function.Body.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.CommandAst]
        }, $true)

        foreach ($call in $targetFunctionBody) {
            $calleeNames += $call.CommandElements[0].Value
        }

        $functionConnections[$targetFunctionName] = @{
            "Callers" = $callerNames -as [Array]
            "Callees" = $calleeNames -as [Array]
            "Location" = $scriptPath
        }

        break
    }
}

# Output the connections for the target function
if ($functionConnections.Count -eq 0) {
    Write-Host "No connections found for the target function. Exiting script."
    exit
}

Write-Host "Connections for $targetFunctionName in $($scriptPath):"
$functionConnections

# Generate the DOT script for the target function
$dotScript = "digraph G {
    rankdir=LR;
    node [shape=box];
    label = `"$targetFunctionName in $scriptPath`";
"

foreach ($caller in $functionConnections[$targetFunctionName].Callers) {
    $dotScript += "`"$caller`" -> `"$targetFunctionName`";`n"
}

foreach ($callee in $functionConnections[$targetFunctionName].Callees) {
    $dotScript += "`"$targetFunctionName`" -> `"$callee`";`n"
}

$dotScript += "}"

# Save the DOT script to a file
Set-Content -Path "Path\To\Output\Graph_$targetFunctionName.dot" -Value $dotScript

# Output the generated DOT script for debugging
Write-Host "Generated DOT Script for $targetFunctionName:"
Write-Host $dotScript