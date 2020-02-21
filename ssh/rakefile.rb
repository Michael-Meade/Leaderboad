bgvfdsatask :block do
	File.readlines("blocked.txt").each do |package|
		system(package)
	end 
end
task :user do
	Net::SSH.start('139.59.211.245', 'root', :password => "derby3333") do |ssh|
		output = ssh.exec!("touch obama.txt")
	end
end