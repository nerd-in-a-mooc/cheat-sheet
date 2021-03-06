# 🐽 Hardening

These configurations aren't perfect, but one can find them useful as a fully functional starting point.

## 🍳 Iptables-persistent

Install this package. Rules will survive a reboot, no script needed.

```shell
apt -y install iptables-persistent
```

Try these rules as a starting point.

- `/etc/iptables/rules.v4`

<details>
    <summary>click to see the configuration file.</summary>

```bash
##############################################
# GENERIC ACCEPT RULES FOR AUTHORIZED INPUTS #

# Autoriser les réponses au connexions établies.
iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT

# Localhost
iptables -A INPUT -i lo -j ACCEPT

# ICMPv4
iptables -A INPUT -p icmp -j ACCEPT

# SSH depuis poste(s) admin
iptables -s xxx.xxx.xxx.xxx -A INPUT -p tcp --dport 22 -j ACCEPT

###############################################
# Add rules only if you need more than web

# WEB

iptables -A INPUT -i eth1 -p tcp --dport 80  -j ACCEPT
iptables -A INPUT -i eth1 -p tcp --dport 443 -j ACCEPT

##############################################
# GENERIC DROP RULE FOR NON-AUTHORIZED INPUT #

# Refuser les autres connexions
iptables -A INPUT -j DROP
```

</details>

Save them !

```bash
iptables-save > /etc/iptables/rules.v4
```

And check them !

```shell
iptables -L
```

Or flush them if anything went wrong !

```shell
iptables -F
```

Restore them !

```bash
iptables-restore < /etc/iptables/rules.v4
```

You can edit your `/etc/iptables/rules.v4` file or add them one by one to add or remove rules.

## 🥘 Disable Apache signatures

```bash
echo "" >> /etc/apache2/apache2.conf
echo "#Security :" >> /etc/apache2/apache2.conf
echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
echo "ServerSignature Off" >> /etc/apache2/apache2.conf
```

## 🍲 Error redirection

Create / use a redirection for error pages. Use them in `apache2.conf` or in your vHOST configuration file. 

```bash
ErrorDocument 404 https://http.cat/404
ErrorDocument 301 https://http.cat/301
```

## 🥣 Fail2ban

These are good !

