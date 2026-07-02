import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_helper.dart';
import '../../../models/daily_report_model.dart';

class AnalyticsRepository {
  final FirebaseFirestore _firestore;

  AnalyticsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<DailyReportModel> watchTodayReport() {
    final todayId = DateHelper.dayId(DateTime.now());

    return _firestore.collection('daily_reports').doc(todayId).snapshots().map(
      (doc) {
        if (!doc.exists || doc.data() == null) {
          return DailyReportModel.empty(todayId);
        }

        return DailyReportModel.fromMap(doc.id, doc.data()!);
      },
    );
  }

  Stream<List<Map<String, dynamic>>> watchTodayTopProducts({int limit = 5}) {
    final todayId = DateHelper.dayId(DateTime.now());

    return _firestore
        .collection('daily_reports')
        .doc(todayId)
        .collection('top_products')
        .orderBy('quantitySold', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList(),
        );
  }
}
