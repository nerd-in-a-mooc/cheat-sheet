# 🦄 Most Used Snippets

**Capturer tous les paquets sauf ma session SSH**
```bash
tcpdump port not 22 and not host my.ip.addr.ess
```

**Capturer 1000 paquets**
```bash
tcpdump -c 1000 -w /tmp/capture.pcap
```

**Rotation automatique avec timestamp des fichiers de captures**
```bash
tcpdump -w /tmp/capture-%Y-%m-%d_%H-%M.pcap -G 1800
```

# 👩‍🔧 Interfaces

**Lister les interfaces réseaux disponibles**
```bash
tcpdump -D
```

**Choisir l'interface réseau sur laquelle écouter**
```bash
tcpdump -i eth1
```

**Afficher en ASCII**
```bash
tcpdump -A
```

# 👨‍🔧 Paramètres de capture

## Ports

**Capturer les paquets d'un port spécifique**
```bash
tcpdump -i eth1 port 9000
```

**Capturer les paquets de plusieurs ports**
```bash
tcpdump port 80 or port 443 
```

**Capturer les paquets d'un range de ports**
```bash
tcpdump portange 9200-9300
```

## Configuration des hôtes

**Capturer les paquets d'un subnet**
```bash
tcpdump -i eth1 net 10.100.10.0/24
```

**Capturer les paquets en spécifiant l'hôte**
```bash
tcpdump host 10.100.10.6
```

**Capturer les paquets en provenance d'une IP particulière**
```bash
tcpdump src 10.100.10.6
```

**Capturer les paquets depuis un hote vers un autre**
```bash
tcpdump src 10.10.0.1 and dst 192.168.100.54
```

**Capturer les paquets entre deux réseaux**
```bash
tcpdump src net 10.10.0.0/24 and dst net 192.168.100.0/24
```

**Capturer les paquets dans les deux sens**
```bash
tcpdump host 10.10.0.1 and host 192.168.100.54
```

## Configuration de la taille du paquet

**Capturer les paquets dont la taille est supérieure à 200 bytes**
```bash
tcpdump greater 200
```

**Capturer les paquets dont la taille est comprise entre 200 et 500 bytes**
```bash
tcpdump not less 200 and not greater 500
```

# 📂 Fichier de capture
---
**Enregistrer la capture**
```bash
tcpdump -i eth1 -w /root/capture.pcap
```

**Lire la capture**
```bash
tcpdump -r /root/capture.pcap
```

**Affichage *human-friendly* d'un fichier de capture**
```bash
tcpdump -d /root/capture.pcap
```