- [Roque Night Rules](https://github.com/RoqueNight/Fail2Ban-Filters)

### 🌱 Configuration

- `/etc/fail2ban/jail.local`

<details>
    <summary>click to see the configuration file.</summary>

```bash
[DEFAULT]
bantime    = 84600
findtime   = 600
maxretry   = 3
destemail  = janitor@localhost
sendername = Fail2ban
action     = %(action_mwl)s

[sshd]
enabled  = true
port     = 22
filter   = sshd
maxretry = 3
bantime  = 3600
logpath  = %(sshd_log)s
backend  = %(sshd_backend)s

[apache-auth]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s

[apache-badbots]
enabled  = true
port     = http,https
logpath  = %(apache_access_log)s
bantime  = 48h
maxretry = 1

[apache-noscript]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s

[apache-overflows]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s
maxretry = 2

[apache-nohome]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s
maxretry = 2

[apache-botsearch]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s
maxretry = 2

[apache-fakegooglebot]
enabled  = true
port     = http,https
logpath  = %(apache_access_log)s
maxretry = 1
ignorecommand = %(ignorecommands_dir)s/apache-fakegooglebot <ip>

[apache-modsecurity]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s
maxretry = 2

[apache-shellshock]
enabled  = true
port    = http,https
logpath = %(apache_error_log)s
maxretry = 1

[apache-404]
enabled  = true
port     = http, https
filter   = apache-404
logpath  = /var/log/apache2/
maxretry = 5

[apache-301]
enabled  = true
port     = http, https
filter   = apache-301
logpath  = /var/log/apache2/
maxretry = 5

[apache-nohacking]
enabled  = true
port     = http, https
filter   = apache-nohacking
logpath  = /var/log/apache2/
maxretry = 1

[apache-osinjection]
enabled = true
port = http,https
filter = apache-osinjection
logpath = /var/log/apache2/
maxretry = 1
```

</details>

### 🌳 Règles

- `/etc/fail2ban/filter.d/apache-404.conf`

```bash
[Definition]
failregex   = <HOST> - - \[.*\] ".*?" 404
ignoreregex =
```

- `/etc/fail2ban/filter.d/apache-301.conf`

```bash
[Definition]
failregex   = <HOST> - - \[.*\] ".*?" 301
ignoreregex =
```

- `/etc/fail2ban/filter.d/apache-nohacking.conf`

```bash
[Definition]
badbotscustom = EmailCollector|ApacheBench/2.3|Python-urlib/2.7|curl/7.52.1|curl/7.40.0|nmap|Nessus|libwww-perl/6.13|python-requests/2.9.1|VEGA123|Ruby|Vega/1.0|python-requests/2.12.3|muhstik-scan|zgrab/0.x|Telesphoreo|Grabber|curl|CURL|Googlebot/2.1|sqlmap|W3C_Validator/1.3 http://validator.w3.org/services|masscan/1.0 (https://github.com/robertdavidgraham/masscan)|Go-http-client/1.1|python-requests/2.18.4|Mozilla/5.0 zgrab/0.x|Python-urllib/2.7|masscan|HTTrack|Baiduspider|wpscan|Acunetix|sysscan|Nmap Scripting Engine|Nikto/2.1.6|commix/v2.2-stable|curl/7.55.1|UserAgent|Wget/1.19.1 (linux-gnu)|wget|Wget|WebEMailExtrac|TrackBack/1\.02|sogou music spider
badbots       = Atomic_Email_Hunter/4\.0|atSpider/1\.0|autoemailspider|bwh3_user_agent|China Local Browse 2\.6|ContactBot/0\.2|ContentSmartz|DataCha0s/2\.0|DBrowse 1\.4b|DBrowse 1\.4d|Demo Bot DOT 16b|Demo Bot Z 16b|DSurf15a 01|DSurf15a 71|DSurf15a 81|DSurf15a VA|EBrowse 1\.4b|Educate Search VxB|EmailSiphon|EmailSpider|EmailWolf 1\.00|ESurf15a 15|ExtractorPro|Franklin Locator 1\.8|FSurf15a 01|Full Web Bot 0416B|Full Web Bot 0516B|Full Web Bot 2816B|Guestbook Auto Submitter|Industry Program 1\.0\.x|ISC Systems iRc Search 2\.1|IUPUI Research Bot v 1\.9a|LARBIN-EXPERIMENTAL \(efp@gmx\.net\)|LetsCrawl\.com/1\.0 \+http\://letscrawl\.com/|Lincoln State Web Browser|LMQueueBot/0\.2|LWP\:\:Simple/5\.803|Mac Finder 1\.0\.xx|MFC Foundation Class Library 4\.0|Microsoft URL Control - 6\.00\.8xxx|Missauga Locate 1\.0\.0|Missigua Locator 1\.9|Missouri College Browse|Mizzu Labs 2\.2|Mo College 1\.9|MVAClient|Mozilla/2\.0 \(compatible; NEWT ActiveX; Win32\)|Mozilla/3\.0 \(compatible; Indy Library\)|Mozilla/3\.0 \(compatible; scan4mail \(advanced version\) http\://www\.peterspages\.net/?scan4mail\)|Mozilla/4\.0 \(compatible; Advanced Email Extractor v2\.xx\)|Mozilla/4\.0 \(compatible; Iplexx Spider/1\.0 http\://www\.iplexx\.at\)|Mozilla/4\.0 \(compatible; MSIE 5\.0; Windows NT; DigExt; DTS Agent|Mozilla/4\.0 efp@gmx\.net|Mozilla/5\.0 \(Version\: xxxx Type\:xx\)|NameOfAgent \(CMS Spider\)|NASA Search 1\.0|Nsauditor/1\.x|PBrowse 1\.4b|PEval 1\.4b|Poirot|Port Huron Labs|Production Bot 0116B|Production Bot 2016B|Production Bot DOT 3016B|Program Shareware 1\.0\.2|PSurf15a 11|PSurf15a 51|PSurf15a VA|psycheclone|RSurf15a 41|RSurf15a 51|RSurf15a 81|searchbot admin@google\.com|ShablastBot 1\.0|snap\.com beta crawler v0|Snapbot/1\.0|Snapbot/1\.0 \(Snap Shots&#44; \+http\://www\.snap\.com\)|sogou develop spider|Sogou Orion spider/3\.0\(\+http\://www\.sogou\.com/docs/help/webmasters\.htm#07\)|sogou spider|Sogou web spider/3\.0\(\+http\://www\.sogou\.com/docs/help/webmasters\.htm#07\)|sohu agent|SSurf15a 11 |TSurf15a 11|Under the Rainbow 2\.2|User-Agent\: Mozilla/4\.0 \(compatible; MSIE 6\.0; Windows NT 5\.1\)|VadixBot|WebVulnCrawl\.unknown/1\.0 libwww-perl/5\.803|Wells Search II|WEP Search 00
failregex     = ^<HOST> -.*"(GET|POST|HEAD).*HTTP.*"(?:%(badbots)s|%(badbotscustom)s)"$
ignoreregex   =
```

- `/etc/fail2ban/filter.d/apache-osinjection`

```bash
[Definition]
failregex = ^<HOST>.*GET.*(?i)ls.*
            ^<HOST>.*GET.*(?i)cd.*
            ^<HOST>.*GET.*(?!)var.*
            ^<HOST>.*GET.*(?!)www.*
            ^<HOST>.*GET.*(?!)idfile.*
            ^<HOST>.*GET.*(?i)mv.*
            ^<HOST>.*GET.*(?!)echo.*
            ^<HOST>.*GET.*(?!)log.*
            ^<HOST>.*GET.*(?!)tmp.*
            ^<HOST>.*GET.*(?!)wget.*
            ^<HOST>.*GET.*(?!)nc.*
            ^<HOST>.*GET.*(?!)id.*
            ^<HOST>.*GET.*(?i)adduser.*
            ^<HOST>.*GET.*(?i)mkdir.*
            ^<HOST>.*GET.*(?i)sudo.*
            ^<HOST>.*GET.*(?i)passwd.*
            ^<HOST>.*GET.*(?!)etc.*
            ^<HOST>.*GET.*(?!)bin.*
            ^<HOST>.*GET.*(?!)cat.*
            ^<HOST>.*GET.*(?!)cmd.*
            ^<HOST>.*GET.*(?!)uname.*
            ^<HOST>.*GET.*(?!)bash.*
            ^<HOST>.*GET.*(?!)ps.*
            ^<HOST>.*GET.*(?!)sh.*
ignoreregex =
```

```bash
systemctl restart fail2ban.service
```

## 🥗 Hardening vHOST SSL

Use this excellent [SSL Configuration Generator](https://ssl-config.mozilla.org/) by moz://a :

<details>
    <summary>Example of a hardened vHOST</summary>

```bash
<IfModule mod_ssl.c>
<VirtualHost *:443>

        ServerName catnap.fr
        ServerAlias www.catnap.fr

        ServerAdmin janitor@localhost

        RewriteEngine on
        RewriteCond %{HTTP_USER_AGENT}  ^.*sqlmap.*$
        RewriteCond %{HTTP_USER_AGENT}  ^.*Nikto.*$
        RewriteRule . - [R=403,L]

        ServerSignature Off

        DocumentRoot /home/catnap/www/

        <Directory /home/catnap/www/>
            Options +FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        SSLEngine on
        SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
        SSLCipherSuite HIGH:!aNULL:!MD5:!ADH:!RC4:!DH:!RSA
        SSLHonorCipherOrder on

        Header always set Strict-Transport-Security "max-age=31536000"
        Header always set Content-Security-Policy "default-src 'self'; font-src *;img-src * data:; script-src *; style-src *;"
        Header always set Referrer-Policy "strict-origin-when-cross-origin"
        Header always set X-Content-Type-Options "nosniff"
        Header always set X-Frame-Options "SAMEORIGIN"
        Header always set Expect-CT "enforce, max-age=300, report-uri='https://catnap.fr/'"
        Header always set Permissions-Policy "geolocation=();midi=();notifications=();push=();sync-xhr=();microphone=();camera=();magnetometer=();gyroscope=();speaker=(self);vibrate=();fullscreen=(self);payment=();"

        ErrorDocument 404 https://http.cat/404
        ErrorDocument 301 https://http.cat/301

Include /etc/letsencrypt/options-ssl-apache.conf
SSLCertificateFile /etc/letsencrypt/live/catnap.fr/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/catnap.fr/privkey.pem
</VirtualHost>
</IfModule>
```

</details>