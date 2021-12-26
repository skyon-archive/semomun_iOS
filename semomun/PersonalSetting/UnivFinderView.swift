//
//  UnivFinderView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/26.
//

import SwiftUI
import Alamofire

struct UnivRequester {
    static let link =  "https://www.career.go.kr/cnet/openapi/getOpenApi?apiKey=5432f1390b6511279c38c81aa2e0d364&svcType=api&svcCode=SCHOOL&contentType=json&gubun=univ_list&thisPage=1&perPage=10000&searchSchulNm="
    static func request(completion: @escaping ([String]) -> Void) {
        guard let urlString = link.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            completion([])
            return
        }
        AF.request(urlString).responseJSON { response in
            let decoder = JSONDecoder()
            guard let data = response.data else {
                completion([])
                return
            }
            do {
                let json = try decoder.decode(CareerNetJSON.self, from: data)
                let ret = json.dataSearch.content.map(\.schoolName)
                completion(Array(Set(ret)).sorted())
                print("대학 정보 다운로드 완료")
                return
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct FinderWithMagnifyingglass: View {
    @Binding var search: String
    var body: some View {
        HStack {
            TextField("대학 이름을 검색하세요", text: $search)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
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
    }
}

struct UnivFinderView: View {
    @State private var search = ""
    @State private var filteredUnivList: [String] = []
    @Binding var selected: String
    @State private var univList: [String] = []
    
    private func filterList() {
        filteredUnivList = univList.filter { search == "" || $0.contains(search) }
    }
    
    var body: some View {
        VStack {
            FinderWithMagnifyingglass(search: $search)
                .onChange(of: search) { _ in
                    filterList()
                }
            ScrollView {
                LazyVStack {
                    ForEach(filteredUnivList, id: \.self) { univ in
                        Button(action: { self.selected = univ }) {
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
            UIApplication.shared.addTapGestureRecognizer()
            UnivRequester.request(completion: { downloaded in
                self.univList = downloaded
                filterList()
            })
        })
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}

struct CareerNetJSON: Codable {
    let dataSearch: DataSearch
}

struct DataSearch: Codable {
    let content: [UnivContent]
}

struct UnivContent: Codable {
    let campusName: String
    let collegeinfourl: String
    let schoolType: String
    let link: String
    let schoolGubun: String
    let adres: String
    let schoolName: String
    let region: String
    let totalCount: String
    let estType: String
    let seq: String
}

struct UnivFinderView_Previews: PreviewProvider {
    static var previews: some View {
        UnivFinderView(selected: .constant(""))
    }
}
