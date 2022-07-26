//
//  TestInfoView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/10.
//

import SwiftUI

protocol TestStartable: AnyObject {
    func startTest()
    func dismiss()
}

struct TestInfoView: View {
    @State private var startTest = false
    @State private var titleTopPadding: CGFloat = 117
    @Environment(\.presentationMode) var presentationMode
    private weak var delegate: TestStartable?
    
    let info: TestInfo
    
    init(info: TestInfo, delegate: TestStartable) {
        self.info = info
        self.delegate = delegate
        if UIWindow.isLandscape {
            self._titleTopPadding = State(initialValue: 30)
        }
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                self.TitleView
                HStack(alignment: .top) {
                    self.CloseButton
                    Spacer()
                }
            }
            Spacer()
            self.CenterBorderView
            Spacer()
            self.StartTestButton
        }
        .onRotate { newOrientation in
            if newOrientation.isPortrait {
                self.titleTopPadding = 117
            } else if newOrientation.isLandscape {
                self.titleTopPadding = 30
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// MARK: View
extension TestInfoView {
    var TitleView: some View {
        VStack {
            Text(self.info.title)
                .font(.system(size: 30, weight: .semibold))
                .padding(EdgeInsets(top: self.titleTopPadding, leading: 0, bottom: 5, trailing: 0))
            Text("\(self.info.area) 영역(\(self.info.subject))")
                .font(.system(size: 50, weight: .bold))
        }
    }
    
    var CloseButton: some View {
        let image = UIImage(.chevronLeftOutline).withRenderingMode(.alwaysTemplate)
        return Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            self.delegate?.dismiss()
        }) {
            HStack(spacing: 2) {
                Image(uiImage: image)
                    .frame(width: 24, height: 24, alignment: .center)
                Text("뒤로")
                    .font(Font(uiFont: .heading5))
            }
        }
        .foregroundColor(Color(.getSemomunColor(.orangeRegular)))
        .padding(10)
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
            self.delegate?.startTest()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("시험 시작")
                .font(Font(uiFont: .heading3))
                .foregroundColor(Color(.getSemomunColor(.white)))
                .offset(x: 0, y: -4.5)
        }
        .foregroundColor(.white)
        .frame(height: 73)
        .frame(maxWidth: .infinity)
        .background(Rectangle().fill(Color(.getSemomunColor(.orangeRegular))))
    }
}

struct TestInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let info = TestInfo(title: "2022년 1회차 고3 실전 모의고사", area: "사회탐구", subject: "윤리와 사상")
        if #available(iOS 15.0, *) {
            TestInfoView(info: info, delegate: StudyVC())
//                .previewInterfaceOrientation(.landscapeLeft)
        } else {
            // Fallback on earlier versions
        }
    }
}
