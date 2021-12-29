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
    @State private var selectedMajor: String
    @State private var selectedMajorDetail: String
    @State private var schoolName: String
    @State private var graduationStatus: String
    
    @State private var schoolType: SchoolSearchUseCase.SchoolType = .high
    @State private var showUnivSearch = false
    
    @State private var majorsWithMajorDetails: [String: [String]] = [:]
    @State private var majors: [String] = []
    
    var majorDetails: [String] {
        return majorsWithMajorDetails[selectedMajor] ?? []
    }
    
    let categories = UserDefaults.standard.value(forKey: "categorys") as? [String] ?? ["예시 카테고리 1", "예시 카테고리 2", "예시 카테고리 3"]
    let graduationStatuses = ["재학", "졸업"]
    private var userInfo: UserCoreData?
    
    init(delegate: ReloadUserData?) {
        self.delegate = delegate
        self.userInfo = CoreUsecase.fetchUserInfo()
        self._favoriteCategory = State(initialValue: self.userInfo?.favoriteCategory ?? "수능 및 모의고사")
        self._selectedMajor = State(initialValue: self.userInfo?.major ?? "문과 계열")
        self._selectedMajorDetail = State(initialValue: self.userInfo?.majorDetail ?? "공학")
        self._schoolName = State(initialValue: self.userInfo?.schoolName ?? "서울대학교")
        self._graduationStatus = State(initialValue: self.userInfo?.graduationStatus ?? "재학")
    }
    
    var body: some View {
        VStack {
            ZStack {
                if self.showUnivSearch {
                    Button(action: {
                        withAnimation {
                            self.showUnivSearch = false
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Text(showUnivSearch ? "\(schoolType.rawValue) 찾기" : "세부정보 수정하기")
                    .font(.system(size: 20, weight: .semibold))
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 15)
                
            if showUnivSearch {
                VStack {
                    UnivFinderView(selected: $schoolName, schoolType: schoolType)
                        .padding(.horizontal, 20)
                        .onChange(of: schoolName) { _ in
                            withAnimation { showUnivSearch = false }
                        }
                }
            } else {
                VStack(spacing: 50) {
                    SettingUserRow(title: "관심문제", options: categories, selected: $favoriteCategory)
                    SettingUserRow(title: "계열", options: majors, selected: $selectedMajor)
                    SettingUserRow(title: "전공", options: majorDetails, selected: $selectedMajorDetail)
                    HStack(spacing: 20) {
                        VStack(spacing: 20) {
                            Text("학교")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Menu {
                                ForEach(SchoolSearchUseCase.SchoolType.allCases, id: \.self) { schoolType in
                                    Button(action: {
                                        withAnimation {
                                            self.schoolType = schoolType
                                            showUnivSearch = true
                                        }
                                    }) {
                                        Text(schoolType.rawValue)
                                    }
                                }
                            } label: {
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
                            self.updateUserInfo()
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
        .padding(50)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(.white)
        )
        .onAppear {
            self.fetchMajors()
        }
    }
    
    private func fetchMajors() {
        NetworkUsecase.getMajors(completion: { downloaded in
            guard let downloaded = downloaded else {
                // TODO: Alert 창 띄우기 로직 구현
                print("전공 정보 다운로드 실패")
                return
            }
            self.majors = downloaded.compactMap { $0.keys.first }
            self.majorsWithMajorDetails = downloaded.reduce(into: [:]) { result, next in
                if let key = next.keys.first {
                    result[key] = next[key]
                }
            }
        })
    }
    
    private func updateUserInfo() {
        guard let userInfo = self.userInfo else { return }
        UserDefaults.standard.setValue(self.favoriteCategory, forKey: "currentCategory")
        userInfo.setValue(self.favoriteCategory, forKey: "favoriteCategory")
        userInfo.setValue(self.schoolName, forKey: "schoolName")
        userInfo.setValue(self.selectedMajor, forKey: "major")
        userInfo.setValue(self.selectedMajorDetail, forKey: "majorDetail")
        userInfo.setValue(self.graduationStatus, forKey: "graduationStatus")
        NetworkUsecase.postUserInfoUpdate(userInfo: userInfo) { status in
            guard let status = status else {
                //TODO: Alert 창 띄우기 로직 구현
                print("회원정보 업데이트 실패")
                return
            }
            if status {
                //TODO: Alert 창 띄우기 로직 구현
                CoreDataManager.saveCoreData()
                NotificationCenter.default.post(name: .updateCategory, object: nil)
                self.delegate?.loadData()
                self.presentationMode.wrappedValue.dismiss()
            } else {
                //TODO: Alert 창 띄우기 로직 구현
                print("회원정보 업데이트 실패")
                return
            }
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
