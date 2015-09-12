# AccessibilityAnnouncer
An accessibility announcement queue for iOS with timeout and retry behavior. Built using RAC.

## The Idea

Commonly when writing accessibile iOS code, we write something like  `UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Hello")`. While this can work if the app is currently silent, it is very easy for these announcements to get swollowed by other announcements and/or VO reading something else that has been selected on the screen. The help tackle this problem, I've implmeented an annoucement queueing sytem to be used instead of the raw `UIAccessibilityPostNotification` function. This system allows the client to set a default timeout. If an annoucement fails on first go, the queue will continue to retry until the timeout and will not move on to the next announcement.

Note, while this does mean that app annoucnements interruped by system annoucements will be retried, system announcements will *not* by in your app queue. Thus, they will not obey the queue ordering.

## How to use

There should be one AccessibilityAnnouncer app wide. It can be initalied with a default timeout. You'll notice the default is 3 seconds, which I recommend. Passing a timeout of 0 will result in no retry behavior.

    private let announcer = AccessibilityAnnouncer(defaultTimeout: 2.0)
    // or
    private let announcer = AccessibilityAnnouncer() // default timeout is 3 seconds
    
To use the announcer, simply pass it the string you'd like to announce using the `announce(announcement: String)` function.

    announcer.announce("Hello!")
    
If you would like a given announcement to have a different timeout than your default (for example, you don't want it to be retried if it fails), you can pass an timeout argument.

    announcer.announce("Hello!", withRetryTimeout: 0.0)

## Installing

The easiest way to install this is with Carthage. Simply add `github spanage/AccessibilityAnnouncer` to your `Cartfile`.