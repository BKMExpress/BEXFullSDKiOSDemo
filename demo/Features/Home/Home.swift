//
//  Home.swift
//  bex-fullsdk-demo
//

@_spi(Internals) import BKMExpressSDK
import Foundation
import SwiftUI

enum Home {
  struct HashableWrapper<A>: Hashable {
    private let id = UUID()
    let content: A
    
    init(content: A) {
      self.content = content
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.id == rhs.id
    }
  }
  
  enum Destination: Hashable {
    case settings
  }
  
  enum Presented: Hashable {
    case sdk(UISDKTests.StartContext)
  }


  struct Screen: View {
    // MARK: State
    @AppStorage("mode") var mode: Mode = .default
    @State var path: [Destination] = []
    @State var sheet: Presented?
    
    // MARK: UI
    var body: some View {
      NavigationStack(path: $path) {
        UISDKTests.Screen()
          .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
              Button {
                path.append(.settings)
              } label: {
                Image(systemName: "gear")
              }
            }
          })
          .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .settings:
              Settings.Screen()
            }
          }
      }
    }
  }
}

#if DEBUG
#Preview {
  Home.Screen()
}
#endif
