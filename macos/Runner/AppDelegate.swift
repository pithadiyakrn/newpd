//import Cocoa
//import FlutterMacOS
//
//@NSApplicationMain
//class AppDelegate: FlutterAppDelegate {
//  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
//    return true
//  }
//}

import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    var blurEffectView: NSVisualEffectView?

    override func applicationDidFinishLaunching(_ notification: Notification) {
        super.applicationDidFinishLaunching(notification)

        // Add observer for screen capture
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureStateChanged),
            name: NSNotification.Name(rawValue: "com.apple.screenIsCaptured"),
            object: nil
        )

        // Check initial screen capture state
        checkScreenCaptureState()
    }

    @objc func screenCaptureStateChanged(notification: Notification) {
        checkScreenCaptureState()
    }

    func checkScreenCaptureState() {
        guard let window = NSApplication.shared.windows.first else { return }

        let isCaptured = CGDisplayIsCaptured(CGMainDisplayID()) == 1
        if isCaptured {
            addBlurEffect(to: window)
        } else {
            removeBlurEffect()
        }
    }

    func addBlurEffect(to window: NSWindow) {
        if blurEffectView == nil {
            let blurEffect = NSVisualEffectView()
            blurEffect.blendingMode = .behindWindow
            blurEffect.material = .dark
            blurEffect.state = .active
            blurEffect.frame = window.contentView!.bounds
            blurEffect.autoresizingMask = [.width, .height]
            window.contentView?.addSubview(blurEffect)
            blurEffectView = blurEffect
        }
    }

    func removeBlurEffect() {
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
