<#
- This module is a collection of PSScriptAnalyzer rules that are used to enforce best practices and coding standards for PowerShell scripts.
- The rules are based on the recommendations from the PowerShell Best Practices and Style Guide
    - Code Layout and Formatting
        - Capitalization Conventions
            - Public Identifiers - Pascal Case
                - Module Names
                - Function Names
                - Cmdlet Names
                - Class Names
                - Enum Names
                - Attribute Names
                - Public Fields and Properties
                - Global Variables
                - Constants
                - Parameter Names
            - PowerShell Language Keywords - Lower Case
            - Comment-Based Help Keywords - Upper Case
            - Two Letter acyronyms - Upper Case
            - Variables within Functions - Camel Case (taste)
            - Variables with two-letter acronyms - letters Lower Case 
            (- Shared Variables - Scope)
        - Brace Style
            - OTBF - One True Brace Style (VSCode)
        - Script-start
            - Scripts and Functions should use always CmdletBinding
            - Write script in order of exectution
                - param
                - begin
                - process
                - end
                - clean
        - Identation - 4 spaces
        - Line length - 115 characters (when possible)
        - Blank Lines
            - Around Functions - 2 blank lines
            - Around Class defintions - 2 blank lines
            - File End - 1 blank line
        - Trailing spaces - No trailing spaces
        - Space around parameters and operators
            - Single space around: 
                - Parameter names and operators
                - Commas
                - Semicolons
                - Curly braces
                - Exception for switch parameters and Unary operators
            - Single space inside:
                - subexpressions ($())
                - scriptblocks ({})
            - Avoid semi-colons as line terminators
        - Function structure
            - Functions
                - Avoid ending with return statement
            - Advanced Functions
                - Verb-Noun naming convention
                - Noun can be more than one word in Pascal Case
                - Return objects in Process, not in Begin or End
                - Always have a CmdletBinding attribute
                - When process is present, use ValueFromPipeline and ValueFromPipelineByPropertyName
                - Specify an output type, if functions returns objects
                    - When more than one type is returned, create one per parameter set
                - When a ParameterSetName is used in any of the parameters, always provide a DefaultParameterSetName in the CmdletBinding attribute.
                - When using advanced functions or scripts with CmdletBinding attribute avoid validating parameters in the body of the script when possible and use parameter validation attributes instead.
        - Documentation
            - Write comment-based help for all functions and scripts
            - Inline comments should be soaced two spaces after the code
            - Document each parameter, short descriptions should reside in the param block
            - Provide at least a Synopsis, Description, and Example in the comment-based help
        - Readability
            - Indentation
            - Avoid backticks
        - Naming Conventions
            - Use the full name of each command
            - Use full parameter names
            - Use full explicit Paths
            - Avoid use of ~
#>

#Voorbeeldje:
#using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
#using namespace System.Management.Automation.Language

function Test-PSContinueOutsideLoop {
    <#
    .SYNOPSIS
        PSContinueOutsideLoop
    
    .DESCRIPTION
        The continue statement should only be used inside loops (for, foreach, do, while), switch, or trap statements.
    #>
    
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.ContinueStatementAst]$Ast
    )
    
    # Get the parent ASTs to determine if we're inside a loop structure
    $parentAst = $ast.Parent
    $insideValidConstruct = $false
    
    # Navigate up the AST until we find a loop construct or reach the root
    while ($null -ne $parentAst) {
        if ($parentAst -is [System.Management.Automation.Language.ForStatementAst] -or
            $parentAst -is [System.Management.Automation.Language.ForEachStatementAst] -or
            $parentAst -is [System.Management.Automation.Language.DoWhileStatementAst] -or
            $parentAst -is [System.Management.Automation.Language.WhileStatementAst] -or
            $parentAst -is [System.Management.Automation.Language.SwitchStatementAst] -or
            $parentAst -is [System.Management.Automation.Language.TrapStatementAst]) {
            
            $insideValidConstruct = $true
            break
        }
        
        $parentAst = $parentAst.Parent
    }
    
    # If we're not inside a valid construct, report a violation
    if (-not $insideValidConstruct) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Continue statement is used outside of a loop, switch or trap statement.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}

