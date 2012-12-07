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
  requires ['ec2-api-tools-installed']
  met? {
    File.exist?(ENV["EC2_PRIVATE_KEY"]) && 
    File.exist?(ENV["EC2_CERT"])
  }

  meet {
    puts "You should do this (and hopefully you have that available):"
    puts ". ~/bin/ec2-env"
  }

end


dep 'ec2-api-tools-installed' do
  requires {
    on :ubuntu, 'ec2-run-instances.bin'
    on :debian, 'hello world'
  }
end

dep 'ec2-run-instances.bin' do
  installs {
    on :ubuntu, 'ec2-run-instances.bin'
    on :debian, 'hello world'
  }
end

dep 'ec2-run-instancesOnDebian' do

end

meta "deb" do
  accepts_list_for :source
  accepts_list_for :extra_source # this shouldn't be needed, will be patched soon
  template {
    helper :missing_sources do
      source.reject {|s|
        shell("dpkg show #{s.inspect}") # or whatever the actual command is
      }
    end
    met? {
      missing_sources.empty?
    }
    meet {
      missing_sources.each {|s|
        shell("dpkg install #{s.inspect}") # or whatever the actual command is
      }
    }
  }
end

dep 'ec2-run-instances.deb' 

