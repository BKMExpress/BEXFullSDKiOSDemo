//
//  Models+Extensions.swift
//  bex-fullsdk-demo
//

@_spi(Internals) import BKMExpressSDK
import Foundation

extension Mode {
  static var `default`: Self {
    .test
  }
  
  var name: String {
    switch self {
    case .test: "Test"
    case .preprod: "Preprod"
    case .production: "Production"
    }
  }
}

#if INTERNAL_DISTRIBUTION
extension RequestLog {
  init(from log: BKMExpressSDK.RequestLog) {
    self.init(
      id: log.id,
      code: log.code,
      body: log.body,
      kind: log.kind,
      responseHeaders: log.responseHeaders,
      requestHeaders: log.requestHeaders,
      url: log.url,
      response: log.response,
      timestamp: log.timestamp,
      errorReason: log.errorReason
    )
  }
}

extension RequestLog {
  init(from log: BKMExpressLiteSDK.RequestLog) {
    self.init(
      id: log.id,
      code: log.code,
      body: log.body,
      kind: log.kind,
      responseHeaders: log.responseHeaders,
      requestHeaders: log.requestHeaders,
      url: log.url,
      response: log.response,
      timestamp: log.timestamp,
      errorReason: log.errorReason
    )
  }
}
#endif

