from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from .models import Lawsuit, LegalTemplate, FinancialClaim
from .serializers import (
    LawsuitSerializer, LawsuitCreateSerializer, LawsuitUpdateSerializer,
    LegalTemplateSerializer, FinancialClaimSerializer
)
from accounts.permissions import IsJudgeOrLawyerOrAdmin


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
    ViewSet for Lawsuit
    """
    queryset = Lawsuit.objects.select_related('created_by', 'court_fk').prefetch_related('financial_claims').all()
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['case_type', 'case_status', 'status', 'court', 'governorate']
    search_fields = ['case_number', 'subject', 'court', 'governorate']
    ordering_fields = ['created_at', 'filing_date', 'case_number']
    ordering = ['-created_at']
    
    def get_serializer_class(self):
        if self.action == 'create':
            return LawsuitCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return LawsuitUpdateSerializer
        return LawsuitSerializer
    
    def get_permissions(self):
        # Allow all authenticated users to create lawsuits
        # Only restrict update/delete to judges, lawyers, and admins
        if self.action in ['update', 'partial_update', 'destroy']:
            return [IsJudgeOrLawyerOrAdmin()]
        return [IsAuthenticated()]
    
    def perform_create(self, serializer):
        # Set created_by to current user
        serializer.save(created_by=self.request.user)
    
    def perform_update(self, serializer):
        # Only allow users to update their own lawsuits, or judges/lawyers/admins can update any
        instance = serializer.instance
        user = self.request.user
        if hasattr(user, 'profile'):
            user_role = user.profile.role
            # Citizens can only update their own lawsuits
            if user_role == 'citizen' and instance.created_by != user:
                from rest_framework.exceptions import PermissionDenied
                raise PermissionDenied("You can only update your own lawsuits")
        serializer.save()
    
    def perform_destroy(self, instance):
        # Only allow users to delete their own lawsuits, or judges/lawyers/admins can delete any
        user = self.request.user
        if hasattr(user, 'profile'):
            user_role = user.profile.role
            # Citizens can only delete their own lawsuits
            if user_role == 'citizen' and instance.created_by != user:
                from rest_framework.exceptions import PermissionDenied
                raise PermissionDenied("You can only delete your own lawsuits")
        instance.delete()
    
    def get_queryset(self):
        queryset = super().get_queryset()
        # Citizens can only see their own lawsuits
        # Lawyers, judges, and admins can see all lawsuits
        if hasattr(self.request.user, 'profile'):
            user_role = self.request.user.profile.role
            if user_role == 'citizen':
                queryset = queryset.filter(created_by=self.request.user)
            # Lawyers, judges, and admins can see all lawsuits (no filter)
        return queryset
    
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
        
        # Group by section_key
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
