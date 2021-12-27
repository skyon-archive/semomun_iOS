//
//  UnivFinderView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/26.
//

import SwiftUI
import Alamofire

struct UnivRequester {
    
    enum SchoolType: String, CaseIterable {
        case elementary = "초등학교"
        case middle = "중학교"
        case high = "고등학교"
        case univ = "대학교"
        case special = "특수/기타 학교"
        case alter = "대안학교"
        var key: String {
            switch self {
            case .elementary: return "elem_list"
            case .middle: return "midd_list"
            case .high: return "high_list"
            case .univ: return "univ_list"
            case .special: return "seet_list"
            case .alter: return "alte_list"
            }
        }
    }
    
    static func request(type: SchoolType, completion: @escaping ([String]) -> Void) {
        guard let apiKey = Bundle.main.infoDictionary?["API_ACCESS_KEY1"] as? String else {
            completion([])
            return
        }
        let param = [
            "apiKey": apiKey,
            "svcType": "api",
            "svcCode": "SCHOOL",
            "contentType": "json",
            "gubun": type.key,
            "thisPage": "1",
            "perPage": "20000"
        ]
        Network.get(url: NetworkUsecase.URL.schoolApi, param: param) { data in
            guard let data = data else {
                completion([])
                return
            }
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(CareerNetJSON.self, from: data)
                let ret = json.dataSearch.content.map(\.schoolName)
                completion(Array(Set(ret)).sorted())
                print("학교 정보 다운로드 완료")
            } catch {
                completion([])
                print(error)
            }
        }
    }
    
    private struct CareerNetJSON: Codable {
        let dataSearch: DataSearch
    }

    private struct DataSearch: Codable {
        let content: [SchoolContent]
    }

    private struct SchoolContent: Codable {
        let schoolName: String
    }
}

struct UnivFinderView: View {
    @State private var search = ""
    @State private var filteredUnivList: [String] = []
    @Binding var selected: String
    @State private var univList: [String] = []
    
    let schoolType: UnivRequester.SchoolType
    
    weak var delegate: SchoolSelectAction?
    
    private func filterList() {
        filteredUnivList = univList.filter { $0.contains(search) }
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("\(schoolType.rawValue) 이름을 검색하세요", text: $search)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .padding(.trailing, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray.opacity(0.2))
            )
            .padding(.bottom)
            .onChange(of: search) { _ in
                filterList()
            }
            ScrollView {
                LazyVStack {
                    ForEach(filteredUnivList, id: \.self) { univ in
                        Button(action: {
                            self.selected = univ
                            delegate?.schoolSelected(univ)
                        }) {
                            Text(univ)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 3)
                        }
                        .accentColor(.black)
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 0.5)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxHeight: 500)
        }
        .padding()
        .onAppear(perform: {
            UnivRequester.request(type: schoolType, completion: { downloaded in
                self.univList = downloaded
                filterList()
            })
        })
    }
}

struct UnivFinderView_Previews: PreviewProvider {
    static var previews: some View {
        UnivFinderView(selected: .constant(""), schoolType: .middle)
    }
}

protocol SchoolSelectAction: AnyObject {
    func schoolSelected(_ univName: String)
}
