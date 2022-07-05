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
        VStack(spacing: 0) {
            Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: SemomunImage.xmark.rawValue.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(UIColor(.lightGray) ?? .gray))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 27)
            .padding(.top, 24)
            Text("\(schoolType.rawValue) 찾기")
                .font(.system(size: 18, weight: .medium))
                .padding(.top, 3)
                .padding(.bottom, 30)
            UnivFinderView(selected: .constant(""), schoolType: schoolType, delegate: delegate)
                .padding(.horizontal, 40)
        }
        .frame(width: 572, height: 643)
        .background(
            RoundedRectangle(cornerRadius: 10)
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
