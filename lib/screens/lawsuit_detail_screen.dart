import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lawsuit_provider.dart';
import '../providers/auth_provider.dart';
import '../models/lawsuit_model.dart';
import '../models/party_model.dart';
import 'dart:developer' as developer;

/// Lawsuit Detail Screen - Updated to support legal templates
class LawsuitDetailScreen extends StatefulWidget {
  final int? lawsuitId;

  const LawsuitDetailScreen({super.key, this.lawsuitId});

  @override
  State<LawsuitDetailScreen> createState() => _LawsuitDetailScreenState();
}

class _LawsuitDetailScreenState extends State<LawsuitDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _caseNumberController;
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  
  // Legal text controllers (dynamic based on case type)
  final Map<String, TextEditingController> _legalTextControllers = {};
  
  String? _selectedCaseType;
  String? _selectedCaseStatus;
  String? _selectedGovernorate;
  int? _selectedCourtId;
  
  bool _isLoadingTemplates = false;
  Map<String, dynamic>? _templates;
  List<String> _templateKeys = [];
  
  // Parties data
  List<PlaintiffModel> _plaintiffs = [];
  List<DefendantModel> _defendants = [];
  bool _isLoadingParties = false;
  
  bool get _isEditMode => widget.lawsuitId != null;

  @override
  void initState() {
    super.initState();
    _caseNumberController = TextEditingController();
    _subjectController = TextEditingController();
    _descriptionController = TextEditingController();
    
    // Default case type
    _selectedCaseType = 'دعوى';
    _selectedCaseStatus = 'جديد';

    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLawsuit();
        _loadParties();
      });
    } else {
      // Load templates for default case type
      _loadTemplates(_selectedCaseType!);
    }
  }

  @override
  void dispose() {
    _caseNumberController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    for (var controller in _legalTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLawsuit() async {
    final provider = Provider.of<LawsuitProvider>(context, listen: false);
    await provider.loadLawsuit(widget.lawsuitId!);
    final lawsuit = provider.selectedLawsuit;
    if (lawsuit != null) {
      _caseNumberController.text = lawsuit.caseNumber;
      _subjectController.text = lawsuit.subject ?? '';
      _descriptionController.text = lawsuit.description ?? '';
      _selectedCaseType = lawsuit.caseType;
      _selectedCaseStatus = lawsuit.caseStatus ?? 'جديد';
      _selectedGovernorate = lawsuit.governorate;
      
      // Load templates and populate legal text fields
      await _loadTemplates(_selectedCaseType!);
      
      // Populate legal text fields from lawsuit
      if (lawsuit.facts != null && _legalTextControllers.containsKey('facts')) {
        _legalTextControllers['facts']!.text = lawsuit.facts!;
      }
      if (lawsuit.legalBasis != null && _legalTextControllers.containsKey('legal')) {
        _legalTextControllers['legal']!.text = lawsuit.legalBasis!;
      }
      if (lawsuit.requests != null && _legalTextControllers.containsKey('requests')) {
        _legalTextControllers['requests']!.text = lawsuit.requests!;
      }
    }
  }

  Future<void> _loadParties() async {
    if (widget.lawsuitId == null) return;
    
    setState(() {
      _isLoadingParties = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final plaintiffsResponse = await authProvider.apiService.getPlaintiffs(
        lawsuitId: widget.lawsuitId,
      );
      final defendantsResponse = await authProvider.apiService.getDefendants(
        lawsuitId: widget.lawsuitId,
      );

      setState(() {
        _plaintiffs = (plaintiffsResponse['results'] as List? ?? [])
            .map((json) => PlaintiffModel.fromJson(json))
            .toList();
        _defendants = (defendantsResponse['results'] as List? ?? [])
            .map((json) => DefendantModel.fromJson(json))
            .toList();
      });
    } catch (e) {
      developer.log('Error loading parties: $e', name: 'LawsuitDetailScreen');
    } finally {
      setState(() {
        _isLoadingParties = false;
      });
    }
  }

  Future<void> _loadTemplates(String caseType) async {
    setState(() {
      _isLoadingTemplates = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.apiService.getLawsuitTemplates(caseType);
      
      setState(() {
        _templates = response;
        _templateKeys = (response['templates'] as List)
            .map((t) => t['section_key'] as String)
            .toList();
        
        // Create controllers for each template
        for (var template in response['templates']) {
          final key = template['section_key'] as String;
          if (!_legalTextControllers.containsKey(key)) {
            _legalTextControllers[key] = TextEditingController(
              text: template['default_text'] as String? ?? '',
            );
          }
        }
      });
    } catch (e) {
      developer.log('Error loading templates: $e', name: 'LawsuitDetailScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل النصوص القانونية: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingTemplates = false;
      });
    }
  }

  void _onCaseTypeChanged(String? newType) {
    if (newType != null && newType != _selectedCaseType) {
      setState(() {
        _selectedCaseType = newType;
        // Clear existing legal text controllers
        for (var controller in _legalTextControllers.values) {
      controller.dispose();
    }
        _legalTextControllers.clear();
        _templateKeys.clear();
      });
      // Load new templates
      _loadTemplates(newType);
    }
  }

  Future<void> _saveLawsuit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<LawsuitProvider>(context, listen: false);
    
    // Build legal texts from controllers
    String? facts;
    String? legalBasis;
    String? requests;
    
    if (_legalTextControllers.containsKey('facts')) {
      facts = _legalTextControllers['facts']!.text.trim();
    }
    if (_legalTextControllers.containsKey('legal')) {
      legalBasis = _legalTextControllers['legal']!.text.trim();
    }
    if (_legalTextControllers.containsKey('requests')) {
      requests = _legalTextControllers['requests']!.text.trim();
    }
    
    final lawsuit = LawsuitModel(
      id: widget.lawsuitId,
      caseNumber: _caseNumberController.text.trim(),
      caseType: _selectedCaseType!,
      caseStatus: _selectedCaseStatus,
      subject: _subjectController.text.trim().isEmpty 
          ? null 
          : _subjectController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      facts: facts?.isEmpty ?? true ? null : facts,
      legalBasis: legalBasis?.isEmpty ?? true ? null : legalBasis,
      requests: requests?.isEmpty ?? true ? null : requests,
      governorate: _selectedGovernorate,
      filingDate: DateTime.now(),
    );

    final success = _isEditMode
        ? await provider.updateLawsuit(widget.lawsuitId!, lawsuit)
        : await provider.createLawsuit(lawsuit);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'تم تحديث الدعوى بنجاح' : 'تم إنشاء الدعوى بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'حدث خطأ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'تعديل الدعوى' : 'إضافة دعوى جديدة'),
      ),
      body: _isEditMode
          ? Consumer<LawsuitProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.selectedLawsuit == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildForm();
              },
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Case Type (triggers template loading)
            DropdownButtonFormField<String>(
              value: _selectedCaseType,
              decoration: const InputDecoration(
                labelText: 'نوع القضية',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'امر_اداء', child: Text('أمر أداء')),
                DropdownMenuItem(value: 'دعوى', child: Text('دعوى')),
                DropdownMenuItem(value: 'رد_على_دعوى', child: Text('رد على دعوى')),
                DropdownMenuItem(value: 'استئناف', child: Text('استئناف')),
                DropdownMenuItem(value: 'طعن', child: Text('طعن')),
              ],
              onChanged: _onCaseTypeChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار نوع القضية';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Case Number
            TextFormField(
              controller: _caseNumberController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'رقم الدعوى',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم الدعوى';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Subject
            TextFormField(
              controller: _subjectController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'موضوع الدعوى',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
              maxLength: 150,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال موضوع الدعوى';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Case Status
            DropdownButtonFormField<String>(
              value: _selectedCaseStatus,
              decoration: const InputDecoration(
                labelText: 'حالة القضية',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              items: const [
                DropdownMenuItem(value: 'جديد', child: Text('جديد')),
                DropdownMenuItem(value: 'قيد_النظر', child: Text('قيد النظر')),
                DropdownMenuItem(value: 'مكتمل', child: Text('مكتمل')),
                DropdownMenuItem(value: 'مغلق', child: Text('مغلق')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCaseStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'الوصف (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Legal Templates Section
            if (_isLoadingTemplates)
              const Center(child: CircularProgressIndicator())
            else if (_templates != null && _templateKeys.isNotEmpty)
              ..._buildLegalTextFields()
            else
              const SizedBox.shrink(),

            const SizedBox(height: 32),

            // Parties Section (only in edit mode)
            if (_isEditMode && widget.lawsuitId != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              _buildPartiesSection(),
              const SizedBox(height: 16),
            ],

            // Save button
            Consumer<LawsuitProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: (provider.isLoading || _isLoadingTemplates) ? null : _saveLawsuit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditMode ? 'حفظ التغييرات' : 'إنشاء الدعوى',
                          style: const TextStyle(fontSize: 16),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLegalTextFields() {
    if (_templates == null) return [];
    
    final templates = _templates!['templates'] as List;
    final widgets = <Widget>[];
    
    widgets.add(
      const Divider(),
    );
    widgets.add(
      const Text(
        'النصوص القانونية',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
    widgets.add(const SizedBox(height: 16));
    
    for (var template in templates) {
      final key = template['section_key'] as String;
      final title = template['section_title'] as String;
      final isRequired = template['is_required'] as bool? ?? false;
      
      if (!_legalTextControllers.containsKey(key)) {
        _legalTextControllers[key] = TextEditingController(
          text: template['default_text'] as String? ?? '',
        );
      }
      
      widgets.add(
        TextFormField(
          controller: _legalTextControllers[key],
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: title + (isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.gavel),
            helperText: 'يمكنك تعديل النص الافتراضي',
          ),
          maxLines: 8,
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'هذا الحقل إجباري';
                  }
                  return null;
                }
              : null,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    return widgets;
  }

  Widget _buildPartiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'أطراف الدعوى',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.green),
                  onPressed: () => _showAddPartyDialog(isPlaintiff: true),
                  tooltip: 'إضافة مدعي',
                ),
                IconButton(
                  icon: const Icon(Icons.person_add_outlined, color: Colors.orange),
                  onPressed: () => _showAddPartyDialog(isPlaintiff: false),
                  tooltip: 'إضافة مدعى عليه',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Plaintiffs
        Card(
          color: Colors.green.shade50,
          child: ExpansionTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: Text('المدعون (${_plaintiffs.length})'),
            children: _isLoadingParties
                ? [const Center(child: CircularProgressIndicator())]
                : _plaintiffs.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('لا يوجد مدعون', style: TextStyle(color: Colors.grey)),
                        ),
                      ]
                    : _plaintiffs.map((plaintiff) => _buildPartyCard(plaintiff, isPlaintiff: true)).toList(),
          ),
        ),
        const SizedBox(height: 8),
        
        // Defendants
        Card(
          color: Colors.orange.shade50,
          child: ExpansionTile(
            leading: const Icon(Icons.person_outline, color: Colors.orange),
            title: Text('المدعى عليهم (${_defendants.length})'),
            children: _isLoadingParties
                ? [const Center(child: CircularProgressIndicator())]
                : _defendants.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('لا يوجد مدعى عليهم', style: TextStyle(color: Colors.grey)),
                        ),
                      ]
                    : _defendants.map((defendant) => _buildPartyCard(defendant, isPlaintiff: false)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPartyCard(PartyModel party, {required bool isPlaintiff}) {
    return ListTile(
      title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الجنس: ${party.genderDisplay}'),
          Text('الجنسية: ${party.nationality}'),
          if (party.occupation != null) Text('المهنة: ${party.occupation}'),
          Text('العنوان: ${party.address}'),
          if (party.phone != null) Text('الهاتف: ${party.phone}'),
          if (party.attorneyName != null) Text('الوكيل: ${party.attorneyName}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showAddPartyDialog(
              isPlaintiff: isPlaintiff,
              party: party,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteParty(party, isPlaintiff: isPlaintiff),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPartyDialog({
    required bool isPlaintiff,
    PartyModel? party,
  }) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: party?.name ?? '');
    final nationalityController = TextEditingController(text: party?.nationality ?? '');
    final occupationController = TextEditingController(text: party?.occupation ?? '');
    final addressController = TextEditingController(text: party?.address ?? '');
    final phoneController = TextEditingController(text: party?.phone ?? '');
    final attorneyNameController = TextEditingController(text: party?.attorneyName ?? '');
    final attorneyPhoneController = TextEditingController(text: party?.attorneyPhone ?? '');
    String? selectedGender = party?.gender ?? 'male';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(party == null 
            ? (isPlaintiff ? 'إضافة مدعي' : 'إضافة مدعى عليه')
            : (isPlaintiff ? 'تعديل مدعي' : 'تعديل مدعى عليه')),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم *'),
                  validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(labelText: 'الجنس *'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('ذكر')),
                    DropdownMenuItem(value: 'female', child: Text('أنثى')),
                  ],
                  onChanged: (v) => selectedGender = v,
                ),
                TextFormField(
                  controller: nationalityController,
                  decoration: const InputDecoration(labelText: 'الجنسية *'),
                  validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                TextFormField(
                  controller: occupationController,
                  decoration: const InputDecoration(labelText: 'المهنة'),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'العنوان *'),
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'الهاتف'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: attorneyNameController,
                  decoration: const InputDecoration(labelText: 'اسم الوكيل'),
                ),
                TextFormField(
                  controller: attorneyPhoneController,
                  decoration: const InputDecoration(labelText: 'هاتف الوكيل'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _saveParty(
                  isPlaintiff: isPlaintiff,
                  party: party,
                  name: nameController.text,
                  gender: selectedGender!,
                  nationality: nationalityController.text,
                  occupation: occupationController.text.isEmpty ? null : occupationController.text,
                  address: addressController.text,
                  phone: phoneController.text.isEmpty ? null : phoneController.text,
                  attorneyName: attorneyNameController.text.isEmpty ? null : attorneyNameController.text,
                  attorneyPhone: attorneyPhoneController.text.isEmpty ? null : attorneyPhoneController.text,
                );
                Navigator.pop(context);
              }
            },
            child: Text(party == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );

    nameController.dispose();
    nationalityController.dispose();
    occupationController.dispose();
    addressController.dispose();
    phoneController.dispose();
    attorneyNameController.dispose();
    attorneyPhoneController.dispose();
  }

  Future<void> _saveParty({
    required bool isPlaintiff,
    PartyModel? party,
    required String name,
    required String gender,
    required String nationality,
    String? occupation,
    required String address,
    String? phone,
    String? attorneyName,
    String? attorneyPhone,
  }) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final lawsuitId = widget.lawsuitId!;
      
      final partyData = {
        'lawsuit_id': lawsuitId,
        'name': name,
        'gender': gender,
        'nationality': nationality,
        if (occupation != null) 'occupation': occupation,
        'address': address,
        if (phone != null) 'phone': phone,
        if (attorneyName != null) 'attorney_name': attorneyName,
        if (attorneyPhone != null) 'attorney_phone': attorneyPhone,
      };

      if (party == null) {
        // Create new party
        if (isPlaintiff) {
          await authProvider.apiService.createPlaintiff(partyData);
        } else {
          await authProvider.apiService.createDefendant(partyData);
        }
      } else {
        // Update existing party
        if (isPlaintiff) {
          await authProvider.apiService.updatePlaintiff(party.id!, partyData);
        } else {
          await authProvider.apiService.updateDefendant(party.id!, partyData);
        }
      }

      // Reload parties
      await _loadParties();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(party == null 
                ? (isPlaintiff ? 'تم إضافة المدعي بنجاح' : 'تم إضافة المدعى عليه بنجاح')
                : 'تم التحديث بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      developer.log('Error saving party: $e', name: 'LawsuitDetailScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteParty(PartyModel party, {required bool isPlaintiff}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${party.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (isPlaintiff) {
        await authProvider.apiService.deletePlaintiff(party.id!);
      } else {
        await authProvider.apiService.deleteDefendant(party.id!);
      }

      // Reload parties
      await _loadParties();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحذف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      developer.log('Error deleting party: $e', name: 'LawsuitDetailScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
