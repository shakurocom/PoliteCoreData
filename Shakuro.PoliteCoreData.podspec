Pod::Spec.new do |s|

    s.name             = 'Shakuro.PoliteCoreData'
    s.version          = '1.7.0'
    s.summary          = 'PoliteCoreData'
    s.homepage         = 'https://github.com/shakurocom/PoliteCoreData'
    s.license          = { :type => "MIT", :file => "LICENSE.md" }
    s.authors          = {'wwwpix' => 'spopov@shakuro.com'}
    s.source           = { :git => 'https://github.com/shakurocom/PoliteCoreData.git', :tag => s.version }
    s.swift_versions   = ['5.1', '5.2', '5.3', '5.4', '5.5', '5.6']
    s.source_files     = 'Source/*', 'Source/SwiftUI/*'
    s.ios.deployment_target = '15.0'

    s.dependency "Shakuro.CommonTypes", "~> 1.1"

end
