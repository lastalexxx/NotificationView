import UIKit

public class NotificationView: UIView, NotificationViewActionsDelegate {
    
    /// Position of view presentation on device screen.
    enum positionEnum {
        case top, bottom
    }
    
    /// To find view use tag 42.
    public override var tag: Int { get { return 42 } set{} }
    
    /// Text label. Supported 2 lines.
    ///
    /// To set text or other changes override **configure()** func and perform setup in it.
    public let textLabel = UILabel()
    
    /// Image View. Use to show what's going on to your users.
    ///
    /// To set text or other changes override **configure()** func and perform setup in it.
    public let imageView = UIImageView()
    
    /// Default view center position.
    private var viewCenter: CGPoint!
    
    /// Hidden view center position.
    private var viewHiddenCenter: CGPoint!
    
    //MARK: - init
    convenience init(at position: positionEnum) {
        self.init()
        let screenBounds = UIScreen.main.bounds
        var orientationMultiplier: CGFloat = 0
        var widthCorrection: CGFloat = 0
        setViewMargins(orientationMultiplier: &orientationMultiplier, widthCorrection: &widthCorrection)
        
        let size = CGSize(width: screenBounds.width - widthCorrection, height: screenBounds.height / orientationMultiplier)
        
        let centerY: CGFloat!
        centerY = position == .top ? UIApplication.shared.windows[0].safeAreaInsets.top : screenBounds.height - UIApplication.shared.windows[0].safeAreaInsets.bottom - size.height
        let origin = CGPoint(x: widthCorrection / 2, y: centerY)
        
        frame = CGRect(origin: origin, size: size)
        layer.cornerRadius = size.height / 4
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        
        viewCenter = center
        let hiddenCenterY = position == .top ? center.y - frame.height * 2 : screenBounds.height + size.height / 2
        viewHiddenCenter = CGPoint(x: center.x, y: hiddenCenterY)
        center = viewHiddenCenter
        
        textLabel.numberOfLines = 2
        setImagePosition()
        setTextPosition()
        configure()
    }
    
    //MARK: - private
    /// Adding imageView to view using layout constraints.
    private func setImagePosition() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: -8)
        let width = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: -8)
        let leading = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 8)
        let centerY = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        addSubview(imageView)
        addConstraints([height, width, leading, centerY])
    }
    
    /// Shake animation and generating vibration if view presentation called while already presenting.
    private func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = viewCenter
        animation.toValue = CGPoint(x: center.x + 10, y: center.y)
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
        
        layer.add(animation, forKey: "position")
    }
    
    /// Adding textLabel to view using layout constraints.
    private func setTextPosition() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: textLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: -8)
        let trailing = NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -8)
        let leading = NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 8)
        let centerY = NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        addSubview(textLabel)
        addConstraints([height, trailing, leading, centerY])
    }
    
    //MARK: - public
    /// Configuration of textLabel and imageView.
    ///
    /// Override this function in inherited class to set text, image and other options.
    public func configure() {
        backgroundColor = .systemTeal
        textLabel.text = "Placeholder line\nNext"
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "circle")
        } else {
            imageView.backgroundColor = .systemRed
        }
        imageView.tintColor = .white
    }
    
    /// If you need to change image and/or text, call this function.
    /// - Parameters:
    ///   - image: UIImage. Optional.
    ///   - text: String. Optional.
    public final func setImageAndText(image: UIImage? = nil, text: String? = nil) {
        if let unwrapedImage = image {
            imageView.image = unwrapedImage
        }
        if let unwrapedText = text {
            textLabel.text = unwrapedText
        }
    }
    
    /// Function will present view with animation.
    ///
    /// If this function called repeatedly while view is already presenting, view will perform shake animation.
    /// - Parameter dismissAfter: Time in seconds to dismiss this view.
    public final func present(dismissAfter: Double? = nil) {
        if center == viewCenter {
            shake()
            return
        }
        
        if let rootViewController = UIApplication.shared.windows.last?.rootViewController {
            rootViewController.view.addSubview(self)
        }
        
        animate(action: { self.center = self.viewCenter }) {
            if let unwrapedDismiss = dismissAfter {
                DispatchQueue.main.asyncAfter(deadline: .now() + unwrapedDismiss) {
                    self.dismiss()
                }
            }
        }
    }
    
    /// Function will dismiss view with animation.
    public final func dismiss() {
        if self.center == self.viewHiddenCenter {
            return
        }
        animate(action: { self.center = self.viewHiddenCenter }) {
            self.removeFromSuperview()
        }
    }
    
    /// Function will dismiss view with animation and perform action in handler.
    ///
    /// Notice: if view already dismissed, action will not be performed.
    public final func dismissWithHandler(handler: @escaping () -> Void) {
        if self.center == self.viewHiddenCenter {
            return
        }
        animate(action: { self.center = self.viewHiddenCenter }) {
            handler()
            self.removeFromSuperview()
        }
    }
    
    //MARK: - fileprivate
    /// Animation settings.
    ///
    /// Animation duration - 1, spring dumping - 40 and initial spring velocity - 20.
    /// - Parameters:
    ///   - action: Animation action.
    ///   - handler: @escaping handler that will be performed after animation is finished.
    fileprivate func animate(action: @escaping () -> (), handler: @escaping () -> Void) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 40, initialSpringVelocity: 20, options: [.curveEaseInOut], animations: {
            action()
        }) { complited in
            if complited {
                handler()
            }
        }
    }
    
    fileprivate func setViewMargins(orientationMultiplier: inout CGFloat, widthCorrection: inout CGFloat) {
        if #available(iOS 13, *) {
            if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
                switch orientation {
                case .landscapeLeft, .landscapeRight:
                    orientationMultiplier = 7
                    widthCorrection = 80
                default:
                    orientationMultiplier = 15
                    widthCorrection = 40
                }
            } else {
                orientationMultiplier = 15
                widthCorrection = 40
            }
        } else {
            if UIApplication.shared.statusBarOrientation.isLandscape {
                orientationMultiplier = 7
                widthCorrection = 80
            } else {
                orientationMultiplier = 15
                widthCorrection = 40
            }
        }
    }
    
}

//MARK: - protocol
/// Use this protocol for control NotificationView presenting and dismissing.
protocol NotificationViewActionsDelegate {
    func present(dismissAfter: Double?)
    func dismiss()
    func dismissWithHandler(handler: @escaping () -> Void)
}
