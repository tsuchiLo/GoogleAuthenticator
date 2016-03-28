Pod::Spec.new do |spec|
  spec.name = "GoogleAuthenticator"
  spec.version = "0.1.0"
  spec.summary = "Authentication to Google services made easy."
  spec.homepage = "https://www.github.com/fabiomassimo/googleauthenticator"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Fabio Milano" => 'fabio@touchwonders.com' }
  spec.social_media_url = "http://twitter.com/iamfabiomilano"

  spec.platform = :ios, "9.0"
  spec.requires_arc = true
  spec.source = { git: "https://www.github.com/fabiomassimo/googleauthenticator", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "GoogleAnalyticsReader/**/*.{h,swift}"

  spec.dependency "OAuthSwift", "~> 0.5"
  spec.dependency "Locksmith", "~> 2.0.8"
end