#region Code Layout and Formatting
#region Capitalization Conventions
#region Public Identifiers - Pascal Case
# - Module Names, how to test this?
# Function Names
function Test-PSPublicIdentifiersPascalCaseFunction {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.FunctionDefinitionAst]$Ast
    )
    # Predicate
    $insideValidConstruct = $ast.Name -cnotmatch '^[A-Z][a-z]*(-)([A-Z][a-z]*)+$'
    # If we're not inside a valid construct, report a violation
    # @(
    #     'bad-Example1',
    #     'bad-example2',
    #     'BadExample3',
    #     'Badexample4'
    #     'Good-Example',
    #     'Good-ExampleTwo'
    # )
    if ($insideValidConstruct) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Function name is not in Pascal Case or missing a hyphen.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}
# - Cmdlet Names (binary modules only)
# - Class Names - Same as enum names
# - Enum Names
function Test-PSPublicIdentifiersPascalCaseClass {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.TypeDefinitionAst]$ast
    )
    # Predicate
    # enum Good {
    #     Asterisk
    # }
    # enum bad {
    #     Dash
    # }
    # class Good {
    #     [string]$Brand
    # }
    # class bad{
    #     [string]$Model
    # }
    $insideValidConstruct = $ast.Name -cnotmatch '^[A-Z]'
    # If we're not inside a valid construct, report a violation
    
    if ($insideValidConstruct) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Class name is not in Pascal Case'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}
# - Attribute Names
function Test-PSPublicIdentifiersPascalCaseAttribute {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.AttributeAst]$Ast
    )
    # Predicate
    $insideValidConstruct = $ast.TypeName.Name -cnotmatch '^[A-Z]'
    # If we're not inside a valid construct, report a violation
    if ($insideValidConstruct) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Attribute name is not in Pascal Case'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}
# - Public Fields and Properties - not a concept in pwsh
# - Global Variables
function Test-PSPublicIdentifiersPascalCaseGlobalVariable {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.VariableExpressionAst]$Ast
    )
    # Predicate
    $insideValidConstruct = $false
    if ($ast.VariablePath.IsGlobal) {
        $insideValidConstruct = $ast.VariablePath.UserPath -cnotmatch '^global:[A-Z]'
    }
    # If we're not inside a valid construct, report a violation
    if ($insideValidConstruct) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'GlobalVariable name is not in Pascal Case'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}

# - Constants
function Test-PSPublicIdentifiersPascalCaseConstant {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.CommandAst]$Ast
    )

    # Check if this is a New-Variable command with -Option Constant
    if ($ast.CommandElements[0].Value -eq 'New-Variable') {
        $nameParam = $null
        $optionParam = $null
        
        # Find name and option parameters
        foreach ($element in $ast.CommandElements) {
            if ($element -is [System.Management.Automation.Language.CommandParameterAst]) {
                if ($element.ParameterName -eq 'Name') {
                    $nameParam = $ast.CommandElements[$ast.CommandElements.IndexOf($element) + 1]
                }
                if ($element.ParameterName -eq 'Option') {
                    $optionParam = $ast.CommandElements[$ast.CommandElements.IndexOf($element) + 1]
                }
            }
        }
        
        # Check if this is defining a constant
        if ($null -ne $optionParam -and $optionParam.Value -eq 'Constant') {
            # Check if the constant name is Pascal Case
            if ($nameParam.Value -cnotmatch '^[A-Z][a-zA-Z0-9_]*$') {
                return [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message  = 'Constant name is not in Pascal Case'
                    Extent   = $nameParam.Extent
                    RuleName = $myinvocation.MyCommand.Name
                    Severity = 'Information'
                }
            }
        }
    }
}

# - Parameter Names
function Test-PSPublicIdentifiersPascalCaseParameter {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.ParameterAst]$Ast
    )
    # Predicate
    $insideValidConstruct = $ast.Name.VariablePath -cnotmatch '^[A-Z]'
    # If we're not inside a valid construct, report a violation
    if ($insideValidConstruct) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Parameter name is not in Pascal Case'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}
