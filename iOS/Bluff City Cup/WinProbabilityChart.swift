//
//  WinProbabilityChart.swift
//  Bluff City Cup
//
//  Shared types for win probability charts used in match cards and the scorecard.
//

import UIKit
import SwiftUI
import Charts

struct MatchPredictionData: Identifiable {
    let id = UUID()
    let team: String
    let probabilities: [PredictionPerHole]
}

struct PredictionPerHole {
    let hole: Int
    let probability: Double
}

struct ProbabilityChartView: View {
    var data: [MatchPredictionData]

    private let blueUIColor = UIColor(red: CGFloat((0x0F296B & 0xFF0000) >> 16) / 255,
                                      green: CGFloat((0x0F296B & 0x00FF00) >> 8)  / 255,
                                      blue:  CGFloat(0x0F296B & 0x0000FF)         / 255,
                                      alpha: 1)
    private let redUIColor  = UIColor(red: CGFloat((0xB70A1C & 0xFF0000) >> 16) / 255,
                                      green: CGFloat((0xB70A1C & 0x00FF00) >> 8)  / 255,
                                      blue:  CGFloat(0xB70A1C & 0x0000FF)         / 255,
                                      alpha: 1)

    var body: some View {
        let blueColor = Color(blueUIColor)
        let redColor  = Color(redUIColor)

        Chart {
            if let blueSeries = data.first(where: { $0.team == "Blue" }) {
                ForEach(blueSeries.probabilities, id: \.hole) { element in
                    LineMark(x: .value("Hole", element.hole),
                             y: .value("Win Probability", element.probability),
                             series: .value("Team", "Blue"))
                    .foregroundStyle(blueColor)
                    .interpolationMethod(.linear)
                    .symbol(Circle())
                    .offset(x: 9)
                }
            }
            if let redSeries = data.first(where: { $0.team == "Red" }) {
                ForEach(redSeries.probabilities, id: \.hole) { element in
                    LineMark(x: .value("Hole", element.hole),
                             y: .value("Win Probability", element.probability),
                             series: .value("Team", "Red"))
                    .foregroundStyle(redColor)
                    .interpolationMethod(.linear)
                    .symbol(Circle())
                    .offset(x: 9)
                }
            }
            if let tieSeries = data.first(where: { $0.team == "Tie" }) {
                ForEach(tieSeries.probabilities, id: \.hole) { element in
                    LineMark(x: .value("Hole", element.hole),
                             y: .value("Win Probability", element.probability),
                             series: .value("Team", "Tie"))
                    .foregroundStyle(Color.gray)
                    .interpolationMethod(.linear)
                    .symbol(Circle())
                    .offset(x: 9)
                }
            }
        }
        .chartLegend(.hidden)
        .chartXScale(domain: 1...19)
        .chartXAxis {
            AxisMarks(values: Array(1...19)) { value in
                AxisValueLabel { Text("\(value.index + 1)") }
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                if let intValue = value.as(Int.self) {
                    if intValue == 0 || intValue == 50 || intValue == 100 { AxisValueLabel() }
                    if intValue == 25 || intValue == 75 {
                        AxisGridLine(stroke: StrokeStyle(dash: [4, 4], dashPhase: 0.5))
                    } else {
                        AxisGridLine()
                    }
                }
            }
        }
        .chartYScale(domain: 0...100)
        .frame(height: 109)
        .padding()
        .clipped()
    }
}

struct ProbabilityChartRepresentable: UIViewControllerRepresentable {
    var data: [MatchPredictionData]

    func makeUIViewController(context: Context) -> UIViewController {
        UIHostingController(rootView: ProbabilityChartView(data: data))
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
