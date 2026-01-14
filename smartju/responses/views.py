from rest_framework import viewsets, filters
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from .models import Response
from .serializers import ResponseSerializer
from accounts.permissions import IsJudgeOrLawyerOrAdmin


class ResponseViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Response
    """
    queryset = Response.objects.select_related('lawsuit', 'submitted_by_user').all()
    serializer_class = ResponseSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['response_type', 'lawsuit', 'submitted_by_user']
    search_fields = ['response_text', 'submitted_by']
    ordering_fields = ['created_at', 'submission_date']
    ordering = ['-submission_date', '-created_at']
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsJudgeOrLawyerOrAdmin()]
        return [IsAuthenticated()]
    
    def perform_create(self, serializer):
        serializer.save(submitted_by_user=self.request.user)
