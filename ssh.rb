dep 'ssh keys' do
  setup { define_var :ssh_dir, :message => 'Where do your SSH keys live? ', :default => '~/.ssh' }
  met? { (var(:ssh_dir) / 'id_rsa.pub').exists? && (var(:ssh_dir) / 'id_rsa').exists? }
  prepare { define_var :ssh_password, :message => 'What passphrase do you want to encrypt your SSH keys with?' }
  meet { shell "ssh-keygen -t rsa -N #{var :ssh_password} -f #{var :ssh_dir}/id_rsa" }
end

dep 'github has my public key' do
  requires 'ssh keys'
  define_var :github_username, :message => 'What is your GitHub username?'
  define_var :github_password, :message => 'What is your GitHub password?'
  met? { raw_shell('ssh -T git@github.com 2>&1').stdout['successfully authenticated'] }
  prepare {
    set :hostname, shell('hostname')
    set :public_key, shell('cat ~/.ssh/id_rsa.pub')
    set :github_api, 'https://api.github.com'
  }
  meet {
    auth = "#{var :github_username}:#{var :github_password}"
    args = "{\"title\": \"#{var :hostname}\", \"key\": \"#{var :public_key}\"}"
    shell "curl -u '#{auth}' -d '#{args}' #{var :github_api}/user/keys"
  }
end

dep 'babushka deps cloned' do
  requires 'github has my public key'
  setup {
    set :babushka_deps_dir, '~/.babushka/deps'.to_fancypath
    define_var :github_username, :message => 'What is your GitHub username?'
    define_var :babushka_deps_repo_name, :message => 'What is your Babushka deps repo called?', :default => 'babushka-deps'
    set :babushka_deps_repo, "git@github.com:#{var :github_username}/#{var :babushka_deps_repo_name}.git"
  }
  met? { var(:babushka_deps_dir).directory? && shell("(cd #{var :babushka_deps_dir} && git remote -v)")[var :babushka_deps_repo] }
  meet { shell "git clone #{var :babushka_deps_repo} #{var :babushka_deps_dir}" }
end

dep 'ssh-bootstrap' do
  requires 'babushka deps cloned'
end
