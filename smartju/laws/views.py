from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import LegalCategory, Law, LawChapter, LawSection, LawArticle, CaseLegalReference
from .serializers import (
    LegalCategorySerializer, LawSerializer, LawChapterSerializer,
    LawSectionSerializer, LawArticleSerializer, CaseLegalReferenceSerializer
)


class LegalCategoryViewSet(viewsets.ModelViewSet):
    queryset = LegalCategory.objects.all()
    serializer_class = LegalCategorySerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = []
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'created_at']
    ordering = ['name']


class LawViewSet(viewsets.ModelViewSet):
    queryset = Law.objects.select_related('category').all()
    serializer_class = LawSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['category', 'issue_year']
    search_fields = ['name', 'description']
    ordering_fields = ['category', 'issue_year', 'name', 'created_at']
    ordering = ['category', 'issue_year', 'name']


class LawChapterViewSet(viewsets.ModelViewSet):
    queryset = LawChapter.objects.select_related('law').all()
    serializer_class = LawChapterSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['law']
    search_fields = ['title', 'law__name']
    ordering_fields = ['law', 'order', 'created_at']
    ordering = ['law', 'order']


class LawSectionViewSet(viewsets.ModelViewSet):
    queryset = LawSection.objects.select_related('chapter', 'chapter__law').all()
    serializer_class = LawSectionSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['chapter']
    search_fields = ['title']
    ordering_fields = ['chapter', 'order', 'created_at']
    ordering = ['chapter', 'order']


class LawArticleViewSet(viewsets.ModelViewSet):
    queryset = LawArticle.objects.select_related('section', 'section__chapter', 'section__chapter__law').all()
    serializer_class = LawArticleSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['section']
    search_fields = ['article_number', 'article_text']
    ordering_fields = ['section', 'order', 'article_number', 'created_at']
    ordering = ['section', 'order']


class CaseLegalReferenceViewSet(viewsets.ModelViewSet):
    queryset = CaseLegalReference.objects.select_related('lawsuit', 'article').all()
    serializer_class = CaseLegalReferenceSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['lawsuit', 'article', 'is_ai']
    search_fields = ['notes']
    ordering_fields = ['confidence_score', 'created_at']
    ordering = ['-confidence_score', '-created_at']

