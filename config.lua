return {
	bot_api_key =  os.getenv ( ' BOT_TOKEN ' ) ou  '  ' , - token Colocar
	cmd =  ' ^ [/!] ' ,
	allowed_updates = { " message " , " edited_message " , " callback_query " },
	db =  0 , - padrão redis db: 0
	superadmins = { 487693235 },
	log = {
		chat =  487693235 ,
		admin =  487693235 ,
		stats =  nil
	}
	human_readable_version =  ' 1.0.v - @Moderadorbot ' ,
	bot_settings = {
		cache_time = {
			adminlist =  18000 , - 5 horas (18000s) Tempo de cache do administrador, em segundos.
			alert_help =  72 ,   - quantidade de horas para alertas de ajuda do cache
			chat_titles =  18000
		}
		report = {
			duração =  1200 ,
			times_allowed =  2
		}
		notify_bug =  true , - Notifica se ocorrer um erro!
		log_api_errors =  true , - Erros de log, que acontecem durante a interação com o bot api.
		stream_commands =  true ,
		admin_mode =  false ,
		debug_connections =  false ,
		realm_max_members =  60 ,
		realm_max_subgroups =  6
	}
	canal =  ' @moderadores ' , - nome de usuário do canal com o '@'
	source_code =  ' https://github.com/viniciusvrc/moderadorbot ' ,
	help_groups_link =  ' https://telegram.me/viniciusvrc ' ,
	plugins = {
		' onmessage ' , - DEVE SER O PRIMEIRO: SE UM USUÁRIO ESTIVER INUNDADO / ESTÁ BLOQUEADO, O BOT NÃO IRÁ ATRAVÉS DE PLUGINS
		' antispam ' , - SAME OF onmessage.lua
		- "reinos", - deve ficar aqui
		' backup ' ,
		' banhammer ' ,
		' block ' ,
		' configure ' ,
		' dashboard ' ,
		' floodmanager ' ,
		' ajuda ' ,
		' links ' ,
		' logchannel ' ,
		' mediasettings ' ,
		' menu ' ,
		' mudo ' ,
		' moderadores ' ,
		' pin ' ,
		' Privado ' ,
		' particular_settings ' ,
		' report ' ,
		' regras ' ,
		' serviço ' ,
		' setlang ' ,
		' usuários ' ,
		" avisar " ,
		' Boas-vindas ' ,
		' admin ' ,
        ' voteban ' ,
		' extra ' , - deve ser o último plugin da lista.
		' chatbot ' ,
	}
	multipurpose_plugins = {},
	available_languages = {
		[ ' en ' ] =  ' inglês 🇬🇧 ' ,
		[ ' it ' ] =  ' Italiano 🇮🇹 ' ,
		[ ' es ' ] =  ' Español 🇪🇸 ' ,
		[ ' pt_BR ' ] =  ' Português 🇧🇷 ' ,
		[ ' ru ' ] =  ' Русский 🇷🇺 ' ,
		[ ' de ' ] =  ' Deutsch 🇩🇪 ' ,
		- ['sv'] = 'Svensk 🇸🇪',
		[ ' ar ' ] =  ' العربية 🇸🇩 ' ,
		- ['fr'] = 'Français 🇫🇷',
		[ ' zh ' ] =  '中文 🇨🇳 ' ,
		[ ' fa ' ] =  ' فارسی 🇮🇷 ' ,
		[ ' id ' ] =  ' Bahasa Indonesia 🇮🇩 ' ,
		[ ' nl ' ] =  ' holandês '
		- mais idiomas virão
	}
	allow_fuzzy_translations =  false ,
	chat_settings = {
		[ ' configurações ' ] = {
			[ ' Welcome ' ] =  ' off ' ,
			[ ' Adeus ' ] =  ' desligado ' ,
			[ ' Extra ' ] =  ' on ' ,
			- ['Flood'] = 'off',
			[ ' Silent ' ] =  ' off ' ,
			[ ' Regras ' ] =  ' off ' ,
			[ ' Relatórios ' ] =  ' off ' ,
			[ ' voteban ' ] =  ' off ' ,
			[ ' Welbut ' ] =  ' off ' ,
			[ ' Antibot ' ] =  ' off '
		}
		[ ' antispam ' ] = {
			[ ' links ' ] =  ' alwd ' ,
			[ ' encaminha ' ] =  ' alwd ' ,
			[ ' avisa ' ] =  2 ,
			[ ' ação ' ] =  ' ban '
		}
		[ ' flood ' ] = {
			[ ' MaxFlood ' ] =  5 ,
			[ ' ActionFlood ' ] =  ' chute '
		}
		[ ' char ' ] = {
			[ ' Arab ' ] =  ' permitido ' , - 'chute' / 'ban'
			[ ' Rtl ' ] =  ' permitido '
		}
		[ ' floodexceptions ' ] = {
			[ ' text ' ] =  ' no ' ,
			[ ' foto ' ] =  ' não ' , - imagem
			[ ' avançar ' ] =  ' não ' ,
			[ ' video ' ] =  ' não ' ,
			[ ' adesivo ' ] =  ' não ' ,
			[ ' gif ' ] =  ' não ' ,
		}
		[ ' warnsettings ' ] = {
			[ ' type ' ] =  ' ban ' ,
			[ ' mediatype ' ] =  ' ban ' ,
			[ ' max ' ] =  3 ,
			[ ' mediamax ' ] =  2
		}
		[ ' bem-vindo ' ] = {
			[ ' type ' ] =  ' no ' ,
			[ ' content ' ] =  ' não '
		}
		[ ' adeus ' ] = {
			[ ' type ' ] =  ' custom ' ,
		}
		[ ' voteban ' ] = {
			[ ' Quorum ' ] =  5 ,
			[ ' duração ' ] =  1800 ,   - meia hora
		}
		[ ' media ' ] = {
			[ ' foto ' ] =  ' ok ' , - 'notok' | imagem
			[ ' audio ' ] =  ' ok ' ,
			[ ' video ' ] =  ' ok ' ,
			[ ' adesivo ' ] =  ' ok ' ,
			[ ' gif ' ] =  ' ok ' ,
			[ ' voz ' ] =  ' ok ' ,
			[ ' contato ' ] =  ' ok ' ,
			[ ' document ' ] =  ' ok ' , - arquivo
			[ ' link ' ] =  ' ok ' ,
			[ ' jogo ' ] =  ' ok ' ,
			[ ' location ' ] =  ' ok '
		}
		[ ' tolog ' ] = {
			[ ' ban ' ] =  ' não ' ,
			[ ' kick ' ] =  ' não ' ,
			[ ' unban ' ] =  ' não ' ,
			[ ' tempban ' ] =  ' não ' ,
			[ ' report ' ] =  ' não ' ,
			[ ' warn ' ] =  ' não ' ,
			[ ' nowarn ' ] =  ' não ' ,
			[ ' mediawarn ' ] =  ' não ' ,
			[ ' spamwarn ' ] =  ' não ' ,
			[ ' inundação ' ] =  ' não ' ,
			[ ' promover ' ] =  ' não ' ,
			[ ' rebaixar ' ] =  ' não ' ,
			[ ' cleanmods ' ] =  ' não ' ,
			[ ' new_chat_member ' ] =  ' não ' ,
			[ ' new_chat_photo ' ] =  ' não ' ,
			[ ' delete_chat_photo ' ] =  ' não ' ,
			[ ' new_chat_title ' ] =  ' não ' ,
			[ ' pinned_message ' ] =  ' não ' ,
			[ ' blockban ' ] =  ' não ' ,
			[ ' block ' ] =  ' não ' ,
			[ ' desbloquear ' ] =  ' não '
		}
		[ ' modsettings ' ] = {
			[ ' promdem ' ] =  ' sim ' , - 'sim': os administradores podem promover ou rebaixar os moderadores; 'não': somente o proprietário pode
			[ ' martelo ' ] =  ' sim ' ,
			[ ' config ' ] =  ' não ' ,
			[ ' textos ' ] =  ' não '
		}
	}
	private_settings = {
		rules_on_join =  ' off ' ,
		relatórios =  ' off '
	}
	chat_hashes = { ' extra ' , ' info ' , ' links ' , ' warns ' , ' mediawarn ' , ' spamwarns ' , ' bloqueado ' , ' report ' },
	chat_sets = { ' whitelist ' , ' mods ' },
	bot_keys = {
		d3 = { ' bot: general ' , ' bot: usernames ' , ' bot: chat: latsmsg ' },
		d2 = { ' bot: groupsid ' , ' bot: groupsid: removido ' , ' tempbanned ' , ' bot: bloqueado ' , ' remolden_chats ' } - remolden_chats: bate-papo removido com o comando $ remold
	}
}
