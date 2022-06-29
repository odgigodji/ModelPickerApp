//
//  ContentView.swift
//  ModeLPickerApp
//
//  Created by Nikita Evdokimov on 28.06.2022.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: String?
    @State private var modelConfirmedForPlacement: String?
    
    private var models: [String] = {
        //Dynamically get our model filenames
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else { return [] }
        
        var availableModels: [String] = []
        for filename in files where filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            availableModels.append(modelName)
        }
        
        return availableModels
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlasement: $modelConfirmedForPlacement)
            
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: $isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlasement: String?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = self.modelConfirmedForPlasement {
            
            print("DEBUG: adding model to scene - \(modelName)")
            
            let fileName = modelName + ".usdz"
            let modelEntity = try! ModelEntity.loadModel(named: fileName)
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.addChild(modelEntity)
            
            uiView.scene.addAnchor(anchorEntity)
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlasement = nil
            }
        }
    }
    
}

//MARK: - Model Picker View
struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    
    var models: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0..<self.models.count) {
                    index in
                    Button {
                        print("DEBUG: selected model is \(self.models[index])")
                        
                        self.selectedModel = self.models[index]
                        
                        self.isPlacementEnabled = true
                    } label: {
                        Image(uiImage: UIImage(named: self.models[index])!).resizable().frame(height: 80).aspectRatio(1/1, contentMode: .fit).background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle()).cornerRadius(12)
                }
                
            }
            .padding(20).background(Color.black.opacity(0.5))
        }
    }
}

//MARK: - PlacemetnButtons View
struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    @Binding var modelConfirmedForPlacement: String?
    
    var body: some View {
        HStack {
            // Cancel Button
            Button {
                print("DEBUG: cancel model placement")
                
                self.resetPlacementParameters()
            } label: {
                Image(systemName: "xmark").frame(width: 60, height: 60).font(.title)
                    .background(Color.white.opacity(0.75)).cornerRadius(30)
                    .padding(20)
            }
            
            // Confirm Button
            Button {
                print("DEBUG: model placement confirm")
                
                self.modelConfirmedForPlacement = self.selectedModel
                
                self.resetPlacementParameters()
            } label: {
                Image(systemName: "checkmark").frame(width: 60, height: 60).font(.title)
                    .background(Color.white.opacity(0.75)).cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
