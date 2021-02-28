# NotificationView

![](https://i.imgur.com/G1m9X8u.png)
## Menu
1. [About](#about)
2. [Install](#install)
3. [Working](#working)
4. [Options](#options)
5. [Examples](#examples)

## About
This library can save you some time if you need to create a lot of notification views in your app. Need to show network, done, error, message status? You are welcome.

## Install
Copy repo URL and add it to your project via [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Working
1. Import this library.
```swift
import NotificationView
```
2. Create inherited class.
```swift
class MyNotification: NotificationView {}
```
3. Override `configure` function.
```swift
class MyNotification: NotificationView {
    override func configure() {
        //setup backgroundColor, imageView and textLabel here 
    }
}
```
4. Now create `MyNotification` class instance with selecting notification position.
```swift
var myNotification: MyNotification?

override func viewDidLoad() {
    super.viewDidLoad()
    myNotification = MyNotification(at: .top)
}
```
5. And call `present` when you need.
```swift
func showNotification() {
    myNotification?.present()
}
```

## Options

##### Handlers and dismissing
If you need to make some action after view is dismissed, use `dismissWithHandler`.
```swift
func GenerateVibration() {
    myNotification?.dismissWithHandler {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
    }
}
```
You can dismiss your view after presenting automatically.
```swift
func ShowNotification() {
    //hide view after five seconds
    myNotification?.present(dismissAfter: 5)
}
```

##### Dynamic change image and text
If you need to dynamic change image or text use `setImageAndText` function.
```swift
//change image and text
myNotification?.setImageAndText(image: myImage, text: "Hello")
//change image
myNotification?.setImageAndText(image: myImage)
//change text
myNotification?.setImageAndText(text: "Hello")
```

## Examples
View configuration of bad network connection example:
```swift
class BadNetworkView: NotificationView {
    
    override func configure() {
        backgroundColor = .systemRed
        imageView.image = UIImage(systemName: "network")
        imageView.tintColor = .white
        textLabel.text = "Bad network connection"
    }
    
}
```
**Result:**
![Simple notification](https://i.imgur.com/8rSxi0C.png)

Or use your imagination, like this:
```swift
class LikeView: NotificationView {
    
    override func configure() {
        backgroundColor = .secondarySystemGroupedBackground
        imageView.image = UIImage(systemName: "hand.thumbsup.fill")
        imageView.backgroundColor = .systemIndigo
        imageView.clipsToBounds = false
        imageView.layer.cornerRadius = (frame.height - 8) / 2
        imageView.contentMode = .scaleToFill
        imageView.tintColor = .white
        textLabel.text = "Nicola like's your comment:\n\"Tesla is the best!\""
        textLabel.textAlignment = .natural
        thumbAnimation()
    }
    
    public func thumbAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: { timer in
            timer.invalidate()
            UIView.transition(with: self.imageView, duration: 0.5, options: [.curveEaseInOut, .transitionFlipFromTop], animations: {
                self.imageView.image = UIImage(named: "N.Tesla")
                self.imageView.backgroundColor = .systemBlue
                self.imageView.clipsToBounds = true
            })
        })
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { timer in
            timer.invalidate()
            self.dismiss()
        })
    }
    
}
```

**Result:**
[video link](https://i.imgur.com/Rz4ZCJe.mp4)

## Conclusion
Not rocket science but you can save time by not doing it manually.
![It ain't much](https://i.kym-cdn.com/entries/icons/original/000/028/021/work.jpg)
