import Foundation


protocol SomeLinkedBox {
  associatedtype ContentType
  associatedtype PreviousContentType

  var content: ContentType { get }
  var previousContent: PreviousContentType { get }
}


struct LinkedBox<Content, PreviousContent>: SomeLinkedBox {
  var content: Content
  var previousContent: PreviousContent
}


extension SomeLinkedBox {
  func get(_ type: ContentType.Type) -> ContentType {
    content
  }

  func get(_ type: PreviousContentType.Type) -> PreviousContentType {
    previousContent
  }
}


extension SomeLinkedBox where PreviousContentType: SomeLinkedBox {
  func get(_ type: PreviousContentType.ContentType.Type) -> PreviousContentType.ContentType {
    previousContent.get(type)
  }

  func get(_ type: PreviousContentType.PreviousContentType.Type) -> PreviousContentType.PreviousContentType {
    previousContent.get(type)
  }

}


struct StringField {
  var string: String
}

struct IntField {
  var int: Int
}


struct DoubleField {
  var double: Double
}


let box = LinkedBox(
  content: IntField(int: 1),
  previousContent: LinkedBox(
    content: DoubleField(double: 2),
    previousContent: LinkedBox(
      content: DoubleField(double: 2),
      previousContent: StringField(string: "foo")
    )
  )
)


print(box.get(IntField.self))
print(box.get(StringField.self))

