//
//  useGV.swift
//  graphvizTest
//
//  Created by Klaus Kneupner on 29/1/17.
//  Copyright © 2017 Klaus Kneupner. All rights reserved.
//

import XCTest

class GraphvizTest: XCTestCase {

    func testGraphviz() {


        let g = GVGraph(name: "my Graph")

        let n1 = g.newNode(name: "n1")
        let n2 = g.newNode(name: "n2")
        let n3 = g.newNode(name: "n3")
        let n4 = g.newNode(name: "n4")
        XCTAssertEqual(g.nodes.count, 4)
        let e1 = g.newEdge(from: n1, to: n2, name: "e1")
        let e2 = g.newEdge(from: n2, to: n3, name: "e2")
        let e3 = g.newEdge(from: n4, to: n3, name: "e3")
        g.setNodeSize(node: n1, height: 50, width: 99)
        g.layout()
        let pos = g.getNodePos(node: n1)
        let pos2 = g.getEdgePos(edge: e3)


    }

}