#endregion Public Identifiers - Pascal Case
#endregion Capitalization Conventions
#endregion Code Layout and Formatting
#endregion Public Identifiers - Pascal Case
#endregion Capitalization Conventions
#region Script-start
# - Scripts and Functions should use always CmdletBinding
function Test-PSScriptStartCmdletBinding {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.ScriptBlockAst]$Ast
    )
    
    # Skip this check if we're in a .psm1 file or if the file path is null
    if ($null -eq $Ast.Extent.File -or $Ast.Extent.File -match '\.psm1$') {
        return
    }
    
    # Only check top-level script blocks in .ps1 files
    if ($Ast.Parent -is [System.Management.Automation.Language.ScriptBlockAst] -or 
        $Ast.Parent -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
        return
    }
    
    # Check if the script has CmdletBinding
    $hasCmdletBinding = $false
    if ($null -ne $Ast.ParamBlock) {
        foreach ($attribute in $Ast.ParamBlock.Attributes) {
            if ($attribute.TypeName.Name -eq 'CmdletBinding') {
                $hasCmdletBinding = $true
                break
            }
        }
        
        # If we don't have CmdletBinding, report a violation
        if (-not $hasCmdletBinding) {
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                Message  = 'Script is missing CmdletBinding attribute'
                Extent   = $Ast.ParamBlock.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Information'
            }
        }
    }
}
function Test-PSFunctionStartCmdletBinding {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.FunctionDefinitionAst]$Ast
    )
    # Predicate
    $insideValidConstruct = $false
    
    # Check if the function has a CmdletBinding attribute
    foreach ($attribute in $Ast.Body.ParamBlock.Attributes) {
        if ($attribute.TypeName.Name -eq 'CmdletBinding') {
            $insideValidConstruct = $true
            break
        }
    }
    
    # If we're not inside a valid construct, report a violation
    if (-not $insideValidConstruct) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Function is missing CmdletBinding attribute'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}
function Test-PSScriptNamedBlockOrder {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.ScriptBlockAst]$Ast
    )
    
    # Only check top-level script blocks (not inside functions)
    if ($Ast.Parent -is [System.Management.Automation.Language.ScriptBlockAst] -or 
        $Ast.Parent -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
        return
    }
    
    # Get only direct child named blocks for this script
    $blocks = $Ast.FindAll({ 
            param($node)
            $node -is [System.Management.Automation.Language.NamedBlockAst] -and
            $node.Parent -eq $Ast
        }, $false)
    
    # If no blocks or only one block, nothing to check
    if ($null -eq $blocks -or $blocks.Count -le 1) {
        return
    }
    
    # Sort blocks by their actual position in the code
    $sortedBlocks = $blocks | Sort-Object { $_.Extent.StartOffset }
    
    $expectedOrder = @('param', 'begin', 'process', 'end', 'clean')
    $foundBlocks = @()
    
    foreach ($block in $sortedBlocks) {
        $blockType = $block.BlockKind.ToString().ToLower()
        if ($blockType -in $expectedOrder) {
            $foundBlocks += $blockType
        }
    }
    
    # Check if the found blocks are in the expected order
    for ($i = 0; $i -lt ($foundBlocks.Count - 1); $i++) {
        $currentIndex = $expectedOrder.IndexOf($foundBlocks[$i])
        $nextIndex = $expectedOrder.IndexOf($foundBlocks[$i + 1])
        
        if ($nextIndex -lt $currentIndex) {
            return [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                Message  = 'Script blocks not in recommended order: param, begin, process, end, clean'
                Extent   = $sortedBlocks[$i + 1].Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Information'
            }
        }
    }
}

