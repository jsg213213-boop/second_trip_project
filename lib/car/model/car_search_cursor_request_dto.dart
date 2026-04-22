class CarSearchCursorRequestDTO {
  final String region;
  final String startDate;
  final String endDate;
  final int cursorPrice;
  final String cursorName;
  final int size;
  final int optionSize;

  const CarSearchCursorRequestDTO({
    required this.region,
    required this.startDate,
    required this.endDate,
    this.cursorPrice = 0,
    this.cursorName = '',
    this.size = 10,
    this.optionSize = 3,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'region': region,
      'startDate': startDate,
      'endDate': endDate,
      'cursorPrice': cursorPrice,
      'cursorName': cursorName,
      'size': size,
      'optionSize': optionSize,
    };
  }
}