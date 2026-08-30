import 'package:cdegad_kp/core/api/dashboard_api_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardApiAdapter', () {
    test('accepts the dashboard raw VDC list response', () {
      final rows = DashboardApiAdapter.list([
        {'id': 7, 'vdc_name': 'Demo VDC'},
      ]);

      final mobile = DashboardApiAdapter.vdcRow(rows.single);
      expect(mobile['id'], 7);
      expect(mobile['villageName'], 'Demo VDC');
    });

    test('maps a mobile VDC submission to dashboard fields', () {
      final request = DashboardApiAdapter.vdcRequest({
        'villageName': 'Shahi Bala',
        'district': 'Peshawar',
        'division': 'Peshawar Division',
        'tehsil': 'Peshawar',
        'description': 'Plantation support',
      });

      expect(request['vdc_name'], 'Shahi Bala');
      expect(request['village_pu'], 'Shahi Bala');
      expect(request['forest_region'], 'Peshawar');
      expect(request['main_intervention'], 'Plantation support');
    });

    test('maps every mobile module to its dashboard identity field', () {
      expect(
        DashboardApiAdapter.jfmcRequest({
          'committeeName': 'JFMC Demo',
        })['jfmc_name'],
        'JFMC Demo',
      );
      expect(
        DashboardApiAdapter.massRequest({
          'plantationName': 'Mass Demo',
        })['projects_name'],
        'Mass Demo',
      );
      expect(
        DashboardApiAdapter.awarenessRequest({
          'title': 'Awareness Demo',
        })['types_events'],
        'Awareness Demo',
      );
      expect(
        DashboardApiAdapter.youthRequest({
          'nurseryName': 'Nursery Demo',
        })['Project_Name'],
        'Nursery Demo',
      );
      expect(
        DashboardApiAdapter.farmRequest({
          'ownerName': 'Farm Demo',
        })['employee_name'],
        'Farm Demo',
      );
      expect(
        DashboardApiAdapter.womenRequest({
          'organizationName': 'WO Demo',
        })['name_of_wo'],
        'WO Demo',
      );
      expect(
        DashboardApiAdapter.otherRequest({
          'activityName': 'Activity Demo',
        })['activity_title'],
        'Activity Demo',
      );
    });

    test(
      'uses request data when a legacy create response only returns an id',
      () {
        final record = DashboardApiAdapter.record(
          {'success': true, 'insertId': 42},
          fallback: {'jfmc_name': 'Demo'},
        );

        expect(record['id'], 42);
        expect(record['jfmc_name'], 'Demo');
      },
    );
  });
}
