//
//  Window.swift
//  04-sliding-window
//
//  Created by 김민우 on 10/28/25.
//
import Foundation


// MARK: Object
public class Window {
    // MARK: core
    public init(_ owner: SlidingWindowData, _ values: [Int]) {
        self.owner = owner
        self.values = values
        self.size = values.count
    }
    
    // MARK: state
    let owner: SlidingWindowData
    
    let size: Int
    var startPosition: Int = 0
    var endPosition: Int { startPosition + size - 1 }
    
    var values: [Int] = []
    func removeFirst() {
        self.values.removeFirst()
    }
    func append(_ newValue: Int) {
        self.values.append(newValue)
    }
    func maxValue() -> Int? {
        return self.values.max()
    }
    
    // MARK: action
    public func addMaxValue() {
        // capture
        guard let maxValue = self.maxValue() else {
            print("최대값이 존재하지 않습니다.")
            return
        }
        
        // mutate
        owner.result.append(maxValue)
    }
    public func moveRight() {
        // capture
        let nextPosition = endPosition.advanced(by: 1)
        guard let nextValue = owner.getNumber(at: nextPosition) else {
            print("더 이상 이동이 불가능합니다. 현재 위치 \(startPosition)-\(endPosition)")
            return
        }
        guard let maxValue = self.maxValue() else {
            print("최대값이 존재하지 않습니다.")
            return
        }
        
        // mutate
        if nextPosition == owner.numbers.count - 1 {
            owner.isFinished = true
        }
            
        self.removeFirst()
        self.append(nextValue)
        self.startPosition += 1
    }
}
