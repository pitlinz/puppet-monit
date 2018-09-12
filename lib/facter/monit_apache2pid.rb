Facter.add('monit_apche2pid') do
  confine :kernel => 'Linux'
  setcode do
    Facter::Core::Execution.exec("if [ -f /etc/apache2/envvars ]; then . /etc/apache2/envvars; echo $APACHE_PID_FILE; fi")
  end
end