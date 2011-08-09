maintainer        "SpeedyTable, Inc."
maintainer_email  "contact@speedyseat.com"
license           "Proprietary"
description       "Installs all programs needed for a SpeedyTable server."
version           "0.0.1"
recipe            "speedyTableServer", "Installs all programs needed for a SpeedyTable server."

%w{ fedora redhat centos ubuntu debian }.each do |os|
  supports os
end
