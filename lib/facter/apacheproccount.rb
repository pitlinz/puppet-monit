Facter.add('monitapacheproccount') do
  confine :kernel => 'Linux'
  setcode do
    if File.exist? '/etc/apache2/'
      Facter::Core::Execution.exec("echo `/bin/ps aux | /bin/grep apache2 | /bin/grep -c start`")
    end
  end
end

