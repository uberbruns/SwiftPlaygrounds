//
//  main.swift
//  StructuredDataFlow
//
//  Created by Karsten Bruns on 12.01.23.
//

import AsyncAlgorithms
import Foundation


struct User {
  let name: String
}


actor UserProvider {
  let channel = AsyncChannel<User?>()
}


struct UserStatus {
  let signedIn: Bool
}


actor UserStatusProvider {
  let channel = AsyncChannel<UserStatus>()
  init() { }
}



struct TripInfo {
  let id: String
}


actor TripInfoProvider {
  let channel = AsyncChannel<TripInfo>()
  init() { }
}


struct TripOrder {
  let id: String
}


actor TripOrderProvider {
  let channel = AsyncChannel<TripOrder>()
  init() { }
  func orderTrip() { }
}


enum PaymentInitiation {
  case loading
  case succeeded
  case failed
}


actor PaymentInitiationProvider {
  let channel = AsyncChannel<PaymentInitiation>()
  init() { }
}


struct Tipping {
}


actor TippingProvider {
  init() { }
  func channel(trip: TripInfo) -> AsyncChannel<Tipping> {
    let channel = AsyncChannel<Tipping>()
    return channel
  }
}


struct TripGuidance {
}


actor TripGuidanceProvider {
  init() { }
  func channel(trip: TripInfo) -> AsyncChannel<TripGuidance> {
    let channel = AsyncChannel<TripGuidance>()
    return channel
  }
}



let userProvider = UserProvider()



for await user in userProvider.channel {
  guard let user = user else { continue }

  let paymentInitiationProvider = PaymentInitiationProvider()
  let tripOrderProvider = TripOrderProvider()
  let tripInfoProvider = TripInfoProvider()
  let tippingProvider = TippingProvider()
  let tripGuidanceProvider = TripGuidanceProvider()

  for await paymentInitiation in paymentInitiationProvider.channel {
    if case .succeeded = paymentInitiation {
      await tripOrderProvider.orderTrip()
    }
  }

  for await tripInfo in tripInfoProvider.channel {
    let combined = await combineLatest(
      tripGuidanceProvider.channel(trip: tripInfo),
      tippingProvider.channel(trip: tripInfo)
    )
    for await (tripGuidance, tippingProvider) in combined {

    }
  }
}
