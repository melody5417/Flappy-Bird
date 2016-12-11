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
    case 障碍物
    case 前景
    case 游戏角色
}

enum 物理层 {
    static let 无: UInt32 =              0
    static let 游戏角色: UInt32 =       0b1 // 1
    static let 障碍物: UInt32 =        0b10 // 2
    static let 地面: UInt32 =         0b100 // 4
}

class GameScene: SKScene {
    
    // k作为常量开头
    let k前景地面数 = 2
    let k地面移动速度: CGFloat = -150.0
    let k重力: CGFloat = -500.0
    let k上冲速度: CGFloat = 200
    let k底部障碍最小乘数: CGFloat = 0.1
    let k底部障碍最大乘数: CGFloat = 0.6
    let k缺口乘数: CGFloat = 3.5
    let k首次生成障碍延迟: TimeInterval = 1.75
    let k每次重新障碍延迟: TimeInterval = 1.5
    
    var 速度 = CGPoint.zero
    
    // 作为容纳整个游戏的容器
    let 游戏世界 = SKNode()
    var 游戏区域起始点: CGFloat = 0
    var 游戏区域的高度: CGFloat = 0
    let 主角 = SKSpriteNode(imageNamed: "Bird0")
    let 帽子 = SKSpriteNode(imageNamed: "Sombrero")
    var 上一次更新时间: TimeInterval = 0
    var dt: TimeInterval = 0
    
