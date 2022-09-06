//
//  SubscriptionVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/09/06.
//

import SwiftUI
import SwiftyStoreKit

fileprivate enum ActiveSheet: Identifiable {
    case personalInfo
    case terms
    var id: Int { hashValue }
}

fileprivate enum SubscriptionAlert: Identifiable {
    case restoreSuccess
    case restoreFailed
    case subscriptionFailed
    var id: Int { hashValue }
}

struct SubscriptionView: View {
    @State private var resource: ActiveSheet?
    @State private var animation: CGFloat = 0
    @State private var alert: SubscriptionAlert?
    @State private var loading = false
    @Environment(\.presentationMode) var presentationMode
    
    let subjects = ["대학수학능력시험", "9급 지방직 공무원", "초등교사임용시험", "중등교사임용시험", "소방공무원", "초중고 검정고시", "수능특강", "변리사 국가자격시험", "우정서기보 공무원", "PSAT", "LEET", "..."]
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .padding(.top, 20)
                    Text("세모문 구독 시작하기")
                        .font(Font(uiFont: .heading1))
                        .foregroundColor(Color(UIColor.getSemomunColor(.black)))
                        .padding(.bottom, 15)
                    Text("모든 문제집을 무제한으로 다운로드해보세요.\n무료 요금제는 최대 3권까지 다운로드가 가능합니다.")
                        .font(Font(uiFont: .largeStyleParagraph))
                        .foregroundColor(Color(UIColor.getSemomunColor(.darkGray)))
                        .padding(.bottom, 80)
                    FlowLayout(mode: .vstack, items: subjects) { text in
                        Text(text)
                            .font(Font(uiFont: .largeStyleParagraph))
                            .foregroundColor(Color(UIColor.getSemomunColor(.darkGray)))
                            .padding(12)
                            .background(Color(UIColor.getSemomunColor(.border)))
                            .cornerRadius(.cornerRadius16)
                    }
                    .frame(height: 300, alignment: .top)
                    Button(action: restore) {
                        Text("구매 복원")
                            .font(Font(uiFont: .heading4))
                            .foregroundColor(Color(UIColor.getSemomunColor(.lightGray)))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    Button(action: purchase) {
                        Text("정기 구독 시작하기 (월 7800원)")
                            .font(Font(uiFont: .heading3))
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .background(Color(UIColor.getSemomunColor(.orangeRegular)))
                    .cornerRadius(.cornerRadius12)
                    .padding(.bottom, 20)
                    VStack(alignment: .leading) {
                        Text("결제를 설정하고 iTunes로 구독하는 즉시 서비스를 이용할 수 있습니다. 세모문의 1개월 구독료는 8900원이며 결제를 확인하면 Apple ID 계정으로 청구됩니다. 결제 주기가 끝나기 24시간 전에 자동 갱신을 중지하지 않는 한 구독이 자동으로 갱신됩니다. 사용자는 계정 설정에서 구독을 관리하거나 자동 갱신을 사용 중지할 수 있습니다.")
                            .font(Font(uiFont: .smallStyleParagraph))
                            .foregroundColor(Color(UIColor.getSemomunColor(.lightGray)))
                            .padding(.bottom, 10)
                        Text("계속 진행하면 관련 약관에 동의하는 것으로 간주됩니다.")
                            .font(Font(uiFont: .smallStyleParagraph))
                            .foregroundColor(Color(UIColor.getSemomunColor(.lightGray)))
                        HStack {
                            Text("개인정보 처리 방침")
                                .font(Font(uiFont: .smallStyleParagraph))
                                .foregroundColor(Color(UIColor.getSemomunColor(.lightGray)))
                                .underline()
                                .onTapGesture {
                                    self.resource = .personalInfo
                                }
                            Text("이용 약관")
                                .font(Font(uiFont: .smallStyleParagraph))
                                .foregroundColor(Color(UIColor.getSemomunColor(.lightGray)))
                                .underline()
                                .onTapGesture {
                                    self.resource = .terms
                                }
                        }
                    }
                }
            }
            .padding(40)
            .sheet(item: $resource, onDismiss: nil) { resource in
                SubscriptionLongTextView(resource: resource == .personalInfo ? .personalInformationProcessingPolicy : .termsAndConditions)
            }
            .alert(item: $alert) { alert in
                switch alert {
                case .restoreSuccess:
                    return Alert(title: .init("구매 내역 복원 완료"), dismissButton: .default(.init("확인"), action: { presentationMode.wrappedValue.dismiss() }))
                case .restoreFailed:
                    return Alert(title: .init("구매 내역 복원 실패"), dismissButton: .default(.init("확인"), action: { presentationMode.wrappedValue.dismiss() }))
                case .subscriptionFailed:
                    return Alert(title: .init("구독 실패"), dismissButton: .default(.init("확인"), action: { presentationMode.wrappedValue.dismiss() }))
                }
            }
            if loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.getSemomunColor(.background)).opacity(0.5))
            }
        }
    }
    
    private func purchase() {
        loading = true
        SwiftyStoreKit.purchaseProduct("com.skyon.semomun.monthlysubscription", atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                presentationMode.wrappedValue.dismiss()
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
                self.alert = .subscriptionFailed
            case .deferred(purchase: let purchase):
                print("Deferred: \(purchase)")
                self.alert = .subscriptionFailed
            }
            loading = false
            NotificationCenter.default.post(name: .updateSubscription, object: nil)
        }
    }
    
    private func restore() {
        loading = true
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                self.alert = .restoreFailed
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                self.alert = .restoreSuccess
            } else {
                print("Nothing to Restore")
                self.alert = .restoreSuccess
            }
            loading = false
            NotificationCenter.default.post(name: .updateSubscription, object: nil)
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
        Text("test")
            .sheet(isPresented: .constant(true)) {
                SubscriptionView()
            }
    }
}

