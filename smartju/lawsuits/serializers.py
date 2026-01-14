from rest_framework import serializers
from .models import Lawsuit, LegalTemplate, FinancialClaim
from accounts.serializers import UserSerializer
from courts.serializers import CourtSerializer


class LegalTemplateSerializer(serializers.ModelSerializer):
    """
    Serializer for LegalTemplate model
    """
    case_type_display = serializers.CharField(source='get_case_type_display', read_only=True)
    
    class Meta:
        model = LegalTemplate
        fields = (
            'id', 'case_type', 'case_type_display', 'section_key', 
            'section_title', 'default_text', 'is_required'
        )
        read_only_fields = ('id',)


class FinancialClaimSerializer(serializers.ModelSerializer):
    """
    Serializer for FinancialClaim model
    """
    currency_display = serializers.CharField(source='get_currency_display', read_only=True)
    
    class Meta:
        model = FinancialClaim
        fields = (
            'id', 'lawsuit', 'amount', 'currency', 'currency_display', 
            'due_date', 'description', 'created_at'
        )
        read_only_fields = ('id', 'created_at')


class LawsuitSerializer(serializers.ModelSerializer):
    """
    Serializer for Lawsuit model
    """
    created_by = UserSerializer(read_only=True)
    case_type_display = serializers.CharField(source='get_case_type_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    case_status_display = serializers.CharField(source='get_case_status_display', read_only=True)
    court_detail = CourtSerializer(source='court_fk', read_only=True)
    financial_claims = FinancialClaimSerializer(many=True, read_only=True)
    
    class Meta:
        model = Lawsuit
        fields = (
            'id', 'case_number', 'filing_date', 'gregorian_date', 'hijri_date', 
            'case_type', 'case_type_display', 
            'case_status', 'case_status_display',
            'governorate',
            'court_fk', 'court_detail', 'court', 
            'subject', 'description', 'facts', 'legal_basis', 'legal_reasons', 'reasons', 
            'requests', 'status', 'status_display', 'notes',
            'created_by', 'created_at', 'updated_at',
            'financial_claims'
        )
        read_only_fields = ('id', 'created_at', 'updated_at')


class LawsuitCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating Lawsuit
    """
    class Meta:
        model = Lawsuit
        fields = (
            'case_number', 'filing_date', 'gregorian_date', 'hijri_date', 
            'case_type', 'case_status', 'governorate',
            'court_fk', 'court', 'subject', 'description', 
            'facts', 'legal_basis', 'legal_reasons', 'reasons', 'requests', 
            'status', 'notes'
        )


class LawsuitUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for updating Lawsuit
    """
    class Meta:
        model = Lawsuit
        fields = (
            'case_number', 'filing_date', 'gregorian_date', 'hijri_date', 
            'case_type', 'case_status', 'governorate',
            'court_fk', 'court', 'subject', 'description', 
            'facts', 'legal_basis', 'legal_reasons', 'reasons', 'requests', 
            'status', 'notes'
        )
