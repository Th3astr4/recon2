$pclip = ""
 $array = @()
 $counter = 0



    while($true){

$cclip = Get-Clipboard


        if ($pclip -eq $cclip){

        #Do Nothing
        
        } else {


        $array += $cclip
        $pclip = $cclip
        $cclip = Get-Clipboard


        $counter++

            

            $pclip >> C:\Temp\clp2.txt

            

        }
     
        Start-Sleep -Seconds 5
       
        }
        