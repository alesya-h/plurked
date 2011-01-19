Plurked monitors your twitter account and reposts new tweets to your plurk.
# Installation
	gem install plurk
	gem install twitter
	git clone git@github.com:nekotwi/plurked.git

# Running
	cd plurked
	./plurked.rb # first time. it needs your input for configuration file creation.
	./plurked.rb & # each time system starts. or you may use your desired way to daemonize it.

# Configuring
Configuration stored in YAML format at ~/.plurked.

Options:

* key -- your plurk API key. You may use mine or your own.
* username -- your plurk login
* password -- your plurk password
* interval -- interval for checking twitter for new tweets
* twitter -- twitter account to monitor. Only public accounts are currently supported.
* lastcheck -- last time twitter was checked for updates and new tweets reposted.
