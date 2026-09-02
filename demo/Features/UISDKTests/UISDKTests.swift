//
//  UISDKTests.swift
//  bex-fullsdk-demo
//

import Foundation
import SwiftUI
@_spi(Internals) import BKMExpressSDK

enum UISDKTests {
  struct StartContext: Hashable {
    let theme: Theme
    let presentationKind: PresentationKind
  }
  
  enum Theme: CaseIterable {
    case `default`
    
    fileprivate var name: String {
      switch self {
        case .default: "Varsayılan"
      }
    }
    
    fileprivate var bkmExpressTheme: BKMExpress.Theme {
      switch self {
        case .default:
          return .init()
      }
    }
  }
  
  enum PresentationKind: CaseIterable {
    case sheet
    case fullScreen
    
    fileprivate var name: String {
      switch self {
        case .sheet: "Bottom Sheet"
        case .fullScreen: "Tam Ekran"
      }
    }
  }
  
  enum TransactionKind: String, CaseIterable {
    case payment = "transaction_payment"
    case pairing = "transaction_pairing"
    
    var name: String {
      switch self {
        case .payment: "Ödeme"
        case .pairing: "Kart Eşleştirme"
      }
    }
    
    var buttonTitle: String {
      switch self {
        case .payment: "Ödeme Yap"
        case .pairing: "Kart Eşleştir"
      }
    }
  }
  
  enum PaymentSecurityKind: String, CaseIterable {
    case tds = "3DS"
    case otp = "OTP"
    case none = "Yok"
    
    var bexPaymentSecurity: BKMExpress.PaymentSecurity {
      switch self {
        case .tds: .tds
        case .otp: .otp
        case .none: .none
      }
    }
  }
  
  public enum TransactionTypeKind: String, Sendable, CaseIterable {
    case sale = "Satış"
    case preAuth = "Ön Provizyon"
    case recurring = "Tekrarlayan"
    
    var bexTransactionType: BKMExpress.TransactionType {
      switch self {
        case .sale: .sale
        case .preAuth: .preAuth
        case .recurring: .recurring
      }
    }
  }
  
  struct Screen: View {
      // MARK: State
    @State var theme: Theme = .default
    @AppStorage("merchantID") var merchantID = ""
    @AppStorage("merchantUserID") var merchantUserID = ""
    @AppStorage("phoneNumber") var phoneNumber = ""
    @AppStorage("authToken") var token = ""
    @AppStorage("mode") var mode: Mode = .default
    @AppStorage("amount") var amount: Double?
    @AppStorage("orderID") var orderId = ""
    @State var presentationKind: PresentationKind = .fullScreen
    @AppStorage("transactionKind") var transactionKind: TransactionKind = .pairing
    @State var presentation: BKMExpressPresentation?
    @AppStorage("currency") var currency = "TRY"
    @AppStorage("installmentCount") var installmentCount: Int = 1
    @AppStorage("paymentSecurity") var security: PaymentSecurityKind = .none
    @AppStorage("transactionType") var transactionType: TransactionTypeKind = .sale
    @AppStorage("success_url") var successUrl: String = ""
    @AppStorage("error_url") var failUrl: String = ""
    @State var alert: AlertState?
    @State var selectedCardInfo: (String, String)?
    @State var initInProgress = false
    
    @State var numberFormatter: NumberFormatter = {
      var nf = NumberFormatter()
      nf.numberStyle = .decimal
      nf.maximumFractionDigits = 2
      nf.minimumFractionDigits = 2
      return nf
    }()
    @State var integerFormatter: NumberFormatter = {
      var nf = NumberFormatter()
      nf.numberStyle = .none
      nf.maximumFractionDigits = 0
      nf.minimumFractionDigits = 0
      return nf
    }()
    
      // MARK: UI
    var body: some View {
      VStack {
        Text("Uygulama şu an '\(mode.name)' modundadır.")
        
        if let selectedCardInfo {
          Text("Seçili Kart: \n\(selectedCardInfo.0) - \(selectedCardInfo.1)")
            .frame(maxWidth: .infinity)
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.3))
            )
        }
        
