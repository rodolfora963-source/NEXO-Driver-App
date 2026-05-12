class Load {
  final String id;
  final String origin;
  final String destination;
  final double rate;
  final int? distanceMiles;
  final int? weightLbs;
  final String equipmentType;
  final String? pickupWindow;
  final String? deliveryTime;
  final String? brokerName;
  final double tollCosts;
  final double fuelEstimate;

  const Load({
    required this.id,
    required this.origin,
    required this.destination,
    required this.rate,
    this.distanceMiles,
    this.weightLbs,
    required this.equipmentType,
    this.pickupWindow,
    this.deliveryTime,
    this.brokerName,
    this.tollCosts = 0,
    this.fuelEstimate = 0,
  });

  factory Load.fromJson(Map<String, dynamic> j) => Load(
        id:            j['id'] as String,
        origin:        j['origin'] as String,
        destination:   j['destination'] as String,
        rate:          (j['rate'] as num).toDouble(),
        distanceMiles: j['distance_miles'] as int?,
        weightLbs:     j['weight_lbs'] as int?,
        equipmentType: j['equipment_type'] as String? ?? 'Dry Van',
        pickupWindow:  j['pickup_time'] as String?,
        deliveryTime:  j['delivery_time'] as String?,
        brokerName:    j['broker_name'] as String?,
        tollCosts:     (j['toll_costs'] as num?)?.toDouble() ?? 0,
        fuelEstimate:  (j['fuel_estimate'] as num?)?.toDouble() ?? 0,
      );

  double get netRate => rate - tollCosts - fuelEstimate;

  String get weightFormatted => weightLbs != null
      ? '${(weightLbs! / 1000).toStringAsFixed(0)}k lbs'
      : '—';

  String get distanceFormatted =>
      distanceMiles != null ? '$distanceMiles mi' : '—';
}
