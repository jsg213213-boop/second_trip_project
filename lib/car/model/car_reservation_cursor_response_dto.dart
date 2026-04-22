import 'car_rental_reservation_dto.dart';

class CarReservationCursorResponseDTO {
  final List<CarRentalReservationDTO> reservation;
  final bool hasNext;
  final int? nextCursorStatusOrder;
  final String? nextCursorEndDate;
  final int? nextCursorId;

  CarReservationCursorResponseDTO({
    required this.reservation,
    required this.hasNext,
    this.nextCursorStatusOrder,
    this.nextCursorEndDate,
    this.nextCursorId,
  });

  factory CarReservationCursorResponseDTO.fromJson(Map<String, dynamic> json) {
    return CarReservationCursorResponseDTO(
      reservation: (json['reservation'] as List)
          .map((e) => CarRentalReservationDTO.fromJson(e))
          .toList(),
      hasNext: json['hasNext'],
      nextCursorStatusOrder: json['nextCursorStatusOrder'] as int?,
      nextCursorEndDate: json['nextCursorEndDate'] as String?,
      nextCursorId: json['nextCursorId'] as int?,
    );
  }
}