bishnu@srv555969:~/server_api/server$ sudo apt install php8.1-fpm
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
E: Unable to locate package php8.1-fpm
E: Couldn't find any package by glob 'php8.1-fpm'
bishnu@srv555969:~/server_api/server$ sudo apt update
sudo apt install php php-fpm php-mysql -y
Hit:1 https://download.docker.com/linux/ubuntu noble InRelease
Hit:2 http://archive.ubuntu.com/ubuntu noble-backports InRelease                                 
Hit:3 http://in.archive.ubuntu.com/ubuntu noble InRelease                                        
Hit:4 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:5 http://in.archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:6 http://archive.ubuntu.com/ubuntu noble-security InRelease
Hit:7 http://in.archive.ubuntu.com/ubuntu noble-backports InRelease
Hit:8 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:9 http://in.archive.ubuntu.com/ubuntu noble-security InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
15 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
php-mysql is already the newest version (2:8.3+93ubuntu2).
php-mysql set to manually installed.
The following additional packages will be installed:
apache2 apache2-bin apache2-data apache2-utils libapache2-mod-php8.3 libapr1t64 libaprutil1-dbd-sqlite3 libaprutil1-ldap
libaprutil1t64 liblua5.4-0 php8.3 php8.3-fpm ssl-cert
Suggested packages:
apache2-doc apache2-suexec-pristine | apache2-suexec-custom www-browser php-pear
The following NEW packages will be installed:
apache2 apache2-bin apache2-data apache2-utils libapache2-mod-php8.3 libapr1t64 libaprutil1-dbd-sqlite3 libaprutil1-ldap
libaprutil1t64 liblua5.4-0 php php-fpm php8.3 php8.3-fpm ssl-cert
0 upgraded, 15 newly installed, 0 to remove and 15 not upgraded.
Need to get 5876 kB of archives.
After this operation, 19.7 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble-security/main amd64 libapr1t64 amd64 1.7.2-3.1ubuntu0.1 [108 kB]
Get:2 http://archive.ubuntu.com/ubuntu noble/main amd64 libaprutil1t64 amd64 1.6.3-1.1ubuntu7 [91.9 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble/main amd64 libaprutil1-dbd-sqlite3 amd64 1.6.3-1.1ubuntu7 [11.2 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble/main amd64 libaprutil1-ldap amd64 1.6.3-1.1ubuntu7 [9116 B]
Get:5 http://archive.ubuntu.com/ubuntu noble/main amd64 liblua5.4-0 amd64 5.4.6-3build2 [166 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble-security/main amd64 apache2-bin amd64 2.4.58-1ubuntu8.6 [1330 kB]
Get:7 http://archive.ubuntu.com/ubuntu noble-security/main amd64 apache2-data all 2.4.58-1ubuntu8.6 [163 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble-security/main amd64 apache2-utils amd64 2.4.58-1ubuntu8.6 [97.2 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble-security/main amd64 apache2 amd64 2.4.58-1ubuntu8.6 [90.2 kB]
Get:10 http://archive.ubuntu.com/ubuntu noble-security/main amd64 libapache2-mod-php8.3 amd64 8.3.6-0ubuntu0.24.04.4 [1850 kB]
Get:11 http://archive.ubuntu.com/ubuntu noble-security/universe amd64 php8.3-fpm amd64 8.3.6-0ubuntu0.24.04.4 [1925 kB]
Get:12 http://archive.ubuntu.com/ubuntu noble-security/main amd64 php8.3 all 8.3.6-0ubuntu0.24.04.4 [9172 B]
Get:13 http://archive.ubuntu.com/ubuntu noble/main amd64 php all 2:8.3+93ubuntu2 [4076 B]
Get:14 http://archive.ubuntu.com/ubuntu noble/universe amd64 php-fpm all 2:8.3+93ubuntu2 [4162 B]
Get:15 http://archive.ubuntu.com/ubuntu noble/main amd64 ssl-cert all 1.1.2ubuntu1 [17.8 kB]
Fetched 5876 kB in 2s (3696 kB/s)     
Preconfiguring packages ...
Selecting previously unselected package libapr1t64:amd64.
(Reading database ... 114086 files and directories currently installed.)
Preparing to unpack .../00-libapr1t64_1.7.2-3.1ubuntu0.1_amd64.deb ...
Unpacking libapr1t64:amd64 (1.7.2-3.1ubuntu0.1) ...
Selecting previously unselected package libaprutil1t64:amd64.
Preparing to unpack .../01-libaprutil1t64_1.6.3-1.1ubuntu7_amd64.deb ...
Unpacking libaprutil1t64:amd64 (1.6.3-1.1ubuntu7) ...
Selecting previously unselected package libaprutil1-dbd-sqlite3:amd64.
Preparing to unpack .../02-libaprutil1-dbd-sqlite3_1.6.3-1.1ubuntu7_amd64.deb ...
Unpacking libaprutil1-dbd-sqlite3:amd64 (1.6.3-1.1ubuntu7) ...
Selecting previously unselected package libaprutil1-ldap:amd64.
Preparing to unpack .../03-libaprutil1-ldap_1.6.3-1.1ubuntu7_amd64.deb ...
Unpacking libaprutil1-ldap:amd64 (1.6.3-1.1ubuntu7) ...
Selecting previously unselected package liblua5.4-0:amd64.
Preparing to unpack .../04-liblua5.4-0_5.4.6-3build2_amd64.deb ...
Unpacking liblua5.4-0:amd64 (5.4.6-3build2) ...
Selecting previously unselected package apache2-bin.
Preparing to unpack .../05-apache2-bin_2.4.58-1ubuntu8.6_amd64.deb ...
Unpacking apache2-bin (2.4.58-1ubuntu8.6) ...
Selecting previously unselected package apache2-data.
Preparing to unpack .../06-apache2-data_2.4.58-1ubuntu8.6_all.deb ...
Unpacking apache2-data (2.4.58-1ubuntu8.6) ...
Selecting previously unselected package apache2-utils.
Preparing to unpack .../07-apache2-utils_2.4.58-1ubuntu8.6_amd64.deb ...
Unpacking apache2-utils (2.4.58-1ubuntu8.6) ...
Selecting previously unselected package apache2.
Preparing to unpack .../08-apache2_2.4.58-1ubuntu8.6_amd64.deb ...
Unpacking apache2 (2.4.58-1ubuntu8.6) ...
Selecting previously unselected package libapache2-mod-php8.3.
Preparing to unpack .../09-libapache2-mod-php8.3_8.3.6-0ubuntu0.24.04.4_amd64.deb ...
Unpacking libapache2-mod-php8.3 (8.3.6-0ubuntu0.24.04.4) ...
Selecting previously unselected package php8.3-fpm.
Preparing to unpack .../10-php8.3-fpm_8.3.6-0ubuntu0.24.04.4_amd64.deb ...
Unpacking php8.3-fpm (8.3.6-0ubuntu0.24.04.4) ...
Selecting previously unselected package php8.3.
Preparing to unpack .../11-php8.3_8.3.6-0ubuntu0.24.04.4_all.deb ...
Unpacking php8.3 (8.3.6-0ubuntu0.24.04.4) ...
Selecting previously unselected package php.
Preparing to unpack .../12-php_2%3a8.3+93ubuntu2_all.deb ...
Unpacking php (2:8.3+93ubuntu2) ...
Selecting previously unselected package php-fpm.
Preparing to unpack .../13-php-fpm_2%3a8.3+93ubuntu2_all.deb ...
Unpacking php-fpm (2:8.3+93ubuntu2) ...
Selecting previously unselected package ssl-cert.
Preparing to unpack .../14-ssl-cert_1.1.2ubuntu1_all.deb ...
Unpacking ssl-cert (1.1.2ubuntu1) ...
Setting up php8.3-fpm (8.3.6-0ubuntu0.24.04.4) ...
Package apache2 is not configured yet. Will defer actions by package php8.3-fpm.

