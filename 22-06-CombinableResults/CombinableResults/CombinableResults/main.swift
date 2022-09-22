import Foundation


protocol Mixable { }


struct ThingResult: Mixable {
  let value: String
}

struct StuffResult: Mixable {
  let value: String
}

struct SomeResult: Mixable {
  let value: String
}


let firstMix = ThingResult(value: "Thing!")
  .mixIn(StuffResult(value: "Stuff!"))
  .mixIn(SomeResult(value: "Some?"))
  .mixIn(ThingResult(value: "Thing?"))


// Stage, Contributer, Composer, Mixer
struct SomeStage {
  let value: String
  func mixIn<T: ThingResultInput>(_ other: T) -> SomeResultOutput<T> {
    other.mixIn(SomeResult(value: value + other.thingResult.value))
  }
}

let secondMix = SomeStage(value: "Some!").mixIn(firstMix)

print(secondMix.thingResult)
print(secondMix.stuffResult)
print(secondMix.someResult)
