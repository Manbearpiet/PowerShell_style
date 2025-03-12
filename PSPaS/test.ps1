    function Verb-Noun {
        [cmdletBinding()]
        param (
            # Parameter help description
            [parameter(mandatory)]
            [validateNotNullOrEmpty()]
            $ParameterName
        )
    }

