## Import data from csv and store it in variable 'data'

$data = import-csv ./roster.csv

foreach ($i in $data)
{
 $alias = $i.Last[0] + $i.Name 

 $Company = "Company Name"
 $Department = $i.Department
 $Title = $i.Position
 $Fax = $i.Fax
 $Street ="Address"
 $City = "City"
 $State = "State"
 $zip = zip
	

 Set-User -Identity $alias -Title $Title -Company $Company -Department $Department -Street $Street -City $City -State $State -postal $zip -Fax $fax
}

