Facter.add('monit_apche2version') do
  confine :kernel => 'Linux'
  setcode do
    Facter::Core::Execution.exec("if [ -x /usr/sbin/apachectl ]; then /usr/sbin/apachectl -v | grep version | cut -f2 -d'/' | cut -f1 -d' '; fi")
  end
end