function Test-PSFunctionNamedBlockOrder {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.FunctionDefinitionAst]$Ast
    )
    
    # Get the function's script block
    $scriptBlock = $Ast.Body
    
    # Get named blocks in the function
    $blocks = $scriptBlock.FindAll({ 
            param($node)
            $node -is [System.Management.Automation.Language.NamedBlockAst] -and
            $node.Parent -eq $scriptBlock
        }, $false)
    
    # If no blocks or only one block, nothing to check
    if ($null -eq $blocks -or $blocks.Count -le 1) {
        return
    }
    
    # Sort blocks by their actual position in the code
    $sortedBlocks = $blocks | Sort-Object { $_.Extent.StartOffset }
    
    $expectedOrder = @('param', 'begin', 'process', 'end', 'clean')
    $foundBlocks = @()
    
    foreach ($block in $sortedBlocks) {
        $blockType = $block.BlockKind.ToString().ToLower()
        if ($blockType -in $expectedOrder) {
            $foundBlocks += $blockType
        }
    }
    
    # Check if the found blocks are in the expected order
    for ($i = 0; $i -lt ($foundBlocks.Count - 1); $i++) {
        $currentIndex = $expectedOrder.IndexOf($foundBlocks[$i])
        $nextIndex = $expectedOrder.IndexOf($foundBlocks[$i + 1])
        
        if ($nextIndex -lt $currentIndex) {
            return [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                Message  = 'Function blocks not in recommended order: param, begin, process, end, clean'
                Extent   = $sortedBlocks[$i + 1].Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Information'
            }
        }
    }
}
#endregion Script-start
# - Identation - 4 spaces (VSCode)
# - Line length - 115 characters (when possible) (VSCode)
# - Blank Lines
#     - Around Functions - 2 blank lines
function Test-PSBlankLinesAroundFunction {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.FunctionDefinitionAst]$Ast
    )
    
    # Skip if there's no file content to check
    if ($null -eq $Ast.Extent.File) {
        return
    }
    
    # Read the file content
    $fileContent = Get-Content -Path $Ast.Extent.File -Raw
    $lines = $fileContent -split "`n"
    
    # Get the line numbers for this function
    $startLine = $Ast.Extent.StartLineNumber - 1  # 0-based index
    $endLine = $Ast.Extent.EndLineNumber - 1      # 0-based index
    
    $blankLinesBefore = 0
    $blankLinesAfter = 0
    
    # Count blank lines before function
    for ($i = $startLine - 1; $i -ge 0; $i--) {
        if ([string]::IsNullOrWhiteSpace($lines[$i])) {
            $blankLinesBefore++
        } else {
            break
        }
    }
    
    # Count blank lines after function
    for ($i = $endLine + 1; $i -lt $lines.Length; $i++) {
        if ([string]::IsNullOrWhiteSpace($lines[$i])) {
            $blankLinesAfter++
        } else {
            break
        }
    }
    
    # Check if we have at least 2 blank lines before and after
    if ($blankLinesBefore -lt 2 -or $blankLinesAfter -lt 2) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Functions should have 2 blank lines before and after'
            Extent   = $Ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}

#     - Around Class defintions - 2 blank lines
function Test-PSBlankLinesAroundClass {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.TypeDefinitionAst]$Ast
    )
    
    # Skip if there's no file content to check
    if ($null -eq $Ast.Extent.File) {
        return
    }
    
    # Read the file content
    $fileContent = Get-Content -Path $Ast.Extent.File -Raw
    $lines = $fileContent -split "`n"
    
    # Get the line numbers for this class
    $startLine = $Ast.Extent.StartLineNumber - 1  # 0-based index
    $endLine = $Ast.Extent.EndLineNumber - 1      # 0-based index
    
    $blankLinesBefore = 0
    $blankLinesAfter = 0
    
    # Count blank lines before class
    for ($i = $startLine - 1; $i -ge 0; $i--) {
        if ([string]::IsNullOrWhiteSpace($lines[$i])) {
            $blankLinesBefore++
        } else {
            break
        }
    }
    
    # Count blank lines after class
    for ($i = $endLine + 1; $i -lt $lines.Length; $i++) {
        if ([string]::IsNullOrWhiteSpace($lines[$i])) {
            $blankLinesAfter++
        } else {
            break
        }
    }
    
    # Check if we have at least 2 blank lines before and after
    if ($blankLinesBefore -lt 2 -or $blankLinesAfter -lt 2) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Classes should have 2 blank lines before and after'
            Extent   = $Ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}
