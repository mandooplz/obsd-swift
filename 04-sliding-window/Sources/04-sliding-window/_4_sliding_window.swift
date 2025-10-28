// The Swift Programming Language
// https://docs.swift.org/swift-book
import NumberData



@main
struct _4_sliding_window {
    static func main() {
        let datas = NumberData(numbers: [1,2,3], windowSize: 1)
        datas.setUpWindow()

        let window = datas.window!

        while datas.isFinished == false {
            window.moveRight()
            window.addMaxValue()
        }

        print(datas.result)
    }
}
