#!/bin/bash
yum -y update
yum -y install httpd
MYIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor = "black">
<h2><font color = "gold" > Built by the power of <font color ="red">Terraform</font></h2><br>
<font color = "green">Server private IP: <font color= "aqua"> $myip<br><br>
<font color = "magenta">
<b>Version 1.0</b>
</body>
</html>
EOF

service httpd start
chkconfig httpd on
