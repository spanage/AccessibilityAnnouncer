# AccessibilityAnnouncer
An accessibility announcement queue for iOS with timeout and retry behavior. Built using RAC.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


## The Idea

Commonly when writing accessibile iOS code, we write something like  `UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Hello")`. While this can work if the app is currently silent, it is very easy for these announcements to get swallowed by other announcements and/or VO reading something else that has been selected on the screen. The help tackle this problem, I've implemented an annoucement queueing sytem to be used instead of the raw `UIAccessibilityPostNotification` function. This system allows the client to set a default timeout. If an annoucement fails on first attempt, the queue will continue to retry until the timeout, at which point it will move on to the next announcement.

Note, while this does mean that app announcements interruped by system annoucements will be retried, system announcements will *not* be in your app queue. Thus, they will not obey the queue ordering.

## How to use

There should be one AccessibilityAnnouncer app wide. It can be initalied with a default timeout. You'll notice the default is 3 seconds, which I recommend. Passing a timeout of 0 will result in no retry behavior.

```swift
private let announcer = AccessibilityAnnouncer(defaultTimeout: 2.0)
// or
private let announcer = AccessibilityAnnouncer() // default timeout is 3 seconds
```
    
To use the announcer, simply pass it the string you'd like to announce using the `announce(announcement: String)` function.

```swift
announcer.announce("Hello!")
 ```
 
If you would like a given announcement to have a different timeout than your default (for example, you don't want it to be retried if it fails), you can pass a timeout argument.

```swift
announcer.announce("Hello!", withRetryTimeout: 0.0)
```

## Installing

The easiest way to install this is with Carthage. Simply add `github "spanage/AccessibilityAnnouncer"` to your `Cartfile`.
