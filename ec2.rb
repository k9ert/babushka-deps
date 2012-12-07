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
   installs 'ec2-api-tools'
end
