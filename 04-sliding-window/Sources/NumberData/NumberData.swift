//
//  File.swift
//  04-sliding-window
//
//  Created by 김민우 on 10/28/25.
//

import Foundation


// MARK: Object
public class NumberData {
    // MARK: core
    public init(numbers: [Int], windowSize: Int) {
        self.numbers = numbers
        self.windowSize = windowSize
    }
    
    
    // MARK: state
    private let numbers: [Int]
    internal func getNumber(at index: Int) -> Int? {
        guard index >= 0 && index < numbers.count else { return nil }
        return numbers[index]
    }
    
    let windowSize: Int
    var window: Window? = nil
    var result: [Int] = []
    var isFinished: Bool = false
    
    
    
    // MARK: action
    func setUpWindow() {
        // capture
        guard window == nil else {
            return
        }
        
        // compute
        let initValues = Array(self.numbers.prefix(self.windowSize))
        
        // mutate
        if let maxValue = initValues.max() {
            self.result.append(maxValue)
        }
        
        let windowRef = Window(self, initValues)
        self.window = windowRef
    }
}
