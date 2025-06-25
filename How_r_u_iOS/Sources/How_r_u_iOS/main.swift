// Sources/How_r_u_iOS/main.swift
import Vapor

let app = try Application()
defer { app.shutdown() }

// API 엔드포인트 설정 (예시)
app.get("health") { req -> String in
    return "OK"
}

try app.run()
// 서버 실행
// 이 코드는 Vapor 프레임워크를 사용하여 간단한 HTTP 서버를 설정합니다. 