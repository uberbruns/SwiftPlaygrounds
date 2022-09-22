// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
protocol Remixable { }



// MARK: - `SomeResult` Boxing Support

protocol SomeResultInput: Remixable {
  var someResult: SomeResult { get }
}

extension SomeResult: SomeResultInput {
  var someResult: SomeResult {
    self
  }
}

struct SomeResultOutput<Precursor>: SomeResultInput, Remixable {
  let someResult: SomeResult
  let precursor: Precursor
}

extension Remixable {
  func mixIn(_ someResult: SomeResult) -> SomeResultOutput<Self> {
    SomeResultOutput(someResult: someResult, precursor: self)
  }
}

extension SomeResultOutput: StuffResultInput where Precursor: StuffResultInput {
  var stuffResult: StuffResult {
    precursor.stuffResult
  }
}

extension SomeResultOutput: ThingResultInput where Precursor: ThingResultInput {
  var thingResult: ThingResult {
    precursor.thingResult
  }
}


// MARK: - `StuffResult` Boxing Support

protocol StuffResultInput: Remixable {
  var stuffResult: StuffResult { get }
}

extension StuffResult: StuffResultInput {
  var stuffResult: StuffResult {
    self
  }
}

struct StuffResultOutput<Precursor>: StuffResultInput, Remixable {
  let stuffResult: StuffResult
  let precursor: Precursor
}

extension Remixable {
  func mixIn(_ stuffResult: StuffResult) -> StuffResultOutput<Self> {
    StuffResultOutput(stuffResult: stuffResult, precursor: self)
  }
}

extension StuffResultOutput: SomeResultInput where Precursor: SomeResultInput {
  var someResult: SomeResult {
    precursor.someResult
  }
}

extension StuffResultOutput: ThingResultInput where Precursor: ThingResultInput {
  var thingResult: ThingResult {
    precursor.thingResult
  }
}


// MARK: - `ThingResult` Boxing Support

protocol ThingResultInput: Remixable {
  var thingResult: ThingResult { get }
}

extension ThingResult: ThingResultInput {
  var thingResult: ThingResult {
    self
  }
}

struct ThingResultOutput<Precursor>: ThingResultInput, Remixable {
  let thingResult: ThingResult
  let precursor: Precursor
}

extension Remixable {
  func mixIn(_ thingResult: ThingResult) -> ThingResultOutput<Self> {
    ThingResultOutput(thingResult: thingResult, precursor: self)
  }
}

extension ThingResultOutput: SomeResultInput where Precursor: SomeResultInput {
  var someResult: SomeResult {
    precursor.someResult
  }
}

extension ThingResultOutput: StuffResultInput where Precursor: StuffResultInput {
  var stuffResult: StuffResult {
    precursor.stuffResult
  }
}

