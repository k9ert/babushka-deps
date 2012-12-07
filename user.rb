dep 'dotfiles', :username, :github_user, :repo do
  username.default!(shell('whoami'))
  github_user.default('k9ert')
  repo.default('dotfiles')
  requires 'user exists'.with(:username => username), 'git', 'curl.bin','rake.bin'
  met? {
    "~#{username}/.dotfiles/.git".p.exists?
  }
  meet {
    shell %Q{git clone git://github.com/#{github_user}/#{repo} ~/.dotfiles }, :as => username
    shell "cd ~/.dotfiles && git checkout custom-bash-zsh && rake install[y]"
  }
end

dep 'rake.bin'

dep 'user setup for provisioning', :username, :key do
  requires [
    'user exists'.with(:username => username),
    'passwordless ssh logins'.with(username, key),
    'passwordless sudo'.with(username)
  ]
end

dep 'app user setup', :user, :key, :env do
  env.default('production')
  requires [
    'user setup'.with(user, key),        # Dot files, ssh keys, etc.
    'app env vars set'.with(user, env),  # Set RACK_ENV and friends.
    'web repo'.with("~#{user}/current") # Configure ~/current to accept deploys.
  ]
end

dep 'user auth setup', :username, :password, :key do
  requires 'user exists with password'.with(username, password)
  requires 'passwordless ssh logins'.with(username, key)
end

dep 'user exists with password', :username, :password do
  requires 'user exists'.with(:username => username)
  on :linux do
    met? { shell('sudo cat /etc/shadow')[/^#{username}:[^\*!]/] }
    meet {
      sudo %{echo "#{password}\n#{password}" | passwd #{username}}
    }
  end
end

dep 'user exists', :username, :home_dir_base do
  home_dir_base.default(username['.'] ? '/srv/http' : '/home')

  on :osx do
    met? { !shell("dscl . -list /Users").split("\n").grep(username).empty? }
    meet {
      homedir = home_dir_base / username
      {
        'Password' => '*',
        'UniqueID' => (501...1024).detect {|i| (Etc.getpwuid i rescue nil).nil? },
        'PrimaryGroupID' => 'admin',
        'RealName' => username,
        'NFSHomeDirectory' => homedir,
        'UserShell' => '/bin/bash'
      }.each_pair {|k,v|
        # /Users/... here is a dscl path, not a filesystem path.
        sudo "dscl . -create #{'/Users' / username} #{k} '#{v}'"
      }
      sudo "mkdir -p '#{homedir}'"
      sudo "chown #{username}:admin '#{homedir}'"
      sudo "chmod 701 '#{homedir}'"
    }
  end
  on :linux do
    met? { '/etc/passwd'.p.grep(/^#{username}:/) }
    meet {
      sudo "mkdir -p #{home_dir_base}" and
      sudo "useradd -m -s /bin/bash -b #{home_dir_base} -G admin #{username}" and
      sudo "chmod 701 #{home_dir_base / username}"
    }
  end
end
