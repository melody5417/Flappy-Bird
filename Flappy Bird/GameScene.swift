//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Yiqi Wang on 2016/12/7.
//  Copyright © 2016年 Melody5417. All rights reserved.
//

import SpriteKit

enum 图层: CGFloat {
    case 背景
    case 前景
    case 游戏角色
}

class GameScene: SKScene {
    
    // 作为容纳整个游戏的容器
    let 世界单位 = SKNode()
    var 游戏区域起始点: CGFloat = 0
    var 游戏区域的高度: CGFloat = 0
    
    override func didMove(to view: SKView) {
        addChild(世界单位)
        设置背景()
        设置前景()
    }
    
    func 设置背景() {
        let 背景 = SKSpriteNode(imageNamed: "Background")
        背景.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        背景.position =  CGPoint(x: size.width / 2, y: size.height)
        背景.zPosition = 图层.背景.rawValue
        世界单位.addChild(背景)
        
        游戏区域起始点 = size.height - 背景.size.height
        游戏区域的高度 = 背景.size.height
    }
    
    func 设置前景() {
        let 前景 = SKSpriteNode(imageNamed: "Ground")
        前景.anchorPoint = CGPoint(x: 0, y: 1.0)
        前景.position = CGPoint(x: 0, y: 游戏区域起始点)
        前景.zPosition = 图层.前景.rawValue
        世界单位.addChild(前景)
    }
    
    
    
    
}
