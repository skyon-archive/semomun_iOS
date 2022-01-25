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
            let network = Network()
            let networkUseCase = NetworkUsecase(network: network)
            let schoolSearchUseCase = SchoolSearchUseCase(networkUseCase: networkUseCase)
            schoolSearchUseCase.request(schoolKey: schoolType.key, completion: { downloaded in
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
