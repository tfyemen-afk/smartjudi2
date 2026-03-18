import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lawsuit_provider.dart';
import '../models/case_timeline_model.dart';

/// Case Timeline Screen - الجدول الزمني للقضية
///
/// Displays a chronological, scrollable vertical timeline of all events
/// (filing, hearings, documents, judgments, appeals, AI analysis) for a
/// given lawsuit.
///
/// Usage:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => CaseTimelineScreen(lawsuitId: id, caseNumber: num),
///   ));
class CaseTimelineScreen extends StatefulWidget {
  final int lawsuitId;
  final String caseNumber;

  const CaseTimelineScreen({
    super.key,
    required this.lawsuitId,
    required this.caseNumber,
  });

  @override
  State<CaseTimelineScreen> createState() => _CaseTimelineScreenState();
}

class _CaseTimelineScreenState extends State<CaseTimelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LawsuitProvider>(context, listen: false)
          .loadCaseTimeline(widget.lawsuitId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الجدول الزمني - ${widget.caseNumber}'),
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
              onPressed: () =>
                  Provider.of<LawsuitProvider>(context, listen: false)
                      .loadCaseTimeline(widget.lawsuitId),
            ),
          ],
        ),
        body: Consumer<LawsuitProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingTimeline) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE91E63)),
              );
            }

            if (provider.timeline.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timeline, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد أحداث مسجّلة بعد',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيظهر هنا كل حدث بعد رفع الدعوى',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: provider.timeline.length,
              itemBuilder: (context, index) {
                final event = provider.timeline[index];
                final isLast = index == provider.timeline.length - 1;
                return _TimelineEventTile(
                  event: event,
                  isLast: isLast,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Single timeline event tile with connector line
class _TimelineEventTile extends StatelessWidget {
  final CaseTimelineEvent event;
  final bool isLast;

  const _TimelineEventTile({required this.event, required this.isLast});

  Color get _typeColor {
    switch (event.eventType) {
      case 'filing':
        return const Color(0xFF4CAF50);
      case 'hearing':
        return const Color(0xFF2196F3);
      case 'document':
        return const Color(0xFFFF9800);
      case 'judgment':
        return const Color(0xFFE91E63);
      case 'appeal':
        return const Color(0xFF9C27B0);
      case 'payment':
        return const Color(0xFF009688);
      case 'ai_analysis':
        return const Color(0xFFD4AF37);
      default:
        return Colors.grey;
    }
  }

  IconData get _typeIcon {
    switch (event.eventType) {
      case 'filing':
        return Icons.gavel;
      case 'hearing':
        return Icons.event;
      case 'document':
        return Icons.description;
      case 'judgment':
        return Icons.balance;
      case 'appeal':
        return Icons.upload_file;
      case 'payment':
        return Icons.payments;
      case 'ai_analysis':
        return Icons.psychology;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _typeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _typeColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(_typeIcon, color: Colors.white, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Event content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Type badge + date row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Date
                          Text(
                            DateFormat('yyyy/MM/dd').format(event.eventDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              event.eventTypeDisplay,
                              style: TextStyle(
                                fontSize: 11,
                                color: _typeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      // Description
                      if (event.description != null &&
                          event.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.description!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Hijri date
                      if (event.hijriDate != null &&
                          event.hijriDate!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'هجري: ${event.hijriDate}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                          textAlign: TextAlign.right,
                        ),
                      ],
                      // Document link
                      if (event.documentUrl != null &&
                          event.documentUrl!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.attach_file,
                                size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              'وثيقة مرفقة',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
