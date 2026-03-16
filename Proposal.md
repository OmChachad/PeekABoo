
# A Proposal for Privacy-First Passthrough on visionOS

**To:** The Apple Vision Pro Engineering & Privacy Teams

**Subject:** Enabling Context-Aware Apps via User-Initiated Passthrough

**Feedback ID:** FB22255093

---

## The Current State

visionOS is a marvel of engineering, creating a seamless blend of digital content and the physical world. However, for third-party developers, there is a distinct wall between the two. While a developer can place windows and volumes in the user's space, they cannot "see" what the user sees. This severely limits the apps they can build.

This restriction is well-founded in privacy. Apple has correctly identified that a continuously active camera feed available to third-party apps creates significant privacy risks for users and bystanders. I applaud this stance. Trust is paramount for the adoption of spatial computing.

## The Opportunity

There is, however, a vast category of applications that are currently impossible on visionOS due to these restrictions: apps that require *_momentary_* visual context to function.

Examples include:
- **Visual Intelligence Agents:** Apps that can answer "What is this part?" or "Translate this menu."
- **Dietary Tracking:** Logging food by simply looking at it.
- **Accessibility Tools:** Describing surroundings for visually impaired users.
- **Productivity Workflows:** Scanning receipts, whiteboards, or documents directly into a workspace.

These apps don't need a live video feed. They just need a single frame, captured at the user's specific request. And right now, it requires jumping through hoops: taking a photo, opening photos, and then manually sharing it with the app. This breaks the magic of visionOS.

## The "PeekABoo" Pattern: A Privacy-First Solution

My library, `PeekABoo`, demonstrates a workaround that highlights a specific user need: using the system screenshot mechanism (Capture Button + Digital Crown) as a proxy for "Take a picture of what I'm looking at and share it with this app."

**Why this model works for privacy:**
1. **Intentionality:** The capture is physically triggered by the user. It is impossible for an app to "spy" in the background because the user must physically press buttons on the device.
2. **Transparency:** The system provides immediate feedback that an image was captured.
3. **Control:** The _user decides_ when to share their context, rather than the app deciding when to take it.

## The Proposal

The current workaround that PeekABoo uses (observing the Photo Library) is imperfect. It clutters the user's camera roll with temporary images and relies on full library access permissions, which is a heavy ask for a simple utility. Furthermore, the two-button combo clashes with the system screenshot intent.

**I propose a formal API for "User-Initiated Spatial Capture."**

Instead of a passive observation model, Apple can provide an API akin to the standard "Take Photo" action on iOS/iPadOS, but tailored for spatial computing.

### How it could work:

1. **The Trigger:** The app requests a capture session. This invokes the system's native **Capture Mode** (currently toggled via the Capture Button).
2. **The Interaction:** The user frames their shot and presses the **Capture Button** to confirm the capture. This physical action serves as the explicit permission grant. The user is fully aware that a capture is underway, with the classic vignetting that Capture mode on visionOS applies.
3. **The Data:** The captured asset is delivered directly to the app in memory, **bypassing the Photos Library entirely**. This avoids breaking immersion, while providing utility and preserving privacy.

### Enhanced Capabilities (Nice to haves):

To fully leverage the hardware, this API should provide more than just a 2D flat image:
* **Stereo Capture & Depth:** Since visionOS camera captures are inherently spatial, the app should be able to receive stereo image pairs (and/or depth maps) associated with the capture.
* **Layer Control:** The system should offer a toggle (or API parameter) to include or exclude virtual window overlays in the capture. Sometimes a user wants to capture the *_world_* (eg. for a calorie tracker app), and sometimes they want to capture their *_mixed reality view_* (eg. to ask questions about what they are seeing inside an app).

### Benefits

* **For Users:** Access to powerful AI and utility apps without fear of surveillance that feel visionOS-first. No clutter in their photo libraries.
* **For Developers:** A legitimate, supported path to build context-aware experiences with rich spatial data.
* **For Apple:** Maintains the privacy promise of visionOS while unlocking the platform's potential as a productivity and assistance tool.

## Conclusion

I believe that the interaction model demonstrated by `PeekABoo` proves that privacy and passthrough capabilities are not mutually exclusive. By requiring explicit physical action for every frame shared, we can build a system where the user is always in control.

I invite the visionOS team to consider this pattern as a roadmap for future APIs. Thank you for taking the time to read this and considering my views.
