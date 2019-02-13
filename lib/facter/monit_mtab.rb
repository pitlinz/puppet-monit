#
# monit_mstab.rb
#
# 
if Facter.value(:kernel) == 'Linux'
  Facter.add(:monit_curmtab) do
    setcode do      
 
      # init  
      monit_curmtab    = {}
         
      exclude = %w(
          none proc sysfs udev devpts rpc_pipefs systemd iso9660 tmpfs cgmfs udev
          /run /proc /sys 
        )
      
      # Make regular expression form our patterns ...
      exclude = Regexp.union(*exclude.collect { |i| Regexp.new(i) })
  
      # loop mstab
      Facter::Util::Resolution.exec('cat /etc/mtab 2> /dev/null').each_line do |line|
        
        # Remove bloat ...
        line.strip!
    
        # remove empty lines
        next if line.empty? 
        
        # We have something, so let us apply our device type filter ...
        next if line.match(exclude)    
        
        # At this point we split single and valid row into tokens ...
        row = line.split(' ')
        
        next if row[1].match('/dev/')   
    
        # When tere are any spaces in the mount point name then Kernel will
        # replace them with as octal "\040" (which is 32 decimal).  We have
        # to accommodate for this and convert them back into proper spaces ...
        #
        # An example of such case:
        #
        #   /dev/sda1 /srv/shares/My\040Files ext3 rw,relatime,errors=continue,data=ordered 0 0
        #
        device = row[0].strip.gsub('\\040', ' ')
        mount  = row[1].strip.gsub('\\040', ' ')
        if mount == '/' 
          mname = "root"
        else
          mname  = mount.gsub('/', '_')
        end
        
        monit_curmtab[mname] = {}
        monit_curmtab[mname]['mntptn']    = mount
        monit_curmtab[mname]['devpath']   = device
        monit_curmtab[mname]['fstype']    = row[2]
        monit_curmtab[mname]['mntoptions']= row[3]
        monit_curmtab[mname]['dump']      = row[4]
        monit_curmtab[mname]['pass']      = row[5]
        
        #Facter::Util::Resolution.exec('echo "' + mname + ': ' + mount + '" >> /tmp/monit_mtab')
        if Facter::Util::Resolution.exec('cat /etc/fstab  | grep -v \# | grep -c "' + mount + '" ' ) == "1"
          monit_curmtab[mname]['atboot']  = true
        else
          monit_curmtab[mname]['atboot']  = false
        end
      end
  
      monit_curmtab
    end
  end  
  
end