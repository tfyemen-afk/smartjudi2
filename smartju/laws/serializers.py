from rest_framework import serializers
from .models import LegalCategory, Law, LawChapter, LawSection, LawArticle, CaseLegalReference
from lawsuits.serializers import LawsuitSerializer
from smartju.common_fields import LawsuitPrimaryKeyField


class LegalCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = LegalCategory
        fields = ('id', 'name', 'description', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')


class LawSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    
    class Meta:
        model = Law
        fields = ('id', 'category', 'category_name', 'name', 'issue_year', 'description', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')


class LawChapterSerializer(serializers.ModelSerializer):
    law_name = serializers.CharField(source='law.name', read_only=True)
    
    class Meta:
        model = LawChapter
        fields = ('id', 'law', 'law_name', 'title', 'chapter_number', 'order', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')


class LawSectionSerializer(serializers.ModelSerializer):
    chapter_title = serializers.CharField(source='chapter.title', read_only=True)
    law_name = serializers.CharField(source='chapter.law.name', read_only=True)
    
    class Meta:
        model = LawSection
        fields = ('id', 'chapter', 'chapter_title', 'law_name', 'title', 'section_number', 'order', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')


class LawArticleSerializer(serializers.ModelSerializer):
    section_title = serializers.CharField(source='section.title', read_only=True)
    law_name = serializers.CharField(source='section.chapter.law.name', read_only=True)
    
    class Meta:
        model = LawArticle
        fields = ('id', 'section', 'section_title', 'law_name', 'article_number', 'article_text', 'order', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')


class CaseLegalReferenceSerializer(serializers.ModelSerializer):
    lawsuit_detail = LawsuitSerializer(source='lawsuit', read_only=True)
    lawsuit_id = LawsuitPrimaryKeyField(
        source='lawsuit',
        write_only=True,
        required=False,
        allow_null=True
    )
    article_detail = LawArticleSerializer(source='article', read_only=True)
    
    class Meta:
        model = CaseLegalReference
        fields = (
            'id', 'lawsuit', 'lawsuit_detail', 'lawsuit_id',
            'article', 'article_detail',
            'confidence_score', 'is_ai', 'notes',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'created_at', 'updated_at')