        ScrollView {
          VStack(alignment: .leading) {
            Text("Token")
              .bold()
            
            TextField("", text: $token, axis: .vertical)
              .lineLimit(5)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Merchant ID")
              .bold()
            
            TextField("", text: $merchantID)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Merchant User ID")
              .bold()
            
            TextField("", text: $merchantUserID)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Order ID")
              .bold()
            
            TextField("", text: $orderId)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Telefon Numarası")
              .bold()
            
            TextField("", text: $phoneNumber)
              .keyboardType(.decimalPad)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Tutar")
              .bold()
            
            TextField("", value: $amount, formatter: numberFormatter)
              .keyboardType(.numbersAndPunctuation)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Para Birimi")
              .bold()
            
            TextField("", text: $currency)
              .keyboardType(.alphabet)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Taksit Sayısı")
              .bold()
            
            TextField("", value: $installmentCount, formatter: integerFormatter)
              .keyboardType(.decimalPad)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          HStack {
            Text("İşlem Türü")
              .bold()
            
            Spacer()
            
            Picker("İşlem Türü", selection: $transactionType) {
              ForEach(TransactionTypeKind.allCases, id: \.self) { kind in
                Text(kind.rawValue).tag(kind)
              }
            }
          }.padding(.bottom, 16)
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Success Url")
              .bold()
            
            TextField("", text: $successUrl)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Error Url")
              .bold()
            
            TextField("", text: $failUrl)
              .textFieldStyle(.roundedBorder)
          }
          
          Divider()
          
          HStack {
            Text("Tema")
              .bold()
            
            Spacer()
            
            Picker("Tema", selection: $theme) {
              ForEach(Theme.allCases, id: \.self) { theme in
                Text(theme.name).tag(theme)
              }
            }
          }
          
          Divider()
          
          HStack {
            Text("Sunum Türü")
              .bold()
            
            Spacer()
            
            Picker("Sunum Türü", selection: $presentationKind) {
              ForEach(PresentationKind.allCases, id: \.self) { presentationKind in
                Text(presentationKind.name).tag(presentationKind)
              }
            }
          }
          
          Divider()
          
          HStack {
            Text("İşlem Türü")
              .bold()
            
            Spacer()
            
            Picker("İşlem Türü", selection: $transactionKind) {
              ForEach(TransactionKind.allCases, id: \.self) { kind in
                Text(kind.name).tag(kind)
              }
            }
          }
          
          Divider()
          
          if transactionKind == .payment {
            HStack {
              Text("Güvenlik Düzeyi")
                .bold()
              
              Spacer()
              
              Picker("Güvenlik Düzeyi", selection: $security) {
                ForEach(PaymentSecurityKind.allCases, id: \.self) { kind in
                  Text(kind.rawValue).tag(kind)
                }
              }
            }
            .padding(.bottom, 16)
          }
          
        }
        .scrollIndicators(.hidden)
        
