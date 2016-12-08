//
//  GameViewController.swift
//  Flappy Bird
//
//  Created by Yiqi Wang on 2016/12/7.
//  Copyright © 2016年 Melody5417. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let sk视图 = self.view as? SKView {
            if sk视图.scene == nil {
                // 创建场景
                let 长宽比 = sk视图.bounds.size.height / sk视图.bounds.size.width
                let 场景 = GameScene(size: CGSize(width: 320, height: 320 * 长宽比))
                
                // 帧率
                sk视图.showsFPS = true
                
                // 节点数 场景中单位数
                sk视图.showsNodeCount = true
                
                // 显示碰撞模型边框
                sk视图.showsPhysics = true
                
                // 忽略元素的层级 不分前景后景
                sk视图.ignoresSiblingOrder = true
                
                场景.scaleMode = .aspectFill
                
                sk视图.presentScene(场景)
            }
        }
    }
}
