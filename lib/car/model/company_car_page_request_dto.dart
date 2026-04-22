class CompanyCarPageRequestDTO {
  final String carName;
  final String region;
  final String startDate;
  final String endDate;
  final int page;
  final int size;

  const CompanyCarPageRequestDTO({
    required this.carName,
    required this.region,
    required this.startDate,
    required this.endDate,
    required this.page,
    this.size = 3,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'carName': carName,
      'region': region,
      'startDate': startDate,
      'endDate': endDate,
      'page': page,
      'size': size,
    };
  }
}