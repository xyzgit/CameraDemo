//
//  ViewController.swift
//  CameraDemo
//
//  Created by xyz on 2016/12/9.
//  Copyright © 2016年 xyz.develop. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    @IBOutlet weak var originalResolution: UILabel!
    @IBOutlet weak var scaledResolution: UILabel!

    @IBOutlet weak var originalSize: UILabel!
    @IBOutlet weak var scaledSize: UILabel!

    @IBOutlet weak var originalLabel: UILabel!
    @IBOutlet weak var scaleLabel: UILabel!
    
    @IBOutlet weak var compressionQualityLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var compressionQuality: CGFloat = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
               // Dispose of any resources that can be recreated.
    }
   
    //设置压缩比
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = String(format: "%.1f", sender.value)
        compressionQualityLabel.text = value
        compressionQuality = CGFloat((value as NSString).floatValue)
    }
    
    //拍摄照片
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
       
        if(!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        //imagePicker.allowsEditing = true
        
        present(imagePicker, animated: false, completion: nil)
       
    }
    
    //从图库中选择照片
    @IBAction func selectPhotoButtonPressed(_ sender: UIButton) {
        print("select")
        if(!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        //imagePicker.allowsEditing = true
        
        present(imagePicker, animated: false, completion: nil)

    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //原始照片
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        originalLabel.text = "original"
        originalResolution.text = "\(originalImage.size.width) * \(originalImage.size.height)"
        originalSize.text = getImageSize(image: originalImage)
        
        //保存原始照片
        let originalImageData: NSData = NSData(data: UIImageJPEGRepresentation(originalImage, compressionQuality)!)
        originalImageData.write(toFile: "\(NSTemporaryDirectory())/originalImage.jpg", atomically: true)
        
        
        //打印照片元信息，take photo only
//        let metadataDictionary = info[UIImagePickerControllerMediaMetadata] as! NSDictionary
//        print(metadataDictionary)
        
        //等比例缩小照片尺寸
        var height = 600 * originalImage.size.height / originalImage.size.width
        var newSize: CGSize = CGSize(width: 600.0,height: 800.0)
        let scaledImage: UIImage = scaleImageResolution(image: originalImage, newSize: newSize)
        
        scaleLabel.text = "scale down"
        scaledResolution.text = "\(scaledImage.size.width) * \(scaledImage.size.height)"
        scaledSize.text = getImageSize(image: scaledImage)
        
        //保存缩小后的照片
        let scaleImageData: NSData = NSData(data: UIImageJPEGRepresentation(scaledImage, compressionQuality)!)
        scaleImageData.write(toFile: "\(NSTemporaryDirectory())/scaleImage.jpg", atomically: true)
        
//        UIImageWriteToSavedPhotosAlbum(scaledImage,nil,nil,nil)
        
        //等比例缩小照片，缩略图展示
        height = 300 * originalImage.size.height / originalImage.size.width
        newSize = CGSize(width: 300.0,height: height)
        let thumbnail: UIImage = scaleImageResolution(image: originalImage, newSize: newSize)
        
        let frame: CGRect = imageView.frame
        imageView.frame = CGRect(x: frame.origin.x,y: frame.origin.y,width: frame.size.width,height: height)
        imageView.image = thumbnail

        picker.dismiss(animated: true, completion: nil)
    
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("user cancel the operation");
        picker.dismiss(animated: true, completion: nil)
    }
    
    func scaleImageResolution(image: UIImage, newSize: CGSize) -> UIImage {
        
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        var newWidth: CGFloat = 0.0;
        var newHeight: CGFloat = 0.0;
        
        if(oldWidth >= oldHeight) {
            newWidth = newSize.width;
            newHeight = oldHeight * (newSize.width / oldWidth);
        }else {
            newHeight = newSize.height;
            newWidth = oldWidth * (newSize.height / oldHeight);
        }
        
        let rect = CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight)
        let size = CGSize.init(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: rect)
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getImageSize(image: UIImage) -> String {
        let imageData: NSData = NSData(data: UIImageJPEGRepresentation(image, 1)!)
        let imageSize: Int = imageData.length / 1024
        return imageSize > 1024 ? "\(imageSize / 1024)M" : "\(imageSize)K"
    }
}

