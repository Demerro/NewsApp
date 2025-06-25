//
//  LayerView.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 25.06.25.
//

import UIKit

final class LayerView<Layer: CALayer>: UIView {
    
    override class var layerClass: AnyClass {
        Layer.self
    }
    
    var setLayer: Layer {
        layer as! Layer
    }
}
