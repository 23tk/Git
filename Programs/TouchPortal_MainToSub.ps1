Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@

# タスクマネージャー取得
$proc = Get-Process -Name "Taskmgr" -ErrorAction SilentlyContinue
if (-not $proc) { exit }

$hwnd = $proc.MainWindowHandle
if ($hwnd -eq 0) { exit }

# 現在位置取得
[Win32+RECT]$rect = New-Object Win32+RECT
[Win32]::GetWindowRect($hwnd, [ref]$rect) | Out-Null

$width  = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top

# メイン → サブ（右側）へ移動
# 1920px 右へ移動（必要なら後で調整）
$newX = $rect.Left + 1920
$newY = $rect.Top

[Win32]::MoveWindow($hwnd, $newX, $newY, $width, $height, $true) | Out-Null
