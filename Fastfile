# This file contains the fastlane configuration for building and signing the APK
# Use this for automated builds

default_platform(:android)

platform :android do
  desc "Build release APK"
  lane :build_release do
    build_android_app(
      task: "assembleRelease",
      project_dir: "android/",
      gradle_path: "android/gradlew"
    )
  end

  desc "Build and sign release APK"
  lane :build_signed_release do
    build_android_app(
      task: "bundleRelease",
      project_dir: "android/",
      gradle_path: "android/gradlew"
    )
  end
end
