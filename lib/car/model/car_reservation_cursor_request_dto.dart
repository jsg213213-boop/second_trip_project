class CarReservationCursorRequestDTO {
  final int? cursorStatusOrder;
  final String? cursorEndDate;
  final int? cursorId;
  final int size;

  const CarReservationCursorRequestDTO({
    this.cursorStatusOrder,
    this.cursorEndDate,
    this.cursorId,
    this.size = 10,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      if (cursorStatusOrder != null) 'cursorStatusOrder': cursorStatusOrder,
      if (cursorEndDate != null) 'cursorEndDate': cursorEndDate,
      if (cursorId != null) 'cursorId': cursorId,
      'size': size,
    };
  }
}