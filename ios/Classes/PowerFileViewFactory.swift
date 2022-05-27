//
//  PowerFileViewFactory.swift
//  power_file_view
//
//  Created by yaow on 2022/5/27.
//

import UIKit

class PowerFileViewFactory: NSObject, FlutterPlatformViewFactory {
    var _messenger: FlutterBinaryMessenger?
    
    init(messenger: FlutterBinaryMessenger) {
        super.init()
        self._messenger = messenger
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return PowerFileView(withFrame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: _messenger!)
    }
}
