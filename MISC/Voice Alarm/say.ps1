[cmdletbinding()]
  Param (
    [parameter(Position = 0, Mandatory, HelpMessage = "What to say")]
    [ValidateNotNullOrEmpty()]
    [String]$text)

Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

$speak.SpeakAsync($text)