        if initInProgress {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(height: 50)
        } else {
          Button(transactionKind.buttonTitle) {
            Task {
              await initSDK()
            }
          }
          .hubButtonStyle(backgroundColor: .bkmGold)
        }
      }
      .padding()
      .navigationTitle("Full SDK Demo")
      .alert(state: $alert)
      .bkmExpressSheet(
        presentation: $presentation,
        theme: { $0 = theme.bkmExpressTheme },
        style: presentationKind.bkmExpressPresentationStyle
      )
      .toolbarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          
          Button("Done") {
            UIApplication.shared
              .sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
              )
          }
        }
      }
    }
    
      // MARK: Utilities
    private func initSDK() async {
      guard let number = try? BKMExpress.GSMNO(phoneNumber)
      else {
        alert = .init(
          id: .init(),
          title: "Uyarı",
          message: "Lütfen geçerli bir telefon numarası giriniz.\n\nGeçerli telefon numarası 5 ile başlamalı, sadece rakamlardan ve toplamda 10 haneden oluşmalıdır."
        )
        return
      }
      
      initInProgress = true
      defer { initInProgress = false }
      
      do throws(BKMExpress.Failure) {
        switch transactionKind {
          case .payment:
            guard let amount else {
              alert = .init(message: "Başlatılamadı. Lütfen para miktarını girin")
              return
            }
            
            let paymentData = BKMExpress.PaymentData(
              amount: Decimal(amount),
              orderID: orderId,
              transactionDate: Date(),
              security: security.bexPaymentSecurity,
              currencyCode: currency,
              installmentCount: .init(installmentCount)!,
              transactionType: transactionType.bexTransactionType,
              successUrl: successUrl,
              failUrl: failUrl
            )
            
            let initializationToken = try await BKMExpress.initialize(
              context: .init(
                authToken: token,
                merchantID: merchantID,
                transactionID: UUID(),
                gsmNo: number,
                merchantUserID: merchantUserID,
                paymentData: paymentData,
                mode: mode.sdkMode
              )
            )
            
            self.presentation = .payment(
              token: initializationToken,
              data: paymentData,
              completion: { [self] result in
                switch result {
                  case .completed:
                    alert = .init(message: "Ödeme tamamlandı.")
                  case .cancelled:
                    alert = .init(message: "iptal")
                  case let .failed(failure):
                    alert = .init(message: "Hata: \(failure.localizedDescription)")
                }
              }
            )
            
          case .pairing:
            let initializationToken = try await BKMExpress.initialize(
              context: .init(
                authToken: token,
                merchantID: merchantID,
                transactionID: UUID(),
                gsmNo: number,
                merchantUserID: merchantUserID,
                paymentData: .init(currencyCode: currency),
                mode: mode.sdkMode
              )
            )
            
            self.presentation = .cardSelection(
              token: initializationToken,
              completion: { [self] result in
                let alertMessage = switch result {
                  case let .selected(card): "Kart eslestirme tamamlandı. Kart bilgileri: \(card.maskedCardNumber) \(card.id)"
                  case let .failed(error): "Hata oldu: \(error)"
                  case .cancelled: "Iptal Edildi"
                }
                
                self.alert = .init(id: .init(), message: alertMessage)
                if case let .selected(card) = result {
                  selectedCardInfo = (card.alias, card.maskedCardNumber)
                }
              }
            )
        }
      } catch {
        alert = .init(id: .init(), message: "Baslatilamadi. \(error.code ?? -1)  \n\n\(error.localizedDescription)")
      }
    }
  }
}

  // MARK: Extensions
private extension UISDKTests.PresentationKind {
  var bkmExpressPresentationStyle: BKMExpress.PresentationStyle {
    switch self {
      case .sheet: .sheet
      case .fullScreen: .fullScreen
    }
  }
}

private extension Mode {
  var sdkMode: BKMExpress._Mode {
    switch self {
        case .test: .test
        case .preprod: .preprod
        case .production: .production
        }
    }
}

enum BKMExpressPresentation {
  case payment(
  token: BKMExpress.InitializationToken,
  data: BKMExpress.PaymentData,
  completion: (BKMExpress.PaymentResult) -> Void
  )
  case cardSelection(
  token: BKMExpress.InitializationToken,
  completion: (BKMExpress.CardSelectionResult) -> Void
  )
  
  var token: BKMExpress.InitializationToken {
    switch self {
      case let .payment(token, _, _): token
      case let .cardSelection(token, _): token
    }
  }
}

extension View {
  func bkmExpressSheet(
  presentation: Binding<BKMExpressPresentation?>,
  theme: @escaping (inout BKMExpress.Theme) -> Void,
  style: BKMExpress.PresentationStyle
  ) -> some View {
    func tokenBinding() -> Binding<BKMExpress.InitializationToken?> {
      Binding(
      get: { presentation.wrappedValue?.token },
      set: { newValue in
        if newValue == nil {
          presentation.wrappedValue = nil
          }
        }
      )
      }
    
    return Group {
      switch presentation.wrappedValue {
        case let .payment(_, data, completion):
          self.bkmExpressPaymentSheet(
            token: tokenBinding(),
            data: data,
            theme: theme,
            style: style,
            onFinished: { result in
              completion(result)
              presentation.wrappedValue = nil
            }
          )
          
        case let .cardSelection(_, completion):
          self.bkmExpressCardSelectionSheet(
            token: tokenBinding(),
            theme: theme,
            style: style,
            onFinished: { result in
              completion(result)
              presentation.wrappedValue = nil
            }
          )
          
        case nil:
          self
      }
    }
  }
}

#if DEBUG
#Preview {
  NavigationStack {
    UISDKTests.Screen()
    }
}
#endif
