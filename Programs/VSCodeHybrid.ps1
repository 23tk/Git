# VSCode のプロセス一覧を取得
$procs = Get-Process Code -ErrorAction SilentlyContinue

# ウィンドウを持っている Code.exe を探す
$main = $procs | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1

if ($main) {
    # 最前面化
    $hwnd = $main.MainWindowHandle
    $sig = '[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);'
    Add-Type -MemberDefinition $sig -Name Win32SetForegroundWindow -Namespace Win32Functions
    [Win32Functions.Win32SetForegroundWindow]::SetForegroundWindow($hwnd)
    exit
}

# 起動していない場合 → VSCode を起動
#Start-Process "C:\Users\%USERNAME%\AppData\Local\Programs\Microsoft VS Code\bin\Code.exe"
Start-Process "C:\Users\fumitaka\AppData\Local\Programs\Microsoft VS Code\Code.exe"