#     - File End - 1 blank line
function Test-PSBlankLinesFileEnd {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.ScriptBlockAst]$Ast
    )
    
    # Skip if there's no file content to check or not top-level script block
    if ($null -eq $Ast.Extent.File -or $Ast.Parent -ne $null) {
        return
    }
    
    # Read the file content
    $fileContent = Get-Content -Path $Ast.Extent.File -Raw
    
    # Check if the file ends with a newline
    if (-not $fileContent.EndsWith("`n")) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'File should have 1 blank line at the end'
            Extent   = $Ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
    # Check if file ends with multiple blank lines
    elseif ($fileContent.EndsWith("`n`n`n")) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'File should have exactly 1 blank line at the end'
            Extent   = $Ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}
# - Trailing spaces - No trailing spaces - Builtin Rule AvoidTrailingWhitespace
#region Space around parameters and operators
#     - Single space around:
#         - Parameter names and operators #TODO: Check if this is possible
# function Test-PSSpaceAroundParameterAndOperator {
#     [CmdletBinding()]
#     [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
#     param (
#         [System.Management.Automation.Language.CommandAst]$Ast
#     )
#     $expect = ''
#     foreach ($element in $Ast.CommandElements) {
#         $expect += ' ' + $element.Extent.Text
#     }
#     $expect = $expect.TrimEnd()

#     # Check if the parameter name has a space around it
#     if ($_.Extent.Text -ne $expect) {
#         [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
#             Message  = 'Parameter name should have a single space around it'
#             Extent   = $Ast.Extent
#             RuleName = $myinvocation.MyCommand.Name
#             Severity = 'Information'
#         }
#     }
# }
# function Test-PSSpaceAroundParameterAndOperator {
#     [CmdletBinding()]
#     [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
#     param (
#         [System.Management.Automation.Language.CommandAst]$Ast
#     )
    
#     # Look for parameters in the command
#     for ($i = 0; $i -lt $Ast.CommandElements.Count - 1; $i++) {
#         $element = $Ast.CommandElements[$i]
        
#         # Check if this is a parameter (starts with -)
#         if ($element.Extent.Text -match '^-\w+') {
#             $nextElement = $Ast.CommandElements[$i + 1]
            
#             # Check if there's no space between parameter and its value
#             # by examining their positions in the original text
#             if ($element.Extent.EndOffset == $nextElement.Extent.StartOffset) {
#                 return [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
#                     Message  = 'Parameter name should have a single space before its value'
#                     Extent   = $element.Extent
#                     RuleName = $myinvocation.MyCommand.Name
#                     Severity = 'Information'
#                 }
#             }
#         }
#     }
# }
# function Test-PSSpaceAroundParameterAndOperator {
#     [CmdletBinding()]
#     [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
#     param (
#         [System.Management.Automation.Language.CommandExpressionAst]$Ast
#     )
    
#     # Get the full command text
#     $commandText = $Ast.Extent.Text
    
#     # Look for patterns where a parameter is immediately followed by a parenthesis
#     if ($commandText -match '-\w+\(') {
#         [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
#             Message  = 'Parameter should have a space before opening parenthesis'
#             Extent   = $Ast.Extent
#             RuleName = $myinvocation.MyCommand.Name
#             Severity = 'Warning'
#         }
#     }
# }
#         - Commas (VSCode)
#         - Semicolons (VSCode)
#         - Curly braces (VSCode)
#         - Exception for switch parameters and Unary operators #TODO: after parameter and operator rule
#     - Single space inside:
#         - subexpressions ($())
function Test-PSSpaceAroundSubexpression {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.SubExpressionAst]$Ast
    )
    # Get the raw text of the subexpression
    $rawText = $Ast.Extent.Text

    # Look for patterns where a parameter is immediately followed by a parenthesis
    if ($rawText -notmatch '^\$\(\s.*\s\)$') {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'SubExpressions should be surrounded by a single space'
            Extent   = $Ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}

#         - scriptblocks ({}) (vscode)
#     - Avoid semi-colons as line terminators (vscode)
#endregion Space around parameters and operators
#endregion Code Layout and Formatting
#region Functions
# - Function structure
# - Functions
#     - Avoid ending with return statement
function Test-PSFunctionEndsWithReturn {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.NamedBlockAst]$Ast
    )
    
    # Get the last statement in the function
    $lastStatement = $Ast.Statements[-1]
    
    # Check if the last statement is a return statement
    if ($lastStatement -is [System.Management.Automation.Language.ReturnStatementAst]) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Block should not end with a return statement'
            Extent   = $lastStatement.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}
