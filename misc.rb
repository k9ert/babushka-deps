# call it like this: babushka "k9ert:hello world" someone=test
dep 'hello world', :someone do
  met? { false }
  meet {
    puts "Hello #{someone ? someone : "World" }!"
  }
end

dep 'debian-apt-sources' do
  met? {
    File.exist?("/etc/apt/sources.list.d/stable.list") && 
    File.exist?("/etc/apt/sources.list.d/testing.list") && 
    File.exist?("/etc/apt/sources.list.d/unstable.list") &&
    File.exist?("/etc/apt/Preferences")
  }

  meet {
    File.exist?("/etc/apt/sources.list.d/stable.list") or shell "wget -P /etc/apt/sources.list.d https://gist.github.com/raw/3729351/cdddc9401c0dd42fba7c197e36083b3404527c1c/stable.list"
    File.exist?("/etc/apt/sources.list.d/testing.list") or shell "wget -P /etc/apt/sources.list.d https://gist.github.com/raw/3729351/406a499ed98cff61505756cb55c10cf078da5ad9/testing.list"
    File.exist?("/etc/apt/sources.list.d/unstable.list") or shell "wget -P /etc/apt/sources.list.d https://gist.github.com/raw/3729351/be5beb85ef63617ad4020a6a3bf36a1a1a34bb6d/unstable.list"
    File.exist?("/etc/apt/Preferences") or shell "wget -P /etc/apt https://gist.github.com/raw/3729351/aa000e26a3a4aeb4c8573fdbc2ed69d090471f0a/Preferences"
    shell "apt-get update"
  }
end

dep 'puppet-installed' do
  met? {
    shell("puppet --version").match(/2\.7/)
  }

  meet {
    shell "DEBIAN_FRONTEND='noninteractive' apt-get -yq -o Dpkg::Options::=--force-confnew install puppet -t testing"
  }
end
