//
//  ViewController.swift
//  memev1
//
//  Created by Tawfeeq on 25/10/2018.
//  Copyright © 2018 tam. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    let memeTextAttributes:[NSAttributedString.Key : Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:-4]
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizeTextField()
        shareButton.isEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func initilizeTextField(){
        setDefaultTextField(topTextField, "TOP")
        setDefaultTextField(bottomTextField, "BOTTOM")
    }
    
    func setDefaultTextField(_ textField: UITextField,_ text:String){
        textField.text = text
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.autocapitalizationType = .allCharacters;
        textField.textAlignment = .center
    }

    func pickAnImage(from source: UIImagePickerController.SourceType) {
        // TODO:- code to pick an image from source
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController,animated: true,completion: nil)
    }
    
    @IBAction func pickImage(_ sender: Any) {
        pickAnImage(from: .photoLibrary)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        pickAnImage(from: .camera)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        if textField == bottomTextField{
            subscribeToKeyboardNotifications()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == bottomTextField{
            unsubscribeFromKeyboardNotifications()
        }
        return true
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
    }
    
    func generateMemedImage() -> UIImage {
    
        // Render view to an image
        hideUnhideToolbar()
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hideUnhideToolbar()
        return memedImage
    }
    
    func hideUnhideToolbar(){
        if (topToolbar.isHidden && bottomToolbar.isHidden){
            topToolbar.isHidden = false
            bottomToolbar.isHidden = false
        }
        else{
            topToolbar.isHidden = true
            bottomToolbar.isHidden = true
        }
    }
    
    @IBAction func Reset(_ sender: Any) {
        initilizeTextField()
        imagePickerView.image = nil
        shareButton.isEnabled = false
        
    }

    @IBAction func Share(_ sender: Any) {
        // image to share
        let image = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [ image ], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if !completed {
                return
            }
            self.save()
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
}

