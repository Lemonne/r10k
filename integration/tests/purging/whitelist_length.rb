require 'git_utils'
require 'r10k_utils'
require 'master_manipulator'
test_name 'RK-257 C98015  verify default whitelist length'

#Init
env_path = on(master, puppet('config print environmentpath')).stdout.rstrip
r10k_fqp = get_r10k_fqp(master)
git_environments_path = '/root/environments'

git_repo_path = '/git_repos'
git_repo_name = 'environments'
git_control_remote = File.join(git_repo_path, "#{git_repo_name}.git")

last_commit = git_last_commit(master, git_environments_path)
git_provider = ENV['GIT_PROVIDER']

r10k_config_path = get_r10k_config_file_path(master)
r10k_config_bak_path = "#{r10k_config_path}.bak"

#In-line files
r10k_conf = <<-CONF
cachedir: '/var/cache/r10k'
git:
  provider: '#{git_provider}'
sources:
  control:
    basedir: "#{env_path}"
    remote: "#{git_control_remote}"
CONF

teardown do
  step 'Restore Original "r10k" Config'
  on(master, "mv #{r10k_config_bak_path} #{r10k_config_path}")

  clean_up_r10k(master, last_commit, git_environments_path)
end

# initalize file content
step 'Stub the forge'
stub_forge_on(master)

step 'Backup Current "r10k" Config'
on(master, "mv #{r10k_config_path} #{r10k_config_bak_path}")
