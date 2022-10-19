//
//  ViewController.swift
//  Canvas
//
//  Created by Andrew Ushakov on 8/15/22.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    @IBOutlet weak var pencilButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!

    @IBAction  func toggleFingerOrPencil(_ sender: Any) {
        if pencilButton.title == "Pencil" {
            canvasView.drawingPolicy = .anyInput
            pencilButton.title = "Finger"
        } else {
            canvasView.drawingPolicy = .pencilOnly
            pencilButton.title = "Pencil"
        }
    }

    @IBAction func saveDrawing(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)

        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if image != nil {
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }
        }
    }

    let canvasWidth: CGFloat = 768
    let canvasHeight: CGFloat = 500

    let drawing = PKDrawing()
    let toolPicker = PKToolPicker.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing

        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .default

        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale

        updateContentSizeDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: canvasView.adjustedContentInset.top)
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateViewConstraints()
    }

    func updateContentSizeDrawing() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat

        if !drawing.bounds.isNull {
            contentHeight = max(
                canvasView.bounds.height,
                (drawing.bounds.maxY + self.canvasHeight) * canvasView.zoomScale
            )
        } else {
            contentHeight = canvasView.bounds.height
        }

        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
    }
}