# - Advanced Functions
#   - Verb-Noun naming convention
function Test-PSAdvancedFunctionNaming {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.FunctionDefinitionAst]$Ast
    )
    # Predicate
    $containsCmdletBinding = $false

    # Check if the function has a CmdletBinding attribute
    if ($null -ne $Ast.Body.ParamBlock) {
        foreach ($attribute in $Ast.Body.ParamBlock.Attributes) {
            if ($attribute.TypeName.Name -eq 'CmdletBinding') {
                $containsCmdletBinding = $true
                break
            }
        }
    }

    # Only check functions that have CmdletBinding
    if ($containsCmdletBinding) {
        # Check if the function name DOESN'T match the Verb-Noun pattern
        $isInvalidName = $ast.Name -notmatch '^(\w+)-(\w+)$'

        # If the name doesn't follow the convention, report a violation
        if ($isInvalidName) {
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                Message  = 'Function should adhere to the Verb-Noun naming convention'
                Extent   = $ast.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Information'
            }
        }
    }
}
#   - Noun can be more than one word in Pascal Case - ? Dunno how to test this
#   - Return objects in Process, not in Begin or End
function Test-PSReturnInProcessBlock {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.FunctionDefinitionAst]$Ast
    )
    
    # Check if this is an advanced function (has CmdletBinding)
    $hasCmdletBinding = $false
    if ($null -ne $Ast.Body.ParamBlock) {
        foreach ($attribute in $Ast.Body.ParamBlock.Attributes) {
            if ($attribute.TypeName.Name -eq 'CmdletBinding') {
                $hasCmdletBinding = $true
                break
            }
        }
    }
    
    # Only proceed if this is an advanced function
    if (-not $hasCmdletBinding) {
        return
    }
    
    # Find all named blocks in the function
    $namedBlocks = $Ast.Body.FindAll({ param($node) 
            $node -is [System.Management.Automation.Language.NamedBlockAst] 
        }, $true)
    
    # Group blocks by their type
    $beginBlock = $namedBlocks | Where-Object { $_.BlockKind -eq 'Begin' }
    $endBlock = $namedBlocks | Where-Object { $_.BlockKind -eq 'End' }
    $processBlock = $namedBlocks | Where-Object { $_.BlockKind -eq 'Process' }
    
    # Check if we have both process and either begin or end blocks
    if ($processBlock -and ($beginBlock -or $endBlock)) {
        # Check for returns in begin blocks
        foreach ($block in $beginBlock) {
            $returnStatements = $block.FindAll({ param($node) 
                    $node -is [System.Management.Automation.Language.ReturnStatementAst] -or
                ($node -is [System.Management.Automation.Language.PipelineAst] -and 
                    $node.PipelineElements.Count -eq 1 -and
                    $node.Parent -isnot [System.Management.Automation.Language.AssignmentStatementAst])
                }, $true)

            if ($returnStatements) {
                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message  = 'Objects should be returned in the Process block, not in Begin'
                    Extent   = $returnStatements[0].Extent
                    RuleName = $myinvocation.MyCommand.Name
                    Severity = 'Warning'
                }
            }
        }

        # Check for returns in end blocks
        foreach ($block in $endBlock) {
            $returnStatements = $block.FindAll({ param($node) 
                    $node -is [System.Management.Automation.Language.ReturnStatementAst] -or
                ($node -is [System.Management.Automation.Language.PipelineAst] -and 
                    $node.PipelineElements.Count -eq 1 -and
                    $node.Parent -isnot [System.Management.Automation.Language.AssignmentStatementAst])
                }, $true)

            if ($returnStatements) {
                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message  = 'Objects should be returned in the Process block, not in End'
                    Extent   = $returnStatements[0].Extent
                    RuleName = $myinvocation.MyCommand.Name
                    Severity = 'Warning'
                }
            }
        }
    }
}
#   - Always have a CmdletBinding attribute - Fixed by other rule
#   - When process is present, use ValueFromPipeline and ValueFromPipelineByPropertyName
#   - Specify an output type, if functions returns objects - Fixed by builtin rule PSUseOutputTypeCorrectly
#       - When more than one type is returned, create one per parameter set - How to decide this?
#   - When a ParameterSetName is used in any of the parameters, always provide a DefaultParameterSetName in the CmdletBinding attribute.

