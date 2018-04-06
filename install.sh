#! / usr / bin / env bash

read -p " Você quer que eu instale o Group Butler Bot? (S / N): "

if [ " $ REPLY "  ! =  " Y " ] ;  então
    eco  " Saindo ... "
outro
    echo -e " \ e [1; 36mAtualizando pacotes \ e [0m "
    sudo apt-get update -y

    echo -e " \ e [1; 36mInstalando dependências \ e [0m "
    sudo apt-get instalar libreadline-dev libssl-dev lua5.2 luarocks liblua5.2-dev git make descompactar redis-server curl libcurl4-gnutls-dev -y
    
    echo -e " \ e [1; 36mInstalando LuaRocks de fontes \ e [0m "
    
    git clone http://github.com/keplerproject/luarocks
    cd luarocks
    ./configure --lua-version = 5.2
    fazer compilação
    sudo make install
    cd ..
    
    echo -e " \ e [1; 36mInstalando rochas \ e [0m "
    
    rochas = " serpente luasec redis-lua Lua-termo serpente dkjson Lua-cURL "
    para  rock  em  $ rocks ;  Faz
        sudo luarocks instala $ rock
    feito
        
    branch = " master "
    read -p " Deseja usar o ramo beta? (S / N): "
    
    if [ " $ REPLY "  ==  " Y " ] ;  então
        branch = " beta "
    fi
    
    echo -e " \ e [1; 36mConseguindo o último código-fonte do Group Butler (branch: $ branch ) \ e [0m "
    git clone -b $ branch https://github.com/RememberTheAir/GroupButler.git
    
    echo -e " \ e [1; 32mGroup Butler instalado com sucesso! Altere os valores no arquivo de configuração e execute ./launch.sh\e[0m "
    eco  "  "
fi
