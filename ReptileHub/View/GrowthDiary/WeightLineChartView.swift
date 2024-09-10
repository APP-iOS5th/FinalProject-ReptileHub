//
//  weightLineChartView.swift
//  ReptileHub
//
//  Created by 이상민 on 9/3/24.
//

import SwiftUI
import Charts

struct WeightLineChartView: View {
    var weightData: [MonthWeightAverage]?
    var body: some View {
        if let weightData = weightData{
            GroupBox{
                Chart(weightData.sorted(by: { $0.month < $1.month}), id: \.self) { weight in
                    LineMark(x: .value("Month", "\(weight.month)월"),
                             y: .value("Weight", weight.averageWeight)
                    )
                    //                .interpolationMethod(.cardinal)
                    .foregroundStyle(Color.addBtnGraphTabbar)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    
                    PointMark(x: .value("Month", "\(weight.month)월"),
                              y: .value("Weight", weight.averageWeight)
                    )
                    .foregroundStyle(Color.addBtnGraphTabbar)
                    .symbolSize(12)
                    .annotation {
                        Text("\(weight.averageWeight)kg")
                            .font(.system(size: 10))
                            .foregroundColor(Color.addBtnGraphTabbar) // 글씨 색상 설정
                        
                    }
                }
                .background(Color.white)
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
                .padding(.bottom, 20)
                
            }//: GROUPBOX
            .background(Color.white)
        }else{
            Text("데이터가 존재하지 않습니다.")
        }
   
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
