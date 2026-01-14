from rest_framework import viewsets, filters
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from .models import Hearing
from .serializers import HearingSerializer
from accounts.permissions import IsJudgeOrAdmin


class HearingViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Hearing
    """
    queryset = Hearing.objects.select_related('lawsuit', 'judge', 'created_by').all()
    serializer_class = HearingSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['hearing_type', 'lawsuit', 'judge']
    search_fields = ['notes', 'judge_name']
    ordering_fields = ['created_at', 'hearing_date']
    ordering = ['-hearing_date', '-hearing_time']
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsJudgeOrAdmin()]
        return [IsAuthenticated()]
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