#   - When using advanced functions or scripts with CmdletBinding attribute avoid validating parameters in the body of the script when possible and use parameter validation attributes instead.
function Test-PSDefaultParameterSetName {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.FunctionDefinitionAst]$Ast
    )
    
    # Skip if not an advanced function (needs CmdletBinding)
    $cmdletBindingAttribute = $null
    $hasParameterSets = $false
    
    # Check if the function has a param block
    if ($null -eq $Ast.Body.ParamBlock) {
        return
    }
    
    # Check if this function has CmdletBinding
    foreach ($attribute in $Ast.Body.ParamBlock.Attributes) {
        if ($attribute.TypeName.Name -eq 'CmdletBinding') {
            $cmdletBindingAttribute = $attribute
            break
        }
    }
    
    # Skip if not an advanced function
    if ($null -eq $cmdletBindingAttribute) {
        return
    }
    
    # Check if any parameter has a ParameterSetName attribute
    foreach ($parameter in $Ast.Body.ParamBlock.Parameters) {
        foreach ($attribute in $parameter.Attributes) {
            if ($attribute.TypeName.Name -eq 'Parameter') {
                foreach ($namedArg in $attribute.NamedArguments) {
                    if ($namedArg.ArgumentName -eq 'ParameterSetName') {
                        $hasParameterSets = $true
                        break
                    }
                }
                
                if ($hasParameterSets) {
                    break
                }
            }
        }
        
        if ($hasParameterSets) {
            break
        }
    }
    
    # If we have parameter sets, check for DefaultParameterSetName in CmdletBinding
    if ($hasParameterSets) {
        $hasDefaultParameterSetName = $false
        
        if ($null -ne $cmdletBindingAttribute.NamedArguments) {
            foreach ($arg in $cmdletBindingAttribute.NamedArguments) {
                if ($arg.ArgumentName -eq 'DefaultParameterSetName') {
                    $hasDefaultParameterSetName = $true
                    break
                }
            }
        }
        
        if (-not $hasDefaultParameterSetName) {
            return [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                Message  = 'When using ParameterSetName in any parameter, provide a DefaultParameterSetName in the CmdletBinding attribute'
                Extent   = $cmdletBindingAttribute.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }
    }
}
# - When using advanced functions or scripts with CmdletBinding attribute avoid validating parameters in the body of the script when possible and use parameter validation attributes instead. - How to test this?
#endregion Functions
#region Documentation
# - Write comment-based help for all functions and scripts
function Test-PSCommentBasedHelp {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [System.Management.Automation.Language.FunctionDefinitionAst]$Ast
    )
    
    # Skip if there's no file content to check
    if ($null -eq $Ast.Extent.File) {
        return
    }
    
    # Read the file content
    $fileContent = Get-Content -Path $Ast.Extent.File -Raw
    $lines = $fileContent -split "`n"
    
    # Get the line numbers for this function
    $startLine = $Ast.Extent.StartLineNumber - 1  # 0-based index
    $endLine = $Ast.Extent.EndLineNumber - 1      # 0-based index
    
    $hasHelp = $false
    
    # Check if we have comment-based help
    for ($i = $startLine - 1; $i -ge 0; $i--) {
        if ($lines[$i] -match '^\s*<#') {
            $hasHelp = $true
            break
        }
    }
    
    # If we don't have comment-based help, report a violation
    if (-not $hasHelp) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Function is missing comment-based help'
            Extent   = $Ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Information'
        }
    }
}
# - Inline comments should be spaced two spaces after the code
# - Document each parameter, short descriptions should reside in the param block
# - Provide at least a Synopsis, Description, and Example in the comment-based help

# Export the rule
Export-ModuleMember -Function *