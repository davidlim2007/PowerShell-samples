function prompt 
{
	$time = (Get-Date).ToShortTimeString()
 	"┌───($time [$env:COMPUTERNAME]:>)`n└──────────────────────────────▶"
}