import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var playbackActivity: NSObjectProtocol?
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    var windowFrame = self.frame
    windowFrame.size = NSSize(width: 1100, height: 820)
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    let activity = FlutterMethodChannel(name: "rollingtab/audioActivity",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    activity.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setActive", let active = call.arguments as? Bool else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let self = self else { result(nil); return }
      if active && self.playbackActivity == nil {
        self.playbackActivity = ProcessInfo.processInfo.beginActivity(
          options: [.userInitiatedAllowingIdleSystemSleep, .latencyCritical],
          reason: "RollingTAB continuous audio playback")
      } else if !active, let token = self.playbackActivity {
        ProcessInfo.processInfo.endActivity(token)
        self.playbackActivity = nil
      }
      result(nil)
    }

    super.awakeFromNib()
  }
}
