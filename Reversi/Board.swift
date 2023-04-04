import Combine
struct Board: Hashable {
    let width: Int
    let height: Int
    private var disks: [Disk?]
    
    init(width: Int, height: Int, disks: [Disk?]? = nil) {
        precondition(width >= 2, "`width` must be >= 2: \(width)")
        precondition(height >= 2, "`height` must be >= 2: \(height)")
        precondition(width.isMultiple(of: 2), "`width` must be an even number: \(width)")
        precondition(height.isMultiple(of: 2), "`height` must be an even number: \(height)")

        self.width = width
        self.height = height
        if let disks = disks {
            precondition(disks.count == width * height, "`disks.count` must be equal to `width * height`: disks.count = \(disks.count), width = \(width), height = \(height)")
            self.disks = disks
        } else {
            self.disks = [Disk?](repeating: nil, count: width * height)
            reset()
        }
    }
    
    private func diskIndexAt(x: Int, y: Int) -> Int? {
        guard xRange.contains(x) && yRange.contains(y) else { return nil }
        return y * width + x
    }
    
    subscript(x: Int, y: Int) -> Disk? {
        get { diskIndexAt(x: x, y: y).flatMap { i in disks[i] } }
        set {
            guard let index = diskIndexAt(x: x, y: y) else {
                preconditionFailure() // FIXME: Add a message.
            }
            disks[index] = newValue
        }
    }
}

// MARK: Ranges

extension Board {
    var xRange: Range<Int> {
        0 ..< width
    }
    var yRange: Range<Int> {
        0 ..< height
    }
}

// MARK: Reset

extension Board {
    mutating func reset() {
        for y in  yRange {
            for x in xRange {
                self[x, y] = nil
            }
        }
        
        self[width / 2 - 1, height / 2 - 1] = .light
        self[width / 2,     height / 2 - 1] = .dark
        self[width / 2 - 1, height / 2    ] = .dark
        self[width / 2,     height / 2    ] = .light
    }
}

// MARK: Counting

extension Board {
    func getSituation(side: Disk) -> Situation {
        return Situation(disks: disks, side: side)
    }
    struct Situation: Hashable {
        let disks: [Disk?]
        let side: Disk
    }
    static var cache = [Situation: [(Int, Int)]]()
    
    func count(of disk: Disk) -> Int {
        return disks.lazy.filter { $0 == disk }.count
    }
    
    func sideWithMoreDisks() -> Disk? {
        let darkCount = count(of: .dark)
        let lightCount = count(of: .light)
        if darkCount == lightCount {
            return nil
        } else {
            return darkCount > lightCount ? .dark : .light
        }
    }
}

// MARK: Flipped boards

extension Board {
    func flipped() -> Board {
        var flipped = self
        flipped.flip()
        return flipped
    }
    
    mutating func flip() {
        for index in disks.indices {
            disks[index]?.flip()
        }
    }
}

// MARK: Placing disks

extension Board {
    func flippedDiskCoordinatesByPlacingDisk(_ disk: Disk, atX x: Int, y: Int) -> [(Int, Int)] {
        let directions = [
            (x: -1, y: -1),
            (x:  0, y: -1),
            (x:  1, y: -1),
            (x:  1, y:  0),
            (x:  1, y:  1),
            (x:  0, y:  1),
            (x: -1, y:  0),
            (x: -1, y:  1),
        ]
        
        guard self[x, y] == nil else {
            return []
        }
        
        var diskCoordinates: [(Int, Int)] = []
        
        for direction in directions {
            var x = x
            var y = y
            
            var diskCoordinatesInLine: [(Int, Int)] = []
            flipping: while true {
                x += direction.x
                y += direction.y
                
                switch (disk, self[x, y]) { // Uses tuples to make patterns exhaustive
                case (.dark, .some(.dark)), (.light, .some(.light)):
                    diskCoordinates.append(contentsOf: diskCoordinatesInLine)
                    break flipping
                case (.dark, .some(.light)), (.light, .some(.dark)):
                    diskCoordinatesInLine.append((x, y))
                case (_, .none):
                    break flipping
                }
            }
        }
        return diskCoordinates
    }
    
    func canPlaceDisk(_ disk: Disk, atX x: Int, y: Int) -> Bool {
        !flippedDiskCoordinatesByPlacingDisk(disk, atX: x, y: y).isEmpty
    }
    
    func validMoves(for side: Disk) -> [(x: Int, y: Int)] {
        var coordinates: [(Int, Int)] = []
        
        for y in yRange {
            for x in xRange {
                if canPlaceDisk(side, atX: x, y: y) {
                    coordinates.append((x, y))
                }
            }
        }
        
        return coordinates
    }
    
    func cornerCount(_ side: Disk) -> (Int, Int) {
        let counts =  [(0, 0), (0, width-1), (height-1, 0), (height-1, width-1)].reduce((0, 0)) { count, xy in
            let disk = self[xy.0, xy.1]
            let myCount = disk == side ? count.0+1 : count.0
            let enemyCount = disk == side.flipped ? count.1+1 : count.1
            return (myCount, enemyCount)
        }
        return counts
    }
    func cornerFrontCount(_ side: Disk) -> (Int, Int) {
        let counts =  [(1, 1), (1, width-2), (height-2, 1), (height-2, width-2)].reduce((0, 0)) { count, xy in
            let disk = self[xy.0, xy.1]
            let myCount = disk == side ? count.0+1 : count.0
            let enemyCount = disk == side.flipped ? count.1+1 : count.1
            return (myCount, enemyCount)
        }
        return counts
    }

    mutating func place(_ disk: Disk, atX x: Int, y: Int) throws {
        let diskCoordinates = flippedDiskCoordinatesByPlacingDisk(disk, atX: x, y: y)
        if diskCoordinates.isEmpty {
            throw DiskPlacementError(disk: disk, x: x, y: y)
        }
        self[x, y] = disk
        for (x, y) in diskCoordinates {
            self[x, y] = disk
        }
    }
    
    struct DiskPlacementError: Error {
        public let disk: Disk
        public let x: Int
        public let y: Int
        
        public init(disk: Disk, x: Int, y: Int) {
            self.disk = disk
            self.x = x
            self.y = y
        }
    }
}

// MARK: String representations

extension Board {
    init(_ board :String) {
        let lines = board.split(separator: "\n")
        let height = lines.count
        let width = lines.first?.count ?? 0
        
        var disks: [Disk?] = []
        for line in lines {
            precondition(line.count == width, "Illegal format: \(board)")
            for diskCharacter in line {
                switch diskCharacter {
                case "x":
                    disks.append(.dark)
                case "o":
                    disks.append(.light)
                case "-":
                    disks.append(nil)
                default:
                    preconditionFailure("Illegal character: \(diskCharacter)")
                }
            }
        }
        
        self.init(width: width, height: height, disks: disks)
    }
}

extension Board: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        var result: String = ""
        for y in yRange {
            if y > 0 {
                result.append("\n")
            }
            for x in xRange {
                result.append(self[x, y].symbol)
            }
        }
        return result
    }
    
    var debugDescription: String {
        description
    }
}

// MARK: Equatable

extension Board: Equatable {}
