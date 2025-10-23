# Deployment Guide

Produktionsreife Bereitstellung von JSAIAgent

## Pre-Deployment Checklist

### System Requirements
- [ ] Ubuntu 20.04+ / Debian 11+ Server
- [ ] 4+ CPU Cores
- [ ] 4+ GB RAM
- [ ] 20+ GB Disk Space (SSD empfohlen)
- [ ] Statische IP-Adresse oder DDNS
- [ ] Root/sudo Zugriff

### Services & Accounts
- [ ] OpenAI API Account mit API Key
- [ ] Ausreichendes OpenAI API Guthaben
- [ ] Server mit Internetzugang
- [ ] Firewall-Zugriff für Administration

### Network & Security
- [ ] Port-Freigaben (5060 UDP für SIP)
- [ ] Sichere Passwörter generiert
- [ ] SSL-Zertifikate (optional, für SIP-TLS)
- [ ] Backup-Strategie definiert

## Production Deployment

### 1. Server Vorbereitung

```bash
# System aktualisieren
sudo apt-get update && sudo apt-get upgrade -y

# Benötigte Pakete
sudo apt-get install -y git curl wget ufw fail2ban

# Firewall konfigurieren
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 5060/udp  # SIP
sudo ufw allow 10000:20000/udp  # RTP
sudo ufw enable
```

### 2. Installation mit Setup-Script

```bash
# Repository klonen
cd /opt
sudo git clone https://github.com/berndmarcel860-byte/Jsaiagent.git
cd Jsaiagent

# Setup ausführen
sudo ./setup.sh
```

### 3. Konfiguration

#### .env Datei
```bash
sudo nano .env
```

**Produktions-Konfiguration:**
```env
# OpenAI Configuration
OPENAI_API_KEY=sk-proj-your-production-api-key-here

# Asterisk Configuration
ASTERISK_HOST=localhost
ASTERISK_PORT=5038
ASTERISK_USERNAME=admin
ASTERISK_PASSWORD=<secure-random-password>

# AGI Configuration
AGI_PORT=4573

# Coqui TTS Configuration
COQUI_TTS_URL=http://localhost:5002

# Agent Configuration
AGENT_EXTENSION=5000
CALLER_EXTENSION=1000

# Logging
LOG_LEVEL=info
NODE_ENV=production
```

#### Sichere Passwörter generieren
```bash
# Für Asterisk AMI
openssl rand -base64 32

# Für SIP Extensions
openssl rand -base64 16
```

### 4. Asterisk Konfiguration anpassen

```bash
# SIP.conf - IP-Adressen anpassen
sudo nano /etc/asterisk/sip.conf
# Ändern Sie:
# - bindaddr (Ihre Server-IP)
# - externaddr (Ihre externe IP)
# - localnet (Ihr lokales Netzwerk)

# Manager.conf - Passwort setzen
sudo nano /etc/asterisk/manager.conf
# Ändern Sie "your_admin_password_here"

# Asterisk neu laden
sudo asterisk -rx "reload"
```

### 5. Services starten

```bash
# Coqui TTS
sudo systemctl start coqui-tts
sudo systemctl status coqui-tts

# JSAIAgent
sudo systemctl start jsaiagent
sudo systemctl status jsaiagent

# Logs prüfen
sudo journalctl -u jsaiagent -f
```

### 6. System Check

```bash
cd /opt/Jsaiagent
./scripts/check-system.sh
```

Alle Checks sollten ✓ (grün) sein.

### 7. Test-Anruf

```bash
# Mit SIP-Client (Zoiper, Linphone, etc.)
# - Server: <Ihre-Server-IP>
# - Extension: 1000
# - Passwort: (aus sip.conf)
# Dann Extension 5000 anrufen

# Oder via Asterisk CLI:
sudo asterisk -rvvv
> originate SIP/1000 extension 5000@internal
```

## Monitoring & Maintenance

### Log-Rotation einrichten

```bash
sudo nano /etc/logrotate.d/jsaiagent
```

```
/opt/Jsaiagent/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    missingok
    create 0640 jsaiagent jsaiagent
    postrotate
        systemctl reload jsaiagent > /dev/null 2>&1 || true
    endscript
}
```

### Monitoring Setup

```bash
# Systemd Status
watch -n 5 'systemctl status jsaiagent coqui-tts asterisk'

# Logs überwachen
tail -f /opt/Jsaiagent/logs/combined.log

# Asterisk Calls
sudo asterisk -rx "core show channels"

# System Resources
htop
```

### Backup Script

```bash
sudo nano /opt/jsaiagent-backup.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/backup/jsaiagent"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup configuration
tar -czf $BACKUP_DIR/config_$DATE.tar.gz \
    /opt/Jsaiagent/.env \
    /etc/asterisk/extensions.conf \
    /etc/asterisk/sip.conf \
    /etc/asterisk/manager.conf

# Backup logs (last 7 days)
tar -czf $BACKUP_DIR/logs_$DATE.tar.gz \
    /opt/Jsaiagent/logs/*.log

# Keep only last 30 backups
ls -t $BACKUP_DIR/*.tar.gz | tail -n +31 | xargs rm -f

echo "Backup completed: $DATE"
```

```bash
chmod +x /opt/jsaiagent-backup.sh

# Cron für tägliches Backup
sudo crontab -e
# Fügen Sie hinzu:
# 0 2 * * * /opt/jsaiagent-backup.sh
```

## Performance Tuning

### Node.js Memory

