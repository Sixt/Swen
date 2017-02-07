

Pod::Spec.new do |s|
s.name             = 'Swen'
s.version          = '1.1.0'
s.summary          = 'Swen - An Event Bus written in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

s.homepage         = 'https://github.com/e-Sixt/Swen'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'e-Sixt' => 'sixtlabs@sixt.com' }
s.source           = { :git => 'https://github.com/e-Sixt/Swen.git', :tag => s.version.to_s }

s.ios.deployment_target = '9.0'

s.source_files = 'Swen/Classes/**/*'

end
