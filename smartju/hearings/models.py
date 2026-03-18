from django.db import models
from django.contrib.auth.models import User
from lawsuits.models import Lawsuit


class Hearing(models.Model):
    """
    Hearing Model - represents court hearings/sessions
    """
    
    # ForeignKey to Lawsuit
    lawsuit = models.ForeignKey(
        Lawsuit,
        on_delete=models.CASCADE,
        related_name='hearings',
        verbose_name='الدعوى'
    )
    
    # Hearing date
    hearing_date = models.DateField(
        verbose_name='تاريخ الجلسة'
    )
    
    # Hijri date (optional)
    hijri_date = models.CharField(
        max_length=50,
        blank=True,
        null=True,
        verbose_name='التاريخ الهجري'
    )
    
    # Hearing time (optional)
    hearing_time = models.TimeField(
        blank=True,
        null=True,
        verbose_name='وقت الجلسة'
    )
    
    # Notes/remarks
    notes = models.TextField(
        verbose_name='ملاحظات الجلسة'
    )
    
    # Judge name (optional)
    judge_name = models.CharField(
        max_length=200,
        blank=True,
        null=True,
        verbose_name='اسم القاضي'
    )
    
    # ForeignKey to User (judge - optional)
    judge = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='presided_hearings',
        verbose_name='القاضي'
    )
    
    # Hearing type choices (extended to match Flutter frontend)
    HEARING_TYPE_PLEADING = 'pleading'
    HEARING_TYPE_WITNESS = 'witness'
    HEARING_TYPE_EXPERT = 'expert'
    HEARING_TYPE_INITIAL = 'initial'
    HEARING_TYPE_JUDGMENT = 'judgment'
    HEARING_TYPE_PRELIMINARY = 'preliminary'   # kept for backward compat
    HEARING_TYPE_MAIN = 'main'                 # kept for backward compat
    HEARING_TYPE_DECISION = 'decision'          # kept for backward compat
    HEARING_TYPE_ADJOURNED = 'adjourned'        # kept for backward compat
    HEARING_TYPE_OTHER = 'other'

    HEARING_TYPE_CHOICES = [
        (HEARING_TYPE_PLEADING, 'مرافعة'),
        (HEARING_TYPE_WITNESS, 'سماع شهود'),
        (HEARING_TYPE_EXPERT, 'تقرير خبير'),
        (HEARING_TYPE_INITIAL, 'جلسة أولى'),
        (HEARING_TYPE_JUDGMENT, 'جلسة حكم'),
        # Legacy types kept for backward compatibility
        (HEARING_TYPE_PRELIMINARY, 'تمهيدية'),
        (HEARING_TYPE_MAIN, 'رئيسية'),
        (HEARING_TYPE_DECISION, 'قرار'),
        (HEARING_TYPE_ADJOURNED, 'مؤجلة'),
        (HEARING_TYPE_OTHER, 'أخرى'),
    ]

    hearing_type = models.CharField(
        max_length=50,
        choices=HEARING_TYPE_CHOICES,
        default=HEARING_TYPE_PLEADING,
        verbose_name='نوع الجلسة'
    )

    # ========== Decision & Next Hearing (Step 5) ==========

    DECISION_ADJOURNED = 'adjourned'
    DECISION_JUDGMENT = 'judgment'
    DECISION_POSTPONED = 'postponed'
    DECISION_CONTINUED = 'continued'
    DECISION_OTHER = 'other'

    DECISION_CHOICES = [
        (DECISION_ADJOURNED, 'مؤجلة'),
        (DECISION_JUDGMENT, 'صدر حكم'),
        (DECISION_POSTPONED, 'مرجأة'),
        (DECISION_CONTINUED, 'تواصل'),
        (DECISION_OTHER, 'أخرى'),
    ]

    decision = models.CharField(
        max_length=20,
        choices=DECISION_CHOICES,
        default=DECISION_ADJOURNED,
        verbose_name='قرار الجلسة'
    )

    # تاريخ الجلسة القادمة (ميلادي)
    next_hearing_date = models.DateField(
        null=True,
        blank=True,
        verbose_name='تاريخ الجلسة القادمة'
    )

    # تاريخ الجلسة القادمة (هجري)
    next_hijri_date = models.CharField(
        max_length=50,
        null=True,
        blank=True,
        verbose_name='تاريخ الجلسة القادمة (هجري)'
    )

    # Created by
    created_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='created_hearings',
        verbose_name='منشئ السجل'
    )
    
    # Timestamps
    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name='تاريخ الإنشاء'
    )
    
    updated_at = models.DateTimeField(
        auto_now=True,
        verbose_name='تاريخ التحديث'
    )
    
    class Meta:
        verbose_name = 'جلسة'
        verbose_name_plural = 'جلسات'
        ordering = ['-hearing_date', '-hearing_time']
        indexes = [
            models.Index(fields=['lawsuit']),
            models.Index(fields=['hearing_date']),
            models.Index(fields=['hearing_type']),
            models.Index(fields=['decision']),
            models.Index(fields=['next_hearing_date']),
            models.Index(fields=['judge']),
        ]
    
    def __str__(self):
        return f'جلسة - {self.lawsuit.case_number} - {self.hearing_date}'
