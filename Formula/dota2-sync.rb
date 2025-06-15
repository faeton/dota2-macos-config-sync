class Dota2Sync < Formula
    desc "Copy and sync Dota 2 configuration files between Steam accounts on macOS"
    homepage "https://github.com/faeton/dota2-macos-config-sync"
    url "https://github.com/faeton/dota2-macos-config-sync/archive/v1.0.0.tar.gz"
    sha256 "YOUR_SHA256_HASH_HERE"  # You'll need to calculate this
    license "MIT"
  
    def install
      bin.install "bin/dota2-sync"
    end
  
    test do
      system "#{bin}/dota2-sync", "--help"
    end
  end
  