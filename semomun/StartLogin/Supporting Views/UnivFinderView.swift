//
//  UnivFinderView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/26.
//

import SwiftUI
import Alamofire

struct UnivFinderView: View {
    @State private var search = ""
    @State private var filteredUnivList: [String] = []
    @Binding var selected: String
    @State private var univList: [String] = []
    
    let schoolType: SchoolSearchUseCase.SchoolType
    
    weak var delegate: SchoolSelectAction?
    
    private func filterList() {
        filteredUnivList = univList.filter { $0.contains(search) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .padding(.leading, 2)
                TextField("\(schoolType.rawValue) 이름을 검색하세요", text: $search)
                    .font(.system(size: 16, weight: .regular))
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 52)
            .onChange(of: search) { _ in
                filterList()
            }
            Divider()
                .frame(height: 2)
                .background(Color(UIColor(.mainColor) ?? .black))
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredUnivList, id: \.self) { univ in
                        Button(action: {
                            self.selected = univ
                            self.delegate?.schoolSelected(univ)
                        }) {
                            Text(univ)
                                .font(.system(size: 14, weight: .regular))
                                .frame(height: 40)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                        }
                        .accentColor(.black)
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 0.5)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 10)
            .frame(maxHeight: 500)
        }
        .onAppear {
            let network = Network()
            let networkUseCase = NetworkUsecase(network: network)
            let schoolSearchUseCase = SchoolSearchUseCase(networkUseCase: networkUseCase)
            schoolSearchUseCase.request(schoolKey: schoolType.key) { downloaded in
                self.univList = downloaded
                self.filterList()
            }
        }
    }
}

struct UnivFinderView_Previews: PreviewProvider {
    static var previews: some View {
        UnivFinderView(selected: .constant(""), schoolType: .univ)
    }
}

protocol SchoolSelectAction: AnyObject {
    func schoolSelected(_ univName: String)
}
