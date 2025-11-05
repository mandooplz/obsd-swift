# my-chat

이 저장소는 Vapor 기반 서버(`ChatServer`)와 SwiftUI 기반 iOS 클라이언트(`ChatApp`)로 구성된 단순 채팅 예제입니다. 마이크로서비스, 인증/인가 흐름, 그리고 WebSocket 구독 로직을 작게 재현하여 참고용으로 살펴볼 수 있게 구성했습니다.

## 관련 내용
- 마이크로서비스, IDP, 인증 및 인가, Flow의 실행 주체
- 클라이언트의 서버 구독 디자인

## 서버 실행 방법
```bash
# ChatServer 폴더로 이동
cd ChatServer

# 모든 IP 주소에 대해 8080 포트 접근 허용
swift run ChatServer serve --hostname 0.0.0.0 --port 8080
```
- 실행 후 `curl http://localhost:8080/` 명령으로 서버 응답을 확인하세요.
- Vapor 환경변수(`DATABASE_URL` 등)를 사용하는 경우 `.env` 파일을 생성해 원하는 값을 지정할 수 있습니다.

## iOS 클라이언트 실행 방법
1. `my-chat.xcworkspace`를 더블 클릭해 Xcode에서 워크스페이스를 엽니다.
2. 스킴을 `ChatApp`으로 선택한 뒤 시뮬레이터나 실제 기기를 타깃으로 실행합니다.
3. 필요 시 `ChatApp/ChatApp/Flow/ChatServerFlow.swift` 내 `baseURL`을 실행 중인 서버의 주소로 수정합니다.


## 샘플 흐름
1. 사용자가 회원가입(`SignUpForm`)을 진행하면 서버는 자격 증명을 저장하고 즉시 인증을 시도합니다.
2. 인증 성공 시 `ChatApp.completeAuthentication`이 호출되어 메시지 초기 로드와 WebSocket 구독이 이루어집니다.
3. 채팅 입력창에서 메시지를 전송하면 `NewMsgTicket`이 서버로 전달되고, 서버는 메시지를 저장한 뒤 모든 구독자에게 `NewMsgEvent`를 push 합니다.

## API 테스트 예시 (`curl`)
- 기본 주소는 `http://localhost:8080`으로 가정합니다. 실제 서버 주소와 포트가 다르면 적절히 바꿔 주세요.

### 회원가입
```bash
curl -i -X POST http://localhost:8080/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"user@example.com","password":"pass1234"}'
```

### 로그인 (인증 확인)
```bash
curl -X POST http://localhost:8080/auth \
  -H 'Content-Type: application/json' \
  -d '{"email":"user@example.com","password":"pass1234"}'
```

### 메시지 조회
```bash
curl 'http://localhost:8080/getMessages?email=user@example.com&password=pass1234'
```

### 메시지 전송
사전에 클라이언트 ID(구독 식별자)로 사용할 UUID를 준비합니다.
```bash
CLIENT_ID=$(uuidgen)
```
그 다음 아래 명령으로 메시지를 전송합니다. `id`에는 새로 생성한 메시지 UUID를, `client`에는 방금 만든 `CLIENT_ID` 값을 넣어 주세요.
```bash
curl -i -X POST http://localhost:8080/addMessage \
  -H 'Content-Type: application/json' \
  --data-binary @- <<'JSON'
{
  "id": "PUT-GENERATED-UUID-HERE",
  "client": "PUT-CLIENT-UUID-HERE",
  "credential": {
    "email": "user@example.com",
    "password": "pass1234"
  },
  "content": "안녕하세요!"
}
JSON
```

### 구독 등록 (WebSocket 연결 전 사전 단계)
```bash
curl -i -X POST "http://localhost:8080/subscribe?client=PUT-CLIENT-UUID-HERE"
```
`/subscribe` 호출로 서버에 클라이언트를 등록한 뒤, 실제 WebSocket 스트림(`/ws`)은 `websocat`, `wscat`, `websocketd` 같은 도구로 접속해야 합니다. 여기에서도 `PUT-CLIENT-UUID-HERE` 자리에 앞서 정의한 `CLIENT_ID` 값을 넣어 주세요. `curl`은 WebSocket 프로토콜 전송을 직접 지원하지 않습니다.

## 추가 참고
- Swift Concurrency (`async/await`, `actor`)를 실제 앱-서버 통신에 어떻게 적용할 수 있는지 예제로 확인해 보세요.
- `SwiftLogger` 유틸은 간단한 구조화 로그 출력을 위해 사용되었습니다. 로그 태그를 통해 호출 흐름을 추적할 수 있습니다.
- 서버 단위 테스트는 `ChatServer/Tests/`에서 Vapor의 `XCTVapor`를 사용한 예시를 확인할 수 있습니다.
