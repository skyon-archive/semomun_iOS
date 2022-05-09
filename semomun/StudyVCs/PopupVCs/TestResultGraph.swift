//
//  TestResultGraph.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/09.
//

import SwiftUI

extension Path {
    /// 2개 이상의 점으로 이루어진 꺾은선 그래프의 Path를 반환
    /// - Parameters:
    ///   - points: 점들의 y값
    ///   - step: 격자 크기
    static func lineChart(points: [Double?], step: CGPoint) -> Path {
        var path = Path()
        
        for idx in 0..<points.count {
            guard let point = points[idx] else { continue }
            
            let y = step.y * CGFloat(10 - point)
            let p = CGPoint(x: step.x * CGFloat(idx), y: y)
            if idx == 0 {
                path.move(to: p)
            } else {
                path.addLine(to: p)
            }
        }
        
        return path
    }
    
    static func lineChartCircle(points: [Double?], step: CGPoint) -> Path {
        var path = Path()
        
        for idx in 0..<points.count {
            guard let point = points[idx] else { continue }
            
            let y = step.y * CGFloat(10 - point)
            let p = CGPoint(x: step.x * CGFloat(idx), y: y)
            
            var circle = Path()
            circle.addArc(center: p, radius: 5, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
            path.addPath(circle)
        }
        
        return path
    }
}

struct Line: View {
    let data: [Double?]
    let size: CGSize
    let lineColor: Color
    let circleColor: Color
    let strokeStyle: StrokeStyle
    // @Binding var frame: CGRect
    
    @State private var end = CGFloat.zero
    
    var stepWidth: CGFloat {
        return self.size.width / 20
    }
    
    var stepHeight: CGFloat {
        return self.size.height / 9
    }
    
    public var body: some View {
        
        Path.lineChart(points: self.data, step: CGPoint(x: stepWidth, y: stepHeight))
            .stroke(self.lineColor ,style: self.strokeStyle)
            .overlay(
                Path.lineChartCircle(points: self.data, step: CGPoint(x: stepWidth, y: stepHeight))
                    .fill(self.circleColor)
            )
            .rotationEffect(.degrees(180), anchor: .center)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}

struct LineView: View {
    let data: [Double?]
    let average: [Double]
    
    /// 그래프와 축간 간격
    let padding: CGFloat = 30
    /// y축 레이블 간격
    let yLabelPadding: CGFloat = 16
    
    let xLabelCount = 20
    let yLabelCount = 9
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack {
                    ForEach(1...yLabelCount, id: \.self) { grade in
                        Text("\(grade)등급")
                            .font(.system(size: 11, weight: .regular))
                            .frame(width: 40)
                            .frame(maxHeight: .infinity)
                    }
                }
                GeometryReader{ reader in
                    ZStack {
                        Line(data: self.average,
                             size: CGSize(width: reader.frame(in: .local).width , height: reader.frame(in: .local).height),
                             lineColor: Color(UIColor(SemomunColor.semoGray) ?? .gray),
                             circleColor: Color(UIColor(SemomunColor.yellowColor) ?? .black),
                             strokeStyle: .init(lineWidth: 1.5, dash: [5])
                        )
                        Line(data: self.data,
                             size: CGSize(
                                width: reader.frame(in: .local).width*CGFloat((1-1/self.xLabelCount)),
                                height: reader.frame(in: .local).height*CGFloat((1-1/self.yLabelCount))
                             ),
                             lineColor: Color(UIColor(SemomunColor.semoLightGray) ?? .gray),
                             circleColor: Color(UIColor(.mainColor) ?? .black),
                             strokeStyle: .init(lineWidth: 1.5)
                        )
                    }
                    .offset(
                        x: reader.frame(in: .local).width / CGFloat(self.xLabelCount*2),
                        y: reader.frame(in: .local).height / CGFloat(self.yLabelCount*2)
                    )
                }
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
            HStack {
                ForEach(1...xLabelCount, id: \.self) { grade in
                    Text("\(grade)회")
                        .font(.system(size: 11, weight: .regular))
                        .frame(height: 26)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.leading, 40)
        }
        
        .frame(height: 315)
        
    }
}

struct TestResultGraph: View {
    let result: [Double?] = [1, 3, 2, nil, nil, 5, nil, 9, 2].map { $0 == nil ? nil : Double($0!) }
    let average : [Double] = [3, 4, 3, 2, 5, 5, 3, 4, 5].map(Double.init)
    
    var body: some View {
        LineView(data: self.result, average: average)
    }
}

struct TestResultGraph_Previews: PreviewProvider {
    static var previews: some View {
        TestResultGraph()
    }
}
