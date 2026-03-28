from rest_framework import viewsets, filters
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from .models import Plaintiff, Defendant
from .serializers import PlaintiffSerializer, DefendantSerializer
from accounts.permissions import IsJudgeOrLawyerOrAdmin


class PlaintiffViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Plaintiff
    """
    queryset = Plaintiff.objects.select_related('lawsuit').all()
    serializer_class = PlaintiffSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['gender', 'nationality', 'lawsuit']
    search_fields = ['name', 'phone', 'attorney_name']
    ordering_fields = ['created_at', 'name']
    ordering = ['-created_at']
    
    def get_permissions(self):
        # Allow all authenticated users to create parties for their own lawsuits
        # Only restrict update/delete to judges, lawyers, and admins
        if self.action in ['update', 'partial_update', 'destroy']:
            return [IsJudgeOrLawyerOrAdmin()]
        return [IsAuthenticated()]
    
    def perform_create(self, serializer):
        # Verify user owns the lawsuit or is judge/lawyer/admin
        lawsuit = serializer.validated_data.get('lawsuit')
        if lawsuit:
            user = self.request.user
            if hasattr(user, 'profile'):
                user_role = user.profile.role
                # Citizens can only add parties to their own lawsuits
                if user_role == 'citizen' and lawsuit.created_by != user and lawsuit.citizen != user:
                    from rest_framework.exceptions import PermissionDenied
                    raise PermissionDenied("You can only add parties to your own lawsuits")
        
        instance = serializer.save()
        
        # Phase 3 Data Consistency
        if instance.lawsuit and not instance.lawsuit.citizen and instance.id_number:
            from accounts.models import UserProfile
            # Find citizen profile with this ID
            profile = UserProfile.objects.filter(national_id=instance.id_number, role='citizen').first()
            if profile and profile.user:
                instance.lawsuit.citizen = profile.user
                instance.lawsuit.save(update_fields=['citizen'])


class DefendantViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Defendant
    """
    queryset = Defendant.objects.select_related('lawsuit').all()
    serializer_class = DefendantSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['gender', 'nationality', 'lawsuit']
    search_fields = ['name', 'phone', 'attorney_name']
    ordering_fields = ['created_at', 'name']
    ordering = ['-created_at']
    
    def get_permissions(self):
        # Allow all authenticated users to create parties for their own lawsuits
        # Only restrict update/delete to judges, lawyers, and admins
        if self.action in ['update', 'partial_update', 'destroy']:
            return [IsJudgeOrLawyerOrAdmin()]
        return [IsAuthenticated()]
    
    def perform_create(self, serializer):
        # Verify user owns the lawsuit or is judge/lawyer/admin
        lawsuit = serializer.validated_data.get('lawsuit')
        if lawsuit:
            user = self.request.user
            if hasattr(user, 'profile'):
                user_role = user.profile.role
                # Citizens can only add parties to their own lawsuits
                if user_role == 'citizen' and lawsuit.created_by != user and lawsuit.citizen != user:
                    from rest_framework.exceptions import PermissionDenied
                    raise PermissionDenied("You can only add parties to your own lawsuits")
        serializer.save()
