from rest_framework import viewsets, filters
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from .models import Appeal
from .serializers import AppealSerializer
from accounts.permissions import IsJudgeOrLawyerOrAdmin


class AppealViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Appeal
    """
    queryset = Appeal.objects.select_related('lawsuit', 'submitted_by_user').all()
    serializer_class = AppealSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['appeal_type', 'status', 'lawsuit']
    search_fields = ['appeal_number', 'appeal_reasons', 'appeal_requests', 'higher_court']
    ordering_fields = ['created_at', 'appeal_date']
    ordering = ['-appeal_date', '-created_at']
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsJudgeOrLawyerOrAdmin()]
        return [IsAuthenticated()]
    
    def perform_create(self, serializer):
        serializer.save(submitted_by_user=self.request.user)
