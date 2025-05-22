class ProviderInfo {
  final String name;
  final String fullName;
  final String imageAsset;
  final String type; // "MEA" or "PEA"
  final String locationCoverage;

  ProviderInfo({
    required this.name,
    required this.fullName,
    required this.imageAsset,
    required this.type,
    required this.locationCoverage,
  });
}
