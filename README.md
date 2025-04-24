# Desafio 1 - PB Compass 

O objetivo deste desafio é a partir de uma máquina virtual (VM) de distribuição linux, criar um webhook para notificar em um servidor Discord a cada um minuto o status de uma página hospedada no servidor web nginx instalado VM. 

 

Para concluir este objetivo, foram utilizados 

* Oracle Virtual Box versão 7.1.6 

* Debian 12.10 (sistema operacional instalado na VM) 

* Discord (versão para computador) 

* nginx versão (x.x.x) 

 

Opcionalmente, foi usado o SAMBA para transferência de arquivos chave na execução da tarefa. Ao final da próxima sessão haverá a instalação e configuração para que ela seja operacional 

 

## Configurando do ambiente 

Como foi utilizado o Oracle Virtual Box, é necessário primeiro [instalá-lo](https://www.virtualbox.org/wiki/Downloads). Um erro pode ocorrer caso tente instalar em um outro segmento/ disco que não esteja o sistema operacional da máquina original a ser usada. 

 

Ao final da instalação, é possível criar a máquina virtual Debian no computador. Faça o [Download](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso) ou utilize a ferramenta do Virtual Box para fazer o download e instalação da mesma seguindo os passos: 

Selecione a opção máquina e após isto a opção "Novo" 

![Imagem-1](image.png) 

Digite o nome da máquina virtual, a pasta a armazenar seus conteúdos: 

![Imagem-2](image-1.png) 

Caso tenha realizado o download da imagem, selecione o arquivo a partir da opção Imagem ISO > "Outro": 

![Imagem-3](image-2.png) 

Caso não tenha atualizado os itens abaixo, selecione o tipo de sistema operacional, seu respectivo subtipo e sua versão. Siga para o segmento "Hardware" 

![Imagem-4](image-3.png) 

Altere as opções de memória e número de núcleos dependendo da necessidade de sua utilização, para exemplos práticos somente 2 Gb de memória e um núcleo é o suficiente para a prática. Desde a versão 6 de virtual box ocorre erros ao utilizar o EFI para criar o GRUB, indispensável para iniciar a máquina virtual, portanto desabilite esta opção. Desabilite a instalação assistida e siga para a seção de Disco Rígido 

![Imagem-5](image-4.png) 

Para esta prática utilizar somente 20 Gb de armazenamento é o suficiente para configurar e utilizar a máquina virtual. Caso não haja espaço suficiente em disco, mantenha desselecionado a opção "Pré-alocar Tamanho Total" 

Uma vez configurado, pressione finalizar. 

Com esta configuração é possível instalar corretamente a máquina virtual, no entanto, é recomendando mais um passo para a transmissão de arquivos entre a máquina virtual e a máquina hospedeira. Com a máquina virtual selecionada, aperte Configurações > Rede > Adaptador 2 e selecione "Habilitar Placa de Rede   

![Imagem-6](image-5.png) 

Em conectado a: selecione a opção Placa em modo Bridge. Selecione a placa de rede a ser utilizada e aperte ok. 

Siga a instalação escolhendo a linguagem de preferência, escolha o teclado corretamente e nomeie a máquina virtual a sua escolha. Não adicione o nome de domínio caso não seja necessário em sua rede. Digite a senha do administrador da máquina virtual e crie seu usuário. Após selecionar o fuso horário, escolha a opção de partição assistido - usar disco inteiro. Selecione o disco e selecione a opção Partição em /home separada 

![Imagem-7](image-6.png) 

Após esta configuração não há outra adicional a ser feita, conclua o processo de instalação sem informar nenhuma informação solicitada. 

Como o sistema operacional linux no sistema gráfico pode ser custoso, é possivel desabilitá-lo abrindo o Terminal (Selecione o menu ![Imagem-8](image-11.png) e abra o Terminal conforme a figura abaixo) 

![Imagem-9](image-7.png) 

altere para o usuário root (su root), digite a senha do usuário administrador e digite os comandos 

 

``` 

systemctl set-default multi-user.target 

systemctl reboot 

``` 

 

Para desabilitar o protocolo DHCP da interface de rede Bridge, serão necessários os seguintes passos: 

digite o comando  

 

`ip -4 a` 

 

e verifique qual é o nome do segundo adaptador que foi alterado para o modo bridge (ver Imagem 6 o número do adaptador) sendo o adaptador mostrado em 0 o dispositivo de loopback e qual domínio o computador remoto está conectado.  

 

Verifique também as configurações da rede da máquina hospedeira pois será configurada de maneira manual, mantendo-a caso a máquina virtual seja desligada.  

 

Uma vez identificado, utilize novamente o comando para alterar usuário para administrador do sistema operacional root e acesse o arquivo interfaces no diretório /etc/network/ usando o comando 

 

`vi /etc/network/interfaces` 

 

ou 

 

`nano /etc/network/interfaces` 

 

e no final do arquivo digite as linhas: 

``` 

auto < nome_do_dispositivo > 

iface < nome_do_dispositivo > inet static 

address < IP_a_ser_fixado > 

netmask < mascara_de_sub_rede > 

network < endereco_de_rede > 

broadcast < endereco_de_broadcast > 

gateway < porta_da_rede > 

``` 

onde somente o nome do dispositivo e o ip serão exclusivos da VM e o restante das informações serão idênticas ao sistema operacional hospedeiro. 

Estas novas linhas representam: 

- auto: inicia o dispositivo de rede junto ao sistema 

- iface < nome_do_dispositivo > inet static: especifica que o dispositivo será configurado manualmente 

- address: endereço de IP 

- netmask: máscara de sub rede 

- network: endereço de rede  

- broadcast: endereço de broadcast 

- gateway: endereço de gateway 

 

Uma vez salvo o arquivo, utilize o comando 

 

`service networking restart` 

 

para reiniciar o serviço de rede. 

Uma vez reiniciado o serviço está operacional para a tarefa, porém para comunicar melhor com o sistema operacional hospedeiro, foi usada uma pasta compartilhada configurando o servidor para também funcionar como um servidor de arquivos. 

 

Este passo não obrigatório pode ser substituído utilizando as transferências de arquivos utilizando a conexão FTP. Para instalar o serviço (SAMBA), utilize o comando: 

 

`apt-get install samba smbclient cifs-utils ` 

 

Uma vez instalado, verifique se o serviço esteja funcionando com o comando 

 

`service --status-all` 

 

Crie um diretório a ser compartilhado utilizando o comando  

 

`mkdir < Nome_do_diretorio >` 

 

Para compartilhamento total, dê a permissão irrestrita para qualquer usuário utilizando o comando 

 

`chmod 777 < Nome_do_diretorio >` 

 

Entre na pasta utilizando o comando  

 

`cd < Nome_do_diretorio >` 

 

e use o comando 

 

`pwd` 

 

para saber o caminho completo do novo diretório para a próxima etapa. 

Vá ao diretório /etc/samba e crie o arquivo smb.conf com o editor de arquivo de sua prefencia: 

 

`vi smb.conf` 

 

ou 

 

`nano smb.conf` 

 

e digite as linhas 

``` 

[global] 

workgroup = WORKGROUP 

log file = /var/log/samba/log.%m 

syslog = 0 

server role = standalone server 

map to guest = bad user 

 

[< Nome_do_diretorio >] 

path = < caminho_do_diretorio > 

avaliable = yes 

browseable = yes 

writeable = yes 

guest ok = yes 

``` 

Descritivamente, cada linha modifica: 

- map to guest: mapeia usuários mal autenticados para a conta de convidado 

- avaliable: indica o caminho do diretório a ser compartilhado 

- browseable: indica se a pasta estará visível ou não em sua rede 

- writable: indica se o diretório permite escrita de outros usuários 

 

## Configurando o servidor web 

Será utilizado o servidor web nginx. Para a instalação do nginx, é necessário instalar os pré requisitos para utilização. Os pré requisitos são instalados pelo seguinte comando apt-get: 

 

``` 

sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring 

``` 

O segundo passo é buscar a chave de verificação para autentificar os pacotes de instalação do nginx 

``` 

curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \ | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null 

``` 

Verifique se o arquivo baixado contém a chave correta 

``` 

gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg 

``` 

A chave deve conter a chave de caracteres `573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62` 

 

Para adicionar o repositório oficial com a versão estavel, digite o comando 

``` 

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \ http://nginx.org/packages/debian `lsb_release -cs` nginx" \ | sudo tee /etc/apt/sources.list.d/nginx.list 

``` 

Faça a instalação dos pacotes nginx 

``` 

sudo apt update 

sudo apt install nginx 

``` 

 

Uma vez instalado, verifique se o serviço do nginx está operacional 

``` 

service nginx status 

``` 

ou 

``` 

nginx -t 

``` 

para realizar o teste do nginx. 

Configure o arquivo do servidor nginx.conf em /etc/nginx usando o codigo 

 

``` 

vi /etc/nginx/nginx.conf 

``` 

ou 

``` 

nano /etc/nginx/nginx.conf 

``` 

e insira as seguintes linhas 

``` 

    http{ 

        include /etc/nginx/sites-enabled/x; 

        server{ 

            listen 80; 

            location / { 

                root /data/www; 

            } 

        } 

    } 

``` 

*_Note que dentro do arquivo existente já possui a chave http, portanto insira o restante das linhas dentro da mesma._ 

 

Insira crie um arquivo html com o nome `index.html` dentro da pasta `/usr/share/nginx/html/` ou insira um na pasta. Use o protocolo FTP ou o diretório compartilhado na parte opcional da sessão anterior para enviar o arquivo para a máquina virtual. 

 

É possível acessar a página criada através de outro dispositivo dentro da rede pelo endereço `http://<IP_fixado>/index.html` 

 

## Criando o webhook no discord 

para criar um webhook no discord é necessário ser administrador de um servidor do discord. Para criar um servidor siga os seguintes passos: 

Localize o ícone `+` no canto esquerdo 

![Imagem-10](image-12.png) 

Selecione a opção `Criar o meu` 

![Imagem-11](image-13.png) 

Selecione a opção `Para meus amigos e eu` 

![Imagem-12](image-14.png) 

Crie o servidor com o nome desejado 

![Imagem-13](image-16.png) 

Aperte a seta para baixo identificada com o círculo vermelho 

![Imagem-14](image-17.png) 

Selecione a opção `Conf. do Servidor` 

![Imagem-15](image-18.png) 

Selecione a opção `Integrações` em APPs de acordo com a imagem abaixo 

![Imagem-16](image-19.png) 

Escolha a opção `Criar webhook`  

![Imagem-17](image-20.png) 

É possível editar o nome e a imagem nesta sessão. Após personificação, selecione a opção `Copiar URL do webhook` 

![Imagem-18](image-21.png) 

*_Atenção: Essa informação é sensivel, portanto tenha cuidado para enviá-la a terceiros_   

## Criando o script de monitoramento 

Um script de monitoramento pode ser criado no sistema operacional com um arquivo de comandos bash. 

 

É possível enviar o arquivo pronto via FTP ou enviando com a pasta compartilhada. Caso não queira enviar o arquivo para a VM, crie um arquivo com `<nome>.sh` usando os comandos 

``` 

vi <nome>.sh 

``` 

ou 

``` 

nano <nome>.sh 

``` 

Para criar o script de monitoramento, digite o código abaixo: 

``` 

#!/bin/bash 

 

webhook_url="https://<URL_do_webhook>" 

#Substituir o link com suas credenciais no bot do discord 

websites_list="http://<IP_fixado>/index.html" 

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

``` 

As linhas do comando bash: 

- `#!/bin/bash`: inicia a linguagem bash com instruções a serem interpretadas pelo sistema operacional 

- `webhook_url="https://<URL_do_webhook>"`: define a variável associada ao webhook 

 

- `websites_list="http://<IP_fixado>/index.html"`: define uma lista de sites a serem verificadas. caso queira adicionar mais sites, adicione seguindo o exemplo `"http://site1/,http://site2/,..."` 

- `data=$(date +"%F")`: armazena a data em formato aaaa-mm-dd a partir da hora da VM 

- `hora=$(date +"%T")`: armazena hora em formato hh:mm:ss a partir da hora do servidor 

- `for website in ${websites_list}; do`: inicia laço sobre lista de sites da lista a ser verificada 

 

- `status_code=$(curl --write-out %{http_code} --silent --output /dev/null -L ${website})`: armazena saída do comando curl a partir da solicitação de resposta à mensagem REST.  

 

- `if [[ "$status_code" -ne 200 ]] ; then`: verifica se a resposta não possui valor (not equal) de 200 (recebida com sucesso), caso positivo, é disparada a solicitação para o webhook informar o erro 

- `curl -H "Content-Type: application/json" -X POST -d '{"content":"'"${website} esta com erro. Codigo do erro: ${status_code}"'"}'  $webhook_url`: envia via JSON para API do webhook a mensagem relatando erro, com link do site e seu número de erro. 

- `echo "Verificacao do dia ${data} e hora ${hora}.${website} Status: ${status_code}" >> /var/log/log_checker.log`: escreve em arquivo log.log localizado em `/var/log/` a data, hora, link do site e status que ocorreu o erro 

- `else`: condição caso o código seja 200 

- `curl -H "Content-Type: application/json" -X POST -d '{"content":"'"${website} esta ok. Codigo: ${status_code}"'"}'  $webhook_url`: informa via JSON a API do webhook para comunicar que o site está funcional 

- `echo "Verificacao do dia ${data} e hora ${hora}. ${website} Status: ok" >> /var/log/log_checker.log`: escreve em arquivo log.log localizado em `/var/log/` a data, hora, link do site e status ok informando que houve sucesso no instante da verificação 

- `fi`: finaliza o condicional 

- `done`: encerra o laço  

 

Para que o comando tenha permissão de execução, digite o comando 

``` 

chmod +x <nome_do_arquivo>.sh 

``` 

Mova o arquivo para uma pasta a sua escolha e após isto use o comando `pwd` para saber o `< caminho do arquivo >` que será usado a seguir. 

 

Para atribuir uma tarefa cron ou daemon no linux, use o código  

``` 

crontab -e 

``` 

O sistema perguntará qual editor de texto você irá querer usar em sua primeira vez, selecione uma das opções e adicione após as linhas existentes a linha 

``` 

*/1 * * * * /bin/bash < caminho do arquivo >/<nome>.sh 

``` 

O comando contém o padrão cron com o agendamento de tarefa: 

- */1: a cada minuto 

- \*: todas as horas 

- \*: todos os dias 

- \*: todos os meses 

- \*: todos os dias da semana  

- /bin/bash: utilizando o bash  

- < caminho do arquivo >/<nome>.sh: nome do arquivo a ser utilizado usando o caminho global 

*_Atenção: o caminho tem que ser acessível para o administrador, assim como há de ser verificado se o diretório /var/log possui permissão para ser escrito, caso contrário deverá ser criado o arquivo log.log na pasta, atribuir a permissão com o `chmod 777 log_checker.log` e verificar se o erro foi resolvido. Caso contrario, retorne a permissão para 644 com `chmod 644 log_checker.log` e verificar a permissão da pasta com o comando ls -la se está `drwxr-xr-x` 

Após a edição, salve o arquivo e execute o comando para iniciar o agendamento digite o comando 

``` 

/etc/init.d/cron start 

``` 

ou 

``` 

sudo service cron start 

``` 

## Testando as funcionalidades 

Caso tudo esteja funcionando, ao acessar a página index.html retonará uma página em html de acordo com o código enviado e o webhook enviará mensagens da forma: 

![Imagem-19](image-22.png) 

É possível simular a queda do site parando o serviço do nginx utilizando o comando 

``` 

service nginx stop 

``` 

Retornando a mensagem com a abaixo 

![Imagem-20](image-23.png) 

para reiniciar o processo digite o comando 

``` 

service nginx start 

``` 

Também é possível simular a queda do site alterando ou link da lista para um inexistente ou alterando o nome do arquivo para outro que não seja index.html, retornando assim a mensagem: 

![Imagem-21](image-24.png) 

As mensagens de log no arquivo log.log deve possuir a forma 

![Imagem-22](image-25.png) 

 
