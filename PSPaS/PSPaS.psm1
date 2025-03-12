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

Voorbeeldje:
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
        [System.Management.Automation.Language.ContinueStatementAst]$ast
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
        [System.Management.Automation.Language.FunctionDefinitionAst]$ast
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
    $insideValidConstruct = $ast.TypeName -cnotmatch '^[A-Z][a-z]*$'
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
        [System.Management.Automation.Language.AttributeAst]$ast
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
        [System.Management.Automation.Language.VariableExpressionAst]$ast
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
        [System.Management.Automation.Language.CommandAst]$ast
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
        [System.Management.Automation.Language.ParameterAst]$ast
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
#endregion Code Layout and Formatting

# Export the rule
Export-ModuleMember -Function *