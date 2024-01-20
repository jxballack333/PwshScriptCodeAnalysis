# Define the path to your PowerShell script
$scriptPath = "Path\To\Your\Script.ps1"

# Read the script content
$scriptContent = Get-Content -Path $scriptPath -Raw

# Create an AST from the script content
$scriptBlock = [ScriptBlock]::Create($scriptContent)
$ast = $scriptBlock.Ast

# Find all function definitions
$functionDefinitions = $ast.FindAll({
    param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
}, $true)

# Debug: Output the found function definitions
Write-Host "Function Definitions Found:"
foreach ($def in $functionDefinitions) {
    Write-Host $def.Name
}

# Find all function calls
$functionCalls = $ast.FindAll({
    param($node)
    $node -is [System.Management.Automation.Language.CommandAst]
}, $true)

# Debug: Output the found function calls
Write-Host "Function Calls Found:"
foreach ($call in $functionCalls) {
    Write-Host $call.CommandElements[0].Value
}

# Initialize a map for function connections
$functionConnections = @{}

# Map the connections
foreach ($function in $functionDefinitions) {
    $functionName = $function.Name
    $callerNames = @()

    foreach ($call in $functionCalls) {
        if ($call.CommandElements[0].Value -eq $functionName) {
            # Navigate up the AST to find the parent function name
            $parent = $call
            while ($parent -and -not ($parent -is [System.Management.Automation.Language.FunctionDefinitionAst])) {
                $parent = $parent.Parent
            }
            if ($parent -and $parent.Name) {
                $callerNames += $parent.Name
            }
        }
    }

    if ($callerNames) {
        $functionConnections[$functionName] = $callerNames
    } else {
        $functionConnections[$functionName] = @()
    }

    # Debug: Output the mapped connections
    Write-Host "$functionName is called by: $($callerNames -join ', ')"
}

# Check if functionConnections is still empty
if ($functionConnections.Count -eq 0) {
    Write-Host "No connections found. Exiting script."
    exit
}

# Generate the DOT script
$dotScript = "digraph G {
    rankdir=LR;
    node [shape=box];
"

foreach ($function in $functionConnections.Keys) {
    foreach ($caller in $functionConnections[$function]) {
        if ($caller) {
            $dotScript += "`"$caller`" -> `"$function`";`n"
        }
    }
}

$dotScript += "}"

# Save the DOT script to a file
Set-Content -Path "Path\To\Output\Graph.dot" -Value $dotScript

# Output the generated DOT script for debugging
Write-Host "Generated DOT Script:"
Write-Host $dotScript