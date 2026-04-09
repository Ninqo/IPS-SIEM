\# 🖥️ Spécifications des Machines Virtuelles (VirtualBox)



Ce document détaille la configuration nécessaire pour chaque machine du laboratoire afin d'assurer le bon fonctionnement du routage, de l'IPS et de la remontée des logs vers le SIEM.



\## ⚙️ Paramètres Globaux Critiques

Pour que Suricata puisse intercepter le trafic en mode IPS, les réglages suivants sont \*\*obligatoires\*\* dans VirtualBox :

\- \*\*Mode Promiscuité :\*\* `Tout autoriser` (Paramètres > Réseau > Avancé).

\- \*\*Type de carte :\*\* `Paravirtualized Network (virtio-net)` (Indispensable pour éviter les erreurs de driver Tx Unit Hang).



---



\## 1. Gateway (Passerelle de sécurité)

C'est le cœur de l'infrastructure où sont installés \*\*Suricata\*\* et l'\*\*Agent Wazuh\*\*.



| Paramètre | Configuration |

| :--- | :--- |

| \*\*OS\*\* | Debian 12 (64-bit) |

| \*\*CPU / RAM\*\* | 2 vCPU / 2 Go RAM |

| \*\*Adaptateur 1\*\* | Accès par pont (Accès Internet / WAN) |

| \*\*Adaptateur 2\*\* | Réseau interne : `iot-network` (LAN Protégé) |

| \*\*Rôle\*\* | Routage, NAT, Filtrage IPS (NFQUEUE) |



---



\## 2. ITProjet (Cible IoT)

Représente l'objet connecté ou le serveur industriel à protéger.



| Paramètre | Configuration |

| :--- | :--- |

| \*\*OS\*\* | Debian 12 (64-bit) |

| \*\*CPU / RAM\*\* | 1 vCPU / 1 Go RAM |

| \*\*Adaptateur 1\*\* | Réseau interne : `iot-network` |

| \*\*Passerelle par défaut\*\* | `192.168.1.1` (IP de la Gateway) |

| \*\*Services\*\* | Broker MQTT (Mosquitto), SSH |



---



\## 3. Wazuh Manager (SIEM)

Le centre de contrôle qui reçoit et analyse les alertes de sécurité.



| Paramètre | Configuration |

| :--- | :--- |

| \*\*OS\*\* | Ubuntu 22.04 LTS |

| \*\*CPU / RAM\*\* | 2 vCPU / 4 Go RAM (Minimum recommandé : 6 Go) |

| \*\*Stockage\*\* | 50 Go (SSD recommandé pour les index d'alertes) |

| \*\*Adaptateur 1\*\* | Accès par pont (Bridge) |

| \*\*Accès Interface\*\* | `https://<IP\_WAZUH>:443` |



---



\## 🛠️ Procédure de mise en route rapide

1\. \*\*Démarrer la Gateway\*\* et activer l'IP Forwarding :

&nbsp;  `sysctl -w net.ipv4.ip\_forward=1`

2\. \*\*Démarrer l'ITProjet\*\* et vérifier la route par défaut vers la Gateway :

&nbsp;  `ip route add default via 192.168.1.1` (si non configuré en statique).

3\. \*\*Lancer Suricata en mode IPS\*\* sur la Gateway :

&nbsp;  `suricata -c /etc/suricata/suricata.yaml -q 0`

4\. \*\*Appliquer la redirection NFQUEUE\*\* :

&nbsp;  `iptables -I FORWARD -j NFQUEUE --queue-num 0`

