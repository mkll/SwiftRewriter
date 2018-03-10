import XCTest
import ExpressionPasses
import SwiftRewriterLib
import SwiftAST

class FoundationExpressionPassTests: ExpressionPassTestCase {
    override func setUp() {
        super.setUp()
        
        sut = FoundationExpressionPass()
    }
    
    func testIsEqualToString() {
        let res = assertTransformParsed(
            expression: "[self.aString isEqualToString:@\"abc\"]",
            into: .binary(lhs: .postfix(.identifier("self"), .member("aString")),
                          op: .equals,
                          rhs: .constant("abc"))
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .bool)
    }
    
    func testIsEqualToStringNullable() {
        let exp =
            Expression
                .identifier("aString").optional()
                .dot("isEqualToString")
                .call([.constant("abc")])
        
        let res = assertTransform(
            expression: exp,
            into: Expression
                .identifier("aString")
                .binary(op: .equals, rhs: .constant("abc"))
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .bool)
    }
    
    func testNSStringWithFormat() {
        
        
        var res = assertTransformParsed(
            expression: "[NSString stringWithFormat:@\"%@\", self]",
            into: Expression
                .identifier("String")
                .call([
                    .labeled("format", .constant("%@")),
                    .unlabeled(.identifier("self"))
                    ])
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .string)
        
        res = assertTransformParsed(
            expression: "[NSString stringWithFormat:@\"%@\"]",
            into: Expression
                .identifier("String")
                .call([.labeled("format", .constant("%@"))])
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .string)
    }
    
    func testAddObjectsFromArray() {
        let res = assertTransformParsed(
            expression: "[array addObjectsFromArray:@[]]",
            into: Expression
                .identifier("array")
                .dot("addObjects")
                .call([.labeled("from", .arrayLiteral([]))])
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .void)
    }
    
    func testAddObjectsFromArrayNullable() {
        let exp =
            Expression
                .identifier("array")
                .optional()
                .dot("addObjectsFromArray")
                .call([.arrayLiteral([])])
        
        let res = assertTransform(
            expression: exp,
            into: Expression
                .identifier("array")
                .optional()
                .dot("addObjects")
                .call([.labeled("from", .arrayLiteral([]))])
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .optional(.void))
    }
    
    func testNSArrayArrayCreator() {
        let res = assertTransformParsed(
            expression: "[NSArray array]",
            into: Expression.identifier("NSArray").call()
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .typeName("NSArray"))
        
        // Test unrecognized members are left alone
        assertTransformParsed(
            expression: "[NSArray array:thing]",
            into: "NSArray.array(thing)"
        ); assertDidNotNotifyChange()
    }
    
    func testNSMutableArrayArrayCreator() {
        let res = assertTransformParsed(
            expression: "[NSMutableArray array]",
            into: Expression.identifier("NSMutableArray").call()
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .typeName("NSMutableArray"))
        
        // Test unrecognized members are left alone
        assertTransformParsed(
            expression: "[NSMutableArray array:thing]",
            into: "NSMutableArray.array(thing)"
        ); assertDidNotNotifyChange()
    }
    
    func testNSDictionaryDictionaryCreator() {
        let res = assertTransformParsed(
            expression: "[NSDictionary dictionary]",
            into: Expression.identifier("NSDictionary").call()
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .typeName("NSDictionary"))
        
        // Test unrecognized members are left alone
        assertTransformParsed(
            expression: "[NSDictionary dictionary:thing]",
            into: "NSDictionary.dictionary(thing)"
        ); assertDidNotNotifyChange()
    }
    
    func testNSMutableDictionaryDictionaryCreator() {
        let res = assertTransformParsed(
            expression: "[NSMutableDictionary dictionary]",
            into: Expression.identifier("NSMutableDictionary").call()
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .typeName("NSMutableDictionary"))
        
        // Test unrecognized members are left alone
        assertTransformParsed(
            expression: "[NSMutableDictionary dictionary:thing]",
            into: "NSMutableDictionary.dictionary(thing)"
        ); assertDidNotNotifyChange()
    }
    
    func testNSSetSetCreator() {
        let res = assertTransformParsed(
            expression: "[NSSet set]",
            into: Expression.identifier("NSSet").call()
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .typeName("NSSet"))
        
        // Test unrecognized members are left alone
        assertTransformParsed(
            expression: "[NSSet set:thing]",
            into: "NSSet.set(thing)"
        ); assertDidNotNotifyChange()
    }
    
    func testNSMutableSetSetCreator() {
        let res = assertTransformParsed(
            expression: "[NSMutableSet set]",
            into: Expression.identifier("NSMutableSet").call()
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .typeName("NSMutableSet"))
        
        // Test unrecognized members are left alone
        assertTransformParsed(
            expression: "[NSMutableSet set:thing]",
            into: "NSMutableSet.set(thing)"
        ); assertDidNotNotifyChange()
    }
    
    func testNSDateDateCreator() {
        let res = assertTransformParsed(
            expression: "[NSDate date]",
            into: Expression.identifier("Date").call()
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .typeName("NSDate"))
        
        // Test unrecognized members are left alone
        assertTransformParsed(
            expression: "[NSDate date:thing]",
            into: "Date.date(thing)"
        ); assertNotifiedChange()
    }
    
