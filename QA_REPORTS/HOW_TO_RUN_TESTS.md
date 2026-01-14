# كيفية تشغيل الاختبارات
## How to Run Tests

**التاريخ**: 2025-01-04  
**المشروع**: SmartJudi Platform

---

## متطلبات التشغيل

1. ✅ Python 3.8+ مثبت
2. ✅ Virtual environment مفعل
3. ✅ جميع dependencies مثبتة (`pip install -r requirements.txt`)
4. ✅ قاعدة بيانات PostgreSQL جاهزة
5. ✅ Migrations منفذة (`python manage.py migrate`)

---

## تشغيل جميع الاختبارات

```bash
# الانتقال إلى مجلد المشروع
cd smartju

# تشغيل جميع الاختبارات
python manage.py test

# مع تفاصيل أكثر
python manage.py test --verbosity=2

# مع تفاصيل أقل
python manage.py test --verbosity=0
```

---

## تشغيل اختبارات محددة

### Unit Tests:

```bash
# اختبارات accounts
python manage.py test accounts.tests

# اختبارات lawsuits
python manage.py test lawsuits.tests

# اختبارات parties
python manage.py test parties.tests

# اختبارات attachments
python manage.py test attachments.tests

# اختبارات responses
python manage.py test responses.tests

# اختبارات appeals
python manage.py test appeals.tests

# اختبارات hearings
python manage.py test hearings.tests

# اختبارات judgments
python manage.py test judgments.tests

# اختبارات audit
python manage.py test audit.tests
```

### API Tests:

```bash
# اختبارات API - accounts
python manage.py test accounts.test_api

# اختبارات API - lawsuits
python manage.py test lawsuits.test_api

# اختبارات API - parties
python manage.py test parties.test_api

# اختبارات API - integration
python manage.py test test_api_integration

# اختبارات API - validation
python manage.py test test_api_validation

# اختبارات API - pagination
python manage.py test test_api_pagination
```

### Security Tests:

```bash
# اختبارات JWT Security
python manage.py test test_security_jwt

# اختبارات Permissions
python manage.py test test_security_permissions

# اختبارات File Upload Security
python manage.py test test_security_file_upload

# اختبارات Injection Security
python manage.py test test_security_injection

# اختبارات Data Isolation
python manage.py test test_security_data_isolation
```

### Performance Tests:

```bash
# اختبارات Performance & Load
python manage.py test test_performance_load

# اختبارات Optimization
python manage.py test test_performance_optimization_suggestions
```

---

## تشغيل اختبار محدد

```bash
# تشغيل test method محدد
python manage.py test accounts.tests.UserProfileTests.test_user_profile_creation

# تشغيل test class محدد
python manage.py test accounts.tests.UserProfileTests
```

---

## خيارات إضافية

### Keep Test Database:
```bash
python manage.py test --keepdb
```

### Parallel Execution:
```bash
python manage.py test --parallel
```

### Specific Settings:
```bash
python manage.py test --settings=smartju.settings.staging
```

### Debug Mode:
```bash
python manage.py test --debug-mode
```

---

## استخدام pytest (اختياري)

إذا كنت تستخدم pytest:

```bash
# تثبيت pytest-django
pip install pytest-django

# تشغيل جميع الاختبارات
pytest

# تشغيل مع coverage
pytest --cov=smartju --cov-report=html
```

---

## النتائج المتوقعة

### عند نجاح جميع الاختبارات:
```
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
...................
----------------------------------------------------------------------
Ran 50 tests in 2.345s

OK
Destroying test database for alias 'default'...
```

### عند وجود أخطاء:
```
FAILED (failures=2, errors=1)
```

---

## استكشاف الأخطاء

### مشكلة: Database connection error
**الحل**: تأكد من أن PostgreSQL يعمل وأن بيانات الاتصال صحيحة

### مشكلة: Module not found
**الحل**: تأكد من تفعيل virtual environment وتثبيت جميع dependencies

### مشكلة: Migration errors
**الحل**: قم بتشغيل `python manage.py migrate` أولاً

---

## ملاحظات

1. ✅ الاختبارات تستخدم test database منفصلة
2. ✅ Test database يتم حذفها تلقائياً بعد الاختبارات
3. ✅ يمكن استخدام `--keepdb` للاحتفاظ بقاعدة البيانات
4. ⚠️ Performance tests قد تحتاج وقت أطول

---

## Checklist قبل التشغيل

- [ ] Virtual environment مفعل
- [ ] Dependencies مثبتة
- [ ] PostgreSQL يعمل
- [ ] Migrations منفذة
- [ ] Database credentials صحيحة

---

**ملاحظة**: إذا كان Python غير موجود في PATH، استخدم `py` بدلاً من `python`:
```bash
py manage.py test
```

