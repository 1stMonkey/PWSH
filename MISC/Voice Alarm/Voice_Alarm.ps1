[cmdletbinding()]
Param ()

#Get the number of seconds until clock is 0 seconds and Start-Sleep that amount. 
function catchUp { 
  $seconds = (get-date).Second
  $seconds = 60 - $seconds 
  #Write-Host ("This many seconds to catch up to 00 seconds {0}" -f $seconds )
  Start-Sleep($seconds)
}


#Check every minute to see if clock minutes are 0. 
function everyMinute {
  $minute = (get-date).Minute

  #keep wainting until clock is 0 minutes
  while ($minute -ne 00) {
    $minute = (get-date).Minute
    #write-host $minute
    Start-Sleep(60)
  }

  #call funtion every hour on the hour. 
  everyHour
}


# Set say text to the appropiate text to anounce current hour. 
function everyHour {
  $Hour = (get-date).Hour
  switch ($Hour) {
    0 {$text = "It is 12 AM"}
    1 {$text = "It is 1 AM"}
    2 {$text = "It is 2 AM"}
    3 {$text = "It is 3 AM"}
    4 {$text = "It is 4 AM"}
    5 {$text = "It is 5 AM"}
    6 {$text = "It is 6 AM"}
    7 {$text = "It is 7 AM"}
    8 {$text = "It is 8 AM"}
    9 {$text = "It is 9 AM"}
    10 {$text = "It is 10 AM"}
    11 {$text = "It is 11 AM"}
    12 {$text = "It is 12 AM"}
    13 {$text = "It is 1 PM"}
    14 {$text = "It is 2 PM"}
    15 {$text = "It is 3 PM"}
    16 {$text = "It is 4 PM"}
    17 {$text = "It is 5 PM"}
    18 {$text = "It is 6 PM"}
    19 {$text = "It is 7 PM"}
    20 {$text = "It is 8 PM"}
    21 {$text = "It is 9 PM"}
    22 {$text = "It is 10 PM"}
    23 {$text = "It is 11 PM"}
    Default {"what time it is"}
  }

  $speak.SpeakAsync($text) | Out-Null
  start-sleep(60)
  catchUp
  everyMinute
}

#Set paramaters to utilise speech. 
Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

#Display current date and time.
Get-Date
catchUp
everyMinute
#everyHour