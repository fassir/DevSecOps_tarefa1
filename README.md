<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1F9BD4,50:2E75B6,100:16265F&height=200&section=header&text=DevSecOps_tarefa1&fontSize=48&fontColor=ffffff&fontAlignY=38&desc=Ambiente%20Linux%20com%20Servidor%20Web%20Monitorado%20e%20Automação&descAlignY=58&descSize=17" />

</div>

<div align="center">

[![Linux](https://img.shields.io/badge/Linux-Debian%2012-1F9BD4?style=for-the-badge&logo=linux&logoColor=white)](https://debian.org)
[![Nginx](https://img.shields.io/badge/Nginx-Web%20Server-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org)
[![Shell Script](https://img.shields.io/badge/Shell-Automação-2E75B6?style=for-the-badge&logo=gnubash&logoColor=white)](#)
[![Discord](https://img.shields.io/badge/Discord-Webhook-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com)
[![VirtualBox](https://img.shields.io/badge/VirtualBox-VM-16265F?style=for-the-badge&logo=virtualbox&logoColor=white)](https://virtualbox.org)

</div>

---

## 🔐 Sobre o Projeto

> **DevSecOps_tarefa1** é um laboratório prático de **DevSecOps** que provisiona uma VM Linux (Debian 12) no VirtualBox com servidor web nginx monitorado, automação via Shell Script e notificações em tempo real pelo Discord — demonstrando boas práticas de monitoramento de disponibilidade e automação de infraestrutura.

O projeto simula um cenário real de operações: o site é monitorado a cada **1 minuto via cron**, e qualquer mudança de status (online/offline) aciona imediatamente um **Webhook Discord**, garantindo que a equipe seja notificada instantaneamente sobre incidentes.

---

## 🏗️ Arquitetura do Ambiente

<div align="center">

```
┌─────────────────────────────────────────────────────────────────────┐
│                    HOST MACHINE (Windows/Linux)                     │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           Oracle VirtualBox                                 │   │
│  │                                                             │   │
│  │   ┌───────────────────────────────────────────────────┐    │   │
│  │   │              VM: Debian 12                         │    │   │
│  │   │                                                   │    │   │
│  │   │   ┌─────────────┐    ┌────────────────────────┐  │    │   │
│  │   │   │    nginx    │    │   Shell Script Monitor  │  │    │   │
│  │   │   │  Web Server │    │   (cron: * * * * *)     │  │    │   │
│  │   │   │  :80 / :443 │    │   check_site.sh         │  │    │   │
│  │   │   └──────┬──────┘    └───────────┬─────────────┘  │    │   │
│  │   │          │                       │                 │    │   │
│  │   │          │              ┌────────▼────────┐        │    │   │
│  │   │          │              │  Discord Webhook│        │    │   │
│  │   │          │              │  Notificações   │        │    │   │
│  │   │          │              │  Online/Offline │        │    │   │
│  │   │          │              └─────────────────┘        │    │   │
│  │   │   ┌──────▼──────┐                                  │    │   │
│  │   │   │   SAMBA     │◄── Transferência de arquivos     │    │   │
│  │   │   │  (SMB/CIFS) │    host ↔ VM                     │    │   │
│  │   │   └─────────────┘                                  │    │   │
│  │   │                                                   │    │   │
│  │   │   Rede: Bridge Mode (IP na rede local)            │    │   │
│  │   └───────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                         │                           │
│                                Discord (notificações) 📣            │
└─────────────────────────────────────────────────────────────────────┘
```

</div>

---

## ⚙️ Componentes do Projeto

<details>
<summary>🖥️ Configuração da VM (Debian 12 + VirtualBox)</summary>

<br>

| Parâmetro | Configuração |
|:---|:---|
| **Hypervisor** | Oracle VirtualBox (última versão estável) |
| **SO** | Debian 12 (Bookworm) — 64-bit |
| **RAM** | 2 GB (recomendado mínimo) |
| **Disco** | 20 GB VDI dinâmico |
| **Rede** | Modo Bridge (IP na rede local do host) |
| **Servidor Web** | nginx — porta 80 |
| **Usuário sudo** | Configurado com senha segura |

```bash
# Instalação do nginx no Debian 12
sudo apt update && sudo apt upgrade -y
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

# Verificar status
sudo systemctl status nginx
curl http://localhost
```

</details>

<details>
<summary>🔔 Webhook Discord — Monitoramento a cada 1 minuto</summary>

<br>

O script `check_site.sh` é executado via **cron** a cada minuto e envia notificações para o canal Discord configurado:

```bash
#!/bin/bash
# /opt/monitor/check_site.sh

SITE_URL="http://localhost"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/SEU_WEBHOOK_AQUI"
STATUS_FILE="/var/log/site_status.txt"

# Verifica disponibilidade do site
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$SITE_URL")

# Carrega status anterior
PREV_STATUS=$(cat "$STATUS_FILE" 2>/dev/null || echo "UNKNOWN")

if [ "$HTTP_CODE" = "200" ]; then
    CURRENT_STATUS="ONLINE"
    COLOR=3066993       # Verde Discord
    EMOJI="✅"
else
    CURRENT_STATUS="OFFLINE"
    COLOR=15158332      # Vermelho Discord
    EMOJI="🚨"
fi

# Notifica apenas se houve mudança de status
if [ "$CURRENT_STATUS" != "$PREV_STATUS" ]; then
    PAYLOAD=$(cat <<JSON
{
  "embeds": [{
    "title": "${EMOJI} Site Status Changed",
    "description": "**${SITE_URL}** está **${CURRENT_STATUS}**",
    "color": ${COLOR},
    "fields": [
      {"name": "HTTP Code", "value": "${HTTP_CODE}", "inline": true},
      {"name": "Timestamp", "value": "$(date '+%d/%m/%Y %H:%M:%S')", "inline": true}
    ],
    "footer": {"text": "DevSecOps Monitor — Debian 12"}
  }]
}
JSON
)
    curl -s -X POST -H "Content-Type: application/json" \
         -d "$PAYLOAD" "$DISCORD_WEBHOOK"
fi

# Atualiza status persistido
echo "$CURRENT_STATUS" > "$STATUS_FILE"
```

</details>

<details>
<summary>⏰ Configuração do Cron</summary>

<br>

```bash
# Abra o crontab
crontab -e

# Adicione a linha para execução a cada 1 minuto
* * * * * /opt/monitor/check_site.sh >> /var/log/monitor.log 2>&1

# Verifique os logs de monitoramento
tail -f /var/log/monitor.log
```

</details>

<details>
<summary>📁 SAMBA — Transferência de Arquivos Host ↔ VM</summary>

<br>

```bash
# Instalação do SAMBA
sudo apt install samba -y

# Configuração em /etc/samba/smb.conf
sudo tee -a /etc/samba/smb.conf <<'EOF'

[compartilhado]
   path = /home/usuario/compartilhado
   browsable = yes
   read only = no
   guest ok = no
   valid users = usuario
EOF

# Cria diretório e usuário SAMBA
mkdir -p ~/compartilhado
sudo smbpasswd -a usuario

# Reinicia o serviço
sudo systemctl restart smbd nmbd
```

</details>

---

## 🛠️ Stack de Tecnologias

<div align="center">

[![My Skills](https://skillicons.dev/icons?i=linux,bash,nginx&theme=dark)](https://skillicons.dev)

</div>

<div align="center">

![Debian](https://img.shields.io/badge/Debian-12%20Bookworm-A81D33?style=flat-square&logo=debian&logoColor=white)
![VirtualBox](https://img.shields.io/badge/VirtualBox-VM-183A61?style=flat-square&logo=virtualbox&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-Web%20Server-009639?style=flat-square&logo=nginx&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash%20Script-1F9BD4?style=flat-square&logo=gnubash&logoColor=white)
![Cron](https://img.shields.io/badge/Cron-Agendamento-2E75B6?style=flat-square&logo=linux&logoColor=white)
![Discord](https://img.shields.io/badge/Discord-Webhook-5865F2?style=flat-square&logo=discord&logoColor=white)
![SAMBA](https://img.shields.io/badge/SAMBA-SMB%2FCIFS-16265F?style=flat-square&logo=linux&logoColor=white)
![curl](https://img.shields.io/badge/curl-HTTP%20Monitor-aebcd4?style=flat-square&logo=curl&logoColor=white)

</div>

---

## 📦 Instalação e Execução

### Pré-requisitos

```bash
# Software necessário no host
# - Oracle VirtualBox: https://virtualbox.org/wiki/Downloads
# - Imagem ISO Debian 12: https://cdimage.debian.org/debian-cd/current/

# Clone o repositório para ter acesso aos scripts
git clone https://github.com/fassir/DevSecOps_tarefa1.git
cd DevSecOps_tarefa1
```

### Provisionamento da VM

```bash
# 1. Crie a VM no VirtualBox com as configurações descritas
# 2. Instale o Debian 12 normalmente
# 3. Copie os scripts via SAMBA ou diretamente

# Na VM Debian, execute o script de setup completo:
sudo bash setup/provision.sh
```

### Configurando o Discord Webhook

```bash
# 1. No Discord: Configurações do Canal → Integrações → Webhooks → Novo Webhook
# 2. Copie a URL do webhook
# 3. Configure no arquivo de variáveis:
echo 'DISCORD_WEBHOOK="https://discord.com/api/webhooks/SEU_ID/SEU_TOKEN"' \
     >> /opt/monitor/.env

# 4. Instale o monitoramento
sudo bash setup/install_monitor.sh

# 5. Verifique se o cron está ativo
crontab -l
```

### Testando o Monitoramento

```bash
# Para o nginx e observe a notificação Discord
sudo systemctl stop nginx
sleep 65   # Aguarda o próximo cron

# Reinicia e veja a notificação de recuperação
sudo systemctl start nginx
```

---

## ✨ Funcionalidades

<div align="center">

| Funcionalidade | Detalhe | Status |
|:---|:---|:---:|
| 🖥️ VM Debian 12 | Provisionamento completo no VirtualBox | ✅ |
| 🌐 Nginx Web Server | Servidor web configurado e habilitado | ✅ |
| 🔔 Webhook Discord | Notificações instantâneas de mudança de status | ✅ |
| ⏰ Monitoramento Cron | Verificação automática a cada 1 minuto | ✅ |
| 🔄 Detecção de Mudança | Notifica apenas quando o status muda | ✅ |
| 📁 SAMBA | Transferência de arquivos host ↔ VM | ✅ |
| 🌉 Rede Bridge | VM acessível na rede local | ✅ |
| 📝 Logs Persistidos | Histórico de eventos em `/var/log/monitor.log` | ✅ |
| 🔐 Segurança | Usuário sudo sem senha root, SAMBA com auth | ✅ |

</div>

---

## 📂 Estrutura de Arquivos

```
DevSecOps_tarefa1/
├── 📁 setup/
│   ├── provision.sh               # Script de provisionamento completo
│   ├── install_monitor.sh         # Instalação do sistema de monitoramento
│   └── configure_samba.sh         # Configuração do SAMBA
├── 📁 monitor/
│   ├── check_site.sh              # Script principal de monitoramento
│   ├── discord_notify.sh          # Módulo de notificação Discord
│   └── .env.example               # Exemplo de variáveis de ambiente
├── 📁 nginx/
│   ├── nginx.conf                 # Configuração do nginx
│   └── sites-available/
│       └── default                # VirtualHost padrão
├── 📁 samba/
│   └── smb.conf.append            # Bloco de configuração SAMBA
├── 📁 docs/
│   ├── screenshots/               # Capturas de tela do ambiente
│   └── setup_guide.md             # Guia detalhado de configuração
├── crontab.example                # Exemplo de configuração cron
└── README.md
```

---

## 🔒 Boas Práticas DevSecOps Aplicadas

<div align="center">

| Prática | Implementação |
|:---|:---|
| 🔐 **Princípio do menor privilégio** | Usuário dedicado sem acesso root direto |
| 🔑 **Autenticação obrigatória** | SAMBA com usuário e senha, sem acesso guest |
| 📝 **Auditoria e logs** | Todos os eventos registrados com timestamp |
| 🔔 **Alertas proativos** | Notificação imediata no Discord a cada mudança |
| 🔄 **Automação** | Zero intervenção manual no monitoramento |
| 🌐 **Isolamento de rede** | VM em rede bridge com firewall configurado |

</div>

---

## 👤 Autor

<div align="center">

<img src="https://github.com/fassir.png" width="100" style="border-radius:50%"/>

**Fabio Piassi**

[![GitHub](https://img.shields.io/badge/GitHub-fassir-1F9BD4?style=for-the-badge&logo=github&logoColor=white)](https://github.com/fassir)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Fabio%20Piassi-2E75B6?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/fassir)

*Física • DevSecOps • Linux • Cloud • Automação*

</div>

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:16265F,50:2E75B6,100:1F9BD4&height=120&section=footer" />

</div>
