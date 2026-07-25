class LogDimension {
  final int? id;
  final int? orderId;
  final double length;
  final double girth;
  final double volume;
  final double price;

  const LogDimension({
    this.id,
    this.orderId,
    this.length = 0.0,
    this.girth = 0.0,
    this.volume = 0.0,
    this.price = 0.0,
  });

  LogDimension copyWith({
    int? id,
    int? orderId,
    double? length,
    double? girth,
    double? volume,
    double? price,
  }) {
    return LogDimension(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      length: length ?? this.length,
      girth: girth ?? this.girth,
      volume: volume ?? this.volume,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (orderId != null) 'orderId': orderId,
      'length': length,
      'girth': girth,
      'volume': volume,
      'price': price,
    };
  }

  factory LogDimension.fromMap(Map<String, dynamic> map) {
    return LogDimension(
      id: map['id'] as int?,
      orderId: map['orderId'] as int?,
      length: (map['length'] as num).toDouble(),
      girth: (map['girth'] as num).toDouble(),
      volume: (map['volume'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
    );
  }
}
