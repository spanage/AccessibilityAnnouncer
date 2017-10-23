//
//  AccessibilityAnnouncer.swift
//  AccessibilityAnnouncer
//
//  Created by Sommer Panage on 9/11/15.
//  Copyright © 2015 Sommer Panage. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import struct Result.AnyError
import enum Result.NoError

public final class AccessibilityAnnouncer {
    
    // Amount of time for which our announcer should retry a failing announcement before
    // giving up. We recommend no more than 3 seconds for this, otherwise the annoucnement
    // will be out of context. If 0 is set in the initializer, then there will be no retry
    // behavior by default.
    public let defaultRetryTimeout: TimeInterval
    
    private typealias AnnouncerProducer = SignalProducer<(), NoError>
    private typealias NotifierProducer = SignalProducer<(), NotificationError>
    
    private let signal: Signal<AnnouncerProducer, NoError>
    private let sink: Signal<AnnouncerProducer, NoError>.Observer
    private let disposable: Disposable
    
    public init(defaultTimeout: TimeInterval = 3.0) {
        self.defaultRetryTimeout = defaultTimeout
        
        (signal, sink) = Signal<AnnouncerProducer, NoError>.pipe()
        
        disposable = signal
            .flatten(.concat)
            .observeValues { }!
    }
    
    deinit {
        disposable.dispose()
    }
    
    public func announce(_ announcement: String) {
        announce(announcement, withRetryTimeout: defaultRetryTimeout)
    }
    
    // Passing a timeout here overrides the default timeout for this announcement only.
    public func announce(_ announcement: String, withRetryTimeout timeout: TimeInterval) {
        let announcer = createProducerForAnnouncer(announcement)
        let notifier = createProducerForNotifier(announcement)
        
        let announceAndCheckNotificationProducer = announcer
            .promoteError(NotificationError.self)
            .concat(notifier)
        
        let retryTilTimeoutProducer = announceAndCheckNotificationProducer
            .retry(upTo: Int.max)
            .timeout(after: timeout, raising: .announcementTimedOut, on: QueueScheduler())
            .flatMapError{ _ in AnnouncerProducer.empty }
        
        sink.send(value: retryTilTimeoutProducer)
    }
    
    private func createProducerForAnnouncer(_ announcement: String) -> AnnouncerProducer {
        return SignalProducer { sink, disposable in
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, announcement)
            sink.sendCompleted()
        }
    }
    
    private func createProducerForNotifier(_ announcement: String) -> NotifierProducer {
        let notificationSignal = NotificationCenter.default.reactive.notifications(forName: NSNotification.Name.UIAccessibilityAnnouncementDidFinish, object: nil)
            .map { $0.userInfo! }
            .filter { $0[UIAccessibilityAnnouncementKeyStringValue] as! String? == announcement }
            .take(first: 1)
            .promoteError(NotificationError.self)
        let notificationProducer = SignalProducer(notificationSignal)
        
        return notificationProducer.flatMap(.merge) { userInfo -> NotifierProducer in
            let success = (userInfo[UIAccessibilityAnnouncementKeyWasSuccessful]! as AnyObject).boolValue!
            
            if (success) {
                return .empty
            } else {
                return SignalProducer(error: .announcementFailed)
            }
        }
    }
    
    fileprivate enum NotificationError: Error {
        case announcementFailed
        case announcementTimedOut
    }
}
