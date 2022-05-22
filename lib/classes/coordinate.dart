class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate(this.latitude, this.longitude);

  Coordinate.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'];

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}