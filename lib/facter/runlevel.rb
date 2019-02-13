Facter.add('runlevel') do
  confine :kernel => 'Linux'
  setcode do
    Facter::Core::Execution.exec("echo `/sbin/runlevel | cut -b3`")
  end
end