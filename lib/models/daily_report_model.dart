class DailyReportModel {
  final String id;
  final double totalSales;
  final double totalProfit;
  final int totalInvoices;
  final int totalItemsSold;

  const DailyReportModel({
    required this.id,
    required this.totalSales,
    required this.totalProfit,
    required this.totalInvoices,
    required this.totalItemsSold,
  });

  factory DailyReportModel.empty(String id) {
    return DailyReportModel(
      id: id,
      totalSales: 0,
      totalProfit: 0,
      totalInvoices: 0,
      totalItemsSold: 0,
    );
  }

  factory DailyReportModel.fromMap(String id, Map<String, dynamic> data) {
    return DailyReportModel(
      id: id,
      totalSales: (data['totalSales'] ?? 0).toDouble(),
      totalProfit: (data['totalProfit'] ?? 0).toDouble(),
      totalInvoices: data['totalInvoices'] ?? 0,
      totalItemsSold: data['totalItemsSold'] ?? 0,
    );
  }
}
