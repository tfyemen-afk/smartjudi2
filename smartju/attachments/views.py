from rest_framework import viewsets, filters
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from .models import Attachment
from .serializers import AttachmentSerializer
from accounts.permissions import IsJudgeOrLawyerOrAdmin


class AttachmentViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Attachment
    """
    queryset = Attachment.objects.select_related('lawsuit').all()
    serializer_class = AttachmentSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['document_type', 'lawsuit']
    search_fields = ['original_filename', 'content', 'evidence_basis']
    ordering_fields = ['created_at', 'gregorian_date']
    ordering = ['-created_at']
    
    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsJudgeOrLawyerOrAdmin()]
        return [IsAuthenticated()]
