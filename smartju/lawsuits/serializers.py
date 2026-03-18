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
    Serializer for Lawsuit model - with full archive + AI fields
    """
    created_by = UserSerializer(read_only=True)
    archived_by = UserSerializer(read_only=True)
    lawyer_detail = UserSerializer(source='lawyer', read_only=True)

    case_type_display = serializers.CharField(source='get_case_type_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    case_status_display = serializers.CharField(source='get_case_status_display', read_only=True)
    archive_status_display = serializers.CharField(source='get_archive_status_display', read_only=True)
    court_level_display = serializers.CharField(source='get_court_level_display', read_only=True)
    court_detail = CourtSerializer(source='court_fk', read_only=True)
    financial_claims = FinancialClaimSerializer(many=True, read_only=True)

    child_lawsuits_count = serializers.SerializerMethodField()
    plaintiffs_count = serializers.SerializerMethodField()
    defendants_count = serializers.SerializerMethodField()
    attachments_count = serializers.SerializerMethodField()
    hearings_count = serializers.SerializerMethodField()
    judgments_count = serializers.SerializerMethodField()

    # Expose lawyer_id as a plain integer for Flutter
    lawyer_name = serializers.SerializerMethodField()

    class Meta:
        model = Lawsuit
        fields = (
            'id', 'case_number', 'filing_date', 'gregorian_date', 'hijri_date',
            'case_type', 'case_type_display',
            'case_status', 'case_status_display',
            'governorate',
            'court_fk', 'court_detail', 'court',
            # New fields
            'court_level', 'court_level_display',
            'department',
            'lawyer', 'lawyer_detail', 'lawyer_name',
            # Case content
            'subject', 'description', 'facts', 'legal_basis', 'legal_reasons', 'reasons',
            'requests', 'status', 'status_display', 'notes',
            # Archive fields
            'archive_status', 'archive_status_display',
            'archive_date', 'archive_reason', 'archived_by',
            'is_deleted', 'deleted_at',
            'parent_lawsuit',
            # Counts
            'child_lawsuits_count', 'plaintiffs_count', 'defendants_count',
            'attachments_count', 'hearings_count', 'judgments_count',
            # AI fields
            'ai_summary', 'related_laws', 'similar_cases',
            'legal_risk_level', 'success_probability', 'rag_metadata',
            # Timestamps
            'created_by', 'created_at', 'updated_at',
            'financial_claims',
        )
        read_only_fields = (
            'id', 'created_at', 'updated_at',
            'archive_date', 'archived_by', 'is_deleted', 'deleted_at',
            'court_level_display', 'lawyer_detail',
        )

    def get_child_lawsuits_count(self, obj):
        return obj.child_lawsuits.count() if hasattr(obj, 'child_lawsuits') else 0

    def get_plaintiffs_count(self, obj):
        return obj.plaintiffs.count() if hasattr(obj, 'plaintiffs') else 0

    def get_defendants_count(self, obj):
        return obj.defendants.count() if hasattr(obj, 'defendants') else 0

    def get_attachments_count(self, obj):
        return obj.attachments.count() if hasattr(obj, 'attachments') else 0

    def get_hearings_count(self, obj):
        return obj.hearings.count() if hasattr(obj, 'hearings') else 0

    def get_judgments_count(self, obj):
        return obj.judgments.count() if hasattr(obj, 'judgments') else 0

    def get_lawyer_name(self, obj):
        if obj.lawyer:
            return f"{obj.lawyer.first_name} {obj.lawyer.last_name}".strip() or obj.lawyer.username
        return None


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
            'status', 'notes', 'parent_lawsuit',
            # New fields
            'court_level', 'department', 'lawyer',
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
            'status', 'notes', 'archive_status', 'parent_lawsuit',
            # New fields
            'court_level', 'department', 'lawyer',
            # AI fields (can be updated by AI analysis action)
            'ai_summary', 'related_laws', 'similar_cases',
            'legal_risk_level', 'success_probability', 'rag_metadata',
        )
