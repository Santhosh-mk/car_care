class ServiceModel {
  final int? id;
  final int vehicleId;
  final String serviceType;
  final String date;
  final int mileage;

  ServiceModel({
    this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.date,
    required this.mileage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'date': date,
      'mileage': mileage,
    };
  }
}