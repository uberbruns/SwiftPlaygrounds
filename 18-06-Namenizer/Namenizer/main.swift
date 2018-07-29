import Foundation


struct Tokenizer {
  enum Token {
    case text(String)
    case openedParenthesis
    case closedParenthesis
    case separator
  }

  func parse(string: String) -> [Token] {
    var tokens = [Token]()

    for character in string {
      switch character {
      case "[":
        tokens.append(.openedParenthesis)
      case "]":
        tokens.append(.closedParenthesis)
      case ",":
        tokens.append(.separator)
      default:
        if case let .text(textString)? = tokens.last {
          tokens[tokens.endIndex - 1] = .text(textString + String(character))
        } else {
          tokens.append(.text(String(character)))
        }
      }
    }
    return tokens
  }
}


struct AST {
  class Node {
    enum Kind {
      case alternative
      case appendix
    }

    var string: String
    var children: [Node]
    var kind: Kind

    init(string: String, kind: Kind) {
      self.string = string
      self.children = []
      self.kind = kind
    }
  }

  func parse(tokens: [Tokenizer.Token]) -> Node {
    let rootNode = Node(string: "", kind: .appendix)
    var parents = [rootNode]
    var kind = Node.Kind.appendix

    for token in tokens {
      switch token {
      case .text(let string):
        let node = Node(string: string, kind: kind)
        parents.last!.children.append(node)
      case .openedParenthesis:
        let node = Node(string: "", kind: kind)
        parents.last!.children.append(node)
        parents.append(node)
        kind = .alternative
      case .closedParenthesis:
        kind = .appendix
        parents.removeLast()
      case .separator:
        kind = .alternative
      }
    }
    return rootNode
  }
}


struct Parser {
  struct Result {
    let astRootNode: AST.Node
    let result: [String]
  }

  func parse(string: String) -> Parser.Result {
    let tokens = Tokenizer().parse(string: string)
    let astRootNode = AST().parse(tokens: tokens)
    var results = [""]

    func parseAST(node: AST.Node, resultsCopy: [String]? = nil) {
      var copy: [String]? = nil

      for child in node.children {
        let isLeaf = child.children.isEmpty

        if child.kind == .alternative && copy == nil {
          if let resultsCopy = resultsCopy {
            copy = resultsCopy
          } else {
            copy = results
            results.removeAll()
          }
        } else if child.kind != .alternative {
          copy = nil
        }

        switch (isLeaf, child.kind) {
        case (true, .appendix):
          results = results.map { $0 + child.string }

        case (true, .alternative):
          results += copy!.map { $0 + child.string }

        case (false, _):
          parseAST(node: child, resultsCopy: copy)
        }
      }
    }

    parseAST(node: astRootNode)

    return Result(astRootNode: astRootNode, result: results)
  }
}


func printVariations(of string: String, group: Int) {
  let results = Parser().parse(string: string)
  for (index, result) in results.result.sorted().enumerated() {
    print(result)
    if index % group == group - 1 {
      print("")
    }
  }
}

// printVariations(of: "interactor.[receive,request,viewDidRequest,viewRequests,requesting][ViewDidLoadCycle,AddressChange,Cancellation,Submission,BackNavigation]()", group: 5)
printVariations(of: "interactor.[receive][ViewDidLoad,AddressChange,Cancellation,Submission,BackNavigation][Request()]", group: 99999)
// printVariations(of: "interactor.[viewDidLoadCycle,addressChange,cancellation,submission,backNavigation]Requested()", group: 5)
