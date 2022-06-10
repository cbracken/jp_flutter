import Cocoa
import FlutterMacOS

class JunkTexture: NSObject, FlutterTexture {
  var pixelBuffer: CVPixelBuffer?;

  override init() {
    super.init()

    CVPixelBufferCreate(kCFAllocatorDefault,
                        100, 50, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
  }

  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    return Unmanaged.passUnretained(pixelBuffer!)
  }
}

class MainFlutterWindow: NSWindow {
  let junkTexture = JunkTexture()

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    weak var registrar = flutterViewController.registrar(forPlugin: "FooPlugin")

    let textureId = registrar?.textures.register(junkTexture)
    if let id = textureId {
      print("Texture ID is: ", String(id))
    }

    super.awakeFromNib()
  }
}
