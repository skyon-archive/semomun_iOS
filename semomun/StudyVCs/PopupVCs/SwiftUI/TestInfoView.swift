//
//  TestInfoView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/10.
//

import SwiftUI

// 임시용
struct TestInfo {
    let title: String
    let subTitle: String
}
// 임시용
protocol TestStartable: AnyObject {
    func startTest()
}

struct TestInfoView: View {
    @State private var startTest = false
    @State private var titleTopPadding: CGFloat = 117
    @State private var startButtonBottomPadding: CGFloat = 90
    @Environment(\.presentationMode) var presentationMode
    private weak var delegate: TestStartable?
    
    let info: TestInfo
    
    init(info: TestInfo, delegate: TestStartable) {
        self.info = info
        self.delegate = delegate
        if UIWindow.isLandscape {
            self._titleTopPadding = State(initialValue: 30)
            self._startButtonBottomPadding = State(initialValue: 30)
        }
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                self.TitleView
                HStack(alignment: .top) {
                    Spacer()
                    self.CloseButton
                }
            }
            Spacer()
            self.CenterBorderView
            Spacer()
            self.StartTestButton
        }
        .onRotate { newOrientation in
            self.titleTopPadding = newOrientation.isPortrait ? 117 : 30
            self.startButtonBottomPadding = newOrientation.isPortrait ? 90 : 30
        }
    }
}

// MARK: View
extension TestInfoView {
    var TitleView: some View {
        VStack {
            Text(self.info.title)
                .font(.system(size: 30, weight: .semibold))
                .padding(EdgeInsets(top: self.titleTopPadding, leading: 0, bottom: 5, trailing: 0))
            Text(self.info.subTitle)
                .font(.system(size: 50, weight: .bold))
        }
    }
    
    var CloseButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .resizable()
                .foregroundColor(.black)
                .frame(width: 26, height: 26)
        }
        .padding(40)
    }
    
    var CenterBorderView: some View {
        VStack {
            Text("시험 시 유의 사항")
                .font(.system(size: 25, weight: .bold))
                .padding(EdgeInsets(top: 41, leading: 0, bottom: 73, trailing: 0))
            HStack {
                self.WarningContentTextsView
                Spacer()
            }
        }
        .frame(width: 626)
        .border(.black, width: 1.5)
    }
    
    var WarningContentTextsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("○ 문제 풀이 중 ")+Text("중도포기시 재응시가 불가능").bold()+Text("합니다.")
            Text("○ 시험시간을 ")+Text("실제 수능 시간과 동일").bold()+Text("하게 제공됩니다.")
            Text("○ 시험시간이 종료되면 ")+Text("자동으로 채점").bold()+Text("됩니다.")
            Text("○ 모의고사 서비스의 답과 해설은 ")+Text("시험 종료 후 제공").bold()+Text("됩니다.")
            Text("○ 재응시가 불가능 하니 신중하게 응시해주세요.")
        }
        .font(.system(size: 20))
        .padding(.leading, 24)
        .padding(.bottom, 90)
    }
    
    var StartTestButton: some View {
        Button(action: {
            self.startTest = true
            self.delegate?.startTest()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("시험시작")
                .font(.system(size: 20, weight: .medium))
                .frame(width: 345, height: 54)
        }
        .foregroundColor(.white)
        .background(RoundedRectangle(cornerRadius: 5).fill(Color(SemomunColor.mainColor.rawValue)))
        .padding(.bottom, self.startButtonBottomPadding)
    }
}

struct TestInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let info = TestInfo(title: "2022년 1회차 고3 실전전 모의고사", subTitle: "사회탐구 영역 (윤리와 사상)")
        if #available(iOS 15.0, *) {
            TestInfoView(info: info, delegate: StudyVC())
        } else {
            // Fallback on earlier versions
        }
    }
}
