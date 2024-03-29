
Start-Transcript -Path "C:\temp\recon.txt" -NoClobber

Get-NetIPAddress | Sort InterfaceIndex | FT InterfaceIndex, InterfaceAlias, IPAddress -Autosize
Get-Process  
    $user = whoami
    $currenthost = hostname
    $networkinfo = (Get-NetIPAddress).IPAddress
    $Publicip = (curl http://ipinfo.io/ip -UseBasicParsing).content


    Write-Output ""

    Write-Host " User: $user"
    Write-Host " Hostname: $currenthost"
    Write-Host " Public IP: " -NoNewline; Write-Host $Publicip

    Write-Output ""

    Write-Host " [*] Listando AV ... "
    Start-Sleep -Seconds 2

    try {
    
        Get-CimInstance -Namespace root/securitycenter2 -ClassName antivirusproduct | Select-Object displayName | Format-Table -HideTableHeaders
    
        } catch{
        
        write-host "Failed To Get AntiVirus" -ForegroundColor Red

                }

    Write-Output ""

    Write-Host " [*] Listando IP/s ..."
    Start-Sleep -Seconds 2
   
    Write-Output ""

    $networkinfo

    Write-Output ""

        
    $lad = @(Get-WmiObject win32_useraccount | Select name,sid)

        foreach ($l in $lad){
        
          [string]$sid = $l.sid

            if ($sid.EndsWith("500")){

            $ladstatus = (Get-WmiObject win32_useraccount | Where-Object {$_.name -like $l.name}).Disabled 

            if ($ladstatus -eq "True"){
                
                $c = "Green"
            
                } else {

                    $c = "Red"
                
                     }
            
            Write-Host " [*] Buscando Local Admin ..."
            

            Write-Host " Local Admin Encontrado: " -NoNewline ; Write-Host $l.name -ForegroundColor Green -NoNewline ; Write-Host " | Enabled: " -NoNewline ; Write-Host $ladstatus -ForegroundColor $c           
            
            
          }
      
        }

        Get-NetTCPConnection
      
        Write-Output ""

        Write-Host " [*] Listando diretorios de programas ... "
        Start-Sleep -Seconds 2

        $allprogs = @()
        $progs = @((dir "c:\program files").Name)
        $progs32 = @((dir "c:\Program Files (x86)").Name)
        $allprogs += $progs ; $allprogs += $progs32
        

        Write-Output ""

            foreach ($pn in $allprogs){
            
                if ($pn -notlike "*Windows*" -and $pn -notlike "*Microsoft*"){
                    
                    Write-Host $pn -ForegroundColor Green
                
                    } else {
                            
                            Write-Host $pn

                            }

            
                }

            

        Write-Output ""

        Write-Host " [*] Listando SMB Shares ... "
        Start-Sleep -Seconds 2

        Write-Output ""

            Get-SmbShare | Format-Table -HideTableHeaders

        Write-Output ""

        

        Write-Host " [*] Getting " -NoNewline ; Write-Host "Blocked" -ForegroundColor Red -NoNewline ; Write-Host " Firewall Rules...."

        Write-Output ""

            Get-NetFirewallRule | Where-Object Action -eq "Block" | Format-Table DisplayName,Enabled,Profile,Direction,Action,Name

        Write-Output ""
        $subnet = (Get-NetRoute -DestinationPrefix 0.0.0.0/0).NextHop
        $manyips = $subnet.Length
    
    
        if($manyips -eq 2){
        
            $subnet = (Get-NetRoute -DestinationPrefix 0.0.0.0/0).NextHop[1]
            
            
                }
       
            
        $subnetrange = $subnet.Substring(0,$subnet.IndexOf('.') + 1 + $subnet.Substring($subnet.IndexOf('.') + 1).IndexOf('.') + 3)
    
        $isdot = $subnetrange.EndsWith('.')
    
    
    
        if ($isdot -like "False"){
        
                $subnetrange = $subnetrange + '.'
                
                    }
    
        
        $iprange = @(1..254)
    
        Write-Output ""
        Write-Host " [*] Current Network: $subnet"
    
        Write-Host " [*] Scaneando: " -NoNewline ; Write-Host $subnetrange -NoNewline;  Write-Host "0/24" -ForegroundColor Red
    
        Write-Output ""
    
        
     Get-NetTCPConnection
    
    
    
        foreach ($i in $iprange){
    
    
        $currentip = $subnetrange + $i
    
        $islive = test-connection $currentip -Quiet -Count 1
    
    
            if ($islive -eq "True"){
    
                try{$dnstest = (Resolve-DnsName $currentip -ErrorAction SilentlyContinue).NameHost}catch{}
    
    
                    if ($dnstest -like "*.home") {
    
                        $dnstest = $dnstest -replace ".home",""
    
                            }
    
        Write-Output ""
    
        Write-Host " Host acessivel: " -NoNewline  ; Write-Host $currentIP -ForegroundColor Green -NoNewline ; Write-Host "  $dnstest"
    
    
        $portstoscan = @(20,22,23,25,50,51,53,80,110,119,135,136,137,138,139,143,161,162,389,443,445,636,1025,1443,3389,5985,5986,8080,10000)
        $waittime = 5
    
        foreach ($p in $portstoscan){
    
        $TCPObject = new-Object system.Net.Sockets.TcpClient
    
                try{$result = $TCPObject.ConnectAsync($currentip,$p).Wait($waittime)}catch{}
    
                if ($result -eq "True"){
        
                        Write-Host " Port Open: " -NoNewline  ; Write-Host $p -ForegroundColor Green
        
                        }
    
                }
    
                Write-Output ""
    } else {
    
                Write-Host " Failed To Scan $currentip" -ForegroundColor Red
        }
    
            }
 Stop-Transcript       
