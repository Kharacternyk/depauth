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
          "34.0.0"
          "30.0.3"
        ];
        platformVersions = [
          "33"
          "32"
          "31"
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
        XDG_DATA_DIRS = pkgs.lib.strings.concatMapStringsSep
          ":"
          (package: "${package}/share/gsettings-schemas/${package.name}")
          [
            pkgs.gsettings-desktop-schemas
            pkgs.gtk3
          ];
        buildInputs = [
          sdk
          pkgs.jdk17
        ];
      };
    });
}
