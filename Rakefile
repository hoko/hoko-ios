include FileUtils::Verbose

namespace :test do
  task :prepare do
    mkdir_p "Tests/Hoko Tests.xcodeproj/xcshareddata/xcschemes"
    cp Dir.glob('Tests/Schemes/*.xcscheme'), "Tests/Hoko Tests.xcodeproj/xcshareddata/xcschemes/"
  end

  desc "Run the Hoko Tests"
  task :ios => :prepare do
    run_tests('Hoko Tests', 'iphonesimulator')
    tests_failed('iOS') unless $?.success?
  end
end

desc "Run the Hoko Tests for iOS"
task :test do
  Rake::Task['test:ios'].invoke
end

task :default => 'test'


private

def run_tests(scheme, sdk)
  sh("xcodebuild -workspace Hoko.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -configuration Release clean test | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
end

def tests_failed(platform)
  puts red("#{platform} unit tests failed")
  exit $?.exitstatus
end

def red(string)
 "\033[0;31m! #{string}"
end
