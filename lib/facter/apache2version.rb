Facter.add('monitapache2version') do
  confine :kernel => 'Linux'
  setcode do
    if File.exist? '/usr/sbin/apachectl'
      Facter::Core::Execution.exec("/usr/sbin/apachectl -v | grep version | cut -f2 -d'/' | cut -f1 -d' ' | cut -f1-2 -d'.'")
    end
  end
end

