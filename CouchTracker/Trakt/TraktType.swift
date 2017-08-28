/*
Copyright 2017 ArcTouch LLC.
All rights reserved.
 
This file, its contents, concepts, methods, behavior, and operation
(collectively the "Software") are protected by trade secret, patent,
and copyright laws. The use of the Software is governed by a license
agreement. Disclosure of the Software to third parties, in any form,
in whole or in part, is expressly prohibited except as authorized by
the license agreement.
*/

import Moya

public protocol TraktType: TargetType {}

public extension TraktType {

  public var baseURL: URL { return Trakt.baseURL }

  public var method: Moya.Method { return .get }

  public var parameterEncoding: ParameterEncoding { return URLEncoding.default }

  public var task: Task { return .request }

  public var sampleData: Data {
    return "".utf8Encoded
  }
}

func stubbedResponse(_ filename: String) -> Data {
  let bundle = Bundle(for: Trakt.self)
  guard let url = bundle.url(forResource: filename, withExtension: "json"),
    let data = try? Data(contentsOf: url) else {
      return Data()
  }

  return data
}
