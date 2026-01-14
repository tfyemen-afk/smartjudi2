# إصلاح Serializers - PrimaryKeyRelatedField
## Serializers Fix - PrimaryKeyRelatedField queryset Issue

**التاريخ**: 2025-01-04  
**المشكلة**: `AssertionError: Relational field must provide a queryset argument`  
**الحل**: إزالة `queryset=None` من تعريف الحقل وتعيين queryset في `__init__`

---

## المشكلة

```
AssertionError: Relational field must provide a `queryset` argument, 
override `get_queryset`, or set read_only=`True`.
```

**السبب**: DRF يتحقق من queryset عند إنشاء `PrimaryKeyRelatedField` مباشرة، قبل أن نصل إلى `__init__`.

---

## الحل المطبق

تم إزالة `queryset=None` من جميع `PrimaryKeyRelatedField` وتعيين queryset في `__init__` method:

### قبل (خطأ):
```python
lawsuit_id = serializers.PrimaryKeyRelatedField(
    queryset=None,  # ❌ يسبب AssertionError
    source='lawsuit', 
    write_only=True,
    required=False
)
```

### بعد (صحيح):
```python
lawsuit_id = serializers.PrimaryKeyRelatedField(
    source='lawsuit', 
    write_only=True,
    required=False,
    allow_null=True
)

def __init__(self, *args, **kwargs):
    super().__init__(*args, **kwargs)
    # Set queryset for lawsuit_id field
    from lawsuits.models import Lawsuit
    self.fields['lawsuit_id'].queryset = Lawsuit.objects.all()
```

---

## الملفات المعدلة

1. ✅ `smartju/parties/serializers.py` - PlaintiffSerializer, DefendantSerializer
2. ✅ `smartju/attachments/serializers.py` - AttachmentSerializer
3. ✅ `smartju/responses/serializers.py` - ResponseSerializer
4. ✅ `smartju/appeals/serializers.py` - AppealSerializer
5. ✅ `smartju/judgments/serializers.py` - JudgmentSerializer
6. ✅ `smartju/hearings/serializers.py` - HearingSerializer

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

