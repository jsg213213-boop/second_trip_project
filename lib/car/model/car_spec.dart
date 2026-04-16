class CarSpec {
  final String name;
  final String type;
  final int seats;
  final String fuel;
  final int priceMin;
  final int priceMax;

  const CarSpec({
    required this.name,
    required this.type,
    required this.seats,
    required this.fuel,
    required this.priceMin,
    required this.priceMax,
  });
}

const List<CarSpec> carSpecs = [
  // 경형
  CarSpec(name: '모닝',   type: '경형', seats: 4, fuel: '가솔린', priceMin: 20000, priceMax: 30000),
  CarSpec(name: '스파크',  type: '경형', seats: 4, fuel: '가솔린', priceMin: 20000, priceMax: 28000),
  CarSpec(name: '레이',    type: '경형', seats: 4, fuel: '가솔린', priceMin: 22000, priceMax: 32000),
  CarSpec(name: '캐스퍼',  type: '경형', seats: 4, fuel: '가솔린', priceMin: 25000, priceMax: 35000),

  // 소형
  CarSpec(name: '아반떼',  type: '소형', seats: 5, fuel: '가솔린', priceMin: 30000, priceMax: 42000),
  CarSpec(name: 'K3',      type: '소형', seats: 5, fuel: '가솔린', priceMin: 30000, priceMax: 42000),
  CarSpec(name: '벨로스터', type: '소형', seats: 4, fuel: '가솔린', priceMin: 33000, priceMax: 45000),

  // 중형
  CarSpec(name: '쏘나타',  type: '중형', seats: 5, fuel: '가솔린', priceMin: 45000, priceMax: 60000),
  CarSpec(name: 'K5',      type: '중형', seats: 5, fuel: '가솔린', priceMin: 45000, priceMax: 60000),
  CarSpec(name: '말리부',  type: '중형', seats: 5, fuel: '가솔린', priceMin: 43000, priceMax: 58000),

  // 대형
  CarSpec(name: '그랜저',       type: '대형', seats: 5, fuel: '하이브리드', priceMin: 70000, priceMax: 95000),
  CarSpec(name: 'K8',           type: '대형', seats: 5, fuel: '가솔린',    priceMin: 68000, priceMax: 90000),
  CarSpec(name: '제네시스 G80', type: '대형', seats: 5, fuel: '가솔린',    priceMin: 90000, priceMax: 130000),

  // SUV
  CarSpec(name: '티볼리',    type: 'SUV', seats: 5, fuel: '가솔린', priceMin: 40000, priceMax: 55000),
  CarSpec(name: '셀토스',    type: 'SUV', seats: 5, fuel: '가솔린', priceMin: 42000, priceMax: 58000),
  CarSpec(name: '투싼',      type: 'SUV', seats: 5, fuel: '가솔린', priceMin: 50000, priceMax: 68000),
  CarSpec(name: '스포티지',  type: 'SUV', seats: 5, fuel: '디젤',   priceMin: 50000, priceMax: 68000),
  CarSpec(name: '싼타페',    type: 'SUV', seats: 7, fuel: '디젤',   priceMin: 65000, priceMax: 85000),
  CarSpec(name: '팰리세이드', type: 'SUV', seats: 7, fuel: '디젤',  priceMin: 75000, priceMax: 100000),

  // 승합
  CarSpec(name: '스타리아',       type: '승합', seats: 9,  fuel: '디젤', priceMin: 70000, priceMax: 95000),
  CarSpec(name: '카니발',         type: '승합', seats: 9,  fuel: '디젤', priceMin: 65000, priceMax: 90000),
  CarSpec(name: '그랜드 스타렉스', type: '승합', seats: 11, fuel: '디젤', priceMin: 60000, priceMax: 85000),

  // 전기차
  CarSpec(name: '아이오닉5', type: 'SUV',  seats: 5, fuel: '전기', priceMin: 60000, priceMax: 80000),
  CarSpec(name: 'EV6',       type: 'SUV',  seats: 5, fuel: '전기', priceMin: 58000, priceMax: 78000),
  CarSpec(name: '볼트 EV',   type: '소형', seats: 5, fuel: '전기', priceMin: 40000, priceMax: 55000),
];