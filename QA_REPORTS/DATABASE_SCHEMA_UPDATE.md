# تحديث قاعدة البيانات - Database Schema Update

## التاريخ: 2025-01-27

## ملخص التحديثات

تم تحديث قاعدة البيانات لتتوافق مع ملف `dbsmart.sql` المقدم. شمل التحديث إنشاء 4 تطبيقات جديدة وتحديث النماذج الموجودة.

---

## التطبيقات الجديدة (New Apps)

### 1. تطبيق المحاكم (Courts App)

**الموقع:** `smartju/courts/`

**النماذج:**
- `Governorate` - المحافظات
- `District` - الأحياء/المناطق
- `CourtType` - أنواع المحاكم (ابتدائي، استئناف، تمييز، دستوري)
- `CourtSpecialization` - تخصصات المحاكم
- `Court` - المحاكم (مع علاقات Many-to-Many مع التخصصات)

**API Endpoints:**
- `/api/governorates/` - إدارة المحافظات
- `/api/districts/` - إدارة الأحياء/المناطق
- `/api/court-types/` - إدارة أنواع المحاكم
- `/api/court-specializations/` - إدارة تخصصات المحاكم
- `/api/courts/` - إدارة المحاكم

---

### 2. تطبيق المدفوعات (Payments App)

**الموقع:** `smartju/payments/`

**النماذج:**
- `PaymentOrder` - أوامر الدفع (مرتبط بـ Lawsuit)

**API Endpoints:**
- `/api/payment-orders/` - إدارة أوامر الدفع

---

### 3. تطبيق القوانين (Laws App)

**الموقع:** `smartju/laws/`

**النماذج:**
- `LegalCategory` - فئات قانونية
- `Law` - القوانين
- `LawChapter` - فصول القوانين
- `LawSection` - أقسام القوانين
- `LawArticle` - مواد القوانين
- `CaseLegalReference` - المراجع القانونية للدعاوى

**API Endpoints:**
- `/api/legal-categories/` - إدارة الفئات القانونية
- `/api/laws/` - إدارة القوانين
- `/api/law-chapters/` - إدارة فصول القوانين
- `/api/law-sections/` - إدارة أقسام القوانين
- `/api/law-articles/` - إدارة مواد القوانين
- `/api/case-legal-references/` - إدارة المراجع القانونية

---

### 4. تطبيق السجلات (Logs App)

**الموقع:** `smartju/logs/`

**النماذج:**
- `UserSession` - جلسات المستخدمين (مرتبط بـ User)
- `SearchLog` - سجل البحث (مرتبط بـ User)
- `AIChatLog` - سجل محادثات AI (مرتبط بـ User)

**API Endpoints:**
- `/api/user-sessions/` - إدارة جلسات المستخدمين
- `/api/search-logs/` - إدارة سجلات البحث
- `/api/ai-chat-logs/` - إدارة سجلات محادثات AI

---

## التحديثات على النماذج الموجودة

### 1. تحديث نموذج Lawsuit

**الملف:** `smartju/lawsuits/models.py`

**التغييرات:**
- إضافة حقل `filing_date` (تاريخ رفع الدعوى) - DateField
- إضافة حقل `court_fk` - ForeignKey إلى `Court` (بدلاً من CharField فقط)
- إضافة حقل `description` - TextField
- إضافة حقل `legal_basis` - TextField
- الحفاظ على حقل `court` (CharField) للتوافق مع البيانات القديمة

**العلاقات:**
- `court_fk` → `Court` (ForeignKey, nullable)
- `court` → CharField (legacy, nullable)

---

### 2. تحديث UserProfile

**الملف:** `smartju/accounts/models.py`

**التغييرات:**
- إضافة property methods للوصول إلى:
  - `user_sessions` - جميع جلسات المستخدم
  - `active_sessions` - الجلسات النشطة فقط
  - `search_logs` - سجلات البحث
  - `ai_chat_logs` - سجلات محادثات AI

