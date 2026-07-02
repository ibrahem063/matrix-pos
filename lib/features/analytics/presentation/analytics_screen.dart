import 'package:flutter/material.dart';

import '../../../models/daily_report_model.dart';
import '../data/analytics_repository.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AnalyticsRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('التحليلات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<DailyReportModel>(
            stream: repository.watchTodayReport(),
            builder: (context, snapshot) {
              final report = snapshot.data ?? DailyReportModel.empty('today');

              return Column(
                children: [
                  _AnalyticsCard(
                    title: 'مبيعات اليوم',
                    value: '${report.totalSales.toStringAsFixed(2)} JOD',
                    icon: Icons.payments,
                  ),
                  _AnalyticsCard(
                    title: 'ربح اليوم',
                    value: '${report.totalProfit.toStringAsFixed(2)} JOD',
                    icon: Icons.trending_up,
                  ),
                  _AnalyticsCard(
                    title: 'عدد الفواتير',
                    value: '${report.totalInvoices}',
                    icon: Icons.receipt,
                  ),
                  _AnalyticsCard(
                    title: 'القطع المباعة',
                    value: '${report.totalItemsSold}',
                    icon: Icons.shopping_bag,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'أكثر المنتجات مبيعًا اليوم',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: repository.watchTodayTopProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('خطأ: ${snapshot.error}');
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data!;

              if (products.isEmpty) {
                return const Card(
                  child: ListTile(
                    title: Text('لا يوجد مبيعات اليوم حتى الآن'),
                  ),
                );
              }

              return Column(
                children: products.map((product) {
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.star)),
                      title: Text(product['productName'] ?? ''),
                      subtitle: Text('الكمية: ${product['quantitySold'] ?? 0}'),
                      trailing: Text(
                        '${((product['salesAmount'] ?? 0) as num).toDouble().toStringAsFixed(2)} JOD',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
