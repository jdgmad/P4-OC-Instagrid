//
//  ViewController.swift
//  InstaGRD
//
//  Created by José DEGUIGNE on 19/08/2021.
//  Version 1.2

import UIKit

class ViewController: UIViewController {

//  MARK: - Vars
    
    private var currentButton : UIButton?
    private var layoutIsEmpty = true    // This Boolean will permit to check wether the grid is empty or not before sharing
    private var gridViewOrigin: CGPoint!
    private enum Gesture {
        case unknown
        case up
        case down
        case right
        case left
    }
    private var direction: Gesture = .unknown
    private enum Orientation {
        case unknown
        case portrait
        case landscape
    }
    private var layoutOrientation: Orientation = .unknown
    
    private let imagePickerController = UIImagePickerController()
    
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
            return UIApplication.shared.statusBarOrientation
    }
    
    //  MARK: IBOutlets
    
    @IBOutlet weak var photoGridView: UIView!
    @IBOutlet var photoButtons: [UIButton]!
    @IBOutlet var layoutButtons: [UIButton]!
    
    
    // MARK: IBActions
    
    // Select a layout on Button tap
    // The layout is obtain by using the auto-rezizing of the StackView when a button is hiding
    @IBAction func layoutSelect(_ sender: UIButton) {
        deselectButtons()
        showButtons()
        switch sender.tag {
            case 0:
                sender.isSelected = true
                photoButtons[0].isHidden = true
            case 1:
                sender.isSelected = true
                photoButtons[2].isHidden = true
            case 2:
                sender.isSelected = true
            default :
                break
            }
    }
    
    // On a photo Button tap delegate an UIImagePickerControler
    @IBAction func loadPhotos(_ sender: UIButton) {
        self.currentButton = sender
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
//    MARK: - Methods
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
            super.willTransition(to: newCollection, with: coordinator)
        // Update the Orientation status on each rotation of the device
        coordinator.animate(alongsideTransition: { (context) in self.swipeGestureOnOrientationChange()
            })
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Update the orientation status on the first load View
        swipeGestureOnOrientationChange()
        // select a layout by default
        layoutSelect(layoutButtons[1])
    }
  
    // Change the layoutOrientation status at each rotation og the device
    // Select de direction of the swipeGestureRecognizer (up or left)
    private func swipeGestureOnOrientationChange() {
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        let swipeGrid = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureFired(_:)))
        
        if windowInterfaceOrientation.isLandscape {
            // activate landscape changes
            swipeGrid.direction = .left
            self.layoutOrientation = Orientation.landscape
        } else {
            // activate portrait changes
            swipeGrid.direction = .up
            self.layoutOrientation = Orientation.portrait
        }
        photoGridView.addGestureRecognizer(swipeGrid)
    }
    
    @objc func swipeGestureFired (_ gesture: UISwipeGestureRecognizer) {
        if layoutOrientation == .portrait && gesture.direction == .up {
            moveGridViewUp()
        }
        if layoutOrientation == .landscape && gesture.direction == .left {
            moveGridViewLeft()
        }
    }

    // This Method will make all photo buttons visible:
    private func showButtons() {
        for button in photoButtons {
            button.isHidden = false
        }
    }
    
    // Deselect all the layout button
    private func deselectButtons() {
        for lB in layoutButtons {
            lB.isSelected = false
        }
    }

    // Move up the photo grid outside the screen and display the AcivityController if the layout is empty.
    private func moveGridViewUp() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: hideViewPortrait, completion: {
            (true) in
            self.checkLayout()
        })
    }
    
    private func hideViewPortrait() {
        self.photoGridView.transform = CGAffineTransform(translationX: 0, y: -((UIScreen.main.bounds.height/2)+200))
    }
    
    // Move left the photo grid outside the screen and display the AcivityController if the layout is empty.
    private func moveGridViewLeft() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: hideViewLandscape, completion: {
            (true) in
            self.checkLayout()
        })
    }
    
    private func hideViewLandscape() {
        self.photoGridView.transform = CGAffineTransform(translationX: -((UIScreen.main.bounds.width/2)+200), y: 0)
    }
    
    // Share the layout via UIActivityController and move back the photo grid to the original position
    private func shareLayout() {
        let content = photoGridView.asImage()
        let activityController = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)
        // We use the completion handler to move back the mainView when the activityController is closed
        activityController.completionWithItemsHandler = {  (activity, success, items, error) in
            UIView.animate(withDuration: 0.5, animations: {
                self.photoGridView.transform = .identity
            }, completion: nil)
        }
    }
    
    // This function will present an alert if the user tries to share an empty grid
    func checkLayout() {
        let alert = UIAlertController(title: "Empty Grid", message: "Are you sure you want to share an empty grid ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.shareLayout() } ))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.photoGridView.transform = .identity
        }))
        if layoutIsEmpty == true {
            present(alert, animated: true)
        } else {
            shareLayout()
        }
    }
    
}

// METHOD FOR THE DELEGATE: when the user picks up an image from the photo library, the image is set to the button
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.currentButton?.setImage(editedImage, for: UIControl.State.normal)
            self.currentButton?.imageView!.contentMode = .scaleAspectFill
            layoutIsEmpty = false
        }
        layoutIsEmpty = false
        
        dismiss(animated: true, completion: nil)
    }

}


