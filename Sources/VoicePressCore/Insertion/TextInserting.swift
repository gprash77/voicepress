import Foundation

@MainActor
public protocol TextInserting: AnyObject {
    func insert(text: String) async throws
}
