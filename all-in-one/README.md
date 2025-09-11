# file-server (all-in-one)
All in one file server container starts up SSH, FTP, TFTP, and a nginx web server with directory listing to the file share.

## Usage
### Controlling the container
#### Start the container
```
docker compose up -d
```

#### Stop the container
```
docker compose down
```

#### Clean up
```
docker container rm fileserver && docker image rm all-in-one-file-server:latest
```

### Accessing servers (when container is up)
#### Logging into the container via SSH
```
dev@devbox:~$ ssh fileadmin@localhost
fileadmin@localhost's password: 
Last login: Thu Sep 11 14:23:55 2025 from 127.0.0.1
fileadmin@file-server:~$ whoami
fileadmin
fileadmin@file-server:~$ pwd
/home/fileadmin
```

#### FTP
The FTP server uses passive mode (i.e. client establishes data connection with server on server's port range). The default port range is 30000-30010.  

The FTP server accepts both known and anonymous (password-less) users.  
```
dev@devbox:~$ ftp fileadmin@127.0.0.1
Connected to 127.0.0.1.
220 (vsFTPd 3.0.5)
331 Please specify the password.
Password: 
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> get test.txt foo.bar
local: foo.bar remote: test.txt
229 Entering Extended Passive Mode (|||30005|)
150 Opening BINARY mode data connection for test.txt (8 bytes).
100% |***********************************|     8       13.70 KiB/s    00:00 ETA
226 Transfer complete.
8 bytes received in 00:00 (1.55 KiB/s)
```

#### TFTP
TFTP does not play nicely with NAT and port forwarding in containerised environments. For that reason, I have enabled host networking in the docker compose as a short-term fix.  
```
dev@devbox:~$ tftp 127.0.0.1 -v
Connected to 127.0.0.1 (127.0.0.1), port 69
tftp> get test.txt
getting from 127.0.0.1:test.txt to test.txt [netascii]
Received 8 bytes in 0.1 seconds [580 bit/s]
```

#### SFTP
A symlink to the file share directory is present in the user's home directory. Simply SFTP on with the user's creds and get files via the symlink.  
```
dev@devbox:~$ sftp fileadmin@127.0.0.1 -v
fileadmin@127.0.0.1's password: 
Connected to 127.0.0.1.
sftp> ls
share  
sftp> get share/test.txt 
Fetching /home/fileadmin/share/test.txt to test.txt
test.txt                                      100%    8     0.5KB/s   00:00 
```

#### Web server
The web server serves a directory listing to the file share, accessible on port 80/http.  
```
dev@devbox:~$ curl http://localhost:80
<html>
<head><title>Index of /</title></head>
<body>
<h1>Index of /</h1><hr><pre><a href="../">../</a>
<a href="test.txt">test.txt</a>                                           10-Sep-2025 12:25                   8
</pre><hr></body>
</html>
```

## Environment variables
### APP_USER/ APP_PASS
The app user and pass set the default user account inside the container, which can be SSHed/ FTPed onto.  

### FILE_SHARE_DIRECTORY
The default shared file directory, which is set in the .env, is `/srv/share`.    
The root directory for the various services symlink to this shared directory for ease of access.  
