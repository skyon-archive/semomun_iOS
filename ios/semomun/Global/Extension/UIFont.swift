//
//  UIFont.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/05.
//

import UIKit

extension UIFont {
    static let fontName: String = "PretendardVariable"
    static let boldFont: String = fontName+"-Bold"
    static let heading1 = UIFont(name: "PretendardVariable-Bold", size: 36) ?? .systemFont(ofSize: 36, weight: .bold)
    static let heading2 = UIFont(name: "PretendardVariable-Bold", size: 24) ?? .systemFont(ofSize: 24, weight: .bold)
    static let heading3 = UIFont(name: "PretendardVariable-Bold", size: 20) ?? .systemFont(ofSize: 20, weight: .bold)
    static let heading4 = UIFont(name: "PretendardVariable-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
    static let heading5 = UIFont(name: "PretendardVariable-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)
    
    static let largeStyleParagraph = UIFont(name: "PretendardVariable-Regular", size: 16) ?? .systemFont(ofSize: 16, weight: .regular)
    static let regularStyleParagraph = UIFont(name: "PretendardVariable-Regular", size: 14) ?? .systemFont(ofSize: 14, weight: .regular)
    static let smallStyleParagraph = UIFont(name: "PretendardVariable-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular)
}
