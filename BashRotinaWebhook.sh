#!/bin/bash

webhook_url="<URL_do_webhook>"
#Substituir o link com suas credenciais no bot do discord
websites_list="<IP_fixado>/index.html"
#Altere para a lista de sites que queira verificar

data=$(date +"%F")
hora=$(date +"%T")

#Criando o laco
for website in ${websites_list}; do

        status_code=$(curl --write-out %{http_code} --silent --output /dev/null -L ${website})
#Verificando se o codigo de status nao recebeu o status ok
    if [[ "$status_code" -ne 200 ]] ; then
    #se nao recebeu o status ok envia a mensagem para o servidor do discord
        curl -H "Content-Type: application/json" -X POST -d '{"content":"'"${website} esta com erro. Codigo do erro: ${status_code}"'"}'  $webhook_url
        echo "Verificacao do dia ${data} e hora ${hora}.${website} Status: ${status_code}" >> /var/log/log_checker.log
    else
    #caso contrario envia a mensagem que nao caiu:
        curl -H "Content-Type: application/json" -X POST -d '{"content":"'"${website} esta ok. Codigo: ${status_code}"'"}'  $webhook_url
        echo "Verificacao do dia ${data} e hora ${hora}. ${website} Status: ok" >> /var/log/log_checker.log
    fi
done
