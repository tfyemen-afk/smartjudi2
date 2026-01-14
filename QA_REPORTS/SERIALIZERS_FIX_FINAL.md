# إصلاح Serializers - الحل النهائي
## Serializers Fix - Final Solution

**التاريخ**: 2025-01-04  
**المشكلة**: `AssertionError: Relational field must provide a queryset argument`  
**الحل النهائي**: استخدام Custom Field مع `get_queryset` method

---

## المشكلة

```
AssertionError: Relational field must provide a `queryset` argument, 
override `get_queryset`, or set read_only=`True`.
```

**السبب**: DRF يتحقق من queryset عند إنشاء `PrimaryKeyRelatedField` مباشرة، قبل أن نصل إلى `__init__` في Serializer.

---

## الحل النهائي

تم إنشاء Custom Field `LawsuitPrimaryKeyField` الذي يطبق `get_queryset` method:

### ملف جديد: `smartju/smartju/common_fields.py`

```python
"""
Common serializer fields to avoid circular imports
"""
from rest_framework import serializers


class LawsuitPrimaryKeyField(serializers.PrimaryKeyRelatedField):
    """Custom field that sets queryset lazily to avoid circular imports"""
    def get_queryset(self):
        from lawsuits.models import Lawsuit
        return Lawsuit.objects.all()
```

### استخدام الحقل في Serializers:

```python
from smartju.smartju.common_fields import LawsuitPrimaryKeyField

class PlaintiffSerializer(serializers.ModelSerializer):
    lawsuit = LawsuitSerializer(read_only=True)
    lawsuit_id = LawsuitPrimaryKeyField(
        source='lawsuit', 
        write_only=True,
        required=False,
        allow_null=True
    )
    # ... باقي الكود
```

---

## الملفات المعدلة

1. ✅ `smartju/smartju/common_fields.py` - **ملف جديد**
2. ✅ `smartju/parties/serializers.py` - PlaintiffSerializer, DefendantSerializer
3. ✅ `smartju/attachments/serializers.py` - AttachmentSerializer
4. ✅ `smartju/responses/serializers.py` - ResponseSerializer
5. ✅ `smartju/appeals/serializers.py` - AppealSerializer
6. ✅ `smartju/judgments/serializers.py` - JudgmentSerializer
7. ✅ `smartju/hearings/serializers.py` - HearingSerializer

---

## كيف يعمل الحل

1. ✅ Custom Field يطبق `get_queryset()` method
2. ✅ DRF يتعرف على `get_queryset` ويمرر التحقق من queryset
3. ✅ Queryset يتم استيراده lazily عند الحاجة (للتجنب من circular imports)
4. ✅ الحل يعمل في جميع الحالات (tests, runtime, etc.)

---

## التحقق

```bash
# Check for errors
python manage.py check

# Run tests
python manage.py test --verbosity=2
```

---

**الحالة**: ✅ **تم الإصلاح - جاهز للتشغيل**