Creating config file /etc/php/8.3/fpm/php.ini with new version
NOTICE: Not enabling PHP 8.3 FPM by default.
NOTICE: To enable PHP 8.3 FPM in Apache2 do:
NOTICE: a2enmod proxy_fcgi setenvif
NOTICE: a2enconf php8.3-fpm
NOTICE: You are seeing this message because you have apache2 package installed.
Created symlink /etc/systemd/system/multi-user.target.wants/php8.3-fpm.service → /usr/lib/systemd/system/php8.3-fpm.service.
Setting up php8.3 (8.3.6-0ubuntu0.24.04.4) ...
Setting up ssl-cert (1.1.2ubuntu1) ...
Created symlink /etc/systemd/system/multi-user.target.wants/ssl-cert.service → /usr/lib/systemd/system/ssl-cert.service.
Setting up php-fpm (2:8.3+93ubuntu2) ...
Setting up libapr1t64:amd64 (1.7.2-3.1ubuntu0.1) ...
Setting up liblua5.4-0:amd64 (5.4.6-3build2) ...
Setting up apache2-data (2.4.58-1ubuntu8.6) ...
Setting up libaprutil1t64:amd64 (1.6.3-1.1ubuntu7) ...
Setting up php (2:8.3+93ubuntu2) ...
Setting up libaprutil1-ldap:amd64 (1.6.3-1.1ubuntu7) ...
Setting up libaprutil1-dbd-sqlite3:amd64 (1.6.3-1.1ubuntu7) ...
Setting up apache2-utils (2.4.58-1ubuntu8.6) ...
Setting up apache2-bin (2.4.58-1ubuntu8.6) ...
Setting up libapache2-mod-php8.3 (8.3.6-0ubuntu0.24.04.4) ...
Package apache2 is not configured yet. Will defer actions by package libapache2-mod-php8.3.

