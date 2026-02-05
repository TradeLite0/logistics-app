/// 📦 نموذج الطلب
class Order {
  final String id;
  final String customerName;
  final String customerPhone;
  final String address;
  final double latitude;
  final double longitude;
  final double amount;
  final String status; // pending, in_progress, delivered, no_answer, postponed
  final String createdAt;
  final List<OrderItem>? items;
  
  // حقول إضافية للـ Tracking
  final String? trackingNumber;
  final String? destination;
  final String? driverName;
  final String? driverPhone;
  final double? driverLat;
  final double? driverLng;
  final double? pickupLat;
  final double? pickupLng;

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.items,
    this.trackingNumber,
    this.destination,
    this.driverName,
    this.driverPhone,
    this.driverLat,
    this.driverLng,
    this.pickupLat,
    this.pickupLng,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      address: json['address'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : null,
      trackingNumber: json['tracking_number'],
      destination: json['destination'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverLat: json['driver_lat']?.toDouble(),
      driverLng: json['driver_lng']?.toDouble(),
      pickupLat: json['pickup_lat']?.toDouble(),
      pickupLng: json['pickup_lng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'amount': amount,
      'status': status,
      'created_at': createdAt,
      'items': items?.map((i) => i.toJson()).toList(),
      'tracking_number': trackingNumber,
      'destination': destination,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'driver_lat': driverLat,
      'driver_lng': driverLng,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
    };
  }

  // 📝 copyWith لتعديل الحالة
  Order copyWith({
    String? status,
  }) {
    return Order(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      address: address,
      latitude: latitude,
      longitude: longitude,
      amount: amount,
      status: status ?? this.status,
      createdAt: createdAt,
      items: items,
      trackingNumber: trackingNumber,
      destination: destination,
      driverName: driverName,
      driverPhone: driverPhone,
      driverLat: driverLat,
      driverLng: driverLng,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
    );
  }
}

/// 📦 عنصر الطلب
class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}
