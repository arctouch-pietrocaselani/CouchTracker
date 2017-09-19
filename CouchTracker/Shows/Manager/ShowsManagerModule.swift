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

final class ShowsManagerModule {
  private init() {}

  static func setupModule() -> BaseView {
    guard let view = R.storyboard.showsManager.showsManagerViewController() else {
      fatalError("Can't instantiate ShowsManagerViewController from Storyboard")
    }
    return view
  }
}
