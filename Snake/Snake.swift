//
//  Snake.swift
//  Snake
//
//  Created by segev perets on 20/11/2023.
//

import UIKit

// MARK: - Create Snake

class Node: UIView {
    var nextNode: Node?
    
    ///ignore the size
    override init(frame: CGRect) {
        let size = CGSize(width: 20, height: 20)
        super.init(frame: .init(origin: frame.origin, size: size))
        self.backgroundColor = .blue
        self.layer.cornerRadius = 7
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Snake {
    let superView: UIView
    var head: Node
    enum Direction {case up,down,left,right}
    
    init(_ point:CGPoint,superView:UIView) {
        self.superView = superView
        self.head = .init(frame: .init(origin: .init(x: point.x-10, y: point.y-10), size: .zero))
    }
    
    func move(to direction:Direction) {
        //feed direction
        feed(direction)
        //remove last
        removeTail()
    }
    
    ///insert
    func feed(_ direction:Direction) {
        
        //Same as parent size
        let (w,h) = (self.head.frame.width,self.head.frame.height)
        
        let newNodeRect: CGRect!
        switch direction {
        case .up:
             newNodeRect = CGRect(x: head.frame.minX, y: head.frame.minY - 20, width:w , height: h)
        case .down:
            newNodeRect = CGRect(x: head.frame.minX, y: head.frame.maxY , width:w , height: h)
        case .left:
            newNodeRect = CGRect(x: head.frame.minX - 20, y: head.frame.minY, width:w , height: h)
        case .right:
            newNodeRect = CGRect(x: head.frame.maxX , y: head.frame.minY, width:w , height: h)
        }
        
        
        //Get view
        let newNode = Node(frame: newNodeRect)
        superView.addSubview(newNode)
        
        //Set new head for future feeding
        newNode.nextNode = head
        head = newNode
    }
    
    func removeAllNodes() {
        for _ in 0..<length() {
            removeTail()
        }
    }
    
    
    
    func length() -> Int {
        var count = 1
        var node = head.nextNode
        while node?.nextNode != nil {
            count += 1
            node = node?.nextNode
        }
        return count
    }
    
    var tail: Node {
        var node = head.nextNode
        while node?.nextNode != nil {
            node = node?.nextNode
        }
        return node!
    }
    
    func removeTail() {
        var node = head
        var pre: Node?
        while node.nextNode != nil {
            pre = node //remember previous
            node = node.nextNode!
        }
        pre?.nextNode = nil //previous should let loose
        node.removeFromSuperview() //and tail should dissapear
    }
    
    
}


