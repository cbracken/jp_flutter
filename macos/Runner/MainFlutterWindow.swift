import Cocoa
import FlutterMacOS

class JunkTexture: NSObject, FlutterTexture {
  var pixelBuffer: CVPixelBuffer?;

  init(url: String) {
    super.init()

    do {
      //let url = URL(string: "https://chris.bracken.jp/post/2005-04-09-sakura.jpg");
      let image = NSImage(data: try Data(contentsOf: URL(string: url)!))!
      print("Got the image! ", String(image.description))

      let attrs = [
        kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
        kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue] as CFDictionary

      let status = CVPixelBufferCreate(kCFAllocatorDefault,
                          Int(image.size.width),
                          Int(image.size.height),
                          kCVPixelFormatType_32BGRA,
                          attrs,
                          &pixelBuffer)
      guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
        NSLog("Bad news. CVPixelBuffer creation failed!")
        return
      }

      CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      guard let context = CGContext(data: pixelData,
                                    width: Int(image.size.width),
                                    height: Int(image.size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                    space: rgbColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
        NSLog("Pretty bad news. We made it as far as creating a graphics context, then died.")
        return
      }

      let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
      NSGraphicsContext.saveGraphicsState()
      NSGraphicsContext.current = graphicsContext
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      NSGraphicsContext.restoreGraphicsState()
      CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    } catch {
      print(error)
    }

//    CVPixelBufferCreate(kCFAllocatorDefault,
//                        100, 50, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
  }

  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    return Unmanaged.passUnretained(pixelBuffer!)
  }
}

class MainFlutterWindow: NSWindow {
  var junkTexture: JunkTexture?
  var channel: FlutterMethodChannel?
  var textureId: Int64?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // HACK HACK HACK
    weak var registrar = flutterViewController.registrar(forPlugin: "FooPlugin")
    channel = FlutterMethodChannel(name: "foo", binaryMessenger: registrar!.messenger)
    channel!.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      switch call.method {
      case "registerTexture":
        let args = call.arguments as? Dictionary<String, Any>
        let imageUrl = args!["url"] as? String
        self?.junkTexture = JunkTexture(url: imageUrl!)
        if let weakself = self {
          weak var registrar = (weakself.contentViewController as? FlutterViewController)!.registrar(forPlugin: "FooPlugin")
          weakself.textureId = registrar!.textures.register(weakself.junkTexture!)
          NSLog("Texture ID is: %@", weakself.textureId!)
        } else {
          NSLog("Couldn't get weakself")
        }
        result("Loaded image!")
      case "getTextureId":
        if let weakself = self {
          NSLog("Called getTextureId! Returning %@", weakself.textureId!)
        }
        result(self?.textureId!)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    // HACK HACK HACK

    super.awakeFromNib()
  }
}
