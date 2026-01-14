from rest_framework import serializers
from .models import Hearing
from lawsuits.serializers import LawsuitSerializer
from accounts.serializers import UserSerializer
from smartju.common_fields import LawsuitPrimaryKeyField


class HearingSerializer(serializers.ModelSerializer):
    """
    Serializer for Hearing model
    """
    lawsuit = LawsuitSerializer(read_only=True)
    lawsuit_id = LawsuitPrimaryKeyField(
        source='lawsuit', 
        write_only=True,
        required=False,
        allow_null=True
    )
    judge = UserSerializer(read_only=True)
    hearing_type_display = serializers.CharField(source='get_hearing_type_display', read_only=True)
    
    class Meta:
        model = Hearing
        fields = (
            'id', 'lawsuit', 'lawsuit_id', 'hearing_date', 'hijri_date', 'hearing_time',
            'notes', 'judge_name', 'judge', 'hearing_type', 'hearing_type_display',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'created_at', 'updated_at')
