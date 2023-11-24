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
        self.layer.cornerRadius = 9
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
        addTail(.up)
    }
    
    func move(to direction:Direction) {
        //feed direction
        addHead(direction)
        //remove last
        removeTail()
    }
    
    ///insert
    private func addHead(_ direction:Direction) {
        
        let h = self.head.frame.height
        
        let newNodeRect: CGRect!
        switch direction {
        case .up:
            newNodeRect = CGRect(origin: .init(x: head.frame.minX, y: head.frame.minY - h), size: .zero)
        case .down:
            newNodeRect = CGRect(origin: .init(x: head.frame.minX, y: head.frame.maxY), size: .zero)
        case .left:
            newNodeRect = CGRect(origin: .init(x: head.frame.minX - h, y: head.frame.minY), size: .zero)
        case .right:
            newNodeRect = CGRect(origin: .init(x: head.frame.maxX, y: head.frame.minY), size: .zero)
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
    
    func addTail(_ movingDirection:Direction) {
        var node = head
        while node.nextNode != nil {
            node = node.nextNode!
        }
        let tail = node //grab tail
        let newNode = Node() //init new node
        tail.nextNode = newNode //set tail.next as newNode
        
        //place newNode at the end
        let newNodeOrigin: CGPoint = switch movingDirection {
            
        case .up:
            CGPoint(x: tail.frame.minX, y: tail.frame.minY)
        case .down:
            CGPoint(x: tail.frame.minX, y: tail.frame.minY-tail.frame.height)
        case .left:
            CGPoint(x: tail.frame.maxX, y: tail.frame.minY)
        case .right:
            CGPoint(x: tail.frame.minX-tail.frame.width, y: tail.frame.minY)
        }
        newNode.frame = .init(origin: newNodeOrigin, size: .zero)
        
        //add tail to view
        superView.addSubview(newNode)
    }
    
    var frames: [CGRect] {
        var frames: [CGRect] = []
        frames.append(head.frame)
        var node = head
        while node.nextNode != nil {
            node = node.nextNode!
            frames.append(node.frame)
        }
        return frames
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
    
    private func removeTail() {
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


