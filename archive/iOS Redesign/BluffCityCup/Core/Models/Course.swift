import Foundation

/// A golf course with a specific set of tees.
struct Course: Identifiable, Equatable {
    var id: String { "\(name)_\(tees)" }
    let name: String
    let tees: String
    let slope: Int      // USGA slope rating (55–155, standard 113)
    let rating: Double  // Course rating (e.g. 73.5)
    let par: Double     // Total par (usually 72)
    var holes: [Hole]   // 18 holes, sorted by number

    func hole(_ number: Int) -> Hole {
        holes.first { $0.number == number } ?? .empty
    }

    static func == (lhs: Course, rhs: Course) -> Bool {
        lhs.name == rhs.name && lhs.tees == rhs.tees
    }
}

extension Course {
    static let empty = Course(name: "", tees: "", slope: 113, rating: 72.0, par: 72.0, holes: [])
}
