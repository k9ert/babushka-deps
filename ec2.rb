dep 'ec2-sshin' do
  requires ['ec2-oneup']
  met? { false }
  meet {
    ip = shell("ec2-describe-instances | grep running | cut  -f4 ")
    puts "ssh -i ~/.ssh/KimNeunertAWS.pem admin@#{ip}"
  }
end

dep 'ec2-oneup' do
  requires ['ec2-ready']
  met? {
    shell("ec2-describe-instances | grep running | cut  -f4 | wc -l").match(/1/)
  }
  meet {
    shell "ec2-run-instances ami-4d20a724 -k KimNeunertAWS"
  }
end

dep 'ec2-ready' do
  requires 'ec2-run-instances.bin'
  met? {
    ENV["EC2_PRIVATE_KEY"] &&
    File.exist?(ENV["EC2_PRIVATE_KEY"]) && 
    ENV["EC2_CERT"] &&
    File.exist?(ENV["EC2_CERT"])
  }

  meet {
    puts "You should do this (and hopefully you have that available):"
    puts ". ~/bin/ec2-env"
  }

end


dep 'ec2-run-instances.bin' , :for => :debian do
  #installs 'default-jre-headless'
  
  meet {
    Babushka.host.pkg_helper.handle_install! "default-jre-headless"
    shell "wget -P /tmp http://de.archive.ubuntu.com/ubuntu/pool/multiverse/e/ec2-api-tools/ec2-api-tools_1.5.0.0-0ubuntu1_all.deb"
    shell "dpkg -i /tmp/ec2-api-tools_1.5.0.0-0ubuntu1_all.deb"
  }

end

dep 'ec2-run-instances.bin' , :for => :ubuntu do
  installs 'ec2-api-tools'
end


