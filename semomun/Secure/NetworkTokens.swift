//
//  NetworkTokens.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/03.
//

import Foundation

struct NetworkTokens: Decodable, Equatable {
    let accessToken: String
    let refreshToken: String

    init?() {
        let accessTokenKeyChain = KeychainItem(account: .accessToken)
        let refreshTokenKeyChain = KeychainItem(account: .refreshToken)
        do {
            self.accessToken = try accessTokenKeyChain.readItem()
            self.refreshToken = try refreshTokenKeyChain.readItem()
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func save() throws {
        let accessTokenKeyChain = KeychainItem(account: .accessToken)
        let refreshTokenKeyChain = KeychainItem(account: .refreshToken)
        try accessTokenKeyChain.saveItem(self.accessToken)
        try refreshTokenKeyChain.saveItem(self.refreshToken)
    }
}
