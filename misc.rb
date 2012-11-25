dep 'hello world', :someoneelse do
  meet {
    print "Hello World!"
  }
end

dep 'ec2 run wheezy' do
  requires ['ec2 ready']
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
    puts ". ~/ec2-env"
  }

end


dep 'ec2-run-instances.bin' do
   installs 'ec2-api-tools'
end
  
  
 
