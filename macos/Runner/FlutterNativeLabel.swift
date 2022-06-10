//
//  FlutterNativeLabel.swift
//  Runner
//
//  Created by Chris Bracken on 2022-06-03.
//

import FlutterMacOS
import AppKit

class FlutterNativeLabelFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
        return FlutterNativeLabel(frame: CGRect())
    }
}

class FlutterNativeLabel: NSView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        let label = NSTextField()
        label.frame = CGRect(x: 0, y: 0, width: 180, height: 48)
        label.stringValue = "Native text from AppKit"
        label.backgroundColor = NSColor.blue
        label.textColor = NSColor.white
        label.alignment = .center
        label.sizeToFit()
        self.addSubview(label)
    }
}
