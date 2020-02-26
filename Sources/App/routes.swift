import Routing
import Vapor
import Fluent
import FluentSQLite
import Foundation

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.post(User.self, at: "create") { req, user -> Future<User> in
        guard let id = user.id else {
            throw Abort(.badRequest)
        }
        
        return User.find(id, on: req).flatMap(to:User.self) { existing in
            guard existing == nil else {
                throw Abort(.badRequest)
            }
            
            return user.create(on: req).map(to: User.self) { user in
                return user
            }
        }
    }
    
    router.post("login") { req -> Future<Token> in
        let username: String = try req.content.syncGet(at: "id")
        let password: String = try req.content.syncGet(at: "password")
        
        guard username.count > 0, password.count > 0 else {
            throw Abort(.badRequest)
        }
        
        return User.find(username, on: req).flatMap(to: Token.self) { user in
            _ = Token.query(on: req).filter(\.expiry < Date()).delete()
            
            guard let user = user else {
                throw Abort(.notFound)
            }
            
            guard user.password == password else {
                throw Abort(.unauthorized)
            }
            
            let newToken = Token(id: nil, username: username, expiry: Date().addingTimeInterval(86400))
            
            return newToken.create(on: req).map(to: Token.self) { newToken in
                return newToken
            }
        }
    }
    
    router.post("post") { req -> Future<Post> in
        let token: UUID = try req.content.syncGet(at: "token")
        let message: String = try req.content.syncGet(at: "message")
        
        guard message.count > 0 else {
            throw Abort(.badRequest)
        }
        
        let reply: Int = (try? req.content.syncGet(at: "reply")) ?? 0
        
        return Token.find(token, on: req).flatMap(to: Post.self) { token in
            guard let token = token else {
                throw Abort(.unauthorized)
            }
            
            let post = Post(id: nil, username: token.username, message: message, parent: reply, date: Date())
            try post.validate()
            
            return post.create(on: req).map(to: Post.self) { post in
                return post
            }
        }
    }
    
    router.get(String.parameter, "posts") { req -> Future<[Post]> in
        let username = try req.parameters.next(String.self)
        
        return Post.query(on: req).filter(\Post.username == username).all()
    }
    
    router.get(String.parameter, "timeline") { req -> Future<[Post]> in
        let username = try req.parameters.next(String.self)
        
        return FollowUp.query(on: req).filter(\FollowUp.follower == username).join(\FollowUp.following, to: \Post.username).alsoDecode(Post.self).all().map { tuples in
            return tuples.map { tuple in
                return tuple.1
            }
        }
        
    }
    
    router.get("search") { req -> Future<[Post]> in
        let query: String = try req.query.get(String.self, at: ["query"])
        
        return Post.query(on: req).filter(\.message ~~ query).all()
    }
    
    router.post(FollowUp.self, at: "follow") { req, follow -> Future<FollowUp> in
        FollowUp.query(on: req)
            .filter(\.follower == follow.follower)
            .filter(\.following == follow.following)
            .first()
            .flatMap(to: FollowUp.self) { found in
                
            guard found == nil else {
                throw Abort(.badRequest)
            }
                
            return follow.create(on: req).map(to: FollowUp.self) { follow in
                return follow
            }
        }
    }
}
