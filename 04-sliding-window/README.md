# Sliding Window Maximum (Swift OOP)

이 Swift 패키지는 [LeetCode 239. Sliding Window Maximum](https://leetcode.com/problems/sliding-window-maximum/) 문제를 객체 지향적으로 해결한 예시입니다. 슬라이딩 윈도우를 하나의 독립된 객체로 보고, 데이터 집합 위를 이동하며 최대값을 계산하도록 설계했습니다.

## 문제 요약

- 길이가 `k`인 슬라이딩 윈도우를 배열의 왼쪽부터 오른쪽 끝까지 한 칸씩 이동시키며, 각 위치에서의 최대값을 구하는 문제입니다.
- 윈도우가 이동할 때마다 배열의 범위를 벗어나지 않아야 하며, 각 위치의 최대값을 순서대로 반환해야 합니다.
- 최적 해법은 덱을 활용해 O(n)에 풀 수 있지만, 이 패키지는 객체 간 책임 분리에 초점을 맞춘 설계를 보여줍니다.

## 프로젝트 구성

- `Sources/SlidingWindowData/SlidingWindowData.swift`: 입력 배열과 윈도우 크기, 결과를 관리하는 소유 객체입니다. `setUpWindow()`를 통해 초기 윈도우를 설정합니다.
- `Sources/SlidingWindowData/Window.swift`: 실제 윈도우를 표현하는 객체입니다. 현재 창의 값들을 유지하고 `moveRight()`로 오른쪽으로 이동하며, `addMaxValue()`를 통해 최대값을 `SlidingWindowData`에 전달합니다.
- `Sources/04-sliding-window/_4_sliding_window.swift`: 두 객체를 묶어 실행하는 예제 `main`입니다. 환경 변수 또는 기본값을 이용해 최대값 배열을 출력합니다.

두 객체는 책임을 분리한 채 협력합니다. `SlidingWindowData`는 도메인 데이터와 결과 관리에 집중하고, `Window`는 순회 상태와 이동 로직을 담당합니다.

## 동작 방식

1. `SlidingWindowData`를 전체 숫자 배열과 윈도우 크기와 함께 초기화합니다.
2. `setUpWindow()`가 첫 윈도우를 구성하고 초기 최대값을 결과에 추가합니다.
3. 클라이언트 코드(`main`)가 윈도우를 오른쪽으로 이동시키며 각 단계마다 최대값을 누적합니다.

이 구조는 UI 슬라이더나 반복자(iterator)처럼 윈도우를 제어해야 하는 더 큰 애플리케이션으로 확장하기 쉽습니다.

## 실행 방법

```bash
swift run
```

기본 예제는 `[1, 2, 3]`과 윈도우 크기 `1`을 사용하므로 다음과 같은 결과가 출력됩니다.

```
[1, 2, 3]
```

## 환경 변수 입력

실행 시 환경 변수를 지정하면 사용자 정의 배열과 윈도우 크기를 사용할 수 있습니다.

- `SLIDING_WINDOW_NUMBERS`: 정수 배열을 콤마 또는 공백으로 구분해 입력합니다. 예시: `1,3,-1,-3,5,3,6,7`
- `SLIDING_WINDOW_K`: 윈도우 크기를 나타내는 양의 정수입니다.

예시 실행:

```bash
SLIDING_WINDOW_NUMBERS="1,3,-1,-3,5,3,6,7" SLIDING_WINDOW_K=3 swift run
```

유효하지 않은 값이 전달되면 프로그램이 오류 메시지를 출력하고 종료합니다. 입력된 윈도우 크기는 배열 길이 이하이면서 1 이상이어야 합니다.

## 테스트 케이스

| 입력 `nums` | `k` | 예상 출력 |
| --- | --- | --- |
| `[1, 3, -1, -3, 5, 3, 6, 7]` | `3` | `[3, 3, 5, 5, 6, 7]` |
| `[9, 11]` | `2` | `[11]` |
| `[4, 2, 12, 11, -5]` | `1` | `[4, 2, 12, 11, -5]` |
| `[10, -2, -7, 8, 9, -5, 3, 4, 6, -1]` | `4` | `[10, 9, 9, 9, 9, 6, 6]` |

### 실행 예시

```bash
SLIDING_WINDOW_NUMBERS="1,3,-1,-3,5,3,6,7" SLIDING_WINDOW_K=3 swift run
# 예상 출력: [3, 3, 5, 5, 6, 7]
```
```bash
SLIDING_WINDOW_NUMBERS="9,11" SLIDING_WINDOW_K=2 swift run
# 예상 출력: [11]
```
```bash
SLIDING_WINDOW_NUMBERS="4,2,12,11,-5" SLIDING_WINDOW_K=1 swift run
# 예상 출력: [4, 2, 12, 11, -5]
```
```bash
SLIDING_WINDOW_NUMBERS="10,-2,-7,8,9,-5,3,4,6,-1" SLIDING_WINDOW_K=4 swift run
# 예상 출력: [10, 9, 9, 9, 9, 6, 6]
```
