import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/accommodation_providers.dart';
import '../../../util/api_client.dart';
import '../../../util/secure_storage_helper.dart';
import '../../data/models/accommodation.dart';
import '../../data/models/room.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'RoomDetailScreen.dart';

class AccommodationDetailScreen extends ConsumerWidget {
  final Accommodation accommodation;
  const AccommodationDetailScreen({super.key, required this.accommodation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // detailIntro2 API 호출 → 체크인/아웃, 부대시설 정보 채우기
    final detailAsync = ref.watch(accommodationDetailProvider(accommodation));
    final favorites = ref.watch(favoriteProvider);
    final isFav = favorites.contains(accommodation.contentId);

    return detailAsync.when(
      // 로딩 중
      loading: () => Scaffold(
        appBar: AppBar(backgroundColor: AppTheme.surface),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      ),
      // 에러
      error: (e, _) => Scaffold(
        appBar: AppBar(backgroundColor: AppTheme.surface),
        body: Center(child: Text(e.toString())),
      ),
      // 데이터 있음
      data: (detail) => _buildContent(context, ref, detail, isFav),
    );
  }

  Widget _buildContent(
      BuildContext context,
      WidgetRef ref,
      Accommodation detail,
      bool isFav,
      ) {
    // 상세 화면 방문 시 캐시에 저장 → 찜 목록에서 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accommodationCacheProvider.notifier).update(
            (state) => {...state, detail.contentId: detail},
      );
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ─── 상단 이미지 + 앱바 ────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.surface,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const BackButton(color: AppTheme.textPrimary),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppTheme.primary : AppTheme.textPrimary,
                    size: 20,
                  ),
                  onPressed: () async {
                    final isLoggedIn = await SecureStorageHelper().isLoggedIn();

                    // 비회원이면 로그인 안내
                    if (!isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('찜하기는 회원만 가능합니다. 로그인해주세요!'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                      return;
                    }

                    // 회원이면 백엔드 API 호출
                    if (isFav) {
                      // 찜 삭제
                      final success = await ApiClient()
                          .removeFavorite(detail.contentId);
                      if (success) {
                        ref.read(favoriteProvider.notifier)
                            .toggle(detail.contentId);
                      }
                    } else {
                      // 찜 추가
                      final result = await ApiClient().addFavorite(
                        contentId: detail.contentId,
                        accommodationTitle: detail.title,
                        firstImage: detail.firstImage,
                        addr1: detail.addr1,
                      );
                      if (result != null) {
                        ref.read(favoriteProvider.notifier)
                            .toggle(detail.contentId);
                      }
                    }
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: detail.hasImage
                  ? CachedNetworkImage(
                imageUrl: detail.firstImage,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (_, __, ___) => _fallbackImage(),
              )
                  : _fallbackImage(),
            ),
          ),

          // ─── 기본 정보 ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 숙소 유형 배지
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      detail.accommodationType,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 숙소 이름
                  Text(
                    detail.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 주소
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          detail.addr1,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 별점
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 16, color: AppTheme.star),
                      const SizedBox(width: 4),
                      Text(
                        detail.rating?.toStringAsFixed(1) ?? '-',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${detail.reviewCount})',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── 숙소 상세 정보 ─────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('숙소 정보',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _infoItem(
                        icon: Icons.login,
                        label: '체크인',
                        value: detail.checkIn ?? '정보 없음',
                      ),
                      _infoItem(
                        icon: Icons.logout,
                        label: '체크아웃',
                        value: detail.checkOut ?? '정보 없음',
                      ),
                      _infoItem(
                        icon: Icons.local_parking,
                        label: '주차',
                        value: detail.parking ?? '정보 없음',
                      ),
                      _infoItem(
                        icon: Icons.meeting_room,
                        label: '객실수',
                        value: detail.roomCount ?? '정보 없음',
                      ),
                      _infoItem(
                        icon: Icons.outdoor_grill,
                        label: '바비큐',
                        value: detail.barbecue == '1' ? '가능' : '불가',
                      ),
                      _infoItem(
                        icon: Icons.fitness_center,
                        label: '피트니스',
                        value: detail.fitness == '1' ? '가능' : '불가',
                      ),
                      _infoItem(
                        icon: Icons.hot_tub,
                        label: '사우나',
                        value: detail.sauna == '1' ? '가능' : '불가',
                      ),
                      _infoItem(
                        icon: Icons.local_taxi,
                        label: '픽업서비스',
                        value: detail.pickup == '1' ? '가능' : '불가',
                      ),
                    ],
                  ),
                  // 부대시설
                  if (detail.subFacility != null &&
                      detail.subFacility!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('부대시설',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 6),
                    Text(
                      detail.subFacility!,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ─── 객실 목록 ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('객실 정보',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  // 객실 목록 Provider 호출
                  Consumer(
                    builder: (context, ref, _) {
                      final roomsAsync = ref.watch(
                          roomListProvider(detail.contentId));
                      return roomsAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary),
                        ),
                        error: (e, _) => const Text(
                          '객실 정보를 불러오지 못했습니다.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        data: (rooms) {
                          if (rooms.isEmpty) {
                            return const Text(
                              '등록된 객실 정보가 없습니다.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary),
                            );
                          }
                          return Column(
                            children: rooms
                                .map((room) => _RoomCard(
                              room: room,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RoomDetailScreen(room: room, accommodationTitle: detail.title),
                                ),
                              ),
                            ))
                                .toList(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ─── 위치 정보 ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('위치',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    detail.addr1,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  // 지도 자리 (다음 단계에서 flutter_map 연동)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(detail.mapY, detail.mapX),
                          initialZoom: 15,
                        ),
                        children: [
                          // 지도 타일 (OpenStreetMap 무료)
                          TileLayer(
                            urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                            'com.example.second_trip_project',
                          ),
                          // 숙소 위치 마커
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(detail.mapY, detail.mapX),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  size: 40,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),

      // // ─── 하단 예약 버튼 ────────────────────────────────────
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      //   decoration: const BoxDecoration(
      //     color: AppTheme.surface,
      //     border: Border(
      //         top: BorderSide(color: AppTheme.border, width: 0.5)),
      //   ),
      //   // child: ElevatedButton(
      //   //   onPressed: () async {
      //   //     final isLoggedIn = await SecureStorageHelper().isLoggedIn();
      //   //
      //   //     if (!isLoggedIn) {
      //   //       ScaffoldMessenger.of(context).showSnackBar(
      //   //         const SnackBar(
      //   //           content: Text('예약은 회원만 가능합니다. 로그인해주세요!'),
      //   //           backgroundColor: AppTheme.primary,
      //   //           duration: Duration(seconds: 3),
      //   //         ),
      //   //       );
      //   //       return;
      //   //     }
      //   //
      //   //     // 회원이면 예약 화면으로 이동
      //   //     // 나중에 날짜 선택 화면 추가
      //   //     ScaffoldMessenger.of(context).showSnackBar(
      //   //       const SnackBar(
      //   //         content: Text('예약 기능 준비 중입니다.'),
      //   //         backgroundColor: AppTheme.primary,
      //   //       ),
      //   //     );
      //   //   },
      //   //   child: const Text('예약하기'),
      //   // ),
      // ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary)),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() => Container(
    color: const Color(0xFFEEEEEE),
    child: const Center(
      child: Icon(Icons.hotel, size: 60, color: Color(0xFFCCCCCC)),
    ),
  );
}

// ─── 객실 카드 위젯 ───────────────────────────────────
class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  const _RoomCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          children: [
            // 객실 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: room.hasImage
                  ? CachedNetworkImage(
                imageUrl: room.img1!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _roomFallback(),
              )
                  : _roomFallback(),
            ),
            const SizedBox(width: 12),
            // 객실 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomTitle,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '기준 ${room.baseCount}인 / 최대 ${room.maxCount}인',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    room.displayPrice,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary),
                  ),
                ],
              ),
            ),
            // 상세보기 화살표
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _roomFallback() => Container(
    width: 80,
    height: 80,
    color: const Color(0xFFEEEEEE),
    child: const Icon(Icons.bed,
        size: 32, color: Color(0xFFCCCCCC)),
  );
}