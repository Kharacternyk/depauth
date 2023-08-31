{
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      sdk = (pkgs.androidenv.composeAndroidPackages {
        buildToolsVersions = [
          "30.0.3"
          "28.0.3"
        ];
        platformVersions = [
          "33"
          "32"
        ];
        abiVersions = [
          "arveabi-v7a"
          "arm64-v8a"
        ];
      }).androidsdk;
    in
    {
      devShell = pkgs.mkShell {
        ANDROID_SDK_ROOT = "${sdk}/libexec/android-sdk";
        buildInputs = [
          sdk
          pkgs.jdk17
        ];
      };
    });
}
