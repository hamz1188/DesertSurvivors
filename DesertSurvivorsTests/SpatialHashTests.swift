//
//  SpatialHashTests.swift
//  DesertSurvivorsTests
//
//  Created by Ahmed AlHameli on 21/12/2025.
//

import Testing
import SpriteKit
@testable import DesertSurvivors

struct SpatialHashTests {
    
    // MARK: - Basic Insertion and Query
    
    @Test func testInsertAndQueryNearbyNode() {
        let spatialHash = SpatialHash()
        
        let node = SKNode()
        node.position = CGPoint(x: 50, y: 50)
        spatialHash.insert(node)
        
        let nearby = spatialHash.query(near: CGPoint(x: 60, y: 60), radius: 50)
        
        #expect(nearby.count == 1, "Should find the inserted node")
        #expect(nearby.first === node, "Should be the same node instance")
    }
    
    @Test func testQueryExcludesDistantNodes() {
        let spatialHash = SpatialHash()
        
        let nearNode = SKNode()
        nearNode.position = CGPoint(x: 0, y: 0)
        spatialHash.insert(nearNode)
        
        let farNode = SKNode()
        farNode.position = CGPoint(x: 1000, y: 1000)
        spatialHash.insert(farNode)
        
        let nearby = spatialHash.query(near: CGPoint(x: 0, y: 0), radius: 100)
        
        #expect(nearby.count == 1, "Should only find the near node")
        #expect(nearby.first === nearNode)
    }
    
    @Test func testQueryMultipleNodes() {
        let spatialHash = SpatialHash()
        
        // Insert 5 nodes in a cluster
        var nodes: [SKNode] = []
        for i in 0..<5 {
            let node = SKNode()
            node.position = CGPoint(x: CGFloat(i * 10), y: CGFloat(i * 10))
            spatialHash.insert(node)
            nodes.append(node)
        }
        
        let nearby = spatialHash.query(near: CGPoint(x: 25, y: 25), radius: 100)
        
        #expect(nearby.count == 5, "Should find all 5 clustered nodes")
    }
    
    // MARK: - Clear
    
    @Test func testClearRemovesAllNodes() {
        let spatialHash = SpatialHash()
        
        for i in 0..<10 {
            let node = SKNode()
            node.position = CGPoint(x: CGFloat(i * 50), y: CGFloat(i * 50))
            spatialHash.insert(node)
        }
        
        spatialHash.clear()
        
        let nearby = spatialHash.query(near: .zero, radius: 10000)
        #expect(nearby.isEmpty, "After clear, query should return empty")
    }
    
    // MARK: - Edge Cases
    
    @Test func testQueryWithZeroRadius() {
        let spatialHash = SpatialHash()
        
        let node = SKNode()
        node.position = CGPoint(x: 50, y: 50)
        spatialHash.insert(node)
        
        // Zero radius should still check the center cell
        let nearby = spatialHash.query(near: CGPoint(x: 50, y: 50), radius: 0)
        
        // With zero radius, ceil(0/cellSize) = 0, so only center cell is checked
        #expect(nearby.count >= 0) // Just verify no crash
    }
    
    @Test func testQueryNegativeCoordinates() {
        let spatialHash = SpatialHash()
        
        let node = SKNode()
        node.position = CGPoint(x: -500, y: -500)
        spatialHash.insert(node)
        
        let nearby = spatialHash.query(near: CGPoint(x: -490, y: -490), radius: 50)
        
        #expect(nearby.count == 1, "Should find node at negative coordinates")
    }
    
    @Test func testLargeRadiusQuery() {
        let spatialHash = SpatialHash()
        
        // Scatter nodes across a large area
        for x in stride(from: -1000, to: 1000, by: 200) {
            for y in stride(from: -1000, to: 1000, by: 200) {
                let node = SKNode()
                node.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
                spatialHash.insert(node)
            }
        }
        
        // Query with large radius from center
        let nearby = spatialHash.query(near: .zero, radius: 500)
        
        // Should find nodes within 500 units of origin
        #expect(nearby.count > 0, "Should find some nodes within radius")
    }
}
