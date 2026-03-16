<div align="center">
  <img width="200" height="200" src="/Resources/Icon.png" alt="Peekaboo Logo">
  <h1><b>Peekaboo</b></h1>
  <p>
    The first and only consumer-facing "passthrough" API for Apple Vision Pro, crafted with privacy in mind.
  </p>
</div>

<p align="center">
  <a href="https://developer.apple.com/visionOS/"><img src="https://img.shields.io/badge/visionOS-1.0%2B-purple.svg" alt="visionOS 1.0+"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></a>

<div align="center">
  <img width="600" src="/Resources/examples/example1.gif" alt="Peekaboo Demo">
</div>


 


  

## About

The world's first passthrough API for Apple Vision Pro that anyone can use.
It is powered by a clever workaround, but unlocks a whole new genre of apps that was previously impossible on visionOS.
With PeekABoo, you can add passthrough capabilities to your app in just a single line of code.
All while keeping the user in full control of what is shared - it's built with privacy at its heart.


## Installation

```swift
dependencies: [
    .package(url: "https://github.com/OmChachad/PeekABoo", from: "4.0.0")
]
```

Then import the module you need:

```swift
import PeekABoo
```

## Modules

### PeekABoo

Receive images from new screenshots using a one-line SwiftUI modifier.

```swift
import SwiftUI
import PeekABoo

struct ContentView: View {
    @State private var latestImage: UIImage?

    var body: some View {
        VStack {
            if let latestImage {
                Image(uiImage: latestImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Take a screenshot to test PeekABoo")
            }
        }
        .onCapture { image in
            latestImage = image
        }
    }
}
```

The modifier calls your handler whenever a new screenshot is detected in the user's screenshot album.

### Permissions

You must add the `NSPhotoLibraryUsageDescription` key to your `Info.plist` file explaining why you need access to the photo library.

### Manual Authorization

By default, the permission prompt will appear when the view with `.onCapture` appears. If you prefer to request access at a specific time (e.g., during an onboarding flow), you can use the static methods provided by `PeekABoo`:

```swift
import PeekABoo

// Check if access is already granted (specifically "Full Access")
if !PeekABoo.isAccessGranted {
    // Request access manually
    let granted = await PeekABoo.requestAccess()
    if granted {
        print("Access granted!")
    } else {
        print("Access denied or limited.")
    }
}
```

> **Important:** PeekABoo requires **Full Library Access**. If the user grants "Limited Access", `isAccessGranted` will return `false`, and the screenshot observation will not work as expected because it cannot continuously monitor for new screenshots in the background without full access.

### User Instructions

PeekABoo includes a pre-built SwiftUI view that explains to users how to take a screenshot (press Top Button + Digital Crown). This is useful for onboarding or help screens.

```swift
import PeekABoo

// concise instructions
PeekABoo.CaptureInstructions()

// or with custom text below
PeekABoo.CaptureInstructions(description: "Capture your surroundings to analyze them.")
```

If you want to build a custom UI, you can access the instruction image directly:

```swift
// Returns a SwiftUI Image
PeekABoo.captureGestureIcon
    .resizable()
    .scaledToFit()
```

**visionOS 1.0+** · Uses SwiftUI + Photos APIs

---

## How it works

On most platforms, reading camera frames is trivial thanks to standard camera APIs. Additionally, on other platforms, screenshots taken while an app is open typically only capture the app's own interface. This renders screenshot observation useless for data input, as the app would merely receive an image of itself.

On Apple Vision Pro, however, screenshots are uniquely valuable because they include the user's surrounding real-world context in the captured image.
PeekABoo taps into that unique behavior by observing new screenshot assets, then delivering each new capture to your app as a `UIImage`. This essentially allows for a foax passthrough effect on the Vision Pro.
A capture can only be initiated when the Digital Crown and Capture button are clicked simulataneously, ensuring that the user is always in control of when their environment is shared.

In practice:

1. You attach `.onCapture { image in ... }` to your view.
2. PeekABoo requests Photos access from the user.
3. PeekABoo subscribes to screenshot album changes.
4. Each new screenshot is loaded and emitted to your callback.

This provides a practical passthrough pipeline on visionOS while preserving the platform's privacy boundaries.

## Documentation

Documentation and API notes are in the source at:

- `Sources/PeekABoo/PeekABoo.swift`
- `Sources/PeekABoo/PhotoLibraryManager.swift`

## Limitations

- It does not currently allow access to depth information on its own, but can be used in conjunction with Apple's depth mapping APIs to create a full-color map of your surroundings.
- Images will in fact populate the user's camera roll once they are taken. This is an unfortunate limitation since Apple does not allow developers to silently delete items from the user's photo library.

## Proposal for 

Peekaboo is more than just an API for developers. If you're from Apple, Peekaboo is a proposal for a privacy-preserving version of a passthrough capability. One that can be implemented to allow developers to create never-before-possible apps, allowing the visionOS platform to flourish with apps that build upon the user's immediate context.

Read more about the Peekaboo Proposal here:

- [Proposal for Privacy-First Passthrough on visionOS](Proposal.md)

## Examples

PeekABoo can be used to build real-world-aware experiences such as visual inference apps, assistive overlays, and context-triggered workflows. Great examples include a calorie tracking app, or one that scans QR codes.

## Contributing

Contributions welcome. Open an issue or submit a pull request.

Released under the [MIT License](LICENSE).

## Contact

Twitter: [@TheOriginaliTE](https://twitter.com/TheOriginaliTE)
Linkedin: [Om Chachad](https://www.linkedin.com/in/omchachad/)
Website: [iTech Everything](https://itecheverything.com)

Built with love by Om.
