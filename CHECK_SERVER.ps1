Write-Host "=== فحص حالة خادم Django ===" -ForegroundColor Cyan

# التحقق من المنفذ 8000
Write-Host "`nفحص المنفذ 8000..." -ForegroundColor Yellow
$port8000 = netstat -an | Select-String ":8000"
if ($port8000) {
    Write-Host "✅ المنفذ 8000 مستخدم" -ForegroundColor Green
    $port8000 | ForEach-Object { Write-Host "   $_" }
    
    # التحقق من العنوان
    if ($port8000 -match "0\.0\.0\.0:8000" -or $port8000 -match "192\.168\.\d+\.\d+:8000") {
        Write-Host "✅ الخادم يعمل على جميع الواجهات - جاهز للوصول من الشبكة" -ForegroundColor Green
    } elseif ($port8000 -match "127\.0\.0\.1:8000") {
        Write-Host "⚠️  الخادم يعمل على localhost فقط - لا يمكن الوصول من الشبكة!" -ForegroundColor Red
        Write-Host "   يجب إعادة تشغيل الخادم باستخدام: python manage.py runserver 0.0.0.0:8000" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ الخادم غير مشغل على المنفذ 8000" -ForegroundColor Red
    Write-Host "   قم بتشغيل الخادم باستخدام: .\START_DJANGO.ps1" -ForegroundColor Yellow
}

# التحقق من عنوان IP الحالي
Write-Host "`nعنوان IP الحالي:" -ForegroundColor Yellow
$ipConfig = ipconfig | Select-String "IPv4"
if ($ipConfig) {
    $ipConfig | ForEach-Object {
        if ($_ -match "(\d+\.\d+\.\d+\.\d+)") {
            $ip = $matches[1]
            Write-Host "   $ip" -ForegroundColor Cyan
        }
    }
}

# التحقق من إعدادات API
Write-Host "`nإعدادات API في Flutter:" -ForegroundColor Yellow
$apiConfig = Get-Content "lib\config\api_config.dart" | Select-String "baseUrl"
if ($apiConfig) {
    Write-Host "   $apiConfig" -ForegroundColor Cyan
}

Write-Host "`n=== انتهى الفحص ===" -ForegroundColor Cyan
