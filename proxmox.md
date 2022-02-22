# 🦓 PROXMOX

## Supprimer la subscription notice

**Sauvegarde du fichier de configuration**

```shell
mv /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
```

**Modification du fichier de configuration Java de ProxMox** - *Ligne 473*

Ajouter `void` et commenter `Ext.Msg.show`

```shell
void({ //Ext.Msg.show({
  title: gettext('No valid subscription'),
```

**Relancer le service**
```
systemctl restart pveproxy.service
```
