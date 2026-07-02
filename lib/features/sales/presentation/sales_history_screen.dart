import 'package:flutter/material.dart';

import '../../../core/utils/date_helper.dart';
import '../../../models/sale_model.dart';
import '../data/sale_repository.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = SaleRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('سجل المبيعات')),
      body: StreamBuilder<List<SaleModel>>(
        stream: repository.watchRecentSales(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sales = snapshot.data!;

          if (sales.isEmpty) {
            return const Center(child: Text('لا يوجد مبيعات'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sales.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final sale = sales[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                  title: Text('${sale.totalAmount.toStringAsFixed(2)} JOD'),
                  subtitle: Text(
                    '${sale.paymentMethod} | ${sale.createdAt == null ? '...' : DateHelper.formatDate(sale.createdAt!)}',
                  ),
                  trailing: Text(
                    'Profit: ${sale.totalProfit.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