Creating config file /etc/php/8.3/apache2/php.ini with new version
No module matches
Setting up apache2 (2.4.58-1ubuntu8.6) ...
Enabling module mpm_event.
Enabling module authz_core.
Enabling module authz_host.
Enabling module authn_core.
Enabling module auth_basic.
Enabling module access_compat.
Enabling module authn_file.
Enabling module authz_user.
Enabling module alias.
Enabling module dir.
Enabling module autoindex.
Enabling module env.
Enabling module mime.
Enabling module negotiation.
Enabling module setenvif.
Enabling module filter.
Enabling module deflate.
Enabling module status.
Enabling module reqtimeout.
Enabling conf charset.
Enabling conf localized-error-pages.
Enabling conf other-vhosts-access-log.
Enabling conf security.
Enabling conf serve-cgi-bin.
Enabling site 000-default.
info: Switch to mpm prefork for package libapache2-mod-php8.3
Module mpm_event disabled.
Enabling module mpm_prefork.
info: Executing deferred 'a2enmod php8.3' for package libapache2-mod-php8.3
Enabling module php8.3.
Created symlink /etc/systemd/system/multi-user.target.wants/apache2.service → /usr/lib/systemd/system/apache2.service.
Could not execute systemctl:  at /usr/bin/deb-systemd-invoke line 148.
Created symlink /etc/systemd/system/multi-user.target.wants/apache-htcacheclean.service → /usr/lib/systemd/system/apache-htcacheclean.service.
Processing triggers for ufw (0.36.2-6) ...
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for libc-bin (2.39-0ubuntu8.4) ...
Processing triggers for php8.3-fpm (8.3.6-0ubuntu0.24.04.4) ...
NOTICE: Not enabling PHP 8.3 FPM by default.
NOTICE: To enable PHP 8.3 FPM in Apache2 do:
NOTICE: a2enmod proxy_fcgi setenvif
NOTICE: a2enconf php8.3-fpm
NOTICE: You are seeing this message because you have apache2 package installed.
Processing triggers for libapache2-mod-php8.3 (8.3.6-0ubuntu0.24.04.4) ...
Job for apache2.service failed because the control process exited with error code.
See "systemctl status apache2.service" and "journalctl -xeu apache2.service" for details.
invoke-rc.d: initscript apache2, action "restart" failed.
× apache2.service - The Apache HTTP Server
Loaded: loaded (/usr/lib/systemd/system/apache2.service; enabled; preset: enabled)
Active: failed (Result: exit-code) since Sat 2025-05-24 12:19:39 UTC; 10ms ago
Docs: https://httpd.apache.org/docs/2.4/
Process: 17274 ExecStart=/usr/sbin/apachectl start (code=exited, status=1/FAILURE)
CPU: 17ms

May 24 12:19:39 srv555969 systemd[1]: Starting apache2.service - The Apache HTTP Server...
May 24 12:19:39 srv555969 apachectl[17276]: (98)Address already in use: AH00072: make_sock: could not bind to address [::]:80
May 24 12:19:39 srv555969 apachectl[17276]: (98)Address already in use: AH00072: make_sock: could not bind to address 0.0.0.0:80
May 24 12:19:39 srv555969 apachectl[17276]: no listening sockets available, shutting down
May 24 12:19:39 srv555969 apachectl[17276]: AH00015: Unable to open logs
May 24 12:19:39 srv555969 systemd[1]: apache2.service: Control process exited, code=exited, status=1/FAILURE
May 24 12:19:39 srv555969 systemd[1]: apache2.service: Failed with result 'exit-code'.
May 24 12:19:39 srv555969 systemd[1]: Failed to start apache2.service - The Apache HTTP Server.
Scanning processes...                                                                                                        
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
bishnu@srv555969:~/server_api/server$ sudo systemctl status php-fpm
Unit php-fpm.service could not be found.
bishnu@srv555969:~/server_api/server$ 