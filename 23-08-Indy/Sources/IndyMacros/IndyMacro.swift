import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public struct DependentMacro {
}


extension DependentMacro: PeerMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {

    guard let decl = declaration.as(ClassDeclSyntax.self) else {
      fatalError()
    }

    let protocolMembers = decl.memberBlock.members
      .filter { $0.decl.isCompatibleProperty }
      .compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings.first }
      .compactMap { binding -> String? in
        guard let typeAnnotation = binding.typeAnnotation else { return nil }
        return "var \(binding.pattern.trimmedDescription): \(typeAnnotation.type.trimmedDescription) { get }"
      }

    let peerDependencyProtocol: DeclSyntax =
      """
      protocol \(raw: decl.name.text)Dependencies: Dependencies {
          \(raw: protocolMembers.joined(separator: "\n"))
      }
      """

    return [peerDependencyProtocol]
  }
}


extension DependentMacro: MemberMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax, providingMembersOf
    declaration: some SwiftSyntax.DeclGroupSyntax,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    guard let decl = declaration.as(ClassDeclSyntax.self) else {
      fatalError()
    }

    let dependencyDeclarations = decl.memberBlock.members
      .filter { $0.decl.isCompatibleProperty }
      .compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings.first }

    let dependencyPropertyAssignments = dependencyDeclarations
      .compactMap { binding -> String? in
        let propertyName = binding.pattern.trimmedDescription
        return "self.\(propertyName) = dependencies.\(propertyName)"
      }

    let simplePropertyAssignments = dependencyDeclarations
      .compactMap { binding -> String? in
        let propertyName = binding.pattern.trimmedDescription
        return "self.\(propertyName) = \(propertyName)"
      }

    let memberwiseParameters = dependencyDeclarations
      .compactMap { binding -> String? in
        guard let typeAnnotation = binding.typeAnnotation else { return nil }
        let propertyName = binding.pattern.trimmedDescription
        let propertyType = typeAnnotation.type.trimmedDescription
        return "\(propertyName): \(propertyType)"
      }

    let dependencyInitializer: DeclSyntax =
      """
      init(dependencies: some \(raw: decl.name.text)Dependencies) {
          \(raw: dependencyPropertyAssignments.joined(separator: "\n"))
      }
      """

    let memberwiseInitializer: DeclSyntax =
      """
      init(\(raw: memberwiseParameters.joined(separator: ", "))) {
          \(raw: simplePropertyAssignments.joined(separator: "\n"))
      }
      """

    return [
      memberwiseInitializer,
      dependencyInitializer
    ]
  }
}


public struct DependencyMacro: PeerMacro {
  public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
    []
  }
}


@main
struct IndyPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    DependentMacro.self,
    DependencyMacro.self,
  ]
}


private extension DeclSyntaxProtocol {
  var isCompatibleProperty: Bool {
    if let property = self.as(VariableDeclSyntax.self),
       let binding = property.bindings.first, binding.accessorBlock == nil,
       property.attributes.contains(where: { $0.description.contains("@Dependency") })
    {
      return true
    } else {
      return false
    }
  }
}
