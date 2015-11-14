Facter.add('monitapache2pid') do
  confine :kernel => 'Linux'
  setcode do
    if File.exist? '/etc/apache2/envvars'
      Facter::Core::Execution.exec("echo `cat /etc/apache2/envvars | grep PID | cut -f2 -d'=' | cut -f1 -d'$'`.pid")
    end
  end
end

