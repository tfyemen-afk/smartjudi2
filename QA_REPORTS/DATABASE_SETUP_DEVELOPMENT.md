# إعداد قاعدة البيانات للتطوير
## Database Setup for Development

**التاريخ**: 2025-01-04

---

## المشكلة الحالية

```
psycopg2.OperationalError: connection to server at "localhost" (::1), port 5432 failed: 
FATAL: password authentication failed for user "postgres"
```

---

## الحلول المتاحة

### ✅ الحل 1: استخدام SQLite للتطوير (موصى به للتطوير المحلي)

**المميزات**:
- ✅ لا يحتاج إعداد
- ✅ يعمل مباشرة
- ✅ سريع وخفيف
- ✅ مناسب للتطوير

**التطبيق**: 
الكود موجود بالفعل في `settings/base.py` - لكن فقط للاختبارات. يمكنك إضافة SQLite للتطوير أيضاً.

---

### ✅ الحل 2: إعداد PostgreSQL (للإنتاج)

**الخطوات**:

1. **تثبيت PostgreSQL** (إذا لم يكن مثبتاً)
2. **إنشاء قاعدة بيانات**:
```sql
CREATE DATABASE smartju_db;
CREATE USER smartju_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE smartju_db TO smartju_user;
```

3. **تحديث Environment Variables**:
```powershell
$env:DB_NAME="smartju_db"
$env:DB_USER="smartju_user"
$env:DB_PASSWORD="your_password"
$env:DB_HOST="localhost"
$env:DB_PORT="5432"
```

4. **أو تحديث settings/base.py مباشرة**:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'smartju_db',
        'USER': 'smartju_user',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

---

## التوصية

- **للتطوير المحلي**: ✅ استخدم SQLite (أسهل وأسرع)
- **للاختبارات**: ✅ SQLite (تم تطبيقه بالفعل)
- **للإنتاج/Staging**: ✅ PostgreSQL (موجود في settings.staging.py)

---

## حالة المشروع الحالية

1. ✅ **Serializers**: تم الإصلاح - `python manage.py check` يعمل
2. ✅ **الاختبارات**: تستخدم SQLite تلقائياً
3. ⚠️ **Migration/Runserver**: تحتاج إعداد قاعدة البيانات

---

**الخطوة التالية**: اختر الحل المناسب وطبقه!

