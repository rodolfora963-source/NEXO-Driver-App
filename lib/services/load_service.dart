import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/load_model.dart';

const _base = 'https://nexoeliteadvisor.com';

// Mock data — used as fallback if backend is unreachable
final _mockLoads = [
  Load(
    id: 'mock-1',
    origin: 'Newark, NJ',
    destination: 'Philadelphia, PA',
    rate: 1250,
    distanceMiles: 95,
    weightLbs: 18000,
    equipmentType: 'Dry Van',
    brokerName: 'TQL Logistics',
  ),
  Load(
    id: 'mock-2',
    origin: 'Baltimore, MD',
    destination: 'Washington, DC',
    rate: 850,
    distanceMiles: 42,
    weightLbs: 5000,
    equipmentType: 'Cargo Van',
    brokerName: 'Echo Global',
  ),
  Load(
    id: 'mock-3',
    origin: 'Jersey City, NJ',
    destination: 'New York, NY',
    rate: 1500,
    distanceMiles: 15,
    weightLbs: 42000,
    equipmentType: 'Dry Van',
    brokerName: 'Coyote Logistics',
  ),
  Load(
    id: 'mock-4',
    origin: 'Chicago, IL',
    destination: 'Detroit, MI',
    rate: 2100,
    distanceMiles: 280,
    weightLbs: 38000,
    equipmentType: 'Dry Van',
    brokerName: 'XPO Logistics',
  ),
  Load(
    id: 'mock-5',
    origin: 'Dallas, TX',
    destination: 'Houston, TX',
    rate: 980,
    distanceMiles: 240,
    weightLbs: 44000,
    equipmentType: 'Flatbed',
    brokerName: 'Werner Enterprises',
  ),
];

class LoadService {
  final String? jwtToken;
  const LoadService([this.jwtToken]);

  Future<List<Load>> getAvailableLoads({String sort = 'rate'}) async {
    if (jwtToken == null) return _sorted(_mockLoads, sort);

    try {
      final res = await http.get(
        Uri.parse('$_base/api/v1/driver/loads?sort=$sort&limit=20'),
        headers: {'Authorization': 'Bearer $jwtToken'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (body['loads'] as List)
            .map((j) => Load.fromJson(j as Map<String, dynamic>))
            .toList();
        return list.isEmpty ? _sorted(_mockLoads, sort) : list;
      }
    } catch (_) {
      // Fall through to mock
    }
    return _sorted(_mockLoads, sort);
  }

  List<Load> _sorted(List<Load> loads, String sort) {
    final copy = [...loads];
    switch (sort) {
      case 'rate':
        copy.sort((a, b) => b.rate.compareTo(a.rate));
      case 'distance':
        copy.sort((a, b) =>
            (a.distanceMiles ?? 9999).compareTo(b.distanceMiles ?? 9999));
    }
    return copy;
  }
}
