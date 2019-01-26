import SwiftSyntax
import SwiftAST
import Intentions

struct VariableDeclaration {
    var constant: Bool
    var attributes: [AttributeSyntax]
    var modifiers: [DeclModifierSyntax]
    var kind: VariableDeclarationKind
}

struct PatternBindingElement {
    var name: String
    var type: SwiftType?
    var intention: IntentionProtocol?
    var initialization: Expression?
}

enum VariableDeclarationKind {
    case single(pattern: PatternBindingElement, accessors: (() -> AccessorBlockSyntax)?)
    case multiple(patterns: [PatternBindingElement])
}