---

## Migrations

تم إنشاء وتطبيق migrations التالية:

1. **courts.0001_initial** - إنشاء نماذج المحاكم
2. **lawsuits.0002_remove_lawsuit_lawsuits_la_gregori_636e1b_idx_and_more** - تحديث نموذج Lawsuit
3. **laws.0001_initial** - إنشاء نماذج القوانين
4. **logs.0001_initial** - إنشاء نماذج السجلات
5. **payments.0001_initial** - إنشاء نموذج المدفوعات

---

## Serializers و ViewSets

تم إنشاء serializers و viewsets لجميع التطبيقات الجديدة:

- **Courts:** `GovernorateSerializer`, `DistrictSerializer`, `CourtTypeSerializer`, `CourtSpecializationSerializer`, `CourtSerializer`
- **Payments:** `PaymentOrderSerializer`
- **Laws:** `LegalCategorySerializer`, `LawSerializer`, `LawChapterSerializer`, `LawSectionSerializer`, `LawArticleSerializer`, `CaseLegalReferenceSerializer`
- **Logs:** `UserSessionSerializer`, `SearchLogSerializer`, `AIChatLogSerializer`

جميع ViewSets تدعم:
- Pagination (20 عنصر لكل صفحة)
- Filtering
- Search
- Ordering
- Authentication (IsAuthenticated)

---

## تحديث URLs

تم تحديث `smartju/smartju/urls.py` لإضافة جميع endpoints الجديدة.

---

## تحديث LawsuitSerializer

تم تحديث `LawsuitSerializer` ليشمل:
- `court_fk` - ForeignKey إلى Court
- `court_detail` - معلومات المحكمة الكاملة (nested)
- `filing_date` - تاريخ رفع الدعوى
- `description` - الوصف
- `legal_basis` - الأساس القانوني

---

## ملاحظات مهمة

1. **التوافق مع البيانات القديمة:**
   - تم الحفاظ على حقل `court` (CharField) للتوافق مع البيانات القديمة
   - الحقول الجديدة (`filing_date`, `description`, `legal_basis`) nullable للسماح بالبيانات الموجودة

2. **العلاقات:**
   - جميع العلاقات ForeignKey تستخدم `on_delete=models.SET_NULL` أو `CASCADE` حسب الحاجة
   - العلاقات Many-to-Many موجودة في `Court.specializations`

3. **الفهارس (Indexes):**
   - تم إضافة فهارس على الحقول المهمة لتحسين الأداء
   - فهارس على ForeignKeys و fields المستخدمة في البحث والترتيب

4. **الصلاحيات:**
   - جميع endpoints تتطلب Authentication (`IsAuthenticated`)
   - يمكن إضافة صلاحيات أكثر تفصيلاً حسب الحاجة

---

## الخطوات التالية

1. ✅ إنشاء migrations - **مكتمل**
2. ✅ تطبيق migrations - **مكتمل**
3. ✅ إنشاء serializers و viewsets - **مكتمل**
4. ✅ تحديث URLs - **مكتمل**
5. ⏳ ملء البيانات الأولية (Seed Data) - **قيد الانتظار**
6. ⏳ اختبار API endpoints - **قيد الانتظار**
7. ⏳ تحديث Flutter app لاستخدام endpoints الجديدة - **قيد الانتظار**

---

## الاختبار

```bash
# التحقق من عدم وجود أخطاء
python manage.py check

# تشغيل الخادم
python manage.py runserver 0.0.0.0:8000

# الوصول إلى Swagger Documentation
http://localhost:8000/swagger/
```

---

## المراجع

- ملف SQL الأصلي: `dbsmart.sql`
- Django Models: `smartju/*/models.py`
- Django Serializers: `smartju/*/serializers.py`
- Django Views: `smartju/*/views.py`
- URLs: `smartju/smartju/urls.py`

