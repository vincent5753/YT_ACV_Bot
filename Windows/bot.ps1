. .\Credential.ps1

$curdir = (Get-Item .).FullName
If (Test-Path -Path $curdir\DLed.list ) {
    $workdir = $curdir
}else{
    $workdir = "${curdir}YT_ACV"
    echo "[INFO] The vids will be stored @ ${workdir}\"
    New-Item -ItemType Directory -Force -Path ${workdir}\
    echo "[INFO] The DLed list will be stored @ ${workdir}\DLed.list"
    New-Item ${workdir}\DLed.list 2>$null
    cd $workdir
}

$CurlArgument = '-s', '-X', 'POST', "https://api.telegram.org/bot${botid}:${TOKEN}/getUpdates"
$CURLEXE = 'C:\Windows\System32\curl.exe'

& $CURLEXE @CurlArgument
& $CURLEXE @CurlArgument | jq

while(1){
    echo "<Time>"
    Get-Date -Format "dddd yy-MM-dd HH:mm:ss"

    $response = & $CURLEXE @CurlArgument
    #echo "<RAW　Response>"
    #echo $response

    $count = $response | jq -c ".result | length"
    $count = $count-1
    echo "<Count with jq>"
    echo $count

    for ($num = 0 ; $num -le $count ; $num++){
        #echo "$num"
        $msg = $response | jq -c .result[$num].message.text | sed 's/\"//g'
        echo $msg

        #echo ${workdir}\DLed.list
        if (Select-String -Path ${workdir}\DLed.list -Pattern "$msg" -SimpleMatch -Quiet)
        {
            Write-Host "[INFO] Vid DLed!" -fore Green
        }else{
            Write-Host "[INFO] Vid Not DLed yet!" -fore Cyan
            # YT Vid Regex 1
            if ($msg -match 'yt:[^\"&?\/\s]{11}') {
                $ytvid = $response | jq -c .result[$num].message.text | sed 's/\"//g' | awk -F ":" '{print $2}'
                echo $ytvid

                yt-dlp -F https://www.youtube.com/watch?v=$ytvid
                bestyt https://www.youtube.com/watch?v=$ytvid
            if($LASTEXITCODE -eq 0){
                Write-Host "Everything looks find :)" -fore Green
                Add-Content DLed.list "$msg"
                #echo "$msg" >> DLed.list
            }else{
                Write-Host "Fucked, Retry AFT 10 Secs..." -fore Red
                Start-Sleep -S 10
                bestyt https://www.youtube.com/watch?v=$ytvid
                }
            }else{
                echo "MSG not matching patten of yt:vid"
            } 

            # YT Vid Regex 2
            if ($msg -match 'https:\/\/www.youtube.com\/watch\?v=[^\"&?\/\s]{11}') {
                echo "MSG matched patten of url+vid"
                $ytvid = $msg | awk -F "=" '{print $2}'
                echo $ytvid

                yt-dlp -F https://www.youtube.com/watch?v=$ytvid
                bestyt https://www.youtube.com/watch?v=$ytvid
            if($LASTEXITCODE -eq 0){
                Write-Host "Everything looks find :)" -fore Green
                Add-Content DLed.list "$msg"
            }else{
                Write-Host "Fucked, Retry AFT 10 Secs..." -fore Red
                Start-Sleep -S 10
                bestyt https://www.youtube.com/watch?v=$ytvid
                }  
            }else{
                echo "MSG not matching patten of 3wyt.com+vid"
            }

            # YT Vid Regex 3
            if ($msg -match 'https:\/\/youtu.be\/[^\"&?\/\s]{11}') {
                echo "MSG matched patten of url+vid"
                $ytvid = $msg | awk -F "/" '{print $4}'
                echo $ytvid

                yt-dlp -F https://www.youtube.com/watch?v=$ytvid
                bestyt https://www.youtube.com/watch?v=$ytvid
            if($LASTEXITCODE -eq 0){
                Write-Host "Everything looks find :)" -fore green
                Add-Content DLed.list "$msg"
            }else{
                Write-Host "Fucked, Retry AFT 10 Secs..." -fore Red
                Start-Sleep -S 10
                bestyt https://www.youtube.com/watch?v=$ytvid
                }  
            }else{
                echo "MSG not matching patten of youtu.be+vid"
            }

            # YT shorts Regex 1
            if ($msg -match 'https:\/\/youtube.com\/shorts\/[^\"&?\/\s]{11}') {
                echo "MSG matched patten of url+vid"
                $ytvid = $msg | awk -F "/" '{print $5}'
                echo $ytvid

                yt-dlp -F https://www.youtube.com/watch?v=$ytvid
                bestyt https://www.youtube.com/watch?v=$ytvid
            if($LASTEXITCODE -eq 0){
                Write-Host "Everything looks find :)" -fore green
                Add-Content DLed.list "$msg"
            }else{
                Write-Host "Fucked, Retry AFT 10 Secs..." -fore Red
                Start-Sleep -S 10
                bestyt https://www.youtube.com/watch?v=$ytvid
                }  
            }else{
                echo "MSG not matching patten of youtu.be+vid"
            }

            # YT shorts Regex 2
            if ($msg -match 'https:\/\/www.youtube.com\/shorts\/[^\"&?\/\s]{11}') {
                echo "MSG matched patten of url+vid"
                $ytvid = $msg | awk -F "/" '{print $5}'
                echo $ytvid

                yt-dlp -F https://www.youtube.com/watch?v=$ytvid
                bestyt https://www.youtube.com/watch?v=$ytvid
            if($LASTEXITCODE -eq 0){
                Write-Host "Everything looks find :)" -fore green
                Add-Content DLed.list "$msg"
            }else{
                Write-Host "Fucked, Retry AFT 10 Secs..." -fore Red
                Start-Sleep -S 10
                bestyt https://www.youtube.com/watch?v=$ytvid
                }  
            }else{
                echo "MSG not matching patten of youtu.be+vid"
            }
        }
        }
        Write-Host "[INFO] Sleeping" -fore Cyan
        Start-Sleep -S 15
    }