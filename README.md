
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

  

****visionOS 1.0+**** · Uses SwiftUI + Photos APIs

  

---

  

## How it works

  

On most platforms, reading camera frames is trivial and already solved by standard camera APIs, so this pattern would not make much sense there.

  

On Apple Vision Pro, however, screenshots are uniquely valuable because they include the user's surrounding real-world context in the captured image.

PeekABoo taps into that unique behavior by observing new screenshot assets (with explicit Photos permission), then delivering each new capture to your app as a `UIImage`.

  

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

  

## Proposal

  

Peekaboo is more than just an API for developers. If you're from Apple, Peekaboo is a proposal for a privacy-preserving version of a passthrough capability. One that can be implemented to allow developers to create never-before-possible apps, allowing the visionOS platform to flourish with apps that build upon the user's immediate context.

  

Read more about the Peekaboo Proposal here:

  

- Proposal link coming soon

  

## Examples

  

PeekABoo can be used to build real-world-aware experiences such as visual inference apps, assistive overlays, and context-triggered workflows.

  

## Contributing

  

Contributions welcome. Open an issue or submit a pull request.

  

Released under the [MIT License](LICENSE).

  

## Contact

  

Built with love by Om.
