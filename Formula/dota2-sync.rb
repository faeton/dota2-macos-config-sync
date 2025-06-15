class Dota2Sync < Formula
    desc "Copy and sync Dota 2 configuration files between Steam accounts on macOS"
    homepage "https://github.com/faeton/dota2-macos-config-sync"
    url "https://github.com/faeton/dota2-macos-config-sync/archive/v1.0.1.tar.gz"
    sha256 "f17f7e0ebf1f72f5e74e70f24c3d7ca8a68e290079e2c107c4e49255f1a9b4cb"
    license "MIT"
  
    def install
      bin.install "bin/dota2-sync"
    end
  
    test do
      system "#{bin}/dota2-sync", "--help"
    end
  end
