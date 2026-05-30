//
//  RecordsViewModel.swift
//  Bluff City Cup
//

import Foundation

private struct RecordsPlayerMatchDetail {
    let year: String
    let format: String
    let result: String
    let score: String
    let margin: Int
    let holesLeft: Int
    let opponents: [String]
}

final class RecordsViewModel {
    private let excludedPlayers: Set<String> = ["Michael Edwards", "Sam Moody", "Reid Wesson", "Tyler Blocker", "Ryan Burgett"]
    private(set) var payload: RecordsPayload?

    var rows: [RecordsMatchResult] {
        return payload?.rows ?? []
    }

    var years: [String] {
        return sortedUnique(rows.map { $0.year }, numeric: true, descending: true)
    }

    var formats: [String] {
        return sortedUnique(rows.map { $0.format }, numeric: false, descending: false)
    }

    var players: [String] {
        return sortedUnique(rows.flatMap { playersInRow($0) }, numeric: false, descending: false)
    }

    var loadedSummary: String {
        guard let payload = payload else { return "No records loaded" }
        return "\(payload.rows.count) match-side rows, \(payload.playerBios.count) bios, \(payload.playerPictures.count) photos"
    }

    func load(forceRefresh: Bool = false, completion: @escaping (Error?) -> Void) {
        RecordsAPIService.shared.fetchRecords(forceRefresh: forceRefresh) { [weak self] payload, error in
            if let payload = payload {
                self?.payload = payload
            }
            completion(error)
        }
    }

    func playersInRow(_ row: RecordsMatchResult) -> [String] {
        return rawPlayersInRow(row).filter { !excludedPlayers.contains($0) }
    }

    private func rawPlayersInRow(_ row: RecordsMatchResult) -> [String] {
        return [row.player1, row.player2, row.player3, row.player4]
            .map { $0.bccNormalized }
            .filter { !$0.isEmpty }
    }

    func playerLastName(_ name: String) -> String {
        let parts = name.bccNormalized.split(separator: " ").map(String.init)
        return parts.last ?? name.bccNormalized
    }

    func teamYearPointsRows() -> [String] {
        return yearlyPointTotals().map {
            "\($0.year): Red \(RecordsFormatters.points($0.red)), Blue \(RecordsFormatters.points($0.blue))\($0.location.isEmpty ? "" : " - \($0.location)")"
        }
    }

    func yearlyPointTotals() -> [RecordsYearPointTotal] {
        var totals: [String: (red: Double, blue: Double)] = [:]
        for row in rows {
            let year = row.year.bccNormalized
            var total = totals[year] ?? (0, 0)
            if row.team.bccNormalized == "Red" {
                total.red += points(row.points)
            } else if row.team.bccNormalized == "Blue" {
                total.blue += points(row.points)
            }
            totals[year] = total
        }

        var locationByYear: [String: String] = [:]
        for outcome in payload?.yearOutcomes ?? [] {
            locationByYear[outcome.year.bccNormalized] = outcome.location
        }

        return totals.keys.sorted().map { year in
            let total = totals[year] ?? (0, 0)
            return RecordsYearPointTotal(year: year, red: total.red, blue: total.blue, location: locationByYear[year] ?? "")
        }
    }

    func teamFormatRows(years selectedYears: Set<String>) -> [RecordsComparisonRow] {
        let filtered = baseFilter(rows, years: selectedYears)
        var byFormat: [String: (red: RecordsStats, blue: RecordsStats)] = [:]
        var overallRed = RecordsStats()
        var overallBlue = RecordsStats()

        for row in filtered {
            let format = row.format.bccNormalized.isEmpty ? "Unknown" : row.format.bccNormalized
            var bucket = byFormat[format] ?? (RecordsStats(), RecordsStats())
            if row.team.bccNormalized == "Red" {
                bucket.red.apply(outcome: row.winOrLoss, points: points(row.points))
                overallRed.apply(outcome: row.winOrLoss, points: points(row.points))
            } else if row.team.bccNormalized == "Blue" {
                bucket.blue.apply(outcome: row.winOrLoss, points: points(row.points))
                overallBlue.apply(outcome: row.winOrLoss, points: points(row.points))
            }
            byFormat[format] = bucket
        }

        let formatRows = byFormat.map { key, value in
            RecordsComparisonRow(label: key, red: value.red, blue: value.blue)
        }.sorted {
            let leftMatches = max($0.red.matches, $0.blue.matches)
            let rightMatches = max($1.red.matches, $1.blue.matches)
            if leftMatches != rightMatches { return leftMatches > rightMatches }
            return $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending
        }

        return [RecordsComparisonRow(label: "Overall", red: overallRed, blue: overallBlue)] + formatRows
    }

    func courseRows(years selectedYears: Set<String>) -> [RecordsComparisonRow] {
        let courseByMatch = matchCourseLookup()
        var byCourse: [String: (red: RecordsStats, blue: RecordsStats)] = [:]

        for row in baseFilter(rows, years: selectedYears) {
            let course = courseByMatch[matchKey(row.year, row.round, row.match)]?.course.bccNormalized ?? ""
            guard !course.isEmpty else { continue }
            var bucket = byCourse[course] ?? (RecordsStats(), RecordsStats())
            if row.team.bccNormalized == "Red" {
                bucket.red.apply(outcome: row.winOrLoss, points: points(row.points))
            } else if row.team.bccNormalized == "Blue" {
                bucket.blue.apply(outcome: row.winOrLoss, points: points(row.points))
            }
            byCourse[course] = bucket
        }

        return byCourse.map { key, value in
            RecordsComparisonRow(label: key, red: value.red, blue: value.blue)
        }.sorted {
            let leftMatches = max($0.red.matches, $0.blue.matches)
            let rightMatches = max($1.red.matches, $1.blue.matches)
            if leftMatches != rightMatches { return leftMatches > rightMatches }
            return $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending
        }
    }

    func playerRows(team: String, years selectedYears: Set<String>, formats selectedFormats: Set<String>, players selectedPlayers: Set<String>, minMatches: Int, sort: RecordsRankSort) -> [RecordsRankRow] {
        var map: [String: (player: String, team: String, stats: RecordsStats)] = [:]
        for row in baseFilter(rows, team: team, years: selectedYears, formats: selectedFormats) {
            for player in playersInRow(row) {
                if !selectedPlayers.isEmpty && !selectedPlayers.contains(player) { continue }
                let key = "\(player)|\(row.team.bccNormalized)"
                var item = map[key] ?? (player, row.team.bccNormalized, RecordsStats())
                item.stats.apply(outcome: row.winOrLoss, points: points(row.points))
                map[key] = item
            }
        }

        return rankedRows(map.values.map { value in
            RecordsRankRow(rank: 0, title: value.player, subtitle: value.stats.wlt, team: value.team, format: "", stats: value.stats)
        }, minMatches: minMatches, sort: sort)
    }

    func pairingRows(team: String, years selectedYears: Set<String>, formats selectedFormats: Set<String>, players selectedPlayers: Set<String>, minMatches: Int, includeFormat: Bool, sort: RecordsRankSort) -> [RecordsRankRow] {
        let twoManFormats: Set<String> = ["Best Ball", "Mod. Alt. Shot", "2-Man Scramble", "Shamble"]
        var map: [String: (pair: String, team: String, format: String, stats: RecordsStats)] = [:]

        for row in baseFilter(rows, team: team, years: selectedYears) {
            let format = row.format.bccNormalized
            if !twoManFormats.contains(format) { continue }
            if !selectedFormats.isEmpty && !selectedFormats.contains(format) { continue }

            let p1 = row.player1.bccNormalized
            let p2 = row.player2.bccNormalized
            if p1.isEmpty || p2.isEmpty { continue }
            if excludedPlayers.contains(p1) || excludedPlayers.contains(p2) { continue }
            if !selectedPlayers.isEmpty && !selectedPlayers.contains(p1) && !selectedPlayers.contains(p2) { continue }

            let pair = [p1, p2].sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }.joined(separator: " / ")
            let key = includeFormat ? "\(pair)|\(row.team.bccNormalized)|\(format)" : "\(pair)|\(row.team.bccNormalized)"
            var item = map[key] ?? (pair, row.team.bccNormalized, includeFormat ? format : "", RecordsStats())
            item.stats.apply(outcome: row.winOrLoss, points: points(row.points))
            map[key] = item
        }

        return rankedRows(map.values.map { value in
            RecordsRankRow(rank: 0, title: value.pair, subtitle: value.stats.wlt, team: value.team, format: value.format, stats: value.stats)
        }, minMatches: minMatches, sort: sort)
    }

    func singlesRows(team: String, minMatches: Int, sort: RecordsRankSort) -> [RecordsRankRow] {
        return playerRows(team: team, years: Set<String>(), formats: Set(["Singles"]), players: Set<String>(), minMatches: minMatches, sort: sort)
    }

    func matchOutcomeRows(team: String, years selectedYears: Set<String>, formats selectedFormats: Set<String>, player: String) -> [RecordsMatchOutcomeRow] {
        let grouped = groupedMatchSides(rows: baseFilter(rows, years: selectedYears, formats: selectedFormats))
        let courseByMatch = matchCourseLookup()
        let summaries = matchSummaryLookup()

        return grouped.values.compactMap { pair -> RecordsMatchOutcomeRow? in
            guard let red = pair.red, let blue = pair.blue else { return nil }
            let redPlayers = playersInRow(red)
            let bluePlayers = playersInRow(blue)
            let redResult = red.winOrLoss.bccNormalized.lowercased()
            let blueResult = blue.winOrLoss.bccNormalized.lowercased()
            let winner: String
            if redResult == "win" {
                winner = "Red"
            } else if blueResult == "win" {
                winner = "Blue"
            } else {
                winner = "Tie"
            }

            if player == "All" && team != "All" && winner != team { return nil }
            if player != "All" {
                let inRed = redPlayers.contains(player)
                let inBlue = bluePlayers.contains(player)
                if team == "Red" && !inRed { return nil }
                if team == "Blue" && !inBlue { return nil }
                if team == "All" && !inRed && !inBlue { return nil }
            }

            let key = matchKey(red.year, red.round, red.match)
            let course = courseByMatch[key]
            let summary = summaries[key]?.summary ?? ""
            return RecordsMatchOutcomeRow(year: red.year, round: red.round, match: red.match, format: red.format, redPlayers: redPlayers, bluePlayers: bluePlayers, winner: winner, score: red.score.isEmpty ? blue.score : red.score, course: course?.course ?? "", tees: course?.tees ?? "", summary: summary)
        }.sorted {
            if $0.year != $1.year { return Int($0.year) ?? 0 > Int($1.year) ?? 0 }
            if $0.round != $1.round { return Int($0.round) ?? 0 > Int($1.round) ?? 0 }
            return Int($0.match) ?? 0 > Int($1.match) ?? 0
        }
    }

    func headToHeadPlayerPools() -> (red: [RecordsPlayerPicture], blue: [RecordsPlayerPicture]) {
        guard let payload = payload else { return ([], []) }
        let playerKeysByTeam = playerNameKeysByTeam()

        let red = payload.playerPictures.filter { picture in
            picture.team.bccNormalized == "Red"
                && playerKeysByTeam["Red"]?[picture.key.lowercased()] != nil
                && !excludedPlayers.contains(displayName(for: picture))
        }.sorted { displayName(for: $0).localizedCaseInsensitiveCompare(displayName(for: $1)) == .orderedAscending }

        let blue = payload.playerPictures.filter { picture in
            picture.team.bccNormalized == "Blue"
                && playerKeysByTeam["Blue"]?[picture.key.lowercased()] != nil
                && !excludedPlayers.contains(displayName(for: picture))
        }.sorted { displayName(for: $0).localizedCaseInsensitiveCompare(displayName(for: $1)) == .orderedAscending }

        return (red, blue)
    }

    func displayName(for picture: RecordsPlayerPicture) -> String {
        let playerKeys = playerNameKeysByTeam()
        return playerKeys[picture.team.bccNormalized]?[picture.key.lowercased()] ?? "\(picture.first.capitalized) \(picture.last.capitalized)"
    }

    func pictureURL(for team: String, player: String) -> URL? {
        let key = playerNameKey(player)
        guard let picture = payload?.playerPictures.first(where: { $0.team.bccNormalized == team && $0.key.lowercased() == key }) else {
            return nil
        }
        return absolutePictureURL(picture)
    }

    func absolutePictureURL(_ picture: RecordsPlayerPicture) -> URL? {
        let cleaned = picture.url.replacingOccurrences(of: "./", with: "")
        return URL(string: "https://glizzyattheturn.app/bluffcitycup/" + cleaned)
    }

    func headToHeadMatches(redPlayer: String, bluePlayer: String) -> [RecordsHeadToHeadMatch] {
        let grouped = groupedMatchSides(rows: rows)
        return grouped.values.compactMap { pair -> RecordsHeadToHeadMatch? in
            guard let red = pair.red, let blue = pair.blue else { return nil }
            let redPlayers = playersInRow(red)
            let bluePlayers = playersInRow(blue)
            guard redPlayers.contains(redPlayer), bluePlayers.contains(bluePlayer) else { return nil }

            return RecordsHeadToHeadMatch(year: red.year, round: red.round, match: red.match, format: red.format, redPlayers: redPlayers, bluePlayers: bluePlayers, redResult: red.winOrLoss, blueResult: blue.winOrLoss, redPoints: points(red.points), bluePoints: points(blue.points), score: red.score.isEmpty ? blue.score : red.score)
        }.sorted {
            if $0.year != $1.year { return Int($0.year) ?? 0 < Int($1.year) ?? 0 }
            if $0.round != $1.round { return Int($0.round) ?? 0 < Int($1.round) ?? 0 }
            return Int($0.match) ?? 0 < Int($1.match) ?? 0
        }
    }

    func headToHeadSummary(matches: [RecordsHeadToHeadMatch]) -> [RecordsComparisonRow] {
        var redOverall = RecordsStats()
        var blueOverall = RecordsStats()
        var byFormat: [String: (red: RecordsStats, blue: RecordsStats)] = [:]

        for match in matches {
            redOverall.apply(outcome: match.redResult, points: match.redPoints)
            blueOverall.apply(outcome: match.blueResult, points: match.bluePoints)
            var bucket = byFormat[match.format] ?? (RecordsStats(), RecordsStats())
            bucket.red.apply(outcome: match.redResult, points: match.redPoints)
            bucket.blue.apply(outcome: match.blueResult, points: match.bluePoints)
            byFormat[match.format] = bucket
        }

        let rows = byFormat.map { key, value in
            RecordsComparisonRow(label: key, red: value.red, blue: value.blue)
        }.sorted {
            let leftMatches = max($0.red.matches, $0.blue.matches)
            let rightMatches = max($1.red.matches, $1.blue.matches)
            if leftMatches != rightMatches { return leftMatches > rightMatches }
            return $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending
        }

        return [RecordsComparisonRow(label: "Overall", red: redOverall, blue: blueOverall)] + rows
    }

    func playerProfile(name: String, team fallbackTeam: String) -> RecordsPlayerProfile {
        let playerRows = rows.filter { playersInRow($0).contains(name) }
        let team = playerRows.first?.team.bccNormalized ?? fallbackTeam
        let bio = payload?.playerBios.first(where: { $0.playerName.bccNormalized == name && ($0.team.bccNormalized == team || team.isEmpty) })?.bio
            ?? payload?.playerBios.first(where: { $0.playerName.bccNormalized == name })?.bio
            ?? ""

        var overall = RecordsStats()
        var byFormat: [String: RecordsStats] = [:]
        var byYear: [String: RecordsStats] = [:]
        for row in playerRows {
            let pts = points(row.points)
            overall.apply(outcome: row.winOrLoss, points: pts)

            var formatStats = byFormat[row.format.bccNormalized] ?? RecordsStats()
            formatStats.apply(outcome: row.winOrLoss, points: pts)
            byFormat[row.format.bccNormalized] = formatStats

            var yearStats = byYear[row.year.bccNormalized] ?? RecordsStats()
            yearStats.apply(outcome: row.winOrLoss, points: pts)
            byYear[row.year.bccNormalized] = yearStats
        }

        let formatRows = rankedRows(byFormat.map { key, stats in
            RecordsRankRow(rank: 0, title: key, subtitle: stats.wlt, team: team, format: key, stats: stats)
        }, minMatches: 0, sort: .matches)
        let yearRows = byYear.map { key, stats in
            RecordsRankRow(rank: 0, title: key, subtitle: stats.wlt, team: team, format: "", stats: stats)
        }.sorted { (Int($0.title) ?? 0) > (Int($1.title) ?? 0) }

        let recent = matchOutcomeRows(team: "All", years: Set<String>(), formats: Set<String>(), player: name).prefix(8).map { $0 }
        return RecordsPlayerProfile(name: name,
                                    team: team,
                                    bio: bio,
                                    photoURL: pictureURL(for: team, player: name),
                                    overall: overall,
                                    byFormat: formatRows,
                                    byYear: yearRows,
                                    recentMatches: Array(recent),
                                    personalRecords: personalRecords(name: name, team: team, byYear: yearRows, recentMatches: Array(recent)))
    }

    private func personalRecords(name: String, team: String, byYear: [RecordsRankRow], recentMatches: [RecordsMatchOutcomeRow]) -> [RecordsPersonalRecord] {
        let exactName = name.bccNormalized
        let pointsRecord = tiedYearPointRecords(byYear)

        let handicaps = playerHandicapRows(name: exactName, team: team)
        let lowestHandicap = handicapRecord(handicaps, lowest: true)
        let highestHandicap = handicapRecord(handicaps, lowest: false)

        let roundScores = playerRoundScores(name: exactName)
        let lowestRound = roundScoreRecord(roundScores, lowest: true)
        let highestRound = roundScoreRecord(roundScores, lowest: false)

        let matchDetails = playerMatchDetails(name: exactName)
        let margins = marginRecords(matches: matchDetails)
        let teammate = frequentPlayer(name: exactName, sameTeam: true)
        let opponent = frequentPlayer(name: exactName, sameTeam: false)

        return [
            RecordsPersonalRecord(title: "Most points in a tournament", value: pointsRecord),
            RecordsPersonalRecord(title: "Lowest handicap", value: lowestHandicap),
            RecordsPersonalRecord(title: "Highest handicap", value: highestHandicap),
            RecordsPersonalRecord(title: "Lowest individual round", value: lowestRound),
            RecordsPersonalRecord(title: "Highest individual round", value: highestRound),
            RecordsPersonalRecord(title: "Highest margin of victory", value: margins.victory),
            RecordsPersonalRecord(title: "Highest margin of defeat", value: margins.defeat),
            RecordsPersonalRecord(title: "Most frequent teammate", value: teammate),
            RecordsPersonalRecord(title: "Most frequent opponent", value: opponent)
        ]
    }

    private func tiedYearPointRecords(_ rows: [RecordsRankRow]) -> String {
        let rowsWithPoints = rows.filter { $0.stats.points.isFinite }
        guard let best = rowsWithPoints.map({ $0.stats.points }).max() else { return "-" }
        return rowsWithPoints
            .filter { abs($0.stats.points - best) <= 0.0001 }
            .sorted {
                let left = Int($0.title) ?? 0
                let right = Int($1.title) ?? 0
                return left > right
            }
            .map { "\(RecordsFormatters.points($0.stats.points)) points (\($0.title))" }
            .joined(separator: "\n")
    }

    private func playerHandicapRows(name: String, team: String) -> [RecordsPlayerHandicap] {
        let source = (payload?.playerHandicaps ?? []).filter { $0.name.bccNormalized == name }
        var byYear: [String: RecordsPlayerHandicap] = [:]
        for row in source {
            let year = row.year.bccNormalized
            guard !year.isEmpty else { continue }
            let current = byYear[year]
            let candidateMatchesTeam = !team.isEmpty && row.team.bccNormalized == team
            let currentMatchesTeam = !team.isEmpty && current?.team.bccNormalized == team
            if current == nil || (candidateMatchesTeam && !currentMatchesTeam) {
                byYear[year] = row
            }
        }
        return Array(byYear.values)
    }

    private func handicapRecord(_ rows: [RecordsPlayerHandicap], lowest: Bool) -> String {
        let pairs = rows.compactMap { row -> (Double, String)? in
            guard let value = Double(row.handicap.bccNormalized) else { return nil }
            return (value, row.year.bccNormalized)
        }
        guard let best = pairs.map({ $0.0 }).sorted(by: lowest ? (<) : (>)).first else { return "-" }
        return pairs
            .filter { abs($0.0 - best) <= 0.0001 }
            .sorted {
                let left = Int($0.1) ?? 0
                let right = Int($1.1) ?? 0
                return lowest ? left < right : left > right
            }
            .map { "\(String(format: "%.1f", $0.0)) (\($0.1))" }
            .joined(separator: "\n")
    }

    private func playerRoundScores(name: String) -> [(score: Int, year: String, course: String)] {
        let courseByMatch = matchCourseLookup()
        let eligibleIndividualRoundCourses = Set(rows
            .filter { playersInRow($0).contains(name) }
            .filter {
                let format = $0.format.bccNormalized
                let meta = courseByMatch[matchKey($0.year, $0.round, $0.match)]
                return (format == "Singles" || format == "Best Ball") && Int(meta?.matchlength.bccNormalized ?? "") == 18
            }
            .compactMap { row -> String? in
                guard let meta = courseByMatch[matchKey(row.year, row.round, row.match)] else { return nil }
                return "\(row.year.bccNormalized)|\(row.round.bccNormalized)|\(meta.course.bccNormalized)"
            })
        var grouped: [String: (score: Int, year: String, course: String, holes: Int)] = [:]
        for score in payload?.scores ?? [] where score.player.bccNormalized == name {
            guard let value = Int(score.actualscore.bccNormalized) else { continue }
            let key = "\(score.year.bccNormalized)|\(score.course.bccNormalized)|\(score.round.bccNormalized)"
            let roundCourseKey = "\(score.year.bccNormalized)|\(score.round.bccNormalized)|\(score.course.bccNormalized)"
            guard eligibleIndividualRoundCourses.contains(roundCourseKey) else { continue }
            var item = grouped[key] ?? (0, score.year.bccNormalized, score.course.bccNormalized, 0)
            item.score += value
            item.holes += 1
            grouped[key] = item
        }
        return grouped.values.filter { $0.holes == 18 }.map { ($0.score, $0.year, $0.course) }
    }

    private func roundScoreRecord(_ rows: [(score: Int, year: String, course: String)], lowest: Bool) -> String {
        guard let best = rows.map({ $0.score }).sorted(by: lowest ? (<) : (>)).first else { return "-" }
        return rows
            .filter { $0.score == best }
            .sorted {
                let left = Int($0.year) ?? 0
                let right = Int($1.year) ?? 0
                return lowest ? left < right : left > right
            }
            .map {
                let course = $0.course.isEmpty ? "" : " • \($0.course)"
                return "\($0.score)\(course) (\($0.year))"
            }
            .joined(separator: "\n")
    }

    private func marginRecords(matches: [RecordsPlayerMatchDetail]) -> (victory: String, defeat: String) {
        let wins = tiedMarginLeaders(matches.filter { $0.result.lowercased() == "win" && $0.margin > 0 })
        let losses = tiedMarginLeaders(matches.filter { $0.result.lowercased() == "loss" && $0.margin > 0 })
        return (formatMarginRecords(wins), formatMarginRecords(losses))
    }

    private func tiedMarginLeaders(_ matches: [RecordsPlayerMatchDetail]) -> [RecordsPlayerMatchDetail] {
        guard let maxMargin = matches.map({ $0.margin }).max() else { return [] }
        let marginTies = matches.filter { $0.margin == maxMargin }
        guard let bestFinish = marginTies.map({ $0.holesLeft }).max() else { return [] }
        return marginTies.filter { $0.holesLeft == bestFinish }.sorted {
            let leftYear = Int($0.year) ?? 0
            let rightYear = Int($1.year) ?? 0
            if leftYear != rightYear { return leftYear > rightYear }
            return $0.format.localizedCaseInsensitiveCompare($1.format) == .orderedAscending
        }
    }

    private func formatMarginRecords(_ matches: [RecordsPlayerMatchDetail]) -> String {
        if matches.isEmpty { return "-" }
        return matches.map { match in
            let opponents = match.opponents.map(playerLastName).joined(separator: " / ")
            let opponentText = opponents.isEmpty ? "Opponents" : opponents
            return "\(match.format) vs \(opponentText) • \(match.score) (\(match.year))"
        }.joined(separator: "\n")
    }

    private func scoreMargin(_ score: String) -> Int {
        let normalized = score.bccNormalized.lowercased()
        if normalized.isEmpty || normalized == "as" || normalized == "a/s" { return 0 }
        if normalized.contains("&") {
            return Int(normalized.components(separatedBy: "&").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") ?? 0
        }
        if normalized.contains("up") {
            return Int(normalized.components(separatedBy: " ").first ?? "") ?? 0
        }
        return 0
    }

    private func scoreHolesLeft(_ score: String) -> Int {
        let normalized = score.bccNormalized.lowercased()
        if normalized.isEmpty || normalized == "as" || normalized == "a/s" { return 0 }
        if normalized.contains("&") {
            return Int(normalized.components(separatedBy: "&").dropFirst().first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") ?? 0
        }
        return 0
    }

    private func frequentPlayer(name: String, sameTeam: Bool) -> String {
        var statsByPlayer: [String: RecordsStats] = [:]
        for row in rows where playersInRow(row).contains(name) {
            let key = matchKey(row.year, row.round, row.match)
            let opponents = rows.filter { matchKey($0.year, $0.round, $0.match) == key && $0.team.bccNormalized != row.team.bccNormalized }
            let source = sameTeam ? [row] : opponents
            for candidate in source.flatMap({ playersInRow($0) }) where candidate != name {
                var stats = statsByPlayer[candidate] ?? RecordsStats()
                stats.apply(outcome: row.winOrLoss, points: points(row.points))
                statsByPlayer[candidate] = stats
            }
        }
        guard let maxMatches = statsByPlayer.values.map({ $0.matches }).max() else { return "-" }
        return statsByPlayer
            .map { (name: $0.key, stats: $0.value) }
            .filter { $0.stats.matches == maxMatches }
            .sorted {
                if $0.stats.points != $1.stats.points { return $0.stats.points > $1.stats.points }
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            .map { "\($0.name) • \($0.stats.matches) matches, \($0.stats.wlt)" }
            .joined(separator: "\n")
    }

    private func playerMatchDetails(name: String) -> [RecordsPlayerMatchDetail] {
        let grouped = groupedMatchSides(rows: rows)
        return rows.filter { playersInRow($0).contains(name) }.map { row in
            let opponentTeam = row.team.bccNormalized == "Red" ? "Blue" : "Red"
            let pair = grouped[matchKey(row.year, row.round, row.match)]
            let opponentRow = opponentTeam == "Red" ? pair?.red : pair?.blue
            return RecordsPlayerMatchDetail(year: row.year.bccNormalized,
                                            format: row.format.bccNormalized.isEmpty ? "Unknown" : row.format.bccNormalized,
                                            result: row.winOrLoss.bccNormalized,
                                            score: row.score.bccNormalized,
                                            margin: scoreMargin(row.score),
                                            holesLeft: scoreHolesLeft(row.score),
                                            opponents: opponentRow.map(playersInRow) ?? [])
        }
    }

    private func baseFilter(_ source: [RecordsMatchResult], team: String = "All", years: Set<String> = Set<String>(), formats: Set<String> = Set<String>()) -> [RecordsMatchResult] {
        return source.filter { row in
            if team != "All" && row.team.bccNormalized != team { return false }
            if !years.isEmpty && !years.contains(row.year.bccNormalized) { return false }
            if !formats.isEmpty && !formats.contains(row.format.bccNormalized) { return false }
            return true
        }
    }

    private func rankedRows(_ rows: [RecordsRankRow], minMatches: Int, sort: RecordsRankSort) -> [RecordsRankRow] {
        return rows.sorted {
            switch sort {
            case .winPercent:
                if $0.stats.winPctValue != $1.stats.winPctValue { return $0.stats.winPctValue > $1.stats.winPctValue }
                if $0.stats.points != $1.stats.points { return $0.stats.points > $1.stats.points }
                if $0.stats.matches != $1.stats.matches { return $0.stats.matches > $1.stats.matches }
            case .points:
                if $0.stats.points != $1.stats.points { return $0.stats.points > $1.stats.points }
                if $0.stats.winPctValue != $1.stats.winPctValue { return $0.stats.winPctValue > $1.stats.winPctValue }
                if $0.stats.matches != $1.stats.matches { return $0.stats.matches > $1.stats.matches }
            case .matches:
                if $0.stats.matches != $1.stats.matches { return $0.stats.matches > $1.stats.matches }
                if $0.stats.winPctValue != $1.stats.winPctValue { return $0.stats.winPctValue > $1.stats.winPctValue }
                if $0.stats.points != $1.stats.points { return $0.stats.points > $1.stats.points }
            case .name:
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
            return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }.filter { $0.stats.matches >= minMatches }
            .enumerated()
            .map { index, row in
                RecordsRankRow(rank: index + 1, title: row.title, subtitle: row.subtitle, team: row.team, format: row.format, stats: row.stats)
            }
    }

    private func groupedMatchSides(rows source: [RecordsMatchResult]) -> [String: (red: RecordsMatchResult?, blue: RecordsMatchResult?)] {
        var grouped: [String: (red: RecordsMatchResult?, blue: RecordsMatchResult?)] = [:]
        for row in source {
            let key = matchKey(row.year, row.round, row.match)
            var pair = grouped[key] ?? (nil, nil)
            if row.team.bccNormalized == "Red" {
                pair.red = row
            } else if row.team.bccNormalized == "Blue" {
                pair.blue = row
            }
            grouped[key] = pair
        }
        return grouped
    }

    private func matchCourseLookup() -> [String: RecordsMatchCourse] {
        var map: [String: RecordsMatchCourse] = [:]
        for course in payload?.matchCourses ?? [] {
            map[matchKey(course.year, course.round, course.match)] = course
        }
        return map
    }

    private func matchSummaryLookup() -> [String: RecordsMatchSummary] {
        var map: [String: RecordsMatchSummary] = [:]
        for summary in payload?.matchSummaries ?? [] {
            map[matchKey(summary.year, summary.round, summary.match)] = summary
        }
        return map
    }

    private func matchKey(_ year: String, _ round: String, _ match: String) -> String {
        return "\(year.bccNormalized)|\(round.bccNormalized)|\(match.bccNormalized)"
    }

    private func playerNameKey(_ name: String) -> String {
        let parts = name.bccNormalized.lowercased().split(separator: " ").map(String.init)
        guard let first = parts.first, let last = parts.last, parts.count >= 2 else { return "" }
        return "\(first)_\(last)"
    }

    private func playerNameKeysByTeam() -> [String: [String: String]] {
        var result: [String: [String: String]] = ["Red": [:], "Blue": [:]]
        for row in rows {
            let team = row.team.bccNormalized
            if result[team] == nil { continue }
            for player in playersInRow(row) {
                let key = playerNameKey(player)
                if !key.isEmpty {
                    result[team]?[key] = player
                }
            }
        }
        return result
    }

    private func sortedUnique(_ values: [String], numeric: Bool, descending: Bool) -> [String] {
        let set = Set(values.map { $0.bccNormalized }.filter { !$0.isEmpty })
        return Array(set).sorted {
            if numeric {
                let left = Int($0) ?? 0
                let right = Int($1) ?? 0
                return descending ? left > right : left < right
            }
            let result = $0.localizedCaseInsensitiveCompare($1)
            return descending ? result == .orderedDescending : result == .orderedAscending
        }
    }

    private func points(_ value: String) -> Double {
        return Double(value.bccNormalized) ?? 0
    }
}
