import GrammarModels

/// An intention that comes from the reading of a source code file, instead of
/// being synthesized
public class FromSourceIntention: Intention {
    public var source: ASTNode?
    public var accessLevel: AccessLevel
    
    public init(scope: AccessLevel, source: ASTNode?) {
        self.accessLevel = scope
        self.source = source
    }
}

/// An intention to generate a class, struct or enumeration in swift.
public class TypeGenerationIntention: FromSourceIntention {
    public var typeName: String
    
    public var superclassName: String? = "NSObject"
    public var protocols: [ProtocolInheritanceIntention] = []
    public var instanceVariables: [InstanceVariableGenerationIntention] = []
    public var properties: [PropertyGenerationIntention] = []
    public var methods: [MethodGenerationIntention] = []
    
    public init(typeName: String, scope: AccessLevel = .internal, source: ASTNode? = nil) {
        self.typeName = typeName
        
        super.init(scope: scope, source: source)
    }
}

/// An intention to generate a property or method on a type
public class MemberGenerationIntention: FromSourceIntention {
    
}

/// An intention to generate a property, either static/instance, computed/stored
/// for a type definition.
public class PropertyGenerationIntention: MemberGenerationIntention {
    public var typedSource: PropertyDefinition? {
        return source as? PropertyDefinition
    }
    
    public var name: String
    public var type: ObjcType
    
    public init(name: String, type: ObjcType, scope: AccessLevel = .internal, source: ASTNode? = nil) {
        self.name = name
        self.type = type
        super.init(scope: scope, source: source)
    }
}

/// An intention to generate a static/instance function for a type.
public class MethodGenerationIntention: MemberGenerationIntention {
    public var typedSource: MethodDefinition? {
        return source as? MethodDefinition
    }
    
    public var signature: Signature
    
    public var name: String {
        return signature.name
    }
    public var returnType: ObjcType {
        return signature.returnType
    }
    public var parameters: [Parameter] {
        return signature.parameters
    }
    
    public init(name: String, returnType: ObjcType,
                returnTypeNullabilitySpecifier: TypeNullability,
                parameters: [Parameter], scope: AccessLevel = .internal, source: ASTNode? = nil) {
        self.signature =
            Signature(name: name, returnType: returnType,
                      returnTypeNullability: returnTypeNullabilitySpecifier,
                      parameters: parameters)
        super.init(scope: scope, source: source)
    }
    
    public init(signature: Signature, scope: AccessLevel = .internal, source: ASTNode? = nil) {
        self.signature = signature
        super.init(scope: scope, source: source)
    }
    
    public struct Signature {
        public var name: String
        public var returnType: ObjcType
        public var returnTypeNullability: TypeNullability
        public var parameters: [Parameter]
    }
    
    public struct Parameter {
        public var label: String
        public var name: String
        public var nullability: TypeNullability
        public var type: ObjcType
    }
}

/// Access level visibility for a member or type
public enum AccessLevel: String {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
}

extension MethodGenerationIntention.Signature: Equatable {
    public static func ==(lhs: MethodGenerationIntention.Signature, rhs: MethodGenerationIntention.Signature) -> Bool {
        return lhs.name == rhs.name && lhs.parameters == rhs.parameters && lhs.returnType == rhs.returnType
    }
}

extension MethodGenerationIntention.Parameter: Equatable {
    public static func ==(lhs: MethodGenerationIntention.Parameter, rhs: MethodGenerationIntention.Parameter) -> Bool {
        return lhs.name == rhs.name && lhs.label == rhs.label && lhs.nullability == rhs.nullability && lhs.type == rhs.type
    }
}
