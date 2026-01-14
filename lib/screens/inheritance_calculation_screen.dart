import 'package:flutter/material.dart';

/// Inheritance Calculation Screen - حساب المواريث
class InheritanceCalculationScreen extends StatefulWidget {
  const InheritanceCalculationScreen({super.key});

  @override
  State<InheritanceCalculationScreen> createState() =>
      _InheritanceCalculationScreenState();
}

class _InheritanceCalculationScreenState
    extends State<InheritanceCalculationScreen> {
  final TextEditingController _estateValueController = TextEditingController();
  final TextEditingController _debtsController = TextEditingController();
  final TextEditingController _bequestsController = TextEditingController();
  bool _isCalculating = false;

  @override
  void dispose() {
    _estateValueController.dispose();
    _debtsController.dispose();
    _bequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب المواريث'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calculate, color: Colors.green, size: 32),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'حساب المواريث اليمنية',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'حساب المواريث استناداً لكتاب القسمة من وزارة العدل',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'بيانات التركة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _estateValueController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'قيمة التركة',
                      hintText: 'أدخل قيمة التركة',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _debtsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الديون',
                      hintText: 'أدخل قيمة الديون',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.remove_circle),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bequestsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الوصايا',
                      hintText: 'أدخل قيمة الوصايا',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCalculating ? null : _calculateInheritance,
                      icon: _isCalculating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.calculate),
                      label: Text(_isCalculating ? 'جاري الحساب...' : 'حساب الميراث'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.people,
            title: 'تقسيم الورث',
            description: 'تقسيم الورث حسب المدخلات وأحكام الشريعة الإسلامية',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.inventory,
            title: 'جمع وحصر التركة',
            description: 'جمع وحصر جميع أموال التركة بشكل منظم',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.book,
            title: 'كتاب القسمة',
            description: 'حساب المواريث وفق كتاب القسمة من وزارة العدل',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  void _calculateInheritance() {
    if (_estateValueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال قيمة التركة')),
      );
      return;
    }

    setState(() => _isCalculating = true);

    // Simulate calculation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isCalculating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('قريباً: ميزة حساب المواريث')),
      );
    });
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('قريباً: $title')),
          );
        },
      ),
    );
  }
}
