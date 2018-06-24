//
//  CompanyService.swift
//  Neptune
//
//  Created by Karsten Bruns on 23.06.18.
//  Copyright © 2018 MOIA GmbH. All rights reserved.
//

import Foundation


// sourcery:observable_properties
class CompanyService {

  private enum ObservableProperties {
    case ceo(String)
    case bouncer(String)
    case employees([String])
  }

  // sourcery:inline:CompanyService.ObservableProperties
  enum Notification {
    static let newValueKey = "newValue"
    static let oldValueKey = "oldValueKey"

    static let didSetCeo = Foundation.Notification.Name("CompanyServiceDidSetCeoNotification")
    static let didSetBouncer = Foundation.Notification.Name("CompanyServiceDidSetBouncerNotification")
    static let didSetEmployees = Foundation.Notification.Name("CompanyServiceDidSetEmployeesNotification")
  }

  var ceo: String {
    didSet {
      let userInfo = [Notification.newValueKey: ceo, Notification.oldValueKey: oldValue]
      NotificationCenter.default.post(name: Notification.didSetCeo, object: self, userInfo: userInfo)
    }
  }

  var bouncer: String {
    didSet {
      let userInfo = [Notification.newValueKey: bouncer, Notification.oldValueKey: oldValue]
      NotificationCenter.default.post(name: Notification.didSetBouncer, object: self, userInfo: userInfo)
    }
  }

  var employees: [String] {
    didSet {
      let userInfo = [Notification.newValueKey: employees, Notification.oldValueKey: oldValue]
      NotificationCenter.default.post(name: Notification.didSetEmployees, object: self, userInfo: userInfo)
    }
  }
  // sourcery:end

  init() {
    self.ceo = ""
    self.employees = []
    self.bouncer = ""
  }
}


// sourcery:inline:CompanyService.ObserverProtocol
protocol CompanyServiceObserver: AnyObject {
  var companyService: CompanyService { get }
  var companyServiceObserverTokens: [Any] { get set }

  func startObservingCompanyService()
  func stopObservingCompanyService()

  func companyServiceDidSetCeo(_ ceo: String, oldCeo: String)
  func companyServiceDidSetBouncer(_ bouncer: String, oldBouncer: String)
  func companyServiceDidSetEmployees(_ employees: [String], oldEmployees: [String])
}


extension CompanyServiceObserver {

  func startObservingCompanyService() {
    let center = NotificationCenter.default

    companyServiceObserverTokens.append(center.addObserver(forName: CompanyService.Notification.didSetCeo, object: companyService, queue: OperationQueue.main) { [weak self] notification in
      guard let newValue = notification.userInfo?[CompanyService.Notification.newValueKey] as? String,
        let oldValue = notification.userInfo?[CompanyService.Notification.oldValueKey] as? String else { return }
      self?.companyServiceDidSetCeo(newValue, oldCeo: oldValue)
    })

    companyServiceObserverTokens.append(center.addObserver(forName: CompanyService.Notification.didSetBouncer, object: companyService, queue: OperationQueue.main) { [weak self] notification in
      guard let newValue = notification.userInfo?[CompanyService.Notification.newValueKey] as? String,
        let oldValue = notification.userInfo?[CompanyService.Notification.oldValueKey] as? String else { return }
      self?.companyServiceDidSetBouncer(newValue, oldBouncer: oldValue)
    })

    companyServiceObserverTokens.append(center.addObserver(forName: CompanyService.Notification.didSetEmployees, object: companyService, queue: OperationQueue.main) { [weak self] notification in
      guard let newValue = notification.userInfo?[CompanyService.Notification.newValueKey] as? [String],
        let oldValue = notification.userInfo?[CompanyService.Notification.oldValueKey] as? [String] else { return }
      self?.companyServiceDidSetEmployees(newValue, oldEmployees: oldValue)
    })
  }

  func stopObservingCompanyService() {
    let notificationCenter = NotificationCenter.default
    for token in companyServiceObserverTokens {
      notificationCenter.removeObserver(token)
    }
  }

  func companyServiceDidSetCeo(_ ceo: String, oldCeo: String) { }

  func companyServiceDidSetBouncer(_ bouncer: String, oldBouncer: String) { }

  func companyServiceDidSetEmployees(_ employees: [String], oldEmployees: [String]) { }
}
// sourcery:end
