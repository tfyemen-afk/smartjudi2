import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lawsuit_provider.dart';
import '../models/lawsuit_model.dart';
import 'lawsuit_detail_screen.dart';

/// Lawsuits List Screen
class LawsuitsListScreen extends StatefulWidget {
  const LawsuitsListScreen({super.key});

  @override
  State<LawsuitsListScreen> createState() => _LawsuitsListScreenState();
}

class _LawsuitsListScreenState extends State<LawsuitsListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LawsuitProvider>(context, listen: false).loadLawsuits(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final provider = Provider.of<LawsuitProvider>(context, listen: false);
      if (provider.hasMore && !provider.isLoading) {
        provider.loadLawsuits();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الدعاوى'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LawsuitDetailScreen(),
                ),
              ).then((_) {
                // Refresh list after returning
                Provider.of<LawsuitProvider>(context, listen: false).loadLawsuits(refresh: true);
              });
            },
            tooltip: 'إضافة دعوى جديدة',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LawsuitDetailScreen(),
            ),
          ).then((_) {
            // Refresh list after returning
            Provider.of<LawsuitProvider>(context, listen: false).loadLawsuits(refresh: true);
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'إضافة دعوى جديدة',
      ),
      body: Consumer<LawsuitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.lawsuits.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.lawsuits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'حدث خطأ',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[300]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadLawsuits(refresh: true);
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (provider.lawsuits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد دعاوى',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط على زر + لإضافة دعوى جديدة',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadLawsuits(refresh: true);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: provider.lawsuits.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.lawsuits.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final lawsuit = provider.lawsuits[index];
                return _LawsuitCard(lawsuit: lawsuit);
              },
            ),
          );
        },
      ),
    );
  }
}

class _LawsuitCard extends StatelessWidget {
  final LawsuitModel lawsuit;

  const _LawsuitCard({required this.lawsuit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LawsuitDetailScreen(lawsuitId: lawsuit.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lawsuit.caseNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(status: lawsuit.caseStatus ?? lawsuit.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lawsuit.caseTypeDisplay,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (lawsuit.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  lawsuit.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    lawsuit.filingDate != null 
                        ? DateFormat('yyyy-MM-dd').format(lawsuit.filingDate!)
                        : '-',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (lawsuit.courtName != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.business, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lawsuit.courtName!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String? status;

  const _StatusChip({required this.status});

  Color get _statusColor {
    final statusValue = status ?? '';
    switch (statusValue) {
      case 'new':
      case 'جديد':
        return Colors.blue;
      case 'pending':
      case 'قيد_النظر':
      case 'قيد الانتظار':
        return Colors.orange;
      case 'in_progress':
      case 'قيد_النظر':
        return Colors.blue;
      case 'completed':
      case 'مكتمل':
        return Colors.green;
      case 'appealed':
      case 'مستأنف':
        return Colors.purple;
      case 'closed':
      case 'مغلق':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String get _statusText {
    final statusValue = status ?? '';
    switch (statusValue) {
      case 'new':
      case 'جديد':
        return 'جديد';
      case 'pending':
      case 'قيد_النظر':
      case 'قيد الانتظار':
        return 'قيد الانتظار';
      case 'in_progress':
      case 'قيد_النظر':
        return 'قيد النظر';
      case 'completed':
      case 'مكتمل':
        return 'مكتمل';
      case 'appealed':
      case 'مستأنف':
        return 'مستأنف';
      case 'closed':
      case 'مغلق':
        return 'مغلق';
      default:
        return statusValue.isNotEmpty ? statusValue : 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor, width: 1),
      ),
      child: Text(
        _statusText,
        style: TextStyle(
          color: _statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