    //  创建音效
    let 叮的音效 = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let 拍打的音效 = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let 摔倒的音效 = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let 下落的音效 = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let 撞击地面的音效 = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let 砰的音效 = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let 得分的音效 = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        // 关掉重力
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        addChild(游戏世界)
        设置背景()
        设置前景()
        设置主角()
        设置帽子()
        无限重新障碍()
    }
    
    // MARK: 设置的相关方法
    
    func 设置背景() {
        let 背景 = SKSpriteNode(imageNamed: "Background")
        背景.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        背景.position =  CGPoint(x: size.width / 2, y: size.height)
        背景.zPosition = 图层.背景.rawValue
        游戏世界.addChild(背景)
        
        游戏区域起始点 = size.height - 背景.size.height
        游戏区域的高度 = 背景.size.height
        
        let 左下 = CGPoint(x: 0, y: 游戏区域起始点)
        let 右下 = CGPoint(x: size.width, y: 游戏区域起始点)
        
        self.physicsBody = SKPhysicsBody(edgeFrom: 左下, to: 右下)
        self.physicsBody?.categoryBitMask = 物理层.地面
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 物理层.游戏角色
        
    }
    
    func 设置主角() {
        主角.position = CGPoint(x: size.width * 0.2, y: 游戏区域的高度 * 0.4 + 游戏区域起始点)
        主角.zPosition = 图层.游戏角色.rawValue
        
        let offsetX = 主角.size.width * 主角.anchorPoint.x
        let offsetY = 主角.size.height * 主角.anchorPoint.y
        
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: 4 - offsetX, y: 9 - offsetY))
        path.addLine(to: CGPoint(x: 8 - offsetX, y: 11 - offsetY))
        path.addLine(to: CGPoint(x: 11 - offsetX, y: 13 - offsetY))
        path.addLine(to: CGPoint(x: 19 - offsetX, y: 14 - offsetY))
        path.addLine(to: CGPoint(x: 19 - offsetX, y: 5 - offsetY))
        path.addLine(to: CGPoint(x: 17 - offsetX, y: 2 - offsetY))
        path.addLine(to: CGPoint(x: 14 - offsetX, y: 1 - offsetY))
        path.addLine(to: CGPoint(x: 12 - offsetX, y: 1 - offsetY))
        path.addLine(to: CGPoint(x: 10 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 4 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 4 - offsetX, y: 2 - offsetY))
        path.addLine(to: CGPoint(x: 1 - offsetX, y: 3 - offsetY))
        path.addLine(to: CGPoint(x: 2 - offsetX, y: 1 - offsetY))
        path.addLine(to: CGPoint(x: 6 - offsetX, y: 1 - offsetY))
        path.addLine(to: CGPoint(x: 2 - offsetX, y: 6 - offsetY))
        
        path.closeSubpath()
        
        主角.physicsBody = SKPhysicsBody(polygonFrom: path)
        主角.physicsBody?.categoryBitMask = 物理层.游戏角色
        主角.physicsBody?.collisionBitMask = 0
        主角.physicsBody?.contactTestBitMask = 物理层.障碍物 | 物理层.地面
        
        游戏世界.addChild(主角)
    }
    
    func 设置前景() {
        for i in 0..<k前景地面数 {
            let 前景 = SKSpriteNode(imageNamed: "Ground")
            前景.anchorPoint = CGPoint(x: 0, y: 1.0)
            前景.position = CGPoint(x: CGFloat(i) * 前景.size.width, y: 游戏区域起始点)
            前景.zPosition = 图层.前景.rawValue
            游戏世界.addChild(前景)
            
            前景.name = "前景"
        }
    }
    
    func 设置帽子() {
        帽子.position = CGPoint(x: 31 - 帽子.size.width/2, y: 29 - 帽子.size.height/2)
        主角.addChild(帽子)
    }
    
    // MARK: 游戏流程
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 播放音效
        run(拍打的音效)
        
        // 增加上冲速度
        主角飞一下()
        
        // 移动帽子
        let 向上移动 = SKAction.moveBy(x: 0, y: 12, duration: 0.15)
        向上移动.timingMode = .easeInEaseOut
        let 向下移动 = 向上移动.reversed()
        帽子.run(SKAction.sequence([向上移动, 向下移动]))
    }
    
    func 主角飞一下() {
        速度 = CGPoint(x: 0, y: k上冲速度)
    }
    
    func 创建障碍物(图片名: String) -> SKSpriteNode {
        let 障碍物 = SKSpriteNode(imageNamed: 图片名)
        障碍物.zPosition = 图层.障碍物.rawValue
        
        let offsetX = 障碍物.size.width * 障碍物.anchorPoint.x
        let offsetY = 障碍物.size.height * 障碍物.anchorPoint.y
        
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: 27 - offsetX, y: 315 - offsetY))
        path.addLine(to: CGPoint(x: 48 - offsetX, y: 310 - offsetY))
        path.addLine(to: CGPoint(x: 51 - offsetX, y: 268 - offsetY))
        path.addLine(to: CGPoint(x: 49 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 3 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 6 - offsetX, y: 310 - offsetY))

        path.closeSubpath()
        
        障碍物.physicsBody = SKPhysicsBody(polygonFrom: path)
        障碍物.physicsBody?.categoryBitMask = 物理层.障碍物
        障碍物.physicsBody?.collisionBitMask = 0
        障碍物.physicsBody?.contactTestBitMask = 物理层.游戏角色
        
        return 障碍物
    }
    
    func 生成障碍() {
        let 底部障碍 = 创建障碍物(图片名: "CactusBottom")
        // 将底部障碍移到右边屏幕外面
        let 起始X坐标 = size.width + 底部障碍.size.width/2
        
        let Y坐标最小值 = (游戏区域起始点 - 底部障碍.size.height/2) + 游戏区域的高度 * k底部障碍最小乘数
        let Y坐标最大值 = (游戏区域起始点 - 底部障碍.size.height/2) + 游戏区域的高度 * k底部障碍最大乘数
        
        底部障碍.position = CGPoint(x: 起始X坐标, y: CGFloat.random(min: Y坐标最小值, max: Y坐标最大值))
        游戏世界.addChild(底部障碍)
        
        let 顶部障碍 = 创建障碍物(图片名: "CactusBottom")
        顶部障碍.zRotation = CGFloat(180).degreesToRadians()
        顶部障碍.position = CGPoint(x: 起始X坐标, y: 底部障碍.position.y + 底部障碍.size.height/2 + 底部障碍.size.height/2 + 主角.size.height * k缺口乘数)
        游戏世界.addChild(顶部障碍)
        
        let X轴移动距离 = -(size.width + 底部障碍.size.width)
        let 移动持续时间 = X轴移动距离 / k地面移动速度
        
        let 移动的动作队列 = SKAction.sequence([
                SKAction.moveBy(x: X轴移动距离, y: 0, duration: TimeInterval(移动持续时间)),
                SKAction.removeFromParent()
            ])
        顶部障碍.run(移动的动作队列)
        底部障碍.run(移动的动作队列)
    }
    
    func 无限重新障碍 () {
        let 首次延迟 = SKAction.wait(forDuration: k首次生成障碍延迟)
        let 重生障碍 = SKAction.run(生成障碍)
        let 每次重生间隔 = SKAction.wait(forDuration: k每次重新障碍延迟)
        let 重生的动作队列 = SKAction.sequence([重生障碍, 每次重生间隔])
        let 无限重生 = SKAction.repeatForever(重生的动作队列)
        let 总的动作队列 = SKAction.sequence([首次延迟, 无限重生])
        
        run(总的动作队列)
    }
    
    // MARK: 更新
    
    // 理想情况下 每一帧都会调用该方法
    override func update(_ 当前时间: TimeInterval) {
        if 上一次更新时间 > 0 {
            dt = 当前时间 - 上一次更新时间
        } else {
            dt = 0
        }
        上一次更新时间 = 当前时间
        
        更新主角()
        更新前景()
    }
    
    func 更新主角() {
        let 加速度 = CGPoint(x: 0, y: k重力)
        速度 = 速度 + 加速度 * CGFloat(dt)
        主角.position = 主角.position + 速度 * CGFloat(dt)
        //print("position = \(主角.position)")
        
        
        // 检测撞击地面时让其停在地面上
        if 主角.position.y - 主角.size.height / 2 < 游戏区域起始点 {
            主角.position =  CGPoint(x: 主角.position.x, y: 游戏区域起始点 + 主角.size.height / 2)
        }
    }
    
    func 更新前景() {
        游戏世界.enumerateChildNodes(withName: "前景", using: {
            匹配单位, _ in
            if let 前景 = 匹配单位 as? SKSpriteNode {
                let 地面移动速度 = CGPoint(x: self.k地面移动速度, y: 0)
                前景.position += 地面移动速度 * CGFloat(self.dt)
                
                if 前景.position.x < -前景.size.width {
                    前景.position += CGPoint(x: 前景.size.width * CGFloat(self.k前景地面数), y: 0)
                }
            }
        })
    }
    
}