Für hohe Last:
```bash
sudo nano /etc/systemd/system/jsaiagent.service
```

```ini
[Service]
Environment=NODE_OPTIONS="--max-old-space-size=4096"
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart jsaiagent
```

### Asterisk Tuning

```bash
sudo nano /etc/asterisk/asterisk.conf
```

```ini
[options]
maxcalls=100
maxload=2.0
minmemfree=256
```

### TTS Caching (Optional)

Für häufig verwendete Phrasen:
```javascript
// In src/services/tts-service.js
const cache = new Map();
// Cache-Logik implementieren
```

## Scaling

### Load Balancing

Für mehrere Server:

1. **HAProxy** vor Asterisk-Servern
2. **Shared Database** für Call-Logs
3. **Redis** für Session-Management

### Multi-Instance auf einem Server

```bash
# Instance 1
AGI_PORT=4573 npm start &

# Instance 2
AGI_PORT=4574 npm start &

# In Asterisk extensions.conf verschiedene Extensions
# zu verschiedenen Ports routen
```

## Security Hardening

### Fail2ban für Asterisk

```bash
sudo nano /etc/fail2ban/jail.local
```

```ini
[asterisk]
enabled = true
filter = asterisk
action = iptables-allports[name=asterisk, protocol=all]
logpath = /var/log/asterisk/messages
maxretry = 5
bantime = 3600
```

### SSL/TLS für SIP (Optional)

```bash
# Zertifikate generieren
sudo openssl req -x509 -newkey rsa:4096 \
    -keyout /etc/asterisk/keys/asterisk.key \
    -out /etc/asterisk/keys/asterisk.crt \
    -days 365 -nodes

# In sip.conf aktivieren
# tlsenable=yes
# tlsbindaddr=0.0.0.0:5061
# tlscertfile=/etc/asterisk/keys/asterisk.crt
# tlsprivatekey=/etc/asterisk/keys/asterisk.key
```

### API Key Rotation

```bash
# Neuen OpenAI API Key generieren
# .env aktualisieren
sudo nano /opt/Jsaiagent/.env

# Service neu starten
sudo systemctl restart jsaiagent

# Alten Key deaktivieren im OpenAI Dashboard
```

## Troubleshooting Production Issues

### High CPU Usage

```bash
# Prozesse prüfen
top -p $(pgrep -d',' -f jsaiagent)

# Node.js Profiling
node --prof src/index.js
node --prof-process isolate-*.log > processed.txt
```

### Memory Leaks

```bash
# Memory Usage überwachen
ps aux | grep node

# Heap Snapshot
kill -USR2 <node-pid>
# Erstellt heapdump in /tmp
```

### Connection Issues

```bash
# AGI Verbindungen prüfen
netstat -an | grep 4573

# Asterisk Debug
sudo asterisk -rvvv
> agi set debug on
> core set verbose 5
```

### Audio Problems

```bash
# Codec Support
sudo asterisk -rx "core show codecs"

# Audio-Dateien prüfen
ls -lh /opt/Jsaiagent/audio/

# Disk Space
df -h
```

## Update Procedure

```bash
# 1. Backup erstellen
/opt/jsaiagent-backup.sh

# 2. Service stoppen
sudo systemctl stop jsaiagent

# 3. Code aktualisieren
cd /opt/Jsaiagent
sudo git pull

# 4. Dependencies aktualisieren
npm install

# 5. Konfiguration prüfen
diff .env.example .env

# 6. Service starten
sudo systemctl start jsaiagent

# 7. Logs prüfen
sudo journalctl -u jsaiagent -f
```

## Disaster Recovery

### Service Down

```bash
# Status prüfen
sudo systemctl status jsaiagent coqui-tts asterisk

# Neu starten
sudo systemctl restart jsaiagent coqui-tts asterisk

# Logs prüfen
sudo journalctl -u jsaiagent --since "10 minutes ago"
```

### Konfiguration zurücksetzen

```bash
# Aus Backup wiederherstellen
cd /backup/jsaiagent
tar -xzf config_YYYYMMDD_HHMMSS.tar.gz -C /

# Services neu laden
sudo asterisk -rx "reload"
sudo systemctl restart jsaiagent
```

### Komplette Neuinstallation

```bash
# Backup Konfiguration sichern
cp /opt/Jsaiagent/.env ~/jsaiagent-env.backup

# Verzeichnis löschen
sudo rm -rf /opt/Jsaiagent

# Neu klonen und einrichten
cd /opt
sudo git clone https://github.com/berndmarcel860-byte/Jsaiagent.git
cd Jsaiagent
sudo ./setup.sh

# Konfiguration wiederherstellen
cp ~/jsaiagent-env.backup .env
```

## Contact & Support

Bei Produktions-Problemen:
1. Prüfen Sie die Logs: `/opt/Jsaiagent/logs/`
2. Führen Sie System Check aus: `./scripts/check-system.sh`
3. Erstellen Sie ein GitHub Issue mit:
   - Fehlerbeschreibung
   - Log-Auszüge
   - System-Informationen
   - Reproduktionsschritte

## SLA Empfehlungen

Für Produktions-Betrieb:
- **Uptime**: 99.9% (ca. 8.76h Downtime pro Jahr)
- **Response Time**: < 2s für API Calls
- **Call Handling**: < 5s bis Antwort
- **Monitoring**: 24/7 mit Alerting
- **Backup**: Täglich, 30 Tage Aufbewahrung
- **Updates**: Monatlich mit Testing

---

**Viel Erfolg mit Ihrer Produktions-Deployment!**
