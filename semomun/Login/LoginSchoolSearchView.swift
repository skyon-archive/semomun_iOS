//
//  LoginSchoolSearchView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/27.
//

import SwiftUI

struct LoginSchoolSearchView: View {
    
    weak var delegate: SchoolSelectAction?
    
    let schoolType: SchoolSearchUseCase.SchoolType
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            ZStack {
                Text("\(schoolType.rawValue) 찾기")
                    .font(.system(size: 20, weight: .semibold))
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 15)
            UnivFinderView(selected: .constant(""), schoolType: schoolType, delegate: delegate)
                .padding(.horizontal, 20)
        }
        .padding(50)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(.white)
        )
    }
}

struct LoginSchoolSearchView_Preview: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                LoginSchoolSearchView(schoolType: .univ)
            }
    }
}
