Set-PSReadLineKeyHandler -Key F8 `
                         -BriefDescription Favourites `
                         -LongDescription 'Show Favourite Commands to Run' `
                         -ScriptBlock {

    # Create an Array List.
    $commandsList= [System.Collections.ArrayList]@()

    # Create an instance of a PSCustomObject object
    # with specific values.
    # The fact that it is a PSCustomObject is important.
    $commandsList += ([PSCustomObject]@{ 
        Description = 'Notepad';
        CommandLine = 'notepad.exe';
    })    

    # Create an instance of a PSCustomObject object
    # with specific values.
    $commandsList += ([PSCustomObject]@{ 
        Description = 'Calculator';
        CommandLine = 'calc.exe';
    })    

    # Create an instance of a PSCustomObject object
    # with specific values.
    $commandsList += ([PSCustomObject]@{ 
        Description = 'New PowerShell Tab';
        CommandLine = 'wt -w 0 new-tab';
    })    

    # Create an instance of a PSCustomObject object
    # with specific values.
    $commandsList += ([PSCustomObject]@{ 
        Description = 'Visual Studio Code';
        CommandLine = '&"C:\Program Files\Microsoft VS Code\Code.exe"'
    })

    # Create an instance of a PSCustomObject object
    # with specific values.
    $commandsList += ([PSCustomObject]@{ 
        Description = 'Read the News';
        CommandLine = 'Start-Process "https://cnn.com"'
    })

    # Create an instance of a PSCustomObject object
    # with specific values.
    #
    # Note that we have surrounded the CommandLine with double quotes (").
    # This is because the CommandLine string contains an expandable
    # string $PROFILE. The double quotes ensures that expandable strings
    # are expanded.
    # 
    # Note also that we have wrapped the word $PROFILE with single quotes (')
    # This is so that when $PROFILE is expanded, the expanded string
    # is covered by single quotes in case there are spaces in the 
    # expanded string.
    $commandsList += ([PSCustomObject]@{ 
        Description = 'Edit $PROFILE';
        CommandLine = "&'C:\Program Files\Microsoft VS Code\Code.exe' '$PROFILE'"
    })

    # Create an instance of a PSCustomObject object
    # with specific values.
    # Note that this time we surround CommandLine with single quotes (')
    # This is because we do not want $PROFILE to be expanded.
    $commandsList += ([PSCustomObject]@{ 
        Description = 'Update $PROFILE';
        CommandLine = '. $PROFILE'
    })                

    # Display the Grid-View.
    # When the User has selected a Command to Run and Pressed ENTER,
    # The selected command will be set into the $selectedCommand variable.
    # Its CommandLine member will be inserted back into the PowerShell command line.
    # This is done via the Insert() Method.
    # The AcceptLine() is used to simulate the pressing of the ENTER key.
    $selectedCommand = $commandsList | Out-GridView -Title "Favourite Commands to Run" -PassThru
    if ($selectedCommand)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($selectedCommand.CommandLine -join "`n"))
	    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}