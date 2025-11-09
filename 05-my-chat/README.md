# 05-my-chat · Vapor + SwiftUI Chat

Vapor 서버(`ChatServer`)와 SwiftUI iOS 앱(`ChatApp`)이 짝을 이루는 풀스택 채팅 샘플입니다. 인증, WebSocket 구독, Flow 객체 간 협업을 최소 구성으로 살펴볼 수 있습니다.

## Architecture

- **ChatServer**: Vapor REST/WebSocket 서버. 회원가입·인증·메시지 이벤트를 처리하며 `SwiftLogger`로 호출 로그를 남깁니다.
- **ChatApp**: SwiftUI 클라이언트. `ChatServerFlow`에 자격 증명을 전달하고 WebSocket 구독을 유지합니다.

## Design
<img width="5226" height="2673" alt="my-chat" src="https://github.com/user-attachments/assets/a7400b87-4e15-48b0-b28a-ec327d869532" />


## Run

### Server

```bash
cd ChatServer
swift run ChatServer serve --hostname 0.0.0.0 --port 8080
```

- `curl http://localhost:8080/`로 상태를 확인하고, 필요 시 `.env`에 `DATABASE_URL` 등을 지정합니다.

### iOS Client

1. `my-chat.xcworkspace`를 열어 스킴을 `ChatApp`으로 선택합니다.
2. 시뮬레이터/실기기에서 실행하고 `ChatServerFlow.baseURL`을 실행 중인 서버 주소로 맞춥니다.

## Sample Flow

1. `SignUpForm`에서 회원가입 → 서버가 즉시 인증을 시도합니다.
2. `completeAuthentication`이 초기 메시지 로드와 WebSocket 구독을 시작합니다.
3. 사용자가 메시지를 전송하면 `NewMsgTicket`이 서버에 저장되고, `/ws` 구독자에게 `NewMsgEvent`가 push 됩니다.

## Quick API Checks

기본 주소: `http://localhost:8080`

```bash
BASE=http://localhost:8080

# register
curl -X POST $BASE/register -H 'Content-Type: application/json' \
  -d '{"email":"user@example.com","password":"pass1234"}'

# auth
curl -X POST $BASE/auth -H 'Content-Type: application/json' \
  -d '{"email":"user@example.com","password":"pass1234"}'

# messages
curl "$BASE/getMessages?email=user@example.com&password=pass1234"

# send message
CLIENT_ID=$(uuidgen)
MSG_ID=$(uuidgen)
curl -X POST $BASE/addMessage -H 'Content-Type: application/json' --data-binary @- <<JSON
{
  "id": "$MSG_ID",
  "client": "$CLIENT_ID",
  "credential": {"email": "user@example.com","password": "pass1234"},
  "content": "안녕하세요!"
}
JSON
```

WebSocket 구독은 `/subscribe?client=<UUID>`를 POST로 등록한 뒤 `/ws?client=<UUID>`로 연결하면 됩니다.

## Tech Stack

- Swift Concurrency (`async/await`, `actor`)
- Vapor 4 (REST + WebSocket)
- SwiftUI + Xcode workspace 구성
