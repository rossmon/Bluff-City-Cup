import CoreLocation

/// A single hole on a golf course.
struct Hole: Identifiable, Equatable {
    let id: Int          // hole number 1–18
    let number: Int
    let par: Int
    /// Stroke index (1 = hardest, 18 = easiest). Determines handicap stroke allocation.
    let handicapIndex: Int
    let length: Int      // yards
    let greenCenter: CLLocationCoordinate2D
    let courseName: String
    let tees: String

    init(number: Int, par: Int, handicapIndex: Int, length: Int,
         greenCenter: CLLocationCoordinate2D, courseName: String, tees: String) {
        self.id           = number
        self.number       = number
        self.par          = par
        self.handicapIndex = handicapIndex
        self.length       = length
        self.greenCenter  = greenCenter
        self.courseName   = courseName
        self.tees         = tees
    }

    static func == (lhs: Hole, rhs: Hole) -> Bool {
        lhs.courseName == rhs.courseName && lhs.tees == rhs.tees && lhs.number == rhs.number
    }
}

extension Hole {
    static let empty = Hole(number: 0, par: 4, handicapIndex: 1, length: 0,
                            greenCenter: .init(), courseName: "", tees: "")
}
