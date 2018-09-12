Facter.add('monitsummary') do
  confine :kernel => 'Linux'
  setcode do
    if File.file?('/usr/bin/monit')
      Facter::Core::Execution.exec('/usr/bin/monit summary')
    end
  end
end