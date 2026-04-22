import '../../util/api_client.dart';

class CarRentHomeService {
  Future<List<String>> fetchRegions() async {
    final response = await publicDio.get('/car/regions');
    return List<String>.from(response.data);
  }
}