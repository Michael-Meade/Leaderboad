require 'open3'
require 'net/ssh'
require 'open3'
def self.ssh_login
	#stdout_str, error_str, status = Open3.capture3('sshpass -p derby3333 ssh root@139.59.211.245', 'ls')
	Open3.popen3("sshpass -p derby3333 ssh root@139.59.211.245; touch bobs.txt; exit") do |stdout, stderr, status, thread|
		while line=stderr.gets do 
			puts(line) 
		end
	end
	puts stdout_str

end
#puts ssh_login

def self.lol
	Net::SSH.start('139.59.211.245', 'root', :password => "derby3333") do |ssh|
		output = ssh.exec!("touch obama.txt")
	puts output
	end


end

lol