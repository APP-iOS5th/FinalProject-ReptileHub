//
//  weightLineChartView.swift
//  ReptileHub
//
//  Created by 이상민 on 9/3/24.
//

import SwiftUI
import Charts

//struct GrowthDiaryResponse: Codable {
//    var lizardInfo: LizardInfoResponse
//    var parentInfo: ParentsResponse?
//}
//
//struct LizardInfoResponse: Codable {
//    var name: String
//    var species: String
//    var morph: String?
//    var hatchDays: Date
//    var imageURL: String?
//    var gender: String
//    var weight: Int
//    var feedMethod: String
//    var tailexistence: Bool
//}



//struct MonthlyHoursOfSunshine: Identifiable {
//    var date: Date
//    var hoursOfSunshine: Double
//    let id = UUID()
//
//
//    init(month: Int, hoursOfSunshine: Double) {
//        let calendar = Calendar.autoupdatingCurrent
//        self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
//        self.hoursOfSunshine = hoursOfSunshine
//    }
//}
//
//
//var data: [MonthlyHoursOfSunshine] = [
//    MonthlyHoursOfSunshine(month: 1, hoursOfSunshine: 74),
//    MonthlyHoursOfSunshine(month: 2, hoursOfSunshine: 99),
////    MonthlyHoursOfSunshine(month: 3, hoursOfSunshine: 98),
////    MonthlyHoursOfSunshine(month: 4, hoursOfSunshine: 91),
////    MonthlyHoursOfSunshine(month: 5, hoursOfSunshine: 93),
////    MonthlyHoursOfSunshine(month: 6, hoursOfSunshine: 92),
////    MonthlyHoursOfSunshine(month: 7, hoursOfSunshine: 97),
////    MonthlyHoursOfSunshine(month: 8, hoursOfSunshine: 69),
////    MonthlyHoursOfSunshine(month: 9, hoursOfSunshine: 86),
////    MonthlyHoursOfSunshine(month: 10, hoursOfSunshine: 83),
////    MonthlyHoursOfSunshine(month: 11, hoursOfSunshine: 90),
////    MonthlyHoursOfSunshine(month: 12, hoursOfSunshine: 62)
//]

struct weightLineChartView: View {
    var weightData: [LizardInfoResponse]
    
    var body: some View {
        GroupBox{
            Chart(weightData.sorted(by: {$0.hatchDays < $1.hatchDays})) { weight in
                // TODO: 생성날짜로 바꿔야함
                LineMark(x: .value("Month", formatDate(weight.hatchDays)),
                         y: .value("Weight", weight.weight)
                )
//                .interpolationMethod(.cardinal)
                .foregroundStyle(Color.addBtnGraphTabbar)
                .lineStyle(StrokeStyle(lineWidth: 1))
                
                PointMark(x: .value("Month", formatDate(weight.hatchDays)),
                          y: .value("Weight", weight.weight)
                )
                .foregroundStyle(Color.addBtnGraphTabbar)
                .symbolSize(12)
                .annotation {
                    Text("\(weight.weight)g")
                        .font(.system(size: 10))
                        .foregroundColor(Color.addBtnGraphTabbar) // 글씨 색상 설정

                }
            }
            .chartYAxis(.hidden)
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisValueLabel {
                                Text(value.as(String.self) ?? "-")
                                    .font(.system(size: 12)) // 글씨 크기 설정
                                    .foregroundColor(Color.textFieldPlaceholder) // 글씨 색상 설정
                                    .padding(.top)
                            }
                        }
                    }
            .chartPlotStyle(content: { plotArea in
                plotArea
                    .padding(.bottom)
                    .overlay(
                        Rectangle()
                            .frame(width: nil, height: 1, alignment: .top)
                            .foregroundColor(Color.textFieldLine), alignment: .bottom)
            })
        }
        .padding(.bottom, 20)
    }
    
    func formatDate(_ date: Date) -> String{
        let cal = Calendar.current
        let dateComponents = cal.dateComponents([.month], from: date)
        guard let month = dateComponents.month else{
            return "-"
        }
        
        return "\(month)월"
    }
}

#Preview {
    weightLineChartView( weightData: [
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: -1186400), gender: "남성", weight: 3, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: -3186400), gender: "남성", weight: 1, feedMethod: "자율", tailexistence: true),
//                LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: -5536400), gender: "남성", weight: 2, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: -7586400), gender: "남성", weight: 3, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: -9586400), gender: "남성", weight: 4, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: -11586400), gender: "남성", weight: 5, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays:Date(timeIntervalSinceNow: -13586400), gender: "남성", weight: 6, feedMethod: "자율", tailexistence: true),
//                LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: -15586400), gender: "남성", weight: 7, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: -17586400), gender: "남성", weight: 8, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: -20586400), gender: "남성", weight: 8, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(), gender: "남성", weight: 8, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: 3086400), gender: "남성", weight: 11, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: 5586400), gender: "남성", weight: 12, feedMethod: "자율", tailexistence: true),
        LizardInfoResponse(name: "이름", species: "종", hatchDays: Date(timeIntervalSinceNow: 8086400), gender: "남성", weight: 13, feedMethod: "자율", tailexistence: true),
    ])
}
