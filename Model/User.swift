import Foundation
import FluentSQLite
import Vapor

struct User: Content, SQLiteStringModel, Migration {
    var id: String?
    var password: String
}

extension User {
    var followers: Siblings<User, User, FollowUp> {
        return siblings(FollowUp.leftIDKey, FollowUp.rightIDKey)
    }
}
