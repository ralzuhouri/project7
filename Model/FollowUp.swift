import Foundation
import FluentSQLite
import Vapor

struct FollowUp: Content, SQLiteModel, Migration {
    var id: Int?
    var follower: String
    var following: String
}
