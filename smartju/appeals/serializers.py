from rest_framework import serializers
from .models import Appeal
from lawsuits.serializers import LawsuitSerializer
from accounts.serializers import UserSerializer
from smartju.common_fields import LawsuitPrimaryKeyField


class AppealSerializer(serializers.ModelSerializer):
    """
    Serializer for Appeal model
    """
    lawsuit = LawsuitSerializer(read_only=True)
    lawsuit_id = LawsuitPrimaryKeyField(
        source='lawsuit', 
        write_only=True,
        required=False,
        allow_null=True
    )
    submitted_by_user = UserSerializer(read_only=True)
    submitted_by_display = serializers.CharField(source='get_submitted_by_display', read_only=True)
    appeal_type_display = serializers.CharField(source='get_appeal_type_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    
    class Meta:
        model = Appeal
        fields = (
            'id', 'lawsuit', 'lawsuit_id', 'appeal_type', 'appeal_type_display',
            'appeal_number', 'appeal_reasons', 'appeal_requests', 'higher_court',
            'status', 'status_display', 'appeal_date', 'hijri_date', 'submitted_by',
            'submitted_by_user', 'submitted_by_display', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'created_at', 'updated_at')
