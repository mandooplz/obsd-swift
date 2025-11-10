import Vapor
import Logging
import NIOCore
import NIOPosix


// MARK: main
@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = try await Application.make(env)
        
        do {
            try configure(app)
            
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}


// MARK: configure
func configure(_ app: Application) throws {
    // 1) Databases
    
    // 2) Migrations
    
    // 3) Middlewares
    
    // 4) Routes
    try app.register(collection: ChatServerRoutes())
    
    // 5) Infra
    try routeChatServerHub(app)
}
