from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import PaymentOrder
from .serializers import PaymentOrderSerializer


class PaymentOrderViewSet(viewsets.ModelViewSet):
    queryset = PaymentOrder.objects.select_related('lawsuit').all()
    serializer_class = PaymentOrderSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['lawsuit', 'status', 'order_date']
    search_fields = ['order_number', 'description']
    ordering_fields = ['order_date', 'amount', 'created_at']
    ordering = ['-order_date']

