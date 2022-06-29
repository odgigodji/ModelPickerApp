//
//  Model.swift
//  ModeIPickerApp
//
//  Created by Nikita Evdokimov on 29.06.2022.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let fileName = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: fileName).sink(receiveCompletion: { loadCompletion in
           //Handle our Error
            print("DEBUG: Unable to load modelEntity for modelName: \(self.modelName)")
        }, receiveValue: { modelEntity in
            // Get our model Entity
            self.modelEntity = modelEntity
            print("DEBUG: Succesfully loaded modelEntity for modelName: \(self.modelName)")
        })
    }
}
