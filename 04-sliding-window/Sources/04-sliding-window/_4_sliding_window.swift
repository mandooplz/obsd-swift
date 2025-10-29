// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import SlidingWindowData

@main
struct _4_sliding_window {
    private static let numbersEnvKey = "SLIDING_WINDOW_NUMBERS"
    private static let windowEnvKey = "SLIDING_WINDOW_K"
    private static let defaultNumbers = [1, 2, 3]
    private static let defaultWindowSize = 1

    static func main() {
        let environment = ProcessInfo.processInfo.environment

        let numbers: [Int]
        if let rawNumbers = environment[numbersEnvKey] {
            guard let parsedNumbers = parseNumbers(rawNumbers) else {
                print("환경 변수 \(numbersEnvKey) 값을 정수 배열로 해석할 수 없습니다. 예: 1,3,-1,-3,5,3,6,7")
                return
            }
            numbers = parsedNumbers
        } else {
            numbers = defaultNumbers
        }

        let windowSize: Int
        if let rawWindow = environment[windowEnvKey] {
            guard let parsedWindow = parseWindowSize(rawWindow) else {
                print("환경 변수 \(windowEnvKey) 값을 정수로 해석할 수 없습니다.")
                return
            }
            windowSize = parsedWindow
        } else {
            windowSize = defaultWindowSize
        }

        guard validate(numbers: numbers, windowSize: windowSize) else {
            print("유효하지 않은 입력입니다. 배열은 비어 있을 수 없고, 윈도우 크기는 1 이상이며 배열 길이 이하여야 합니다.")
            return
        }

        let data = SlidingWindowData(numbers: numbers, windowSize: windowSize)
        data.setUpWindow()

        guard let window = data.window else {
            print("윈도우 초기화에 실패했습니다.")
            return
        }

        let remainingMoves = numbers.count - windowSize
        if remainingMoves > 0 {
            for _ in 0..<remainingMoves {
                window.moveRight()
                window.addMaxValue()
            }
        }

        print(data.result)
    }

    private static func parseNumbers(_ rawValue: String) -> [Int]? {
        let tokens = rawValue.split(whereSeparator: { ", ".contains($0) })
        guard tokens.isEmpty == false else { return nil }

        var result: [Int] = []
        result.reserveCapacity(tokens.count)

        for token in tokens {
            let trimmed = String(token).trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false, let value = Int(trimmed) else {
                return nil
            }
            result.append(value)
        }

        return result
    }

    private static func parseWindowSize(_ rawValue: String) -> Int? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false, let value = Int(trimmed) else {
            return nil
        }
        return value
    }

    private static func validate(numbers: [Int], windowSize: Int) -> Bool {
        guard windowSize > 0, numbers.isEmpty == false else {
            return false
        }
        return windowSize <= numbers.count
    }
}
