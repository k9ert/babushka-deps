# call it like this: babushka "k9ert:hello world" someone=test
dep 'hello world', :someone do
  met? { false }
  meet {
    puts "Hello #{someone ? someone : "World" }!"
  }
end

dep 'ec2 sshin' do
  requires ['ec2 oneup']
  met? { false }
  meet {
    ip = shell("ec2-describe-instances | grep running | cut  -f4 ")
    puts "ssh -i ~/.ssh/KimNeunertAWS.pem #{ip}"
  }
end

dep 'ec2 oneup' do
  requires ['ec2 ready']
  met? {
    shell("ec2-describe-instances | grep running | cut  -f4 | wc -l").match(/1/)
  }
  meet {
    shell "ec2-run-instances ami-4d20a724 -k KimNeunertAWS"
  }
end

dep 'ec2 ready' do
  requires ['ec2-run-instances.bin']
  met? {
    ENV["EC2_PRIVATE_KEY"] && ENV["EC2_CERT"]
  }

  meet {
    puts "You should do this (and hopefully you have that available):"
    puts ". ~/bin/ec2-env"
  }

end


dep 'ec2-run-instances.bin' do
   installs 'ec2-api-tools'
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
