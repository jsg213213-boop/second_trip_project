import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/CounterProvider.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 화면이 다시 그려질(Rebuild) 때마다 현재 시간을 새로 가져옵니다.
    // watch를 쓰면 이 시간이 계속 바뀌고, Consumer를 쓰면 처음에만 찍히고 멈춰있습니다.
    final updateTime = DateTime.now().toString().substring(11, 19);

    return Scaffold(
      appBar: AppBar(title: const Text('Provider 테스트 (주석 토글)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 같이 변하는지(화면 전체가 재빌드되는지) 확인하기 위한 시간 텍스트
            Text(
              '화면 전체 마지막 업데이트 시간:\n$updateTime',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.blueAccent),
            ),

            const SizedBox(height: 48),

            // ==============================================================
            // 🔴 테스트 1: context.watch 사용 (현재 주석 처리됨)
            // 아래 주석(/* */)을 풀고, [테스트 2]를 주석 처리한 뒤 실행해보세요.
            // 버튼을 누를 때마다 위의 '시간' 텍스트도 같이 변하는 것을 볼 수 있습니다.
            // ==============================================================
            // Text(
            //   // 매우 중요함. !!!, 구독중, 누구를 ?
            //   // 순서3, 구독하고 있는 화면이, 응답을 받고서, 그림을 다시 그리기.
            //   '${context.watch<CounterProvider>().count}',
            //   style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            // ),

            // ==============================================================
            // 🔵 테스트 2: Consumer 사용 (현재 활성화됨)
            // 현재 상태에서 버튼을 눌러보세요. 숫자만 바뀌고 위의 '시간' 텍스트는
            // 변하지 않습니다. (이 Consumer 안쪽만 다시 그려지기 때문입니다.)
            // ==============================================================
            Consumer<CounterProvider>(
              builder: (context, provider, child) {
                print('숫자가 바뀔 때마다 여기만 다시 그려집니다!');
                return Text(
                  '${provider.count}', // provider.count 로 접근
                  style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                );
              },
            ),

            const SizedBox(height: 48),

            // 카운터 조작 버튼들 (read 사용 - 상태 변경 명령만 내림)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<CounterProvider>().decrement(),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  // 이벤트 처리시 동작 흐름. 순서1
                  // 증가 이벤트 함수를 호출하기.
                  onPressed: () => context.read<CounterProvider>().increment(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => context.read<CounterProvider>().reset(),
              child: const Text('초기화'),
            ),
          ],
        ),
      ),
    );
  }
}