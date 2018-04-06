api local =  requer  ' métodos '
redis locais =  requerem  ' redis '
clr local =  require  ' term.colors '
u local , config, plugins, last_update, last_cron
db = redis. connect ( ' 127.0.0.1 ' , 6379 )

function bot_init ( on_reload ) - A função executada quando o bot é iniciado ou recarregado.
	
	config =  dofile ( ' config.lua ' ) - Carrega o arquivo de configuração.
	assert ( não (config. bot_api_key  ==  " "  ou  não config. bot_api_key ), clr. red .. ' Insira o token de bot em config.lua -> bot_api_key ' .. clr. reset )
	assert ( # config. superadmins  >  0 , cl. red .. ' Insira sua identificação de telegrama em config.lua -> superadmins ' .. clr. reset )
	assert (config. log . admin , cl. red .. ' Insira o seu ID de telegrama em config.lua -> log.admin ' .. clr. reset )
	
	db: select (config. db  ou  0 ) - selecione o redis db
	
	u =  dofile ( ' utilities.lua ' ) - Carrega funções diversas e cross-plugin.
	locale =  dofile ( ' languages.lua ' )
	now_ms =  requer ( ' socket ' ). consiga tempo
	
	bot = api. getMe (). resultado  - obter informações de bot
	robô. revisão  = u. bash ( ' git rev-parse - curto HEAD ' )

	plugins = {} - Carrega plugins.
	para i, v em  ipairs (config. plugins ) fazer
		local p =  require ( ' plugins. ' .. v)
		pacote. carregado [ ' plugins. ' .. v] =  nulo
		se p. desencadeia  então
			para esta função, TRGS em  pares (p. gatilhos ) fazer
				para i =  1 , # trgs do
					- interpretar qualquer caractere de espaço em branco em comandos, assim como o espaço
					trgs [i] = trgs [i]: gsub ( '  ' , ' %% s + ' )
				fim
				se  não for p [funct] então
					p. trgs [ funct ] =  nulo
					print (clr. red .. funct .. ' triggers ignorados em ' .. v .. ' : ' .. funct .. ' função não definida ' .. clr. reset )
				fim
			fim
		fim
		table.insert (plugins, p)
	fim

	print ( ' \ n ' .. clr. blue .. ' BOT EXECUTANDO: ' .. clr. reset , clr. red .. ' [@ ' .. bot. username  ..  ' ] [ '  .. bot. first_name  . . ' ] [ ' .. bot. id .. ' ] ' .. clr. reset .. ' \ n ' )
	
	last_update = last_update ou  - 2  - pular atualizações pendentes
	last_cron = last_cron ou  os.time () - a hora do último trabalho cron
	
	se on_reload então
		return  # plugins
	outro
		api. sendAdmin ( _ ( " * Bot * @% s * iniciado! * \ n _% s_ \ n % d plugins carregados " ): format (bot. username : escape (), os.date ( ' !% c UTC ' ) , # plugins), verdadeiros )
		start_timestamp =  os.time ()
		current = {h =  0 }
		last = {h =  0 }
	fim
fim

função local extract_usernames ( msg )
	se msg. a partir de  então
		se msg. de . nome de usuário  , em seguida,
			db: hset ( ' bot: usernames ' , ' @ ' .. msg. de . username : lower (), msg. de . id )
		fim
	fim
	se msg. forward_from  e msg. forward_from . nome de usuário  , em seguida,
		db: hset ( ' bot: nomes de usuários ' , ' @ ' .. msg. forward_from . username : lower (), msg. forward_from . id )
	fim
	se msg. new_chat_member  então
		se msg. new_chat_member . nome de usuário  , em seguida,
			db: hset ( ' bot: usernames ' , ' @ ' .. msg. new_chat_member . nome de usuário : lower (), msg. new_chat_member . id )
		fim
		db: sadd ( string.format ( ' chat:% d: membros ' , msg. chat . id ), msg. new_chat_member . id )
	fim
	se msg. left_chat_member  então
		se msg. left_chat_member . nome de usuário  , em seguida,
			db: hset ( ' bot: nomes de usuários ' , ' @ ' .. msg. left_chat_member . nome de usuário : lower (), msg. left_chat_member . id )
		fim
		db: srem ( string.format ( ' chat:% d: membros ' , msg. chat . id ), msg. left_chat_member . id )
	fim
	se msg. reply_to_message  então
		extract_usernames (msg. reply_to_message )
	fim
	se msg. pinned_message  então
		extract_usernames (msg. pinned_message )
	fim
fim

função local collect_stats ( msg )
	
	extract_usernames (msg)
	
	se msg. chat . tipo  ~ =  ' privado '  e msg. chat . digite  ~ =  ' inline '  e msg. a partir de  então
		db: hset ( ' chat: ' .. msg. bate-papo . id .. ' : userlast ' , msg. de . id , os.time ()) - última mensagem para cada usuário
		db: hset ( ' bot: chats: latsmsg ' , msg. chat . id , os.time ()) - última mensagem no grupo
	fim
fim

função local match_triggers ( triggers , text )
  	se o texto e dispara então
		text = texto: gsub ( ' ^ (/ [% w _] +) @ ' .. bot. username , ' % 1 ' )
		para i, o gatilho em  pares (disparadores) fazer
			correspondências locais = {}
	    	matches = { string.match (texto, gatilho)}
			se  próximo (jogos) então
	    		retornar correspondências, disparar
			fim
		fim
	fim
fim

função local on_msg_receive ( msg , callback ) - A função fn é executada sempre que uma mensagem é recebida.
	- u.dump ('PARSED', msg)
	se  não for msg então
		Retorna
	fim

	se msg. chat . tipo  ~ =  ' grupo '  então  - não processa mensagens de grupos normais
		
		se msg. date  <  os.time () -  7  then  print ( ' Atualização antiga ignorada ' ) return  end  - Não processa mensagens antigas.
		se  não for msg. texto  então msg. text  = msg. subtítulo  ou  ' '  extremidade
		
		localidade. language  = db: get ( ' idioma: ' .. msg. chat . id ) ou  ' en '  - linguagem de grupo
		se  não config. available_languages [localidade. linguagem ] , em seguida,
			localidade. language  =  ' en '
		fim
		
		collect_stats (msg)
		
		local continue =  true
		onm_success local
		para i, plug-in em  pares (plugins) fazer
			se plugin. onEveryMessage  então
				onm_success, continue =  pcall (plugin. onEveryMessage , msg)
				se  não onm_success então
					api. sendAdmin ( ' Ocorreu um #error (pré-processamento). \ n ' .. tostring (continue) .. ' \ n ' .. locale. language .. ' \ n ' .. msg. text )
				fim
			fim
			se  não continuar, então  retornar  final
		fim
		
		para i, plug-in em  pares (plugins) fazer
			se plugin. desencadeia  então
				blocos locais , trigger =  match_triggers (plugin. triggers [callback], msg. texto )
				se blocos então
					
					se msg. chat . tipo  ~ =  ' privado '  e msg. chat . tipo  ~ =  ' inline ' e  não db: exists ( ' chat: ' .. msg. chat . id .. ' : settings ' ) e  não msg. serviço  então  - init agroup se o bot não estava ciente de estar em
							você. initGroup (msg. chat . id )
						fim
					
					se config. bot_settings . stream_commands  então  - imprima alguma informação no terminal
						print (clr. reset .. clr. blue .. ' [ ' .. os.date ( ' % F% T ' ) .. ' ] ' .. clr. red .. '  ' .. gatilho .. clr. reset .. '  ' .. msg. from . first_name .. ' [ ' .. msg. de . id .. ' ] -> [ ' ..msg. chat . id .. ' ] ' )
					fim
					
					- se não check_callback (msg, callback) então goto searchaction end
					sucesso local , resultado =  xpcall (plugin [callback], depuração. traceback , msg, blocos) - executa a função principal do plugin acionado
					
					se  não for sucesso então  - se um bug acontecer
							imprimir (resultado)
							se config. bot_settings . notifique_bug  então
								api. sendReply (msg, _ ( " 🐞 Desculpe, um * bug * ocorreu " ), true )
							fim
    	      				api. sendAdmin ( ' Ocorreu um #error. \ n ' .. result .. ' \ n ' .. locale. language .. ' \ n ' .. msg. text )
							Retorna
						fim
					
					se  tipo (resultado) ==  ' string '  então  - se a ação retornar uma string, faça dessa string o novo msg.text
						msg. texto  = resultado
					elseif  não resulta então  - se a ação retorna true, então não pare o loop das ações do plugin
						Retorna
					fim
				fim
				
			fim
		fim
	outro
		se msg. group_chat_created  or (msg. new_chat_member  e msg. new_chat_member . id  == bot. id ) então
			- definir o idioma
			localidade. idioma  = db: obter ( string.format ( ' lang:% d ' ., msg partir . id )) ou  ' en '
			se  não config. available_languages [localidade. linguagem ] , em seguida,
				localidade. language  =  ' en '
			fim
			
			- enviar divulgador
			api. sendMessage (msg. chat . id , _ ( [[
Olá a todos!
Meu nome é% s e sou um robô feito para ajudar os administradores em seu trabalho árduo.
Infelizmente não posso trabalhar em grupos normais, por favor peça ao criador para converter este grupo para um supergrupo.
]] ): format (bot. first_name ))
			
			- registre este evento
			se config. bot_settings . stream_commands  então
				print ( string.format ( ' % s [% s]% s Bot foi adicionado a um grupo normal% s% s [% d] -> [% d] ' ,
					  clr. azul , os.date ( ' % X ' ), clr. amarelo , clr. reset , msg. de . first_name , msg. de . id , msg. chat . id ))
			fim
		fim
	fim
fim

função local parseMessageFunction ( atualização )
	
	db: hincrby ( ' bot: general ' , ' messages ' , 1 )
	
	msg local , function_key
	
	- se update.message ou update.edited_message ou update.channel_post ou update.edited_channel_post,
	se atualizar. mensagem  ou atualização. edited_message  então
		
		function_key =  ' onTextMessage '
		
		- se não update.message então
			se atualizar. edited_message  então
				atualizar. edited_message . editado  =  verdadeiro
				atualizar. edited_message . data_atual  = atualização. edited_message . encontro
				atualizar. edited_message . date  = update. edited_message . editar data
				function_key =  ' onEditedMessage '
			- [[ elseif update.channel_post então
				update.channel_post.channel_post = true
				function_key = 'onChannelPost'
			elseif update.edited_channel_post então
				update.edited_channel_post.edited_channel_post = true
				update.edited_channel_post.original_date = update.edited_channel_post.date
				update.edited_channel_post.date = update.edited_channel_post.edit_date
				function_key = 'onEditedChannelPost' ]]
			fim
		- fim
		
		- msg = update.message ou update.edited_message ou update.channel_post ou update.edited_channel_post
		msg = atualizar. mensagem  ou atualização. edited_message
		
		se msg. texto  então
		elseif msg. foto  então
			msg. media  =  true
			msg. media_type  =  ' foto '
		elseif msg. áudio  então
			msg. media  =  true
			msg. media_type  =  ' audio '
		elseif msg. documento  então
			msg. media  =  true
			msg. media_type  =  ' documento '
			se msg. documento . mime_type  ==  ' video / mp4 '  então
				msg. media_type  =  ' gif '
			fim
		elseif msg. etiqueta  então
			msg. media  =  true
			msg. media_type  =  ' adesivo '
		elseif msg. vídeo  então
			msg. media  =  true
			msg. media_type  =  ' video '
		elseif msg. voz  então
			msg. media  =  true
			msg. media_type  =  ' voz '
		elseif msg. entre  em contato então
			msg. media  =  true
			msg. media_type  =  ' contato '
		elseif msg. local  então
			msg. media  =  true
			msg. media_type  =  ' local '
		elseif msg. localização  então
			msg. media  =  true
			msg. media_type  =  ' localização '
		elseif msg. jogo  então
			msg. media  =  true
			msg.media_type = 'game'
		elseif msg.left_chat_member then
			msg.service = true
			if msg.left_chat_member.id == bot.id then
				msg.text = '###left_chat_member:bot'
			else
				msg.text = '###left_chat_member'
			end
		elseif msg.new_chat_member then
			msg.service = true
			if msg.new_chat_member.id == bot.id then
				msg.text = '###new_chat_member:bot'
			else
				msg.text = '###new_chat_member'
			end
		elseif msg.new_chat_photo then
			msg.service = true
			msg.text = '###new_chat_photo'
		elseif msg.delete_chat_photo then
			msg.service = true
			msg.text = '###delete_chat_photo'
		elseif msg.group_chat_created then
    		msg.service = true
    		msg.text = '###group_chat_created'
		elseif msg.supergroup_chat_created then
			msg.service = true
			msg.text = '###supergroup_chat_created'
		elseif msg.channel_chat_created then
			msg.service = true
			msg.text = '###channel_chat_created'
		elseif msg.migrate_to_chat_id then
			msg.service = true
			msg.text = '###migrate_to_chat_id'
		elseif msg.migrate_from_chat_id then
			msg.service = true
			msg.text = '###migrate_from_chat_id'
		elseif msg.new_chat_title then
			msg.service = true
			msg.text = '###new_chat_title'
		elseif msg.pinned_message then
			msg.service = true
			msg.text = '###pinned_message'
		else
			--callback = 'onUnknownType'
			print('Unknown update type') return
		end
		
		if msg.forward_from_chat then
			if msg.forward_from_chat.type == 'channel' then
				msg.spam = 'forwards'
			end
		end
		if msg.caption then
			local caption_lower = msg.caption:lower()
			if caption_lower:match('telegram%.me') or caption_lower:match('telegram%.dog') or caption_lower:match('t%.me') then
				msg.spam = 'links'
			end
		end
		if msg.entities then
			for i, entity in pairs(msg.entities) do
				if entity.type == 'text_mention' then
					msg.mention_id = entity.user.id
				end
				if entity.type == 'url' or entity.type == 'text_link' then
					local text_lower = msg.text or msg.caption
					text_lower = entity.url and text_lower..entity.url or text_lower
					text_lower = text_lower:lower()
					if text_lower:match('telegram%.me') or
						text_lower:match('telegram%.dog') or
						text_lower:match('t%.me') then
						msg.spam = 'links'
					else
						msg.media_type = 'link'
						msg.media = true
					end
				end
			end
		end
		if msg.reply_to_message then
			msg.reply = msg.reply_to_message
			if msg.reply.caption then
				msg.reply.text = msg.reply.caption
			end
		end
	--[[elseif update.inline_query then
		msg = update.inline_query
		msg.inline = true
		msg.chat = {id = msg.from.id, type = 'inline', title = 'inline'}
		msg.date = os.time()
		msg.text = '###inline:'..msg.query
		function_key = 'onInlineQuery'
	elseif update.chosen_inline_result then
		msg = update.chosen_inline_result
		msg.text = '###chosenresult:'..msg.query
		msg.chat = {type = 'inline', id = msg.from.id, title = msg.from.first_name}
		msg.message_id = msg.inline_message_id
		msg.date = os.time()
		function_key = 'onChosenInlineQuery']]
	elseif update.callback_query then
		msg = update.callback_query
		msg.cb = true
		msg.text = '###cb:'..msg.data
		if msg.message then
			msg.original_text = msg.message.text
			msg.original_date = msg.message.date
			msg.message_id = msg.message.message_id
			msg.chat = msg.message.chat
		else --when the inline keyboard is sent via the inline mode
			msg.chat = {type = 'inline', id = msg.from.id, title = msg.from.first_name}
			msg.message_id = msg.inline_message_id
		end
		msg.date = os.time()
		msg.cb_id = msg.id
		msg.message = nil
		msg.target_id = msg.data:match('(-%d+)$') --callback datas often ship IDs
		function_key = 'onCallbackQuery'
	else
		--function_key = 'onUnknownType'
		print('Unknown update type') return
	end
	
	if (msg.chat.id < 0 or msg.target_id) and msg.from then
		msg.from.admin = u.is_admin(msg.target_id or msg.chat.id, msg.from.id)
		if msg.from.admin then
			msg.from.mod = true
		else
            -- XXX: double call is_admin function
			msg.from.mod = u.is_mod(msg.target_id or msg.chat.id, msg.from.id)
		end
	end
	
	--print('Mod:', msg.from.mod, 'Admin:', msg.from.admin)
	return on_msg_receive(msg, function_key)
end

bot_init() -- Actually start the script. Run the bot_init function.

api.firstUpdate()
while true do -- Start a loop while the bot should be running.
	local res = api.getUpdates(last_update+1) -- Get the latest updates
	if res then
		clocktime_last_update = os.clock()
		for i, msg in ipairs(res.result) do -- Go through every new message.
			last_update = msg.update_id
			--print(last_update)
			current.h = current.h + 1
			parseMessageFunction(msg)
		end
	else
		print('Connection error')
	end
	if last_cron ~= os.date('%M') then -- Run cron jobs every minute.
		last_cron = os.date('%M')
		last.h = current.h
		current.h = 0
		for i,v in ipairs(plugins) do
			if v.cron then -- Call each plugin's cron function, if it has one.
				local res, err = xpcall(v.cron, debug.traceback)
				if not res then
					print(err)
          			api.sendLog('An #error occurred (cron).\n'..err)
					return
				end
			end
		end
	end
end

print('Halted.\n')
