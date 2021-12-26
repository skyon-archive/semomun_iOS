//
//  SettingUserView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/25.
//

import SwiftUI


struct SettingUserView: View {
    
    weak var delegate: ReloadUserData?
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var favoriteCategory: String
    @State private var major: String
    @State private var majorDetail: String
    @State private var schoolName: String
    @State private var graduationStatus: String
    
    @State private var showUnivSearch = false
    
    
    let categories = UserDefaults.standard.value(forKey: "categorys") as? [String] ?? ["예시 카테고리 1", "예시 카테고리 2", "예시 카테고리 3"]
    let majors = ["문과 계열", "이과 계열", "예체능 계열"]
    let majorDetails = ["공학", "자연", "의학", "생활과학", "기타"]
    let graduationStatuses = ["재학", "졸업"]
    
    init(delegate: ReloadUserData?) {
        self.delegate = delegate
        let userInfo = CoreUsecase.fetchUserInfo()
        self._favoriteCategory = State(initialValue: userInfo?.favoriteCategory ?? "수능 및 모의고사")
        self._major = State(initialValue: userInfo?.major ?? "문과 계열")
        self._majorDetail = State(initialValue: userInfo?.majorDetail ?? "공학")
        self._schoolName = State(initialValue: userInfo?.schoolName ?? "서울대학교")
        self._graduationStatus = State(initialValue: userInfo?.graduationStatus ?? "재학")
    }
    
    var body: some View {
        VStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.system(size: 25))
                    .foregroundColor(.gray)
            }
            Text(showUnivSearch ? "학교 찾기" : "세부정보 수정하기")
                .font(.system(size: 20, weight: .semibold))
                .padding(.bottom, 50)
                
            if showUnivSearch {
                VStack {
                    Button(action: {
                        withAnimation {
                            self.showUnivSearch = false
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                    }
                    .padding(.bottom, 20)
                    UnivFinderView(selected: $schoolName)
                        .onChange(of: schoolName) { _ in
                            withAnimation { showUnivSearch = false }
                        }
                }
            } else {
                VStack(spacing: 50) {
                    SettingUserRow(title: "관심문제", options: categories, selected: $favoriteCategory)
                    SettingUserRow(title: "계열", options: majors, selected: $major)
                    SettingUserRow(title: "전공", options: majorDetails, selected: $majorDetail)
                    HStack(spacing: 20) {
                        VStack(spacing: 20) {
                            Text("학교")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(action: {
                                withAnimation {
                                    showUnivSearch = true
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(hex: "#EEEEEE"))
                                        .frame(height: 50)
                                        .shadow(color: .gray.opacity(0.5), radius: 6, y: 4)
                                    Text(schoolName)
                                        .foregroundColor(.black)
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.trailing)
                                }
                            }
                        }
                        VStack(spacing: 20) {
                            Text("재학/졸업")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Menu {
                                ForEach(graduationStatuses, id: \.self) { status in
                                    Button(action: { self.graduationStatus = status}) {
                                        Text(status)
                                    }
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(hex: "#EEEEEE"))
                                        .frame(height: 50)
                                        .shadow(color: .gray.opacity(0.5), radius: 4, y: 4)
                                    Text(graduationStatus)
                                }
                            }
                            .accentColor(.black)
                        }
                        .frame(width: 180)
                        Button(action: {
                            let userInfo = CoreUsecase.fetchUserInfo()
                            userInfo?.favoriteCategory = self.favoriteCategory
                            userInfo?.schoolName = self.schoolName
                            userInfo?.major = self.major
                            userInfo?.majorDetail = self.majorDetail
                            userInfo?.graduationStatus = self.graduationStatus
                            CoreDataManager.saveCoreData()
                            delegate?.loadData()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 2)
                                    .background(Circle().foregroundColor(Color("mint")))
                                    .frame(width: 60, height: 60)
                                    .shadow(color: .gray.opacity(0.5), radius: 4, y: 4)
                                Text("저장")
                                    .foregroundColor(.white)
                            }
                            .padding([.top, .leading], 30)
                        }
                    }
                }
            }
            
        }
        .padding(.horizontal, 50)
        .padding(.vertical, 25)
        .padding(.bottom, 30)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(.white)
        )
        .onAppear {
            UIApplication.shared.addTapGestureRecognizer()
        }
    }
}

struct SettingUserRow: View {
    let title: String
    let options: [String]
    @Binding var selected: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        self.selected = option
                    }) {
                        Text(option)
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .foregroundColor(option == selected ? .white : .black)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.gray, lineWidth: 2)
                            .opacity(option == selected ? 0 : 1)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(option == selected ? Color("mint") : .clear)
                    )
                }
            }
        }
    }
}

struct SettingUserView_Previews: PreviewProvider {
    static var previews: some View {
        SettingUserView(delegate: nil)
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
