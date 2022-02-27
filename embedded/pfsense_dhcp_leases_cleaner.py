# MANY THANKS TO @JUSTTUGA

import os
import subprocess

lease_file = '/var/dhcpd/var/db/dhcpd.leases'
list = []
with open(lease_file) as getLineNr: # on cherche la première ligne ou 'binding state active' apparaît
    for num, line in enumerate(getLineNr, 1):
        if 'binding state active' in line: 
            list.append(num)

with open(lease_file) as input:
    lines = input.readlines()
    # un fichier qui ne contient pas de baux n'a pas plus de 5 lignes, on change que les fichiers pas 'vides'
    if len(lines)>5:
        if list!=[]:
            # on ne veut pas supprimer les 6 lignes qui précèdent le string 'binding state active'
            # et on supprime tout jusqu'à la 5ème ligne du fichier
            i = 7
            while i < list[0]-5:
                del lines[list[0]-i]
                i = i + 1
                # parfois il reste un '}' à la ligne 7. si c'est le cas, on le supprime
                if '}' in lines[6]:
                    del lines[6]
        # au cas où le fichier ne contient pas de baux actifs
        else:
        i = len(lines)
            while i > 6:
                del lines[i-1]
                i = i - 1

with open('dhcpd_leases_temp.txt','w', newline="") as output:
    for line in lines:
        output.write(line)

input.close()
output.close()
os.remove(lease_file)
os.rename('dhcpd_leases_temp.txt', lease_file)

subprocess.run("/etc/rc.reload_all")