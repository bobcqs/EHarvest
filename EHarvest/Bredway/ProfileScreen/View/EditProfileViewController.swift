//
//  EditProfileViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 23/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var profileNameLabel: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var viewModel: EditProfileViewModeling!
    
    var imagePicker: UIImagePickerController!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileNameLabel.addBorder(toSide: .Bottom, withColor: UIColor.black.cgColor, andThickness: 0.5)
        profileNameLabel.text = UserManager.shared.currentUserName
        if let url = URL.init(string: UserManager.shared.currentUserImageUrl){
            profileImageView.kf.setImage(with: url) { (image, error, cacheType, url) in
                if let err = error{
                    logger.debug("Unabled to fetch image because of \(err)")
                } else {
                    if let profileImage = image{
                        self.viewModel.profileImage.onNext(profileImage)
                    }
                }
            }
        }
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.selectImage))
        profileImageView.addGestureRecognizer(gesture)

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        setupBinding()
    }
    
    func setupBinding(){
        profileNameLabel.rx.text.orEmpty
            .bind(to: viewModel.displayName)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .do(onNext: {
                LoadingManager.shared.showIndicator()
            })
            .bind(to: viewModel.submitDidTap)
            .disposed(by: disposeBag)
        
        viewModel.submissionResult
            .subscribe(onNext: { [weak self] (submissionResult) in
                if submissionResult == SubmissionResult.submissionError{
                    LoadingManager.shared.hideIndicatorWithMessage(message: "Failed to update, please try again", timeInterval: 2)
                } else if submissionResult == SubmissionResult.submissionSuccess{
                    LoadingManager.shared.hideIndicatorWithMessage(message: "Your profile has been updated", timeInterval: 2)
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func selectImage(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        actionSheet.addAction(cancelAction)
        let cameraOption = UIAlertAction(title: "Take A Photo", style: .default) { action in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(self.imagePicker, animated: true, completion:nil)
            }
        }
        actionSheet.addAction(cameraOption)
        let photoAlbumOption = UIAlertAction(title: "From Camera Roll", style: .default) { action in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.imagePicker, animated: true, completion:nil)
        }
        actionSheet.addAction(photoAlbumOption)
        present(actionSheet, animated: true, completion: nil)
    }

}

extension EditProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = image
            viewModel.profileImage.onNext(image)
        } else{
            print ("Log: A valid image isn't selected")
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            profileImageView.image = image
            viewModel.profileImage.onNext(image)
        }
        imagePicker.dismiss(animated:true, completion: nil)
    }
    
}
