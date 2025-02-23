# Rootless-hider
Jailbreak Hider Pro

Jailbreak Hider Pro is a powerful iOS application designed to hide the presence of a jailbreak on your device. It is particularly useful for users who want to bypass jailbreak detection in apps and games while still enjoying the benefits of a jailbroken device.

Key Features

Hide Jailbreak Files:
The app hides critical jailbreak-related files and directories, such as:
/Applications/Cydia.app
/Applications/Sileo.app
/var/jb/ (for rootless jailbreaks like Dopamine)
/Library/MobileSubstrate (tweak injection files)
And many more.
Hide Jailbreak Processes:
It hides jailbreak-related processes, such as:
Cydia
Sileo
sshd
dropbear
bash
And others.
Dynamic Hooking:
The app uses runtime hooking to intercept system calls like stat, access, and sysctl, ensuring that jailbreak detection mechanisms cannot find hidden files or processes.
User-Friendly Interface:
A simple and intuitive UI with a "Run/Stop" button to enable or disable jailbreak hiding.
Real-time logs display the status of hooks and hidden files/processes.
Background Operation:
Once enabled, the app works in the background, ensuring that the jailbreak remains hidden even after the app is closed.
Compatibility:
Supports both traditional jailbreaks (e.g., Unc0ver, Checkra1n) and rootless jailbreaks (e.g., Dopamine 2.0).
Compatible with iOS 14 and later.
How It Works

File Hiding:
The app overrides system functions like stat and access to return "file not found" (ENOENT) for hidden paths.
Process Hiding:
It hooks into the sysctl function to filter out jailbreak-related processes from the list of running processes.
Dynamic Activation:
Users can toggle jailbreak hiding on or off using the "Run/Stop" button in the app.
Persistence:
The app uses a Launch Daemon to ensure that hooks remain active even after a device reboot.
Use Cases

Bypass Jailbreak Detection:
Use banking apps, streaming services, or games that normally block jailbroken devices.
Enhanced Privacy:
Prevent apps from detecting your jailbreak status.
Rootless Jailbreak Support:
Fully compatible with modern rootless jailbreaks like Dopamine 2.0.
Technical Details

Programming Language: Objective-C
Frameworks: UIKit, Foundation
Hooking Mechanism: Method Swizzling (method_setImplementation)
System Calls Hooked:
stat
access
sysctl
Compatibility: iOS 14+ (arm64)
Installation

Download the .deb package from your preferred source (e.g., Sileo).
Install the package using a package manager like Sileo or Filza.
Launch the app and enable jailbreak hiding with the "Run" button.
Screenshots

Main Screen:
Title: "Jailbreak Hider Pro"
Button: "Run" (changes to "Stop" when active)
Logs: Real-time status updates (e.g., "Hooks installed! Jailbreak hidden.")
Logs:
Displays messages like:
"Hiding file: /Applications/Cydia.app"
"Hiding process: Cydia"
Why Choose Jailbreak Hider Pro?

Reliability: Built with robust hooking mechanisms to ensure consistent performance.
Ease of Use: Simple interface with one-touch activation.
Compatibility: Works with both traditional and rootless jailbreaks.
Open Source: Fully transparent code for security-conscious users.
Future Updates

Support for additional jailbreak detection bypass methods.
Enhanced compatibility with newer iOS versions.
Improved performance and stability.
![IMAGE 2025-02-23 21:12:11](https://github.com/user-attachments/assets/344ae3f2-3097-43b9-bbdc-46de220d717f)
