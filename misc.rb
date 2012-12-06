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
  
  
 
