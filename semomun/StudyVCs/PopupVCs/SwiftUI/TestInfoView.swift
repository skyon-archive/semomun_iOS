//
//  TestInfoView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/10.
//

import SwiftUI
import MapKit

struct TestInfoView: View {
    @State private var startTest = false
    
    var body: some View {
        VStack {
            TitleView()
            Spacer()
            CenterBorderView()
            Spacer()
            StartTestButton()
        }
    }
    
    struct TitleView: View {
        var body: some View {
            VStack {
                Text("2022년 1회차 고3 실전 모의고사").font(.system(size: 30, weight: .semibold))
                    .padding(EdgeInsets(top: 117, leading: 0, bottom: 5, trailing: 0))
                Text("사회탐구 영역 (윤리와 사상)").font(.system(size: 50, weight: .bold))
            }
        }
    }
    
    struct CenterBorderView: View {
        var body: some View {
            VStack {
                Text("시험 시 유의 사항")
                    .font(.system(size: 25, weight: .bold))
                    .padding(EdgeInsets(top: 41, leading: 0, bottom: 73, trailing: 0))
                WarningContentTextsView()
            }
            .border(.black, width: 1.5)
            .frame(width: 626)
        }
    }
    
    struct WarningContentTextsView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("○ 문제 풀이 중 중도포기시 재응시가 불가능합니다.").font(.system(size: 20))
                Text("○ 시험시간을 실제 수능 시간과 동일하게 제공됩니다.").font(.system(size: 20))
                Text("○ 시험시간이 종료되면 자동으로 채점됩니다.").font(.system(size: 20))
                Text("○ 모의고사 서비스의 답과 해설은 시험 종료 후 제공됩니다.").font(.system(size: 20))
                Text("○ 재응시가 불가능 하니 신중하게 응시해주세요.").font(.system(size: 20))
            }
            .frame(width: 626)
            .padding(.horizontal, 24)
            .padding(.bottom, 90)
        }
    }
    
    struct StartTestButton: View {
        var body: some View {
            Button(action: {
                print("action")
            }) {
                Text("시험시작").font(.system(size: 20, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(width: 345, height: 54)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color(SemomunColor.mainColor.rawValue)))
            .padding(.bottom, 90)
        }
    }
}


struct TestInfoView_Previews: PreviewProvider {
    static var previews: some View {
        TestInfoView()
    }
}
