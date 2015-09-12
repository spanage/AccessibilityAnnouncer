//
//  AccessibilityAnnouncer.swift
//  AccessibilityAnnouncer
//
//  Created by Sommer Panage on 9/11/15.
//  Copyright © 2015 Sommer Panage. All rights reserved.
//

import UIKit
import ReactiveCocoa

public class AccessibilityAnnouncer {
    
    private typealias AnnouncerProducer = SignalProducer<(), NoError>
    private typealias NotifierProducer = SignalProducer<(), NotificationError>
    
    private let producer: SignalProducer<AnnouncerProducer, NoError>
    private let sink: Event<AnnouncerProducer, NoError>.Sink
    
    public init() {
        (producer, sink) = SignalProducer<AnnouncerProducer, NoError>.buffer()
        
        producer
            .flatten(.Concat)
            .start()
    }
    
    public func announce(announcement: String) {
        let announcer = createProducerForAnnouncer(announcement)
        let notifier = createProducerForNotifier(announcement)
        
       let announceAndCheckNotificationProducer = announcer
            .promoteErrors(NotificationError)
            .concat(notifier)
            .on(error: { print($0) })
        
        let retryTilTimeoutProducer = announceAndCheckNotificationProducer
            .retry(Int.max)
            .timeoutWithError(.AnnouncementTimedOut, afterInterval: 5.0, onScheduler: QueueScheduler())
            .on(error: { print("Error: \($0)") })
            .flatMapError { _ in AnnouncerProducer.empty }
        
        sendNext(sink, retryTilTimeoutProducer)
    }
    
    private func createProducerForAnnouncer(announcement: String) -> AnnouncerProducer {
        return SignalProducer { sink, disposable in
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, announcement)
            sendCompleted(sink)
        }
            .on(started: { print("Announcing \(announcement)") })
    }
    
    private func createProducerForNotifier(announcement: String) -> NotifierProducer {
        return NSNotificationCenter.defaultCenter().rac_notifications(UIAccessibilityAnnouncementDidFinishNotification, object: nil)
            .map { $0.userInfo! }
            .filter { $0[UIAccessibilityAnnouncementKeyStringValue]!.isEqual(announcement) }
            .take(1)
            .promoteErrors(NotificationError)
            .flatMap(.Merge) { userInfo in
                let success = userInfo[UIAccessibilityAnnouncementKeyWasSuccessful]!.boolValue!
                
                if (success) {
                   return .empty
                } else {
                    return SignalProducer(error: .AnnouncementFailed)
                }
            }
    }
    
    private enum NotificationError: ErrorType {
        case AnnouncementFailed
        case AnnouncementTimedOut
    }
}