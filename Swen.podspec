

Pod::Spec.new do |s|
s.name             = 'Swen'
s.version          = '1.4.2'
s.summary          = 'Swen - An Event Bus written in Swift.'

s.description      = <<-DESC
Swen is an Event bus written in Swift, which provides compile time safety and type checking.
DESC

s.homepage         = 'https://github.com/e-Sixt/Swen'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'e-Sixt' => 'sixtlabs@sixt.com' }
s.source           = { :git => 'https://github.com/e-Sixt/Swen.git', :tag => s.version.to_s }

s.ios.deployment_target = '9.0'

s.source_files = 'Swen/Classes/**/*'

end
