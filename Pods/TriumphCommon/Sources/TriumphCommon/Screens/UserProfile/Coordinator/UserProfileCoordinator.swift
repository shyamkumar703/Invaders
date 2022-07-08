// Copyright © TriumphSDK. All rights reserved.

import UIKit
import CropViewController

public enum UserProfile: Equatable {
    case create(String)
    case update
}

public enum UserProfileAvatarAlert {
    case camera, photoLibrary
    
    var title: String {
        switch self {
        case .camera:
            return "Camera"
        case .photoLibrary:
            return "Photo Library"
        }
    }
}

public protocol UserProfileCoordinatorDelegate: Coordinator {
    func userProfileCoordinator(profileDidSignUp coordinator: UserProfileCoordinator)
    func userProfileCoordinator(profileDidFinish coordinator: UserProfileCoordinator)
}

public protocol UserProfileCoordinatorViewModelDelegate: AnyObject {
    func userProfileDidCropToImage(_ image: UIImage)
}

public protocol UserProfileCoordinator: Coordinator {
    var viewModelDelegate: UserProfileCoordinatorViewModelDelegate? { get set }
    
    func showAvatarAlert()
    func profileDidUpdated()
    func profileDidSignUp()
}

// MARK: - Impl.

public final class UserProfileCoordinatorImplementation: NSObject, UserProfileCoordinator {
    public var navigationController: BaseNavigationController?
    public var childCoordinators: [Coordinator] = []
    private lazy var imagePickerController = UIImagePickerController()
    
    public weak var delegate: UserProfileCoordinatorDelegate?
    public weak var viewModelDelegate: UserProfileCoordinatorViewModelDelegate?
    
    public var parentCoordinator: Coordinator?
    private var dependencies: Dependencies
    private var screen: UserProfile
    
    public init(
        navigationController: BaseNavigationController,
        dependencies: Dependencies,
        screen: UserProfile
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.screen = screen
    }
    
    deinit {
        print("DEINIT \(self)")
    }
    
    @MainActor public func start() {
        let viewController = UserProfileViewController()
        viewController.viewModel = UserProfileViewModelImplementation(
            coordinator: self,
            dependencies: dependencies,
            screen: screen
        )
        navigationController?.pushViewController(viewController, animated: true)
        imagePickerController.delegate = self
    }
    
    public func showImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            imagePickerController.modalPresentationStyle = .popover
            imagePickerController.modalTransitionStyle = .coverVertical
            navigationController?.present(imagePickerController, animated: true)
        } else {
            dependencies.swiftMessage.showErrorMessage(
                title: "Error",
                message: "Camera access required"
            )
        }
    }
    
    public func showPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        navigationController?.present(imagePickerController, animated: true)
    }
    
    public func showAvatarAlert() {
        var actions = [UIAlertAction]()
        let sheet: [UserProfileAvatarAlert] = [.camera, .photoLibrary]
        for type in sheet {
            actions.insert(avatarAlertAction(type: type), at: actions.count)
        }
        
        let actionsAlertModel = ActionAlertModel(
            title: "Choose a photo",
            message: nil,
            cancelButtonTitle: "Cancel",
            cancelHandler: { _ in },
            actions: actions
        )
        
        dependencies.alertFabric.showAlert(actionsAlertModel, completion: nil)
    }
    
    private func avatarAlertAction(type: UserProfileAvatarAlert) -> UIAlertAction {
        UIAlertAction(
            title: type.title,
            style: .default,
            handler: { [weak self] _ in
                guard let self = self else { return }
                switch type {
                case .camera:
                    self.showImagePicker()
                case .photoLibrary:
                    self.showPhotoLibrary()
                }
            }
        )
    }
    
    public func profileDidSignUp() {
        delegate?.userProfileCoordinator(profileDidSignUp: self)
    }
    
    public func profileDidUpdated() {
        navigationController?.popViewController(animated: true)
        delegate?.userProfileCoordinator(profileDidFinish: self)
    }
    
    public func didFinish() {
        delegate?.userProfileCoordinator(profileDidFinish: self)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension UserProfileCoordinatorImplementation: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.navigationController?.navigationBar.barTintColor = UIColor.white
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }

        guard picker.topViewController as? CropViewController == nil else { return }

        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        
        if picker.sourceType == .camera {
            picker.dismiss(animated: true) {  [weak self] in
                guard let self = self else { return }
                cropViewController.transitioningDelegate = nil
                cropViewController.modalPresentationStyle = .popover
                cropViewController.modalTransitionStyle = .coverVertical
                self.navigationController?.present(cropViewController, animated: true)
            }
        } else {
            picker.pushViewController(cropViewController, animated: true)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - CropViewControllerDelegate

extension UserProfileCoordinatorImplementation: CropViewControllerDelegate {
    public func cropViewController(
        _ cropViewController: CropViewController,
        didCropToImage image: UIImage,
        withRect cropRect: CGRect,
        angle: Int
    ) {
        cropViewController.dismiss(animated: true) {
            self.viewModelDelegate?.userProfileDidCropToImage(image)
        }
    }
}
