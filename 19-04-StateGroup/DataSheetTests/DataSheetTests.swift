//
//  DataSheetTests.swift
//  DataSheetTests
//
//  Created by Karsten Bruns on 07.04.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import XCTest


protocol AppStateProtocol: StateGroup {
  var isNetworkAvailable: State<Bool> { get }
  var isLoggedIn: State<Bool> { get }
  var isReady: State<Bool> { get }
}


class AppState: StateGroup, AppStateProtocol {
  lazy var isNetworkAvailable = value(false)
  lazy var isLoggedIn = value(false)
  lazy var isReady = zip(isNetworkAvailable, isLoggedIn) { (isNetworkAvailable, isLoggedIn) -> Bool in
    self.isReadyVisits += 1
    return isNetworkAvailable && isLoggedIn
  }

  var isReadyVisits = 0
}


class ViewState: StateGroup {
  weak var appState: AppStateProtocol!

  lazy var showNetworkUnavailableMessage = map(appState.isNetworkAvailable) { !$0 }
  lazy var showContent = map(appState.isReady) { $0 }
  lazy var loginButtonTitle = map(appState.isLoggedIn) { $0 ? "Log Out" : "Log In" }

  init(appState: AppStateProtocol) {
    self.appState = appState
  }
}



class DataSheetTests: XCTestCase {

  var appState: AppState!
  var viewState: ViewState!
  var observationPool: ObservationPool!

  override func setUp() {
    self.appState = AppState()
    self.viewState = ViewState(appState: appState)
    self.observationPool = ObservationPool()
  }

  func test_valueAccess() {
    XCTAssertEqual(appState.isReady.value, false)
  }

  func test_zip1() {
    appState.isNetworkAvailable.value = true
    XCTAssertEqual(appState.isReady.value, false)
  }

  func test_zip2() {
    appState.isLoggedIn.value = true
    XCTAssertEqual(appState.isReady.value, false)
    XCTAssertEqual(viewState.showContent.value, false)
  }

  func test_zip3() {
    appState.isNetworkAvailable.value = true
    appState.isLoggedIn.value = true
    XCTAssertEqual(appState.isReady.value, true)
  }

  func test_map1() {
    XCTAssertEqual(viewState.showNetworkUnavailableMessage.value, true)
  }

  func test_map2() {
    appState.isNetworkAvailable.value = true
    XCTAssertEqual(viewState.showNetworkUnavailableMessage.value, false)
  }

  func test_map3() {
    appState.isLoggedIn.value = true
    XCTAssertEqual(viewState.loginButtonTitle.value, "Log Out")
  }

  func test_map4() {
    appState.isLoggedIn.value = false
    XCTAssertEqual(viewState.loginButtonTitle.value, "Log In")
  }

  func test_observation_variable() {
    var isNetworkAvailable = false

    appState.isNetworkAvailable.observe { value in
      isNetworkAvailable = value
    }.retain(in: observationPool)

    appState.isNetworkAvailable.value = true

    XCTAssertTrue(isNetworkAvailable)
  }

  func test_observation_zip() {
    var showContent = false
    var showContentVisits = 0

    viewState.showContent.observe { value in
      showContent = value
      showContentVisits += 1
    }.retain(in: observationPool)

    appState.isNetworkAvailable.value = true
    XCTAssertEqual(showContent, false)

    appState.isLoggedIn.value = true
    XCTAssertEqual(showContent, true)

    XCTAssertEqual(showContentVisits, 1)
    XCTAssertEqual(appState.isReadyVisits, 3)
  }

  func test_observation_visits() {
    var showContent = false
    var showContentVisits = 0

    viewState.showContent.observe { value in
      showContent = value
      showContentVisits += 1
    }.retain(in: observationPool)

    // Not changing `isNetworkAvailable` values should not increase `isReadyVisits` visits
    appState.isNetworkAvailable.value = true
    appState.isNetworkAvailable.value = true
    appState.isNetworkAvailable.value = true
    appState.isNetworkAvailable.value = true

    // Changing `isNetworkAvailable` values should increase `isReadyVisits` visits, but
    // not trigger the `showContent` observation
    appState.isNetworkAvailable.value = false
    appState.isNetworkAvailable.value = true

    // Changing `isNetworkAvailable` and `isLoggedIn` value to true should
    // trigger the `showContent` observation
    appState.isNetworkAvailable.value = true
    appState.isLoggedIn.value = true
    XCTAssertTrue(showContent)

    XCTAssertEqual(showContentVisits, 1)
    XCTAssertEqual(appState.isReadyVisits, 5)
  }

  func test_observation_memory1() {
    var observeVisits = 0
    weak var weakViewState: ViewState? = nil
    weak var weakObservationPool: ObservationPool? = nil
    weak var weakToken: StateGroup.State<Bool>.Token? = nil

    do {
      let observationPool = ObservationPool()
      weakObservationPool = observationPool

      let viewState = ViewState(appState: self.appState)
      weakViewState = viewState

      let token = viewState.showNetworkUnavailableMessage.observe { value in
        observeVisits += 1
      }
      weakToken = token
      token.retain(in: observationPool)

      self.appState.isNetworkAvailable.value = true

      XCTAssertNotNil(weakViewState)
      XCTAssertNotNil(weakObservationPool)
      XCTAssertNotNil(weakToken)
    }

    appState.isNetworkAvailable.value = false

    XCTAssertEqual(observeVisits, 1)
    XCTAssertNil(weakViewState)
    XCTAssertNil(weakObservationPool)
    XCTAssertNil(weakToken)
  }
}

