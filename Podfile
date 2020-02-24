# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Bredway' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Bredway

  #network request
  pod 'Alamofire', '~> 4.7'

  #Rx
  pod 'RxSwift',    '~> 4.0'
  pod 'RxCocoa',    '~> 4.0'

  #UI
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
  pod "ViewAnimator"
  pod 'NVActivityIndicatorView'

  #Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'Firebase/Performance'
  pod 'FirebaseSwizzlingUtilities', '1.0.0'
  pod 'Fabric', '~> 1.7.9'
  pod 'Crashlytics', '~> 3.10.5'

  #Search
  pod 'AlgoliaSearch-Client-Swift'

  #User Login
  pod 'GoogleSignIn'
  pod 'FBSDKLoginKit'
  pod 'FacebookShare', :git => 'https://github.com/facebook/facebook-sdk-swift', :branch => 'master'

  #object Mapper
  pod 'ObjectMapper', '~> 3.3'

  #logger
  pod 'SwiftyBeaver'

  #Image
  pod 'Kingfisher', '~> 4.0'
  pod 'FSPagerView'

  #Message
  pod 'MessageKit', '~> 1.0'

  #Photo
  pod "TLPhotoPicker"

  # Workaround for Cocoapods issue #7606
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
  end


end
