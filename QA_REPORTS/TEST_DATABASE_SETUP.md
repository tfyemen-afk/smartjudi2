# إعداد قاعدة البيانات للاختبارات
## Test Database Setup Guide

**التاريخ**: 2025-01-04  
**المشكلة**: فشل الاتصال بـ PostgreSQL  
**الحل**: استخدام SQLite للاختبارات أو تصحيح بيانات PostgreSQL

---

## المشكلة

```
django.db.utils.OperationalError: connection to server at "localhost" (::1), port 5432 failed: 
FATAL: password authentication failed for user "postgres"
```

---

## الحلول

### الحل 1: استخدام SQLite للاختبارات (الأسهل) ⭐

يمكن تعديل settings.py لاستخدام SQLite للاختبارات:

#### في `smartju/smartju/settings/base.py`:

أضف هذا الكود قبل تعريف `DATABASES`:

```python
import sys

# Use SQLite for tests
if 'test' in sys.argv or 'pytest' in sys.modules:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'test_db.sqlite3',
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': os.environ.get('DB_NAME', 'smartju_db'),
            'USER': os.environ.get('DB_USER', 'postgres'),
            'PASSWORD': os.environ.get('DB_PASSWORD', 'postgres'),
            'HOST': os.environ.get('DB_HOST', 'localhost'),
            'PORT': os.environ.get('DB_PORT', '5432'),
        }
    }
```

---

### الحل 2: تصحيح بيانات PostgreSQL

#### الطريقة 1: Environment Variables

```powershell
# Windows PowerShell
$env:DB_USER="your_username"
$env:DB_PASSWORD="your_password"
$env:DB_NAME="smartju_db"
$env:DB_HOST="localhost"
$env:DB_PORT="5432"

python manage.py test
```

#### الطريقة 2: تحديث settings/base.py مباشرة

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'smartju_db',
        'USER': 'your_username',  # تغيير هنا
        'PASSWORD': 'your_password',  # تغيير هنا
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

---

### الحل 3: إنشاء مستخدم PostgreSQL جديد

1. **فتح psql**:
```bash
psql -U postgres
```

2. **إنشاء مستخدم جديد**:
```sql
CREATE USER smartju_user WITH PASSWORD 'smartju_password';
CREATE DATABASE smartju_db OWNER smartju_user;
GRANT ALL PRIVILEGES ON DATABASE smartju_db TO smartju_user;
```

3. **تحديث settings.py**:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'smartju_db',
        'USER': 'smartju_user',
        'PASSWORD': 'smartju_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

---

## التوصية

### للاختبارات: ✅ **استخدم SQLite**

SQLite أسهل وأسرع للاختبارات ولا يحتاج إعداد. Django يختبر مع SQLite بشكل تلقائي.

### للإنتاج: ✅ **استخدم PostgreSQL**

PostgreSQL أفضل للإنتاج والبيئات الحقيقية.

---

## التطبيق السريع

أضف هذا الكود إلى `smartju/smartju/settings/base.py`:

```python
import sys

# Use SQLite for tests (easier and faster)
if 'test' in sys.argv or 'pytest' in sys.modules:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'test_db.sqlite3',
        }
    }
else:
    # PostgreSQL for development/production
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': os.environ.get('DB_NAME', 'smartju_db'),
            'USER': os.environ.get('DB_USER', 'postgres'),
            'PASSWORD': os.environ.get('DB_PASSWORD', 'postgres'),
            'HOST': os.environ.get('DB_HOST', 'localhost'),
            'PORT': os.environ.get('DB_PORT', '5432'),
        }
    }
```

---

## بعد التطبيق

```bash
python manage.py test --verbosity=2
```

يجب أن تعمل الاختبارات الآن! ✅

---

## ملاحظات

1. ✅ SQLite أسرع للاختبارات
2. ✅ SQLite لا يحتاج إعداد
3. ✅ Django يدعم SQLite بشكل كامل للاختبارات
4. ⚠️ بعض المميزات المتقدمة في PostgreSQL قد لا تعمل مع SQLite (لكن نادر في الاختبارات)

---

**الحالة**: ✅ **الحل جاهز للتطبيق**

