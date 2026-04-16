import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:second_trip_project/car/controller/rent_comp_controller.dart';

class CarRentScreen extends StatelessWidget {
  const CarRentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RentCompController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(title: Text('${controller.selectedRegion ?? ''} 렌터카')),
          body: _buildBody(context, controller),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RentCompController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(controller.errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<RentCompController>().fetchByRegion(controller.selectedRegion!),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final items = controller.filteredItems;

    if (items.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.directions_car, color: Colors.blueGrey),
            title: Text(item.name ?? '이름 없음'),
            subtitle: Text(
              item.road ?? item.address ?? '주소 없음',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 업체 상세 화면으로 이동
            },
          ),
        );
      },
    );
  }
}