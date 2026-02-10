--------------------------------------------------------------------------------
##Conexão Bahia Sul - Scripts Técnico
Este diretório é destinado a ferramentas de redes automatizadas para o Linux Mint, desenvolvidas para otimizar o trabalho de campo da equipe técnica da Conexão Bahiasul. O objetivo principal é servir como uma central de assistência técnica que padroniza diagnósticos e manutenções de equipamentos de rede.

#🚀 Funcionalidades Principais
O projeto é centralizado no Script Mestre (tecnico-master.sh), que utiliza uma interface visual whiptail para facilitar o acesso às seguintes ferramentas:
1. Teste de Usuário PPPoE: Automatiza a criação e validação de conexões com as credenciais bahiasul24, realizando testes de latência e velocidade via CLI.
2. Configuração de Antenas Ubiquiti: Configura automaticamente o IP técnico (192.168.1.10) para acesso rápido ao IP padrão 192.168.1.20 via Google Chrome, ignorando erros de certificado SSL.
3. Atualização de Firmware LiteBeam AC: Script dedicado para atualizar antenas para a versão v8.7.19 via SSH e SCP.
4. Análise de Wi-Fi: Atalho para lançamento do linssid para escaneamento de canais.
5. Acesso ao Winbox: Execução do Winbox (Mikrotik) através do Wine.
6. Diagnóstico de Rede: Testes rápidos de ping e função de Reset DHCP para limpar configurações temporárias na placa de rede.

#🛠️ Pré-requisitos
Para o funcionamento pleno de todos os scripts, o sistema deve ter as seguintes dependências instaladas:
• Network Manager (nmcli)
• Ferramentas de Transferência: sshpass e scp
• Testes de Velocidade: speedtest-cli
• Ambiente de Execução: wine (para Winbox) e google-chrome-stable
• Interface e Diagnóstico: whiptail e linssid

#📂 Estrutura de Diretórios
Os scripts esperam e organizam-se na seguinte estrutura local:
• ~/Downloads/Conexao_Bahiasul_Scripts_Rede/: Pasta base do repositório.
• ~/Downloads/Conexao_Bahiasul_Scripts_Rede/Atualizações Ubiquit Litebeam AC/: Local para armazenamento do firmware WA.v8.7.19.bin.

#⚙️ Como Utilizar
Para garantir que você possui a versão mais recente e executar o menu principal, utilize os seguintes comandos no terminal:
cd ~/Downloads/Conexao_Bahiasul_Scripts_Rede
git pull origin main
chmod +x *.sh
./tecnico-master.sh

#🔄 Sincronização e Atualização
O sistema possui uma lógica de auto-atualização integrada no tecnico-master.sh. Ao ser iniciado, ele verifica novas versões no GitHub e aplica as mudanças automaticamente. Além disso, o script sync_scripts.sh garante que as cópias dos arquivos na pasta pessoal ($HOME) do técnico estejam sempre atualizadas com o repositório oficial.
--------------------------------------------------------------------------------
Desenvolvido por: TheDevBruno
