//
//  SubscriptionLongTextView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/09/06.
//

import SwiftUI

struct SubscriptionLongTextView: View {
    let text: String
    init(resource: LongTextVC.Resource) {
        guard let filepath = Bundle.main.path(forResource: resource.rawValue, ofType: "txt"),
              let text = try? String(contentsOfFile: filepath) else {
            self.text = ""
            return
        }
        self.text = text
    }
    var body: some View {
        ScrollView {
            Text(text)
                .font(Font(uiFont: .regularStyleParagraph))
                .padding(20)
        }
    }
}

struct SubscriptionLongTextView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionLongTextView(resource: .personalInformationProcessingPolicy)
    }
}
