Plurked monitors your twitter account and reposts new tweets to your plurk.
# Installation
	gem install plurk
	gem install twitter
	git clone git@github.com:nekotwi/plurked.git

# Running
	cd plurked
	./plurked.rb # first time. it needs your input for configuration file creation.
	./plurked.rb & # each time system starts. or you may use your desired way to daemonize it.

or for autostart on mac:
	cd plurked
	cp Library/LaunchAgents/com.nekotwi.plurked.plist ~/Library/LaunchAgents/
	open ~/Library/LaunchAgents/com.nekotwi.plurked.plist
This will start Property List Editor. Edit /Root/ProgramArguments/Item0 so it points to your copy of plurked.rb.

# Command line options

* `-s/--skip` -- skip tweets written before daemon start.

# Configuring
Configuration stored in YAML format at ~/.plurked.

Options:

* key -- your plurk API key. You may use mine or your own.
* username -- your plurk login
* password -- your plurk password
* interval -- interval for checking twitter for new tweets
* twitter -- twitter account to monitor. Only public accounts are currently supported.
* lastcheck -- last time twitter was checked for updates and new tweets reposted.
