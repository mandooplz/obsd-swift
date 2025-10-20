//
//  Fortune.swift
//  Cheetos
//
//  Created by 김민우 on 8/28/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
public final class Fortune: MessageInterface {
    // MARK: core
    internal init(owner: Cheetos.ID) {
        self.owner = owner
        
        FortuneManager.register(self)
    }
    internal func delete() {
        FortuneManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    internal nonisolated let owner: Cheetos.ID
    
    public var content: String? = nil
    public var createdAt: Date? = nil
    
    public nonisolated let isMyMessage: Bool = false
    public var isLoading = true
    
    public var error: Error? = nil
    
    
    // MARK: action
    public func fetch() async {
        // capture
        guard isLoading == true,
              content == nil,
              createdAt == nil else {
            self.error = .alreadyFetched
            return
        }
        
        // compute
        let randomContent = Content.random()
        
        // mutate
        self.content = randomContent
        self.createdAt = .now
        self.isLoading = false
    }
    
    
    
    // MARK: value
    @MainActor
    public struct ID: MessageIDRepresentable, Hashable {
        public let rawValue = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            FortuneManager.container[self] != nil
        }
        public var ref: Fortune? {
            FortuneManager.container[self]
        }
    }
    
    public struct Content {
        private static let messages = [
            "오늘 작성한 코드가 내일의 포트폴리오가 될 거예요! 🚀 ",
            "버그는 당신을 더 강한 개발자로 만들어주는 스승입니다.",
            "오늘은 새로운 프레임워크를 배우기 좋은 날이에요!",
            "당신의 깃허브 잔디가 더욱 푸르러질 예정입니다. 🌱 ",
            "코드 리뷰에서 좋은 피드백을 받을 수 있는 날이에요.",
            "오늘 푼 알고리즘 문제가 면접 질문으로 나올 거예요!",
            "페어 프로그래밍에서 새로운 인사이트를 얻게 됩니다.",
            "스택오버플로우에서 원하는 답을 바로 찾을 수 있는 날!",
            "오늘 작성한 주석이 미래의 당신을 구원할 거예요.",
            "클린 코드의 중요성을 깨닫게 되는 하루가 될 거예요.",
            "실패한 빌드도 성장의 과정입니다. 포기하지 마세요!",
            "오늘의 에러 메시지가 내일의 경험이 됩니다.",
            "당신의 첫 PR이 머지될 날이 다가오고 있어요! 🎉 ",
            "코딩 테스트 준비가 빛을 발할 때가 곧 옵니다.",
            "팀 프로젝트에서 당신의 아이디어가 채택될 거예요.",
            "오늘은 리팩토링하기 완벽한 날입니다.",
            "테스트 코드 작성의 즐거움을 발견하게 될 거예요.",
            "당신의 코드가 누군가에게 영감을 줄 수 있어요.",
            "오늘은 새로운 디자인 패턴을 이해하게 되는 날!",
            "멘토님의 조언이 큰 도움이 될 거예요.",
            "오늘은 구글링 실력이 특히 중요한 날이 될 거예요... 🔍 ",
            "머지 컨플릭트가 예상됩니다. 차분히 해결하세요."
        ]
        static func random() -> String {
            let defaultMessage = "다크모드로 코딩하면 눈이 덜 피로할 거예요. 🌙"
            
            return messages.randomElement() ?? defaultMessage
        }
    }
    
    public enum Error: String, Swift.Error {
        case alreadyFetched
    }
}



// MARK: ObjectManager
@MainActor @Observable
fileprivate final class FortuneManager: Sendable {
    // MARK: core
    static var container: [Fortune.ID:Fortune] = [:]
    static func register(_ object:Fortune) {
        container[object.id] = object
    }
    static func unregister(_ id:Fortune.ID) {
        container[id] = nil
    }
}
