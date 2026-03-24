class Vehicle {
  final int? id;
  final int userId;

  final String vehicleType;     // car/bike/van/lorry/jeep
  final String model;
  final int year;
  final int mileage;

  final String chassisNumber;
  final String plateNumber;
  final String fuelType;        // Petrol/Diesel/Hybrid/Electric etc.
  final String? vehicleImage;

  Vehicle({
    this.id,
    required this.userId,
    required this.vehicleType,
    required this.model,
    required this.year,
    required this.mileage,
    required this.chassisNumber,
    required this.plateNumber,
    required this.fuelType,
    this.vehicleImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vehicleType': vehicleType,
      'model': model,
      'year': year,
      'mileage': mileage,
      'chassisNumber': chassisNumber,
      'plateNumber': plateNumber,
      'fuelType': fuelType,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      userId: map['userId'],
      vehicleType: map['vehicleType'],
      model: map['model'],
      year: map['year'],
      mileage: map['mileage'],
      chassisNumber: map['chassisNumber'],
      plateNumber: map['plateNumber'],
      fuelType: map['fuelType'],
    );
  }
}