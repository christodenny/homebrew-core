class Offlineimap < Formula
  desc "Synchronizes emails between two repositories"
  homepage "http://offlineimap.org/"
  url "https://github.com/OfflineIMAP/offlineimap/archive/v7.0.0.tar.gz"
  sha256 "2c664d85bd99057ec87cca2860074db60ceadb52179f47973ff1ac68fc72de42"
  head "https://github.com/OfflineIMAP/offlineimap.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "bdc9bcf613554253e0ab2deef59d69eec40bbb4e84acd4d3f6d3cd91292b9563" => :el_capitan
    sha256 "ef9f16128e5c1b1cc2ebae438de3f9b757b2f46edb04cf4100096e59084684e4" => :yosemite
    sha256 "bf3db1eea4b8dfb41fb5ff66f70c43a2191d65f3c8f123a6134123d816921365" => :mavericks
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/b3/b2/238e2590826bfdd113244a40d9d3eb26918bd798fc187e2360a8367068db/six-1.10.0.tar.gz"
    sha256 "105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    resource("six").stage do
      system "python", *Language::Python.setup_install_args(libexec/"vendor")
    end
    etc.install "offlineimap.conf", "offlineimap.conf.minimal"
    libexec.install "bin/offlineimap" => "offlineimap.py"
    libexec.install "offlineimap"
    (bin/"offlineimap").write_env_script(libexec/"offlineimap.py",
      :PYTHONPATH => ENV["PYTHONPATH"])
  end

  def caveats; <<-EOS.undent
    To get started, copy one of these configurations to ~/.offlineimaprc:
    * minimal configuration:
        cp -n #{etc}/offlineimap.conf.minimal ~/.offlineimaprc

    * advanced configuration:
        cp -n #{etc}/offlineimap.conf ~/.offlineimaprc
    EOS
  end

  plist_options :manual => "offlineimap"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>EnvironmentVariables</key>
        <dict>
          <key>PATH</key>
          <string>/usr/bin:/bin:/usr/sbin:/sbin:#{HOMEBREW_PREFIX}/bin</string>
        </dict>
        <key>KeepAlive</key>
        <false/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/offlineimap</string>
        </array>
        <key>StartInterval</key>
        <integer>300</integer>
        <key>RunAtLoad</key>
        <true />
        <key>StandardErrorPath</key>
        <string>/dev/null</string>
        <key>StandardOutPath</key>
        <string>/dev/null</string>
      </dict>
    </plist>
    EOS
  end

  test do
    system bin/"offlineimap", "--version"
  end
end
