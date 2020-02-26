import Foundation
import FluentSQLite
import Vapor

struct User: Content, SQLiteStringModel, Migration {
    var id: String?
    var password: String
}
