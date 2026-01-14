from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import UserSession, SearchLog, AIChatLog
from .serializers import UserSessionSerializer, SearchLogSerializer, AIChatLogSerializer


class UserSessionViewSet(viewsets.ModelViewSet):
    queryset = UserSession.objects.select_related('user').all()
    serializer_class = UserSessionSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['user', 'is_active', 'device_type', 'governorate']
    search_fields = ['ip_address', 'country', 'city']
    ordering_fields = ['login_time', 'created_at']
    ordering = ['-login_time']


class SearchLogViewSet(viewsets.ModelViewSet):
    queryset = SearchLog.objects.select_related('user').all()
    serializer_class = SearchLogSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['user']
    search_fields = ['search_query']
    ordering_fields = ['search_date']
    ordering = ['-search_date']


class AIChatLogViewSet(viewsets.ModelViewSet):
    queryset = AIChatLog.objects.select_related('user').all()
    serializer_class = AIChatLogSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['user', 'model_version']
    search_fields = ['question', 'answer']
    ordering_fields = ['created_at']
    ordering = ['-created_at']

