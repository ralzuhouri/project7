import Foundation
import FluentSQLite
import Vapor

struct Token: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var username: String
    var expiry: Date
}
