# Hosting EmiROS at emiralpkayikci.com

This guide explains how to host EmiROS on a Raspberry Pi 5 running PiOS, making it accessible at emiralpkayikci.com.

## Architecture

```
Internet
    ↓
Domain: emiralpkayikci.com
    ↓
Raspberry Pi 5 (Public IP)
    ↓ iptables (port 80 forwarding)
PiOS Host OS
    ↓ QEMU (port forwarding 80→80)
EmiROS Guest (in QEMU)
    ↓
Web Dashboard (BusyBox httpd on port 80)
```

## Prerequisites

- Raspberry Pi 5 with Raspberry Pi OS (PiOS) installed
- Public IP address (static or dynamic DNS)
- Domain name (emiralpkayikci.com)
- Port 80 accessible from internet (check with ISP)

## Setup Steps

### 1. Prepare PiOS Host

Update your Raspberry Pi OS:
```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 2. Copy EmiROS Image

Transfer the built image to your Pi:
```bash
scp output/images/sdcard.img pi@YOUR_PI_IP:/home/pi/
```

Or build directly on the Pi (requires time and resources).

### 3. Run Setup Script

```bash
cd emiros
sudo ./scripts/setup-host.sh
```

This script will:
- Install QEMU
- Create `/opt/emiros` directory
- Copy the EmiROS image
- Create startup script
- Configure systemd service
- Set up firewall rules

### 4. Start EmiROS Service

```bash
sudo systemctl start emiros-qemu
```

Check status:
```bash
sudo systemctl status emiros-qemu
```

### 5. Verify Local Access

On the Pi, test the web dashboard:
```bash
curl http://localhost
```

You should see HTML output.

### 6. Configure DNS

Point your domain to the Raspberry Pi's public IP:

**At your DNS provider (e.g., Cloudflare, GoDaddy):**

Create an A record:
```
Type: A
Name: @
Content: YOUR_PI_PUBLIC_IP
TTL: Auto
```

For subdomain:
```
Type: A
Name: www
Content: YOUR_PI_PUBLIC_IP
TTL: Auto
```

### 7. Configure Router

Forward port 80 from your router to the Raspberry Pi:

1. Access router admin panel (usually 192.168.1.1)
2. Find Port Forwarding settings
3. Add rule:
   - External Port: 80
   - Internal Port: 80
   - Internal IP: YOUR_PI_LOCAL_IP
   - Protocol: TCP

### 8. Test External Access

From another network or mobile data:
```bash
curl http://emiralpkayikci.com
```

Or open in browser: http://emiralpkayikci.com

## HTTPS Setup (Optional)

For HTTPS, you'll need a reverse proxy since BusyBox httpd doesn't support SSL.

### Install Nginx on PiOS

```bash
sudo apt-get install nginx certbot python3-certbot-nginx
```

### Configure Nginx

Edit `/etc/nginx/sites-available/emiros`:

```nginx
server {
    listen 80;
    server_name emiralpkayikci.com www.emiralpkayikci.com;

    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/emiros /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Get SSL Certificate

```bash
sudo certbot --nginx -d emiralpkayikci.com -d www.emiralpkayikci.com
```

Follow prompts. Certbot will automatically configure HTTPS.

## Monitoring

### Check QEMU Process

```bash
ps aux | grep qemu
```

### View QEMU Console

```bash
sudo systemctl status emiros-qemu
sudo journalctl -u emiros-qemu -f
```

### Connect via VNC

From another computer:
```bash
vncviewer YOUR_PI_IP:5900
```

You'll see the EmiROS XFCE desktop.

## Troubleshooting

### Can't Access from Internet

1. Check firewall on Pi:
```bash
sudo iptables -L -n
```

2. Check router port forwarding

3. Check ISP doesn't block port 80

4. Test public IP:
```bash
curl ifconfig.me
```

### QEMU Won't Start

Check logs:
```bash
sudo journalctl -u emiros-qemu -xe
```

Common issues:
- Image file missing
- QEMU not installed
- Permissions issue

Fix permissions:
```bash
sudo chown root:root /opt/emiros/*
sudo chmod 644 /opt/emiros/sdcard.img
```

### Service Restarts Frequently

Check if QEMU is crashing:
```bash
sudo journalctl -u emiros-qemu --since "1 hour ago"
```

Might need more resources:
- Increase Pi RAM allocation
- Reduce QEMU memory: `-m 512M` instead of `-m 1G`

## Performance Optimization

### Reduce QEMU Overhead

Edit `/opt/emiros/start-emiros.sh`:

```bash
# Use KVM if available (not on Pi, but useful on x86)
# Add: -enable-kvm

# Reduce CPU cores
-smp 2  # instead of 4

# Reduce memory
-m 512M  # instead of 1G
```

### Use systemd-networkd

For better networking performance on PiOS.

## Dynamic DNS

If you don't have static IP, use dynamic DNS:

### No-IP Setup

```bash
sudo apt-get install noip2
sudo noip2 -C
```

### Duck DNS Setup

Add to crontab:
```bash
crontab -e
```

Add line:
```
*/5 * * * * curl "https://www.duckdns.org/update?domains=YOUR_DOMAIN&token=YOUR_TOKEN"
```

## Backup

Backup your EmiROS image:
```bash
sudo cp /opt/emiros/sdcard.img /opt/emiros/sdcard.img.backup
```

## Updates

To update EmiROS:

1. Build new image
2. Stop service:
```bash
sudo systemctl stop emiros-qemu
```
3. Replace image:
```bash
sudo cp new-sdcard.img /opt/emiros/sdcard.img
```
4. Start service:
```bash
sudo systemctl start emiros-qemu
```

## Security Considerations

⚠️ **Security Notes:**

1. Change default root password in EmiROS
2. Use HTTPS (see above)
3. Configure firewall properly
4. Keep PiOS updated
5. Monitor access logs
6. Consider VPN instead of public exposure

## Next Steps

- [Customize XFCE](xfce-customization.md)
- Monitor dashboard metrics
- Set up automated backups
