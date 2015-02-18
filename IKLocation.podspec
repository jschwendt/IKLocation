#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "IKLocation"
  s.version          = "1.2"
  s.source           = { :git => "git@github.com:jschwendt/IKLocation.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/inaka'
  s.authors =  { 'Andres Canal' => 'andres@inakanetworks.com', 'Joe Schwendt' => 'Joe@Schwendt.com' }
  s.homepage = "https://github.com/jschwendt/IKLocation"
  s.license = { :type => 'BSD' }
  s.requires_arc = true
  s.source_files  = 'IKLocation/*.{h,m}'

  s.summary          = "IKLocation will let you use CCLocationManager in multiple sections of your app in a nice and easy way."
  s.description      = "If you need to get the device location in multiple sections of the app CLLocationManager may be a solution. CLLocationManager is a wrapper to avoid using multiple CLLocationManager across an application. All delegates added to IKLocation are notified when the location is available or when the refresh method is called. IKLocation automatically removes object when those are deallocated."
end