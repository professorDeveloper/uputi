class ReverseGeocodeResponse {
  final String displayName;
  final String? countryCode;
  final String? city;
  final String? road;
  final String? houseNumber;

  ReverseGeocodeResponse({
    required this.displayName,
    required this.countryCode,
    this.city,
    this.road,
    this.houseNumber,
  });

  factory ReverseGeocodeResponse.fromJson(Map<String, dynamic> json) {
    final addr = (json['address'] as Map<String, dynamic>?) ?? {};
    return ReverseGeocodeResponse(
      displayName: (json['display_name'] ?? '').toString(),
      countryCode: (addr['country_code'] ?? '').toString(),
      city: (addr['city'] ?? addr['town'] ?? addr['village'])?.toString(),
      road: addr['road']?.toString(),
      houseNumber: addr['house_number']?.toString(),
    );
  }
}