    func testNSTimeZoneSystemTimeZone() {
        let res = assertTransformParsed(
            expression: "[NSTimeZone systemTimeZone]",
            into: Expression.identifier("TimeZone").dot("current")
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .typeName("TimeZone"))
        
        assertTransformParsed(
            expression: "NSTimeZone.systemTimeZone",
            into: Expression.identifier("TimeZone").dot("current")
        ); assertNotifiedChange()
        
        // Test unrecognized members are left alone
        assertTransformParsed(
            expression: "[NSTimeZone systemTimeZone:thing]",
            into: "TimeZone.systemTimeZone(thing)"
        ); assertNotifiedChange()
    }
    
    func testNSTimeZoneTransformers() {
        assertTransformParsed(
            expression: "NSTimeZone.localTimeZone",
            into: Expression.identifier("TimeZone").dot("autoupdatingCurrent")
        ); assertNotifiedChange()
        
        assertTransformParsed(
            expression: "NSTimeZone.defaultTimeZone",
            into: Expression.identifier("TimeZone").dot("current")
        ); assertNotifiedChange()
        
        assertTransformParsed(
            expression: "NSTimeZone.systemTimeZone",
            into: Expression.identifier("TimeZone").dot("current")
        ); assertNotifiedChange()
    }
    
    func testNSLocaleTransformers() {
        assertTransformParsed(
            expression: "NSLocale.currentLocale",
            into: Expression.identifier("Locale").dot("current")
        ); assertNotifiedChange()
        
        assertTransformParsed(
            expression: "NSLocale.systemLocale",
            into: Expression.identifier("Locale").dot("current")
        ); assertNotifiedChange()
        
        assertTransformParsed(
            expression: "NSLocale.autoupdatingCurrentLocale",
            into: Expression.identifier("Locale").dot("autoupdatingCurrent")
        ); assertNotifiedChange()
    }
    
    func testClassTypeMethod() {
        // Uppercase -> <Type>.self
         assertTransformParsed(
            expression: "[NSObject class]",
            into: Expression.identifier("NSObject").dot("self")
        ); assertNotifiedChange()
        
        // lowercase -> type(of: <object>)
        assertTransformParsed(
            expression: "[object class]",
            into: Expression
                .identifier("type")
                .call([.labeled("of", .identifier("object"))])
        ); assertNotifiedChange()
        
        assertTransformParsed(
            expression: "[[an expression] class]",
            into: Expression
                .identifier("type")
                .call([.labeled("of", Expression.identifier("an").dot("expression").call())])
        ); assertNotifiedChange()
        
        // Test we don't accidentally convert things that do not match [<exp> class]
        // by mistake.
        assertTransformParsed(
            expression: "[NSObject class:aThing]",
            into: Expression
                .identifier("NSObject")
                .dot("class")
                .call([.unlabeled(.identifier("aThing"))])
        ); assertDidNotNotifyChange()
        
        assertTransformParsed(
            expression: "[object class:aThing]",
            into: Expression
                .identifier("object")
                .dot("class")
                .call([.unlabeled(.identifier("aThing"))])
        ); assertDidNotNotifyChange()
    }
    
    func testClassTypeMethodWithResolvedExpressionType() {
        // Tests that if an expression contains either a .metaType or other type
        // assigned to it, that the expression pass takes advantage of that to
        // make better deductions about whether a `[<exp> class]` invocation is
        // a class or instance invocation
        
        let typeNameExp = Expression.identifier("aTypeName")
        typeNameExp.resolvedType = .metatype(for: .typeName("aTypeName"))
        
        let valueExp = Expression.identifier("LocalName")
        valueExp.resolvedType = .int
        
        let res = assertTransform(
            expression: typeNameExp.dot("class").call(),
            into: typeNameExp.dot("self")
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .metatype(for: .typeName("aTypeName")))
        
        assertTransform(
            expression: valueExp.dot("class").call(),
            into: Expression.identifier("type").call([.labeled("of", valueExp)])
        ); assertNotifiedChange()
    }
    
    func testRespondsToSelector() {
        // Tests conversion of 'respondsToSelector' methods
        
        let res = assertTransform(
            expression: Expression
                .identifier("a")
                .dot("respondsToSelector")
                .call([Expression.identifier("Selector").call([.constant("selector:")])]),
            into: Expression
                .identifier("a")
                .dot("responds")
                .call([
                    .labeled("to", Expression
                        .identifier("Selector").call([
                            .constant("selector:")
                            ]))
                    ])
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .bool)
    }
    
    func testRespondsToSelectorNullable() {
        // Tests conversion of 'respondsToSelector' methods over nullable types
        
        let res = assertTransform(
            expression: Expression
                .identifier("a")
                .optional()
                .dot("respondsToSelector")
                .call([Expression.identifier("Selector").call([.constant("selector:")])]),
            into: Expression
                .identifier("a")
                .optional()
                .dot("responds")
                .call([
                    .labeled("to", Expression
                        .identifier("Selector").call([
                            .constant("selector:")
                            ]))
                    ])
        ); assertNotifiedChange()
        
        XCTAssertEqual(res.resolvedType, .optional(.bool))
    }
}
