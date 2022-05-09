//
//  TestResultGraph.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/09.
//

import SwiftUI

extension View {
    /// View의 frame 주위로 x축과 y축 직선을 추가
    func xyAxis() -> some View {
        return self
            .overlay(
                Rectangle()
                    .frame(width: nil, height: 1, alignment: .bottom)
                    .foregroundColor(.black),
                alignment: .bottom
            )
            .overlay(
                Rectangle()
                    .frame(width: 1, height: nil, alignment: .leading)
                    .foregroundColor(.black),
                alignment: .leading
            )
    }
}

extension Path {
    /// 2개 이상의 점들을 이은 꺾은선 그래프의 Path를 반환
    /// - Parameters:
    ///   - yValue: 점들의 y값
    ///   - grid: 격자의 크기
    static func lineChart(yValue: [Double?], grid: CGSize) -> Path {
        var path = Path()
        
        for (idx, val) in yValue.enumerated() where val != nil {
            let p = CGPoint(x: grid.width * CGFloat(idx), y: grid.height * CGFloat(val!))
            if idx == 0 {
                path.move(to: p)
            } else {
                path.addLine(to: p)
            }
        }
        
        return path
    }
    
    static func lineChartCircle(yValue: [Double?], grid: CGSize) -> Path {
        var path = Path()
        
        for (idx, val) in yValue.enumerated() where val != nil {
            let p = CGPoint(x: grid.width * CGFloat(idx), y: grid.height * CGFloat(val!))
            var circle = Path()
            circle.addArc(center: p, radius: 5, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
            path.addPath(circle)
        }
        
        return path
    }
}

struct Line: View {
    let data: [Double?]
    
    let lineColor: Color
    let circleColor: Color
    let strokeStyle: StrokeStyle
    
    let gridSize: CGSize
    
    var body: some View {
        Path.lineChart(yValue: self.data, grid: self.gridSize) // 직선 차트
            .stroke(self.lineColor ,style: self.strokeStyle)
            .overlay(
                Path.lineChartCircle(yValue: self.data, grid: self.gridSize) // 차트 위 원
                    .fill(self.circleColor)
            )
            .rotationEffect(.degrees(180), anchor: .center)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}

struct GradeLineGraph: View {
    let xLabelCount = 20
    let yLabelCount = 9
    let yLabelWidth: CGFloat = 40
    
    let grades: [Double?]
    let average: [Double]
    
    // 등급이 낮아질수록 y값이 커지는 것 처리
    var gradeYVal: [Double?] {
        return self.grades.map { $0 == nil ? nil : 10-$0! }
    }
    var averageYVal: [Double] {
        return self.average.map { 10 - $0 }
    }
    
    var xAxisLabels: some View {
        HStack {
            ForEach(1...xLabelCount, id: \.self) { grade in
                Text("\(grade)회")
                    .font(.system(size: 11, weight: .regular))
                    .frame(height: 26)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.leading, self.yLabelWidth)
    }
    
    var yAxisLabels: some View {
        VStack {
            ForEach(1...yLabelCount, id: \.self) { grade in
                Text("\(grade)등급")
                    .font(.system(size: 11, weight: .regular))
                    .frame(width: self.yLabelWidth)
                    .frame(maxHeight: .infinity)
            }
        }
    }
    
    func getGridSize(frame: CGSize) -> CGSize {
        return CGSize(width: frame.width / CGFloat(self.xLabelCount), height: frame.height / CGFloat(self.yLabelCount))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                self.yAxisLabels
                GeometryReader{ reader in
                    ZStack {
                        Line(data: self.averageYVal,
                             lineColor: Color(UIColor(SemomunColor.semoGray) ?? .gray),
                             circleColor: Color(UIColor(SemomunColor.yellowColor) ?? .black),
                             strokeStyle: .init(lineWidth: 1.5, dash: [5]),
                             gridSize: self.getGridSize(frame: reader.size)
                        )
                        Line(data: self.gradeYVal,
                             lineColor: Color(UIColor(SemomunColor.semoLightGray) ?? .gray),
                             circleColor: Color(UIColor(.mainColor) ?? .black),
                             strokeStyle: .init(lineWidth: 1.5),
                             gridSize: self.getGridSize(frame: reader.size)
                        )
                    }
                    .offset(
                        x: reader.frame(in: .local).width / CGFloat(xLabelCount*2),
                        y: reader.frame(in: .local).height / CGFloat(yLabelCount*2)
                    )
                }
                .xyAxis()
            }
            self.xAxisLabels
        }
        .frame(height: 315)
    }
}

struct TestResultGraph: View {
    let result: [Double?] = [1, 3, 2, nil, nil, 5, nil, 9, 2].map { $0 == nil ? nil : Double($0!) }
    let average : [Double] = [3, 4, 3, 2, 5, 5, 3, 4, 5].map(Double.init)
    
    var body: some View {
        GradeLineGraph(grades: self.result, average: average)
    }
}

struct TestResultGraph_Previews: PreviewProvider {
    static var previews: some View {
        TestResultGraph()
    }
}
