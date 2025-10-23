# Installation und Einrichtung

## Detaillierte Installationsanleitung für JSAIAgent

### Voraussetzungen

#### 1. Node.js installieren

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Prüfen
node --version  # sollte >= 18.0.0 sein
npm --version
```

#### 2. Asterisk installieren

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install asterisk asterisk-core-sounds-de asterisk-core-sounds-de-gsm

# Asterisk starten
sudo systemctl start asterisk
sudo systemctl enable asterisk

# Status prüfen
sudo systemctl status asterisk
sudo asterisk -rvvv
```

#### 3. Coqui TTS installieren

```bash
# Python und pip installieren
sudo apt-get install python3 python3-pip

# Coqui TTS installieren
pip3 install TTS

# Thorsten-Modell testen
tts --text "Hallo, dies ist ein Test" --model_name tts_models/de/thorsten/tacotron2-DDC --out_path test.wav

# TTS Server starten
tts-server --model_name tts_models/de/thorsten/tacotron2-DDC --port 5002
```

Optional: TTS als Systemd Service einrichten:

```bash
sudo nano /etc/systemd/system/coqui-tts.service
```

Inhalt:
```ini
[Unit]
Description=Coqui TTS Server
After=network.target

[Service]
Type=simple
User=your_user
ExecStart=/usr/local/bin/tts-server --model_name tts_models/de/thorsten/tacotron2-DDC --port 5002
Restart=always

[Install]
WantedBy=multi-user.target
```

Dann:
```bash
sudo systemctl daemon-reload
sudo systemctl enable coqui-tts
sudo systemctl start coqui-tts
```

### JSAIAgent Installation

#### 1. Projekt klonen und einrichten

```bash
cd /opt
sudo git clone https://github.com/berndmarcel860-byte/Jsaiagent.git
sudo chown -R $USER:$USER Jsaiagent
cd Jsaiagent
npm install
```

#### 2. Umgebungsvariablen konfigurieren

```bash
cp .env.example .env
nano .env
```

Tragen Sie Ihre Konfiguration ein:
```env
OPENAI_API_KEY=sk-proj-your-actual-api-key-here
ASTERISK_PASSWORD=your_secure_password
```

#### 3. Asterisk konfigurieren

**Wichtig**: Erstellen Sie immer Backups!

```bash
# Backups erstellen
sudo cp /etc/asterisk/extensions.conf /etc/asterisk/extensions.conf.backup
sudo cp /etc/asterisk/sip.conf /etc/asterisk/sip.conf.backup
sudo cp /etc/asterisk/manager.conf /etc/asterisk/manager.conf.backup

# Konfiguration kopieren
sudo cp asterisk/extensions.conf /etc/asterisk/
sudo cp asterisk/sip.conf /etc/asterisk/
sudo cp asterisk/manager.conf /etc/asterisk/

# WICHTIG: Passwörter in manager.conf anpassen
sudo nano /etc/asterisk/manager.conf
# Ändern Sie "your_admin_password_here" zu einem sicheren Passwort

# Asterisk neu laden
sudo asterisk -rx "dialplan reload"
sudo asterisk -rx "sip reload"
sudo asterisk -rx "manager reload"
```

#### 4. Firewall konfigurieren (optional)

```bash
# UFW Firewall
sudo ufw allow 5060/udp  # SIP
sudo ufw allow 10000:20000/udp  # RTP
sudo ufw allow 5038/tcp  # AMI (nur localhost empfohlen)
```

#### 5. JSAIAgent als Service einrichten

```bash
sudo nano /etc/systemd/system/jsaiagent.service
```

Inhalt:
```ini
[Unit]
Description=JSAIAgent - AI Phone Agent
After=network.target asterisk.service coqui-tts.service
Requires=asterisk.service

[Service]
Type=simple
User=your_user
WorkingDirectory=/opt/Jsaiagent
Environment=NODE_ENV=production
ExecStart=/usr/bin/node src/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Service aktivieren:
```bash
sudo systemctl daemon-reload
sudo systemctl enable jsaiagent
sudo systemctl start jsaiagent
sudo systemctl status jsaiagent
```

### Testen der Installation

#### 1. Dienste prüfen

```bash
# Asterisk
sudo systemctl status asterisk
sudo asterisk -rvvv

# Coqui TTS
systemctl status coqui-tts
curl http://localhost:5002/api/voices

# JSAIAgent
sudo systemctl status jsaiagent
sudo journalctl -u jsaiagent -f
```

#### 2. SIP-Client konfigurieren

Verwenden Sie einen SIP-Client wie:
- **Zoiper** (Windows, Mac, Linux, Mobile)
- **Linphone** (Windows, Mac, Linux, Mobile)
- **MicroSIP** (Windows)

Beispiel-Konfiguration für Extension 1000:
```
Server: <Asterisk-Server-IP>
Port: 5060
Username: 1000
Password: test1000
Display Name: Test User
```

#### 3. Test-Anruf

1. Registrieren Sie Ihren SIP-Client mit Extension 1000
2. Wählen Sie Extension 5000
3. Der AI-Agent sollte antworten mit: "Guten Tag! Willkommen bei unserem Investment Service..."

### Troubleshooting

#### AGI Server startet nicht

```bash
# Port bereits belegt?
sudo netstat -tulpn | grep 4573

# Logs prüfen
tail -f /opt/Jsaiagent/logs/error.log

# Service neu starten
sudo systemctl restart jsaiagent
```

#### Asterisk findet AGI Server nicht

```bash
# In Asterisk CLI:
sudo asterisk -rvvv
> agi set debug on
> dialplan reload

# Test-Anruf durchführen
> originate SIP/1000 extension 5000@internal
```

#### Audio-Probleme

```bash
# Codec-Support prüfen
sudo asterisk -rx "core show codecs"

# Audio-Geräte prüfen
aplay -l
arecord -l

# ALSA-Treiber installieren (falls nötig)
sudo apt-get install alsa-utils
```

#### OpenAI API Fehler

```bash
# API Key testen
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"

# Rate Limits prüfen im OpenAI Dashboard
```

### Performance-Optimierung

#### 1. TTS Caching

Häufig verwendete Phrasen können gecacht werden, um Latenz zu reduzieren.

#### 2. Asterisk Tuning

```bash
# In /etc/asterisk/asterisk.conf
sudo nano /etc/asterisk/asterisk.conf
```

```ini
[options]
minmemfree = 100
```

#### 3. Node.js Memory

Für hohe Last:
```bash
# In Service-Datei
Environment=NODE_OPTIONS="--max-old-space-size=2048"
```

### Produktiv-Einsatz

#### Sicherheits-Checkliste

- [ ] Asterisk Manager nur auf localhost binden
- [ ] Starke Passwörter für alle Extensions
- [ ] Firewall korrekt konfiguriert
- [ ] OpenAI API Key sicher gespeichert
- [ ] Regelmäßige Backups der Konfiguration
- [ ] Log-Rotation eingerichtet
- [ ] Monitoring aktiviert

#### Monitoring

```bash
# Log-Rotation einrichten
sudo nano /etc/logrotate.d/jsaiagent
```

```
/opt/Jsaiagent/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 your_user your_group
    postrotate
        systemctl reload jsaiagent
    endscript
}
```

### Support

Bei Problemen:
1. Prüfen Sie die Logs: `tail -f /opt/Jsaiagent/logs/error.log`
2. Asterisk CLI: `sudo asterisk -rvvv`
3. System-Logs: `sudo journalctl -xe`
4. Öffnen Sie ein Issue auf GitHub
