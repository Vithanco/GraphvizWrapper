//
//  GraphvizWrapper.swift
//  graphvizTest
//
//  Created by Klaus Kneupner on 3/2/17.
//  Copyright © 2017 Klaus Kneupner. All rights reserved.
//

import Foundation



public typealias Node = UnsafeMutablePointer<Agnode_t>
public typealias Edge = UnsafeMutablePointer<Agedge_t>
public typealias CHAR = UnsafeMutablePointer<Int8>
public typealias Spline = UnsafeMutablePointer<splines>
public typealias Bezier = UnsafeMutablePointer<bezier>

func pointTransformGraphvizToCGPoint(point: pointf_s) -> CGPoint {
	return CGPoint(x: Double(point.x), y: Double(point.y))
}


struct EdgeDraw {
	var path : [CGPoint]
	var arrowHead: CGPoint
	init (path: [pointf_s], arrowHead: pointf_s) {
		self.path = path.map(pointTransformGraphvizToCGPoint)
		self.arrowHead = pointTransformGraphvizToCGPoint(point: arrowHead)
	}
	init (){
		path = [NSZeroPoint]
		arrowHead = NSZeroPoint
	}
}


let pointsPerInch: CGFloat = 72.0


func cString(_ s: String) -> CHAR {
	return UnsafeMutablePointer<Int8>(mutating:(s as NSString).utf8String!)
}

func cPointsToInchParameter(_ x: CGFloat) -> CHAR {
	return cString("\(x/pointsPerInch)")
}


public class Graph {
	var gvc : OpaquePointer?
	var g: UnsafeMutablePointer<Agraph_t>
	
	let cHeight = cString("height")
	let cWidth = cString("width")
	let cMinDist = cString("mindist")
	let c100 = cPointsToInchParameter(100.0)
	let c20 = cPointsToInchParameter(20.0)
	let c2 = cPointsToInchParameter(2.0)
	let cDot = cString("dot")
	let cPng = cString("png")
	let cPos = cString("pos")
	
	init (_ name: String) {
		gvc = gvContext()
		g = agopen(cString(name), Agstrictdirected,nil);
		agattr(g, AGRAPH, cHeight, cString("10"))
		agattr(g, AGRAPH, cWidth, cString("10"))
		agattr(g, AGRAPH, cMinDist, c20)
		agattr(g, AGRAPH, cString("nodesep"), c2)
	}
	
	deinit {
		/* Free data */
		gvFreeLayout(gvc, g)
		agclose(g)
		gvFreeContext(gvc)
	}
	
	func newNode(name: String) ->Node  {
		let node = agnode(g,cString(name), 1) as Node //1 means true here, yes, please create a new one
		agsafeset(node, cString("shape"), cString("box"), cString("elipse"))
		return node
	}
	
	func newEdge(from: Node, to: Node, name: String) -> Edge {
		return agedge(g, from, to, cString(name), 1) //1 means true here, yes, please create a new one
	}
	
	func setNodeSize(node: Node, height: CGFloat, width: CGFloat){
		agsafeset(node, cHeight, cString("\(height/pointsPerInch)"), c100)
		agsafeset(node, cWidth, cString("\(width/pointsPerInch)"), c100)
	}
	
	func layout() {
		gvLayout(gvc, g, cDot)
		gvRender(gvc, g, cString("dot"), stdout)
		gvRenderFilename(gvc, g, cPng,cString("/users/Klaus/Downloads/test.png"));
	}
	
	func getNodePos(node: Node) -> CGPoint {
		//#define ND_coord(n) (((Agnodeinfo_t*)(((Agobj_t*)(obj))->data->coord))
		//let t =  node.pointee.base.data
		//print(t)
		//let tt = t!.withMemoryRebound(to: Agnodeinfo_t.self, capacity: 1) {return $0.pointee.coord}
		//let xx = tt.
		//print(tt)
		let s = agget(node, cPos)
		let str = String(utf8String: s!)
		let xStr = str!.components(separatedBy: ",")
		let x = CGFloat(Double(xStr[0])!)
		let y = CGFloat(Double(xStr[1])!)
		return CGPoint(x: x, y: y)
	}
	func getEdgePos(edge: Edge) -> EdgeDraw{
		let t =  edge.pointee.base.data
		//print(t)
		let spline = t!.withMemoryRebound(to: Agedgeinfo_t.self, capacity: 1) {return $0.pointee.spl} as Spline
		print(spline.pointee)
		if let bezier = spline.pointee.list {
			print(bezier.pointee)
			let nrPoints = Int(bezier.pointee.size)
			let pointer = UnsafeRawPointer(bezier.pointee.list).bindMemory(to: pointf_s.self, capacity: nrPoints)
			var points : [pointf_s] = []
			for i in 0..<nrPoints {
					points.append(pointer[i])
			}
			let result = EdgeDraw(path: points, arrowHead: bezier.pointee.ep)
			return result
		}
		assert(false, "\(spline.pointee.list)")
		return EdgeDraw()
	}
	
}
