function prompt 
{
    $asciiArt = @"
________              .__    .___ .____    .__         
\______ \ _____ ___  _|__| __| _/ |    |   |__| _____  
 |    |  \\__  \\  \/ /  |/ __ |  |    |   |  |/     \ 
 |    `   \/ __ \\   /|  / /_/ |  |    |___|  |  Y Y  \
/_______  (____  /\_/ |__\____ |  |_______ \__|__|_|  /
        \/     \/             \/          \/        \/
"@

	$lArrow = [char]0xe0b2
	$rArrow = [char]0xe0b0
	$smiley = "😎"
	## $count will initially be 0 because $Env:Count is a custom environment var 
	## that does not initially not exist.
	$count = [int]$Env:Count
    	$count++
	$Env:Count = [string]$count
	$time = (Get-Date).ToShortTimeString()
	if ($count -eq 1)
	{
		$prompt = "`e[48;5;0m`e[38;5;14m$lArrow`e[48;5;14m`e[38;5;0m$time $smiley [$env:COMPUTERNAME]`e[48;5;0m`e[38;5;14m$rArrow`n`e[5;36m$asciiArt`e[0m"
	}
	else
	{
		$prompt = "`e[48;5;0m`e[38;5;14m$lArrow`e[48;5;14m`e[38;5;0m$time $smiley [$env:COMPUTERNAME]`e[48;5;0m`e[38;5;14m$rArrow"
	}
	$prompt
}
