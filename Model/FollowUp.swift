import Foundation
import FluentSQLite
import Vapor

struct FollowUp: Content, Pivot, Migration {
    var id: Int?
    var follower: User.ID
    var following: User.ID
    
    typealias Left = User
    typealias Right = User
    
    static var leftIDKey: WritableKeyPath<FollowUp, String> {
        return \.follower
    }
    
    static var rightIDKey: WritableKeyPath<FollowUp, String> {
        return \.following
    }
}
