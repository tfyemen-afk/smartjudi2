from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django_filters import rest_framework as django_filters
from django.db.models import Q, Count
from django.utils import timezone
from .models import Lawsuit, LegalTemplate, FinancialClaim
from .serializers import (
    LawsuitSerializer, LawsuitCreateSerializer, LawsuitUpdateSerializer,
    LegalTemplateSerializer, FinancialClaimSerializer
)
from accounts.permissions import IsJudgeOrLawyerOrAdmin


class LawsuitFilter(django_filters.FilterSet):
    """
    Advanced filter for Lawsuit - فلترة متقدمة للدعاوى
    """
    # Date range filters
    filing_date_from = django_filters.DateFilter(
        field_name='filing_date', lookup_expr='gte',
        label='تاريخ الرفع من'
    )
    filing_date_to = django_filters.DateFilter(
        field_name='filing_date', lookup_expr='lte',
        label='تاريخ الرفع إلى'
    )
    created_from = django_filters.DateFilter(
        field_name='created_at', lookup_expr='gte',
        label='تاريخ الإنشاء من'
    )
    created_to = django_filters.DateFilter(
        field_name='created_at', lookup_expr='lte',
        label='تاريخ الإنشاء إلى'
    )
    
    # Text search in parties (via related models)
    party_name = django_filters.CharFilter(
        method='filter_by_party_name',
        label='اسم طرف التقاضي'
    )
    
    # Archive status
    archive_status = django_filters.ChoiceFilter(
        choices=Lawsuit.ARCHIVE_STATUS_CHOICES,
        label='حالة الأرشفة'
    )
    
    # درجة المحكمة
    court_level = django_filters.ChoiceFilter(
        choices=Lawsuit.COURT_LEVEL_CHOICES,
        label='درجة المحكمة'
    )

    # فلتر المحامي
    lawyer = django_filters.NumberFilter(
        field_name='lawyer__id',
        label='معرّف المحامي'
    )

    # Exclude soft-deleted by default
    include_deleted = django_filters.BooleanFilter(
        method='filter_include_deleted',
        label='تضمين المحذوفة'
    )

    class Meta:
        model = Lawsuit
        fields = [
            'case_type', 'case_status', 'status', 'court',
            'governorate', 'archive_status', 'court_fk',
            'court_level', 'lawyer',
        ]
    
    def filter_by_party_name(self, queryset, name, value):
        """Search in plaintiff and defendant names"""
        return queryset.filter(
            Q(plaintiffs__name__icontains=value) |
            Q(defendants__name__icontains=value)
        ).distinct()
    
    def filter_include_deleted(self, queryset, name, value):
        """Include soft-deleted items"""
        if value:
            return queryset
        return queryset.filter(is_deleted=False)


class LegalTemplateViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for LegalTemplate (read-only)
    """
    queryset = LegalTemplate.objects.all()
    serializer_class = LegalTemplateSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['case_type', 'section_key', 'is_required']
    search_fields = ['section_title', 'default_text']
    
    @action(detail=False, methods=['get'])
    def by_case_type(self, request):
        """
        Get all templates for a specific case type
        GET /api/legal-templates/by_case_type/?case_type=دعوى
        """
        case_type = request.query_params.get('case_type')
        if not case_type:
            return Response(
                {'error': 'case_type parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        templates = self.queryset.filter(case_type=case_type)
        serializer = self.get_serializer(templates, many=True)
        
        # Group by section_key for easier access
        grouped = {}
        for template in serializer.data:
            key = template['section_key']
            if key not in grouped:
                grouped[key] = {
                    'section_key': key,
                    'section_title': template['section_title'],
                    'default_text': template['default_text'],
                    'is_required': template['is_required'],
                }
        
        return Response({
            'case_type': case_type,
            'templates': list(grouped.values())
        })


class FinancialClaimViewSet(viewsets.ModelViewSet):
    """
    ViewSet for FinancialClaim
    """
    queryset = FinancialClaim.objects.select_related('lawsuit').all()
    serializer_class = FinancialClaimSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['lawsuit', 'currency']
    search_fields = ['description']
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsJudgeOrLawyerOrAdmin()]
        return [IsAuthenticated()]


class LawsuitViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Lawsuit - with advanced archive features + AI analysis + timeline
    """
    queryset = Lawsuit.objects.select_related(
        'created_by', 'court_fk', 'archived_by', 'parent_lawsuit', 'lawyer'
    ).prefetch_related('financial_claims').all()
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = LawsuitFilter
    search_fields = [
        'case_number', 'subject', 'court', 'governorate',
        'description', 'facts', 'legal_basis', 'notes',
        'department',
        # Search through related parties
        'plaintiffs__name', 'defendants__name',
    ]
    ordering_fields = [
        'created_at', 'filing_date', 'case_number',
        'updated_at', 'archive_date', 'case_status',
    ]
    ordering = ['-created_at']
    
    def get_serializer_class(self):
        if self.action == 'create':
            return LawsuitCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return LawsuitUpdateSerializer
        return LawsuitSerializer
    
    def get_permissions(self):
        if self.action in ['update', 'partial_update', 'destroy']:
            return [IsJudgeOrLawyerOrAdmin()]
        return [IsAuthenticated()]
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
    
    def perform_update(self, serializer):
        instance = serializer.instance
        user = self.request.user
        if hasattr(user, 'profile'):
            user_role = user.profile.role
            if user_role == 'citizen' and instance.created_by != user and instance.citizen != user:
                from rest_framework.exceptions import PermissionDenied
                raise PermissionDenied("You can only update your own lawsuits")
        serializer.save()
    
    def perform_destroy(self, instance):
        """Soft delete instead of hard delete"""
        user = self.request.user
        if hasattr(user, 'profile'):
            user_role = user.profile.role
            if user_role == 'citizen' and instance.created_by != user and instance.citizen != user:
                from rest_framework.exceptions import PermissionDenied
                raise PermissionDenied("You can only delete your own lawsuits")
        # Soft delete
        instance.is_deleted = True
        instance.deleted_at = timezone.now()
        instance.save(update_fields=['is_deleted', 'deleted_at'])
    
    def get_queryset(self):
        queryset = super().get_queryset()
        # Filter out soft-deleted by default
        if not self.request.query_params.get('include_deleted'):
            queryset = queryset.filter(is_deleted=False)
        # Filter based on role
        if hasattr(self.request.user, 'profile'):
            user_role = self.request.user.profile.role
            from django.db.models import Q
            if user_role == 'citizen':
                queryset = queryset.filter(Q(created_by=self.request.user) | Q(citizen=self.request.user))
            elif user_role == 'lawyer':
                queryset = queryset.filter(lawyer=self.request.user)
        return queryset
    
    # ========== Archive Actions ==========
    
    @action(detail=True, methods=['post'])
    def archive(self, request, pk=None):
        """
        Archive a lawsuit - أرشفة دعوى
        POST /api/lawsuits/{id}/archive/
        """
        lawsuit = self.get_object()
        reason = request.data.get('reason', '')
        
        lawsuit.archive_status = Lawsuit.ARCHIVE_ARCHIVED
        lawsuit.archive_date = timezone.now()
        lawsuit.archive_reason = reason
        lawsuit.archived_by = request.user
        lawsuit.save(update_fields=[
            'archive_status', 'archive_date', 'archive_reason', 'archived_by'
        ])
        
        serializer = self.get_serializer(lawsuit)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def unarchive(self, request, pk=None):
        """
        Restore a lawsuit from archive - استعادة دعوى من الأرشيف
        POST /api/lawsuits/{id}/unarchive/
        """
        lawsuit = self.get_object()
        lawsuit.archive_status = Lawsuit.ARCHIVE_ACTIVE
        lawsuit.archive_date = None
        lawsuit.archive_reason = None
        lawsuit.archived_by = None
        lawsuit.save(update_fields=[
            'archive_status', 'archive_date', 'archive_reason', 'archived_by'
        ])
        
        serializer = self.get_serializer(lawsuit)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def restore(self, request, pk=None):
        """
        Restore a soft-deleted lawsuit - استعادة دعوى محذوفة
        POST /api/lawsuits/{id}/restore/
        """
        try:
            lawsuit = Lawsuit.objects.get(pk=pk, is_deleted=True)
        except Lawsuit.DoesNotExist:
            return Response(
                {'error': 'الدعوى غير موجودة أو غير محذوفة'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        lawsuit.is_deleted = False
        lawsuit.deleted_at = None
        lawsuit.save(update_fields=['is_deleted', 'deleted_at'])
        
        serializer = self.get_serializer(lawsuit)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """
        Get archive statistics - إحصائيات الأرشيف
        GET /api/lawsuits/stats/
        """
        qs = self.get_queryset()
        
        # Count by archive status
        archive_counts = {}
        for choice_value, choice_label in Lawsuit.ARCHIVE_STATUS_CHOICES:
            archive_counts[choice_value] = qs.filter(archive_status=choice_value).count()
        
        # Count by case status
        status_counts = {}
        for choice_value, choice_label in Lawsuit.STATUS_CHOICES:
            status_counts[choice_value] = qs.filter(case_status=choice_value).count()
        
        # Count by case type
        type_counts = {}
        for choice_value, choice_label in Lawsuit.CASE_TYPE_CHOICES:
            count = qs.filter(case_type=choice_value).count()
            if count > 0:
                type_counts[choice_value] = {
                    'count': count,
                    'label': choice_label,
                }
        
        return Response({
            'total': qs.count(),
            'deleted': Lawsuit.objects.filter(is_deleted=True).count() if hasattr(request.user, 'profile') and request.user.profile.role in ['admin', 'judge'] else 0,
            'by_archive_status': archive_counts,
            'by_case_status': status_counts,
            'by_case_type': type_counts,
        })
    
    @action(detail=False, methods=['get'])
    def get_templates(self, request):
        """
        Get legal templates for a case type
        GET /api/lawsuits/get_templates/?case_type=دعوى
        """
        case_type = request.query_params.get('case_type')
        if not case_type:
            return Response(
                {'error': 'case_type parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        templates = LegalTemplate.objects.filter(case_type=case_type)
        serializer = LegalTemplateSerializer(templates, many=True)

        grouped = {}
        for template in serializer.data:
            key = template['section_key']
            if key not in grouped:
                grouped[key] = {
                    'section_key': key,
                    'section_title': template['section_title'],
                    'default_text': template['default_text'],
                    'is_required': template['is_required'],
                }

        return Response({
            'case_type': case_type,
            'templates': list(grouped.values())
        })

    # ========== Case Timeline (Step 8) ==========

    @action(detail=True, methods=['get'])
    def timeline(self, request, pk=None):
        """
        Get unified chronological timeline for a case.
        Aggregates: filing, hearings, attachments, judgments, appeals, payments.

        GET /api/lawsuits/{id}/timeline/
        """
        lawsuit = self.get_object()
        events = []

        # 1. رفع الدعوى
        if lawsuit.filing_date:
            events.append({
                'event_id': f'filing_{lawsuit.id}',
                'event_type': 'filing',
                'event_date': str(lawsuit.filing_date),
                'hijri_date': lawsuit.hijri_date,
                'title': f'رفع الدعوى رقم {lawsuit.case_number}',
                'description': lawsuit.subject,
                'related_id': lawsuit.id,
            })
        else:
            events.append({
                'event_id': f'filing_{lawsuit.id}',
                'event_type': 'filing',
                'event_date': str(lawsuit.created_at.date()),
                'title': f'إنشاء الدعوى رقم {lawsuit.case_number}',
                'description': lawsuit.subject,
                'related_id': lawsuit.id,
            })

        # 2. جلسات المحكمة
        for hearing in lawsuit.hearings.order_by('hearing_date'):
            events.append({
                'event_id': f'hearing_{hearing.id}',
                'event_type': 'hearing',
                'event_date': str(hearing.hearing_date),
                'hijri_date': hearing.hijri_date,
                'title': f'جلسة - {hearing.get_hearing_type_display()}',
                'description': hearing.notes,
                'related_id': hearing.id,
            })

        # 3. المرفقات
        for attachment in lawsuit.attachments.order_by('created_at'):
            events.append({
                'event_id': f'document_{attachment.id}',
                'event_type': 'document',
                'event_date': str(attachment.created_at.date()),
                'title': f'مستند: {getattr(attachment, "document_type_display", getattr(attachment, "document_type", "وثيقة"))}',
                'description': getattr(attachment, 'content', ''),
                'related_id': attachment.id,
                'document_url': getattr(attachment, 'file_url', None),
            })

        # 4. أحكام المحكمة
        for judgment in lawsuit.judgments.order_by('judgment_date'):
            events.append({
                'event_id': f'judgment_{judgment.id}',
                'event_type': 'judgment',
                'event_date': str(judgment.judgment_date),
                'hijri_date': judgment.hijri_date,
                'title': f'حكم {judgment.get_court_level_display()} - {judgment.get_judgment_type_display()}',
                'description': judgment.summary or judgment.judgment_text[:200],
                'related_id': judgment.id,
            })

        # 5. الطعون
        for appeal in lawsuit.appeals.order_by('appeal_date'):
            events.append({
                'event_id': f'appeal_{appeal.id}',
                'event_type': 'appeal',
                'event_date': str(appeal.appeal_date),
                'title': f'طعن / استئناف - {appeal.appeal_number}',
                'description': appeal.appeal_reasons[:200] if appeal.appeal_reasons else '',
                'related_id': appeal.id,
            })

        # 6. أوامر الأداء
        for payment in lawsuit.payment_orders.order_by('order_date'):
            events.append({
                'event_id': f'payment_{payment.id}',
                'event_type': 'payment',
                'event_date': str(payment.order_date),
                'title': f'أمر أداء - {payment.order_number or payment.id}',
                'description': payment.description,
                'related_id': payment.id,
            })

        # 7. تحليل الذكاء الاصطناعي (إن وُجد)
        if lawsuit.ai_summary:
            events.append({
                'event_id': f'ai_{lawsuit.id}',
                'event_type': 'ai_analysis',
                'event_date': str(lawsuit.updated_at.date()),
                'title': 'تحليل ذكاء اصطناعي',
                'description': lawsuit.ai_summary[:300],
                'related_id': lawsuit.id,
            })

        # ترتيب تصاعدي حسب التاريخ
        events.sort(key=lambda e: e['event_date'])

        return Response({'results': events, 'count': len(events)})

    # ========== AI Case Analysis (Step 7) ==========

    @action(detail=True, methods=['post'])
    def analyze(self, request, pk=None):
        """
        Trigger AI-powered analysis for a case via the RAG system.
        Saves results back to the lawsuit record.

        POST /api/lawsuits/{id}/analyze/

        Returns:
            ai_summary, related_laws, similar_cases,
            legal_risk_level, success_probability
        """
        lawsuit = self.get_object()

        try:
            # Build a context string for the AI from the case data
            context_parts = [
                f"رقم القضية: {lawsuit.case_number}",
                f"نوع القضية: {lawsuit.get_case_type_display()}",
                f"موضوع القضية: {lawsuit.subject or ''}",
            ]
            if lawsuit.facts:
                context_parts.append(f"وقائع القضية: {lawsuit.facts}")
            if lawsuit.legal_basis:
                context_parts.append(f"الأساس القانوني: {lawsuit.legal_basis}")
            if lawsuit.legal_reasons:
                context_parts.append(f"الأسباب القانونية: {lawsuit.legal_reasons}")
            if lawsuit.requests:
                context_parts.append(f"الطلبات: {lawsuit.requests}")

            case_context = "\n".join(context_parts)

            # Attempt to call the AI service if available
            ai_summary = None
            related_laws = []
            similar_cases = []
            legal_risk_level = 'medium'
            success_probability = 0.5

            try:
                from ai_assistant.services import get_ai_service
                ai_service = get_ai_service()
                if ai_service:
                    result = ai_service.analyze_case(case_context)
                    if result:
                        ai_summary = result.get('summary', '')
                        related_laws = result.get('related_laws', [])
                        similar_cases = result.get('similar_cases', [])
                        legal_risk_level = result.get('risk_level', 'medium')
                        success_probability = result.get('success_probability', 0.5)
            except Exception:
                # AI service not configured — return placeholder
                ai_summary = f"تحليل أولي للقضية {lawsuit.case_number}: {lawsuit.subject or 'غير محدد'}"

            # Persist AI results back to the lawsuit
            update_fields = [
                'ai_summary', 'related_laws', 'similar_cases',
                'legal_risk_level', 'success_probability',
            ]
            lawsuit.ai_summary = ai_summary
            lawsuit.related_laws = related_laws
            lawsuit.similar_cases = similar_cases
            lawsuit.legal_risk_level = legal_risk_level
            lawsuit.success_probability = success_probability
            lawsuit.save(update_fields=update_fields)

            serializer = self.get_serializer(lawsuit)
            return Response({
                'success': True,
                'ai_summary': ai_summary,
                'related_laws': related_laws,
                'similar_cases': similar_cases,
                'legal_risk_level': legal_risk_level,
                'success_probability': success_probability,
                'lawsuit': serializer.data,
            })

        except Exception as e:
            return Response(
                {'error': f'فشل التحليل الذكي: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
