//
//  main.swift
//  NodeResolver
//
//  Created by Karsten Bruns on 16.09.17.
//

import Foundation


protocol ReferencableNode {
    associatedtype Ref: Hashable
    var ref: Ref { get }
}



enum GraphResolverError<In: ReferencableNode>: Error {
    case circularReference(node: In.Ref, edge: In.Ref)
    case missing(In.Ref)
    case cannotRealize(In.Ref)
}



struct ResolvedGraph<R, Out: ReferencableNode> {
    let matchingInput: R
    let nodes: [Out.Ref:Out]

    init(matching: R, nodes: [Out.Ref:Out]) {
        self.matchingInput = matching
        self.nodes = nodes
    }
}



protocol GraphResolver {
    associatedtype In: ReferencableNode
    associatedtype Out: ReferencableNode

    func realize(node: In, edges: [Out.Ref:Out]) throws -> Out
    func provideNode(for ref: In.Ref) throws -> In
    func provideEdges(for node: In) throws -> [In.Ref]
}



extension GraphResolver where In.Ref == Out.Ref {

    /// Resolves all edges/dependencies of the input value
    ///
    /// - Parameter node: An unresolved node in a graph
    /// - Returns: A `ResolvedGraph` type that holds a) the resolved equivalent of the `node` parameter and b) all nodes that needed to be resolved in the process
    /// - Throws: `GraphResolverError`
    func resolve(_ node: In) throws -> ResolvedGraph<Out, Out> {
        let results = try resolve([node])
        let result = ResolvedGraph<Out, Out>(matching: results.matchingInput.first!, nodes: results.nodes)
        return result
    }


    /// Resolves all edges/dependencies of the input values
    ///
    /// - Parameter nodes: A list of unresolved nodes in a graph
    /// - Returns: A `ResolvedGraph` type that holds a) the resolved equivalents of the `nodes` parameter and b) all nodes that needed to be resolved in the process
    /// - Throws: `GraphResolverError`
    func resolve(_ nodes: [In]) throws -> ResolvedGraph<[Out], Out> {
        var resolvedNodes: [Out.Ref:Out] = [:]
        var unresolvedNodes: Set<In.Ref> = []

        for node in nodes {
            guard resolvedNodes[node.ref] == nil else { continue }
            try resolveRecursivly(node, resolvedNodes: &resolvedNodes, unresolvedNodes: &unresolvedNodes)
        }

        let result = ResolvedGraph<[Out], Out>(matching: nodes.map({ resolvedNodes[$0.ref]! }), nodes: resolvedNodes)
        resolvedNodes.removeAll(keepingCapacity: true)
        unresolvedNodes.removeAll(keepingCapacity: true)
        return result
    }


    private func resolveRecursivly(_ node: In, resolvedNodes: inout [Out.Ref:Out], unresolvedNodes: inout Set<In.Ref>) throws {
        var edges: [Out.Ref:Out] = [:]
        unresolvedNodes.insert(node.ref)

        for edgeRef in try provideEdges(for: node) {
            if resolvedNodes[edgeRef] == nil {
                if unresolvedNodes.contains(edgeRef) {
                    throw GraphResolverError<In>.circularReference(node: node.ref, edge: edgeRef)
                }

                let edge = try provideNode(for: edgeRef)
                try resolveRecursivly(edge, resolvedNodes: &resolvedNodes, unresolvedNodes: &unresolvedNodes)
            }

            edges[edgeRef] = resolvedNodes[edgeRef]
        }

        let resolved = try realize(node: node, edges: edges)
        resolvedNodes[resolved.ref] = resolved
        unresolvedNodes.remove(node.ref)
    }
}



struct Value: ReferencableNode {
    typealias Ref = String
    var ref: String { return name }
    var edges: [String] { return include }

    let name: String
    let include: [String]
    let value: Int

    init(name: String, include: [String], value: Int) {
        self.name = name
        self.include = include
        self.value = value
    }
}



struct Sum: ReferencableNode {
    typealias Ref = String
    var ref: String { return name }

    let name: String
    let value: Int

    init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
}


let a = Value(name: "a", include: ["b", "d"], value: 0)
let b = Value(name: "b", include: ["c", "e"], value: 0)
let c = Value(name: "c", include: ["d", "e"], value: 0)
let d = Value(name: "d", include: [], value: 3)
let e = Value(name: "e", include: [], value: 5)


class SumBuilder: GraphResolver {

    typealias In = Value
    typealias Out = Sum

    let allValues: [Value]


    func realize(node: Value, edges: [Sum.Ref:Sum]) throws -> Sum {
        var result = node.value
        for (_, value) in edges {
            let sum = value
            result += sum.value
        }
        return Sum(name: node.name, value: result)
    }


    func provideNode(for ref: String) throws -> Value {
        guard let node = allValues.first(where: { $0.ref == ref }) else {
            throw GraphResolverError<Value>.missing(ref)
        }
        return node
    }


    func provideEdges(for node: Value) throws -> [String] {
        return node.include
    }


    init(allValues: [Value]) {
        self.allValues = allValues
    }
}



do {
    let sumBuilder = SumBuilder(allValues: [a, b, c, d, e])
    let resolvedGraph = try sumBuilder.resolve([a])
    print(resolvedGraph.matchingInput)
} catch let error {
    print(error)
}
