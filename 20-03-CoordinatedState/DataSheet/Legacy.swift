//
//  Legacy.swift
//  DataSheet
//
//  Created by Karsten Bruns on 05.04.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation



/*
 struct Field<T> {
 let name: String
 
 init(_ name: String) {
 self.name = name
 }
 }
 
 
 enum MyFields {
 static var apples = Field<Int>("apples")
 }
 
 
 class ResolvableValue<F> {
 
 private class Map<F, V, R>: ResolvableValue<F> {
 typealias FieldType = F
 typealias Body = (V) -> R
 
 let body: Body
 let value: KeyPath<F, V>
 
 init(_ value: KeyPath<F, V>, _ body: @escaping Body) {
 self.value = value
 self.body = body
 super.init()
 self.linkedFields = [value]
 }
 
 override func resolve(with values: [PartialKeyPath<F>: ResolvableValue<F>]) -> Any {
 if let resolvedValue = values[value]?.resolvedValue as? V {
 return body(resolvedValue)
 } else {
 fatalError()
 }
 }
 }
 
 private class Zip<F, VA, VB, R>: ResolvableValue<F> {
 typealias FieldType = F
 typealias Zip2Body = (VA, VB) -> R
 
 let body: Zip2Body
 let valueA: KeyPath<F, VA>
 let valueB: KeyPath<F, VB>
 
 init(_ valueA: KeyPath<F, VA>, _ valueB: KeyPath<F, VB>, _ body: @escaping Zip2Body) {
 self.valueA = valueA
 self.valueB = valueB
 self.body = body
 super.init()
 self.linkedFields = [valueA, valueB]
 }
 
 override func resolve(with values: [PartialKeyPath<F>: ResolvableValue<F>]) -> Any {
 if let resolvedValueA = values[valueA]?.resolvedValue as? VA,
 let resolvedValueB = values[valueB]?.resolvedValue as? VB {
 return body(resolvedValueA, resolvedValueB)
 } else {
 fatalError()
 }
 }
 }
 
 private(set) var linkedFields: [PartialKeyPath<F>] = []
 var resolvedValue: Any?
 
 func resolve(with values: [PartialKeyPath<F>: ResolvableValue<F>]) -> Any {
 fatalError()
 }
 
 static func map<V, R>(_ value: KeyPath<F, V>, _ body: @escaping (V) -> R) -> ResolvableValue<F> {
 return Map(value, body)
 }
 
 static func zip<VA, VB, R>(_ valueA: KeyPath<F, VA>, _ valueB: KeyPath<F, VB>, _ body: @escaping (VA, VB) -> R) -> ResolvableValue<F> {
 return Zip(valueA, valueB, body)
 }
 
 fileprivate init() { }
 }
 
 
 class StaticValue<F, R>: ResolvableValue<F> {
 let value: R
 
 init(_ value: R) {
 self.value = value
 }
 
 override func resolve(with values: [PartialKeyPath<F>: ResolvableValue<F>]) -> Any {
 return value
 }
 }
 
 
 
 struct FruitCollection {
 var apples = 5
 var pears = 2
 var sum = 7
 var displaySum: String
 }
 
 
 class Model<F> {
 
 private var values: [PartialKeyPath<F>: ResolvableValue<F>]
 
 subscript<V>(_ keyPath: KeyPath<F, V>) -> V {
 get {
 return values[keyPath]!.resolvedValue as! V
 }
 set {
 unresolve(keyPath)
 values[keyPath] = StaticValue(newValue)
 resolve()
 }
 }
 
 subscript<V>(_ keyPath: KeyPath<F, V>) -> ResolvableValue<F> {
 get {
 return values[keyPath]!
 }
 set {
 unresolve(keyPath)
 values[keyPath] = newValue
 resolve()
 }
 }
 
 init(_ values: [PartialKeyPath<F>: ResolvableValue<F>] = [:]) {
 self.values = values
 }
 
 private func unresolve(_ invalidatedKeyPath: PartialKeyPath<F>) {
 values[invalidatedKeyPath]?.resolvedValue = nil
 for (keyPath, value) in values {
 if value.linkedFields.contains(invalidatedKeyPath) {
 unresolve(keyPath)
 }
 }
 }
 
 private func resolve() {
 var unresolvedValues = values.values.filter({ $0.resolvedValue == nil })
 
 while true {
 var solvedSomething = false
 for valueIndex in unresolvedValues.indices.reversed() {
 let value = unresolvedValues[valueIndex]
 
 let resolveValue = {
 value.resolvedValue = value.resolve(with: self.values)
 unresolvedValues.remove(at: valueIndex)
 solvedSomething = true
 }
 
 if value.linkedFields.isEmpty {
 resolveValue()
 } else {
 let hasUnresolvedKeyPath = value.linkedFields.contains { (keyPath) -> Bool in
 return self.values[keyPath]?.resolvedValue == nil
 }
 if !hasUnresolvedKeyPath {
 resolveValue()
 }
 }
 }
 
 if !solvedSomething {
 break
 }
 }
 }
 }
 
 
 
 let fruitModel = Model([
 \FruitCollection.sum: .zip(\.apples, \.pears) { $0 + $1 },
 \FruitCollection.displaySum: .map(\.sum) { "You have \($0) fruits." },
 ])
 
 fruitModel[\.apples] = 2
 fruitModel[\.pears] = 7
 dump(fruitModel[\.displaySum] as String)
 
 fruitModel[\.pears] = 5
 dump(fruitModel[\.displaySum] as String)
 
 */
