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
    static let senderKey = "senderKey"

    static let didSetCeo = Foundation.Notification.Name("CompanyServiceDidSetCeoNotification")
    static let didSetBouncer = Foundation.Notification.Name("CompanyServiceDidSetBouncerNotification")
    static let didSetEmployees = Foundation.Notification.Name("CompanyServiceDidSetEmployeesNotification")
  }

  private var _ceo: String
  private var _bouncer: String
  private var _employees: [String]
  // sourcery:end

  init() {
    self._ceo = ""
    self._employees = []
    self._bouncer = ""
  }
}


// sourcery:inline:CompanyService.ObserverProtocol
protocol CompanyServiceObserver: AnyObject {
  var companyService: CompanyService { get }
  var companyServiceObserverTokens: [Any] { get set }

  func startObservingCompanyService()
  func stopObservingCompanyService()

  func companyServiceDidSetCeo(_ ceo: String, oldCeo: String, sender: Any?)
  func companyServiceDidSetBouncer(_ bouncer: String, oldBouncer: String, sender: Any?)
  func companyServiceDidSetEmployees(_ employees: [String], oldEmployees: [String], sender: Any?)
}


extension CompanyService {

  // MARK: Ceo

  var ceo: String {
    get {
      return _ceo
    }
    set {
      setCeo(newValue, oldValue: _ceo, sender: nil)
    }
  }

  func setCeo(_ newValue: String, sender: Any?) {
    setCeo(newValue, oldValue: _ceo, sender: sender)
  }

  private func setCeo(_ newValue: String, oldValue: String, sender: Any?) {
    _ceo = newValue
    var userInfo: [AnyHashable: Any] = [Notification.newValueKey: newValue, Notification.oldValueKey: oldValue]
    if let sender = sender {
      userInfo[Notification.senderKey] = sender
    }
    NotificationCenter.default.post(name: Notification.didSetCeo, object: self, userInfo: userInfo)
  }

  // MARK: Bouncer

  var bouncer: String {
    get {
      return _bouncer
    }
    set {
      setBouncer(newValue, oldValue: _bouncer, sender: nil)
    }
  }

  func setBouncer(_ newValue: String, sender: Any?) {
    setBouncer(newValue, oldValue: _bouncer, sender: sender)
  }

  private func setBouncer(_ newValue: String, oldValue: String, sender: Any?) {
    _bouncer = newValue
    var userInfo: [AnyHashable: Any] = [Notification.newValueKey: newValue, Notification.oldValueKey: oldValue]
    if let sender = sender {
      userInfo[Notification.senderKey] = sender
    }
    NotificationCenter.default.post(name: Notification.didSetBouncer, object: self, userInfo: userInfo)
  }

  // MARK: Employees

  var employees: [String] {
    get {
      return _employees
    }
    set {
      setEmployees(newValue, oldValue: _employees, sender: nil)
    }
  }

  func setEmployees(_ newValue: [String], sender: Any?) {
    setEmployees(newValue, oldValue: _employees, sender: sender)
  }

  private func setEmployees(_ newValue: [String], oldValue: [String], sender: Any?) {
    _employees = newValue
    var userInfo: [AnyHashable: Any] = [Notification.newValueKey: newValue, Notification.oldValueKey: oldValue]
    if let sender = sender {
      userInfo[Notification.senderKey] = sender
    }
    NotificationCenter.default.post(name: Notification.didSetEmployees, object: self, userInfo: userInfo)
  }
}


extension CompanyServiceObserver {
  func startObservingCompanyService() {
    let center = NotificationCenter.default

    companyServiceObserverTokens.append(center.addObserver(forName: CompanyService.Notification.didSetCeo, object: companyService, queue: .main) { [weak self] notification in
      guard let newValue = notification.userInfo?[CompanyService.Notification.newValueKey] as? String,
        let oldValue = notification.userInfo?[CompanyService.Notification.oldValueKey] as? String else { return }
      let sender = notification.userInfo?[CompanyService.Notification.senderKey]
      self?.companyServiceDidSetCeo(newValue, oldCeo: oldValue, sender: sender)
    })

    companyServiceObserverTokens.append(center.addObserver(forName: CompanyService.Notification.didSetBouncer, object: companyService, queue: .main) { [weak self] notification in
      guard let newValue = notification.userInfo?[CompanyService.Notification.newValueKey] as? String,
        let oldValue = notification.userInfo?[CompanyService.Notification.oldValueKey] as? String else { return }
      let sender = notification.userInfo?[CompanyService.Notification.senderKey]
      self?.companyServiceDidSetBouncer(newValue, oldBouncer: oldValue, sender: sender)
    })

    companyServiceObserverTokens.append(center.addObserver(forName: CompanyService.Notification.didSetEmployees, object: companyService, queue: .main) { [weak self] notification in
      guard let newValue = notification.userInfo?[CompanyService.Notification.newValueKey] as? [String],
        let oldValue = notification.userInfo?[CompanyService.Notification.oldValueKey] as? [String] else { return }
      let sender = notification.userInfo?[CompanyService.Notification.senderKey]
      self?.companyServiceDidSetEmployees(newValue, oldEmployees: oldValue, sender: sender)
    })
  }

  func stopObservingCompanyService() {
    let notificationCenter = NotificationCenter.default
    for token in companyServiceObserverTokens {
      notificationCenter.removeObserver(token)
    }
  }

  func companyServiceDidSetCeo(_ ceo: String, oldCeo: String, sender: Any?) { }

  func companyServiceDidSetBouncer(_ bouncer: String, oldBouncer: String, sender: Any?) { }

  func companyServiceDidSetEmployees(_ employees: [String], oldEmployees: [String], sender: Any?) { }
}
// sourcery:end
