curva local =  requer  ' cURL '
URL local =  require  ' socket.url '
JSON local =  requer  " dkjson "
configuração local =  require  ' config '
clr local =  require  ' term.colors '
api_errors locais =  requerem  ' api_bad_requests '

local BASE_URL =  ' https://api.telegram.org/bot '  .. config. bot_api_key

api local = {}

local curl_context = curl. fácil {verbose = config. bot_settings . debug_connections }

função local getCode ( err )
	err = err: lower ()
	para k, v em  pares (api_errors) fazer
		se err: match (v) então
			retorno k
		fim
	fim
	retorno  7  - se desconhecido
fim

função local performRequest ( url )
	dados locais = {}
	
	- se o multithreading for feito, essa solicitação deverá estar em uma seção crítica
	local c = curl_context: setopt_url (url)
		: setopt_writefunction (tabela. inserção , dados)
		: execute ()

	return  table.concat (data), c: getinfo_response_code ()
fim

função local sendRequest ( url )
	dat local , código =  performRequest (url)
	guia local = JSON. decodificar (dat)

	se  não aba então
		print (clr. red .. ' Erro ao analisar JSON ' .. clr. reset , código)
		print (clr. amarelo .. ' Data: ' .. clr. reset , dat)
		api. sendAdmin (dat .. ' \ n ' .. código)
		- erro ('resposta incorreta')
	fim

	se código ~ =  200  então
		
		se o código ==  400  então
			 - o código de erro 400 é geral: tente especificar
			 code =  getCode (tab. description )
		fim
		
		print (clr. red .. código, tab. descrição .. clr. reset )
		db: hincrby ( ' bot: errors ' , código, 1 )
		
		return  false , código, tab. descrição
	fim
	
	se  não tab. ok  então
		api. sendAdmin ( ' Não tab.ok ' )
		retornar  false , tab. descrição
	fim
	
	guia de retorno

fim

função local log_error ( método , código , extras , descrição )
	se  não o método ou  não código, em seguida,  retornar  final
	
	local ignored_errors = { 110 , 111 , 116 , 118 , 131 , 150 , 155 , 403 , 429 }
	
	para _, ignored_code em  pares (ignored_errors) fazer
		se  tonumber (código) ==  tonumber (ignored_code) , em seguida,  retornar  final
	fim
	
	local text =  ' Digite: #badrequest \ n Método: # ' .. method .. ' \ n Código: #n ' .. code
	
	se a descrição então
		text = text .. ' \ n Desc: ' .. description
	fim
	
	se extras, então
		se  próximo (extras) então
			para i, extra em  pares (extras) fazer
				text = text .. ' \ n #mais ' .. i .. ' : ' .. extra
			fim
		outro
			text = text .. ' \ n #mais: vazio '
		fim
	outro
		text = text .. ' \ n #mais: nulo '
	fim
	
	api. sendLog (texto)
fim

função api.getMe ()

	url local = BASE_URL ..  ' / getMe '

	return  sendRequest (url)

fim

função api.getUpdates ( offset )

	URL local = BASE_URL ..  ' / getUpdates? timeout = 20 '

	se compensar então
		url = url ..  ' & offset = '  .. deslocamento
	fim
	
	return  sendRequest (url)

fim

função api.firstUpdate ()
	url local = BASE_URL ..  ' / getUpdates? timeout = 3600 & limit = 1 & allowed_updates = ' .. JSON. codificar (config. allowed_updates )
	
	return  sendRequest (url)
fim


função api.mudouser ( chat_id , user_id )

	url local = BASE_URL .. ' / restrictChatMember? chat_id = ' .. chat_id .. ' & user_id = ' .. user_id .. ' & can_post_messages = false '

	return  sendRequest (url)

fim


função api.unbanChatMember ( chat_id , user_id )
	
	url local = BASE_URL ..  ' / unbanChatMember? chat_id = '  .. chat_id ..  ' & user_id = '  .. user_id

	return  sendRequest (url)
fim

função api.kickChatMember ( chat_id , user_id )
	
	url local = BASE_URL ..  ' / kickChatMember? chat_id = '  .. chat_id ..  ' & user_id = '  .. user_id
	
	sucesso local , código, descrição =  sendRequest (url)
	se o sucesso então
		db: srem ( string.format ( ' chat:% d: membros ' , chat_id), user_id)
	fim

	retorno sucesso, código, descrição
fim

função local code2text ( code )
	- a descrição do erro padrão não pode ser enviada como saída, portanto é necessária uma tradução
	se código ==  101  ou código ==  105  ou código ==  107  então
		return  _ ( " Eu não sou um administrador, não posso chutar as pessoas " )
	código elseif ==  102  ou código ==  104  então
		return  _ ( " Eu não posso chutar ou banir um admin " )
	código elseif ==  103  então
		return  _ ( " Não há necessidade de desbanir em um grupo normal " )
	código elseif ==  106  ou código ==  134  então
		return  _ ( " Este usuário não é um membro do chat " )
	código elseif = =  7  então
		devolver  falso
	fim
	devolver  falso
fim

função api.banUser ( chat_id , user_id )
	
	res local , code = api. kickChatMember (chat_id, user_id) - tente chutar. "código" já é específico
	
	se res, então  - se o usuário foi chutado, então ...
		return res - return res e não o texto
	else  - -else, o usuário não foi kickado
		texto local =  code2text (código)
		retorna res, código, texto - retorna a motivação também
	fim
fim

function api.kickUser ( chat_id , user_id )
	
	res local , code = api. kickChatMember (chat_id, user_id) - tente chutar
	
	se res, então  - se o usuário foi chutado, então ...
		- desbanir
		api. unbanChatMember (chat_id, user_id)
		api. unbanChatMember (chat_id, user_id)
		api. unbanChatMember (chat_id, user_id)
		return res
	outro
		motivação local =  code2text (código)
		retorno res, código, motivação
	fim
fim

function api.unbanUser ( chat_id , user_id )
	
	res local , code = api. unbanChatMember (chat_id, user_id)
	retorno  verdadeiro
fim

função api.getChat ( chat_id )
	
	url local = BASE_URL ..  ' / getChat? chat_id = '  .. chat_id
	
	return  sendRequest (url)
	
fim

function api.getChatAdministrators ( chat_id )
	
	url local = BASE_URL ..  ' / getChatAdministrators? chat_id = '  .. chat_id
	
	res local , código, desc =  sendRequest (url)
	
	se  não res e código então  - se a requisição falhou e um código é retornado (não 403 e 429)
		log_error ( ' getChatAdministrators ' , código, nil , desc)
	fim
	
	retorno res, código
	
fim

function api.getChatMembersCount ( chat_id )
	
	url local = BASE_URL ..  ' / getChatMembersCount? chat_id = '  .. chat_id
	
	return  sendRequest (url)
	
fim

função api.getChatMember ( chat_id , user_id )
	
	url local = BASE_URL ..  ' / getChatMember? chat_id = '  .. chat_id ..  ' & user_id = '  .. user_id
	
	res local , código, desc =  sendRequest (url)
	
	se  não res e código então  - se a requisição falhou e um código é retornado (não 403 e 429)
		log_error ( ' getChatMember ' , código, nil , desc)
	fim
	
	retorno res, código
	
fim

função api.leaveChat ( chat_id )
	
	url local = BASE_URL ..  ' / leaveChat? chat_id = '  .. chat_id
	
	res local , code =  sendRequest (url)
	
	se res, então
		db: srem ( string.format ( ' chat:% d: membros ' , chat_id), bot. id )
	fim
	
	se  não res e código então  - se a requisição falhou e um código é retornado (não 403 e 429)
		log_error ( ' leaveChat ' , código)
	fim
	
	retorno res, código
	
fim

function api.sendMessage ( chat_id , texto , parse_mode , reply_markup , reply_to_message_id , link_preview )
	- imprimir (texto)
	
	url local = BASE_URL ..  ' / sendMessage? chat_id = '  .. chat_id ..  ' & text = '  .. URL. escape (texto)

	se reply_to_message_id então
		url = url ..  ' & reply_to_message_id = '  .. reply_to_message_id
	fim
	
	se parse_mode então
		se  tipo (parse_mode) ==  ' string '  e parse_mode: lower () ==  ' html '  então
			url = url ..  ' & parse_mode = HTML '
		outro
			url = url ..  ' & parse_mode = Markdown '
		fim
	fim
	
	se reply_markup então
		url = url .. ' & reply_markup = ' .. URL. escape (JSON. codificar (reply_markup))
	fim
	
	se  não link_preview então
		url = url ..  ' & disable_web_page_preview = true '
	fim
	
	res local , código, desc =  sendRequest (url)
	
	se  não res e código então  - se a requisição falhou e um código é retornado (não 403 e 429)
		log_error ( ' sendMessage ' , código, {text}, desc)
	fim
	
	return res, code - return false e o código

fim

função api.sendReply ( msg , texto , markd , reply_markup , link_preview )

	retornar api. sendMessage (msg. chat . id , texto, markd, reply_markup, msg. message_id , link_preview)

fim

função api.editMessageText ( chat_id , message_id , text , parse_mode , keyboard )
	
	url local = BASE_URL ..  ' / editMessageText? chat_id = '  .. chat_id ..  ' & message_id = ' .. mensagem_id .. ' & text = '  .. URL. escape (texto)
	
	se parse_mode então
		se  tipo (parse_mode) ==  ' string '  e parse_mode: lower () ==  ' html '  então
			url = url ..  ' & parse_mode = HTML '
		outro
			url = url ..  ' & parse_mode = Markdown '
		fim
	fim
	
	url = url ..  ' & disable_web_page_preview = true '
	
	se teclado então
		url = url .. ' & reply_markup = ' .. URL. escape ( codificação JSON. (teclado))
	fim
	
	res local , código, desc =  sendRequest (url)
	
	se  não res e código então  - se a requisição falhou e um código é retornado (não 403 e 429)
		log_error ( ' editMessageText ' , código, {text}, desc)
	fim
	
	retorno res, código

fim

função api.deleteMessage ( chat_id , message_id )

	url local = BASE_URL ..  ' / deleteMessage? chat_id = '  .. chat_id ..  ' & message_id = '  .. message_id

	return  sendRequest (url)

fim

função api.deleteMessages ( chat_id , message_ids )

	para i = 1 , # message_ids do
		api. deleteMessage (chat_id, message_ids [i])
	fim
fim

function api.editMarkup ( chat_id , message_id , reply_markup )
	
	url local = BASE_URL ..  ' / editMessageReplyMarkup? chat_id = '  .. chat_id ..
		' & message_id = ' .. message_id ..
		' & reply_markup = ' .. URL. escape (JSON. codificar (reply_markup))
	
	return  sendRequest (url)

fim

função api.answerCallbackQuery ( callback_query_id , text , show_alert , cache_time )
	
	url local = BASE_URL ..  ' / answerCallbackQuery? callback_query_id = '  .. callback_query_id ..  ' & text = '  .. URL. escape (texto)
	
	se show_alert então
		url = url .. ' & show_alert = true '
	fim
	
	se cache_time então
		segundos locais =  tonumber (cache_time) *  3600
		url = url .. ' & cache_time = ' .. segundos
	fim
	
	return  sendRequest (url)
	
fim

função api.sendChatAction ( chat_id , action )
 - As ações de suporte estão digitando, upload_photo, record_video, upload_video, record_audio, upload_audio, upload_document, find_location

	url local = BASE_URL ..  ' / sendChatAction? chat_id = '  .. chat_id ..  ' & action = '  .. action
	return  sendRequest (url)

fim

função api.sendLocation ( chat_id , latitude , longitude , reply_to_message_id )

	url local = BASE_URL ..  ' / sendLocation? chat_id = '  .. chat_id ..  ' & latitude = '  .. latitude ..  ' & longitude = '  .. longitude

	se reply_to_message_id então
		url = url ..  ' & reply_to_message_id = '  .. reply_to_message_id
	fim

	return  sendRequest (url)

fim

função api.forwardMessage ( chat_id , from_chat_id , message_id )

	url local = BASE_URL ..  ' / forwardMessage? chat_id = '  .. chat_id ..  ' & from_chat_id = '  .. from_chat_id ..  ' & message_id = '  .. message_id

	res local , código, desc =  sendRequest (url)
	
	se  não res e código então  - se a requisição falhou e um código é retornado (não 403 e 429)
		log_error ( ' forwardMessage ' , código, nil , desc)
	fim
	
	retorno res, código
	
fim

função api.getFile ( file_id )
	
	url local = BASE_URL ..  ' / getFile? file_id = ' .. file_id
	
	return  sendRequest (url)
	
fim

- ---------------------- Métodos inline ------------------------ -----------------

function api.answerInlineQuery ( inline_query_id , resultados , cache_time , is_personal , switch_pm_text , switch_pm_parameter )
	
	url local = BASE_URL ..  ' / answerInlineQuery? inline_query_id = ' .. inline_query_id .. ' & results = ' .. JSON. codificar (resultados)
	
	se cache_time então
		url = url .. ' & cache_time = ' .. cache_time
	fim
	
	se is_personal então
		url = url .. ' & is_personal = True '
	fim
	
	se switch_pm_text então
		url = url .. ' & switch_pm_text = ' .. switch_pm_text
	fim
	
	se switch_pm_parameter então
		url = url .. ' & switch_pm_parameter = ' .. switch_pm_parameter
	fim
	
	return  sendRequest (url)

fim

- -------------------------- Por Id -------------------- --------------------------

função api.sendMediaId ( chat_id , file_id , media , reply_to_message_id , legenda )
	URL local = BASE_URL
	se media ==  ' voz '  então
		url = url .. ' / sendVoice? chat_id = ' .. chat_id .. ' & voz = '
	mídia elseif ==  ' video '  então
		url = url .. ' / sendVideo? chat_id = ' .. chat_id .. ' & video = '
	mídia elseif ==  ' foto '  então
		url = url .. ' / sendPhoto? chat_id = ' .. chat_id .. ' & photo = '
	outro
		return  false , ' Mídia passada não é voz / vídeo / foto '
	fim
	
	url = url .. file_id
	
	se reply_to_message_id então
		url = url .. ' & reply_to_message_id = ' .. reply_to_message_id
	fim
	se legenda então
		url = url .. ' & caption = ' .. URL. escapar (legenda)
	fim
	
	return  sendRequest (url)
fim

função api.sendPhotoId ( chat_id , file_id , reply_to_message_id , caption )
	
	url local = BASE_URL ..  ' / sendPhoto? chat_id = '  .. chat_id ..  ' & foto = '  .. file_id
	
	se reply_to_message_id então
		url = url .. ' & reply_to_message_id = ' .. reply_to_message_id
	fim
	se legenda então
		url = url .. ' & caption = ' .. URL. escapar (legenda)
	fim
	
	return  sendRequest (url)
	
fim

function api.sendDocumentId ( chat_id , file_id , reply_to_message_id , legenda , reply_markup )
	
	url local = BASE_URL ..  ' / sendDocument? chat_id = '  .. chat_id ..  ' & document = '  .. file_id
	
	se reply_to_message_id então
		url = url .. ' & reply_to_message_id = ' .. reply_to_message_id
	fim
	se legenda então
		url = url .. ' & caption = ' .. URL. escapar (legenda)
	fim
	se reply_markup então
		url = url .. ' & reply_markup = ' .. URL. escape (JSON. codificar (reply_markup))
	fim

	return  sendRequest (url)
	
fim

- -------------------------- Upload de arquivos -------------------- -----------------

função api.sendPhoto ( chat_id , foto , legenda , reply_to_message_id )

	URL local = BASE_URL ..  ' / sendPhoto '
    curl_context: setopt_url (url)

    formulário local = curl. forma ()
    form: add_content ( " chat_id " , chat_id)
    form: add_file ( " foto " , foto)

	se reply_to_message_id então
		form: add_content ( " reply_to_message_id " , reply_to_message_id)
	fim

	se legenda então
		form: add_content ( " legenda " , legenda)
	fim

    data = {}

    local c = curl_context: setopt_writefunction (tabela. inserção , dados)
                          : setopt_httppost (formulário)
                          : execute ()

	return  table.concat (data), c: getinfo_response_code ()
fim

função api.sendDocument ( chat_id , document , reply_to_message_id , caption )

	URL local = BASE_URL ..  ' / sendDocument '
    curl_context: setopt_url (url)

    formulário local = curl. forma ()
    form: add_content ( " chat_id " , chat_id)
    form: add_file ( " document " , documento)

	se reply_to_message_id então
		form: add_content ( " reply_to_message_id " , reply_to_message_id)
	fim

	se legenda então
		form: add_content ( " legenda " , legenda)
	fim

    data = {}

    local c = curl_context: setopt_writefunction (tabela. inserção , dados)
                          : setopt_httppost (formulário)
                          : execute ()

	return  table.concat (data), c: getinfo_response_code ()

fim

função api.sendSticker ( chat_id , sticker , reply_to_message_id )

	URL local = BASE_URL ..  ' / sendSticker '
    curl_context: setopt_url (url)

    formulário local = curl. forma ()
    form: add_content ( " chat_id " , chat_id)
    form: add_file ( " adesivo " , adesivo)

	se reply_to_message_id então
		form: add_content ( " reply_to_message_id " , reply_to_message_id)
	fim

    data = {}

    local c = curl_context: setopt_writefunction (tabela. inserção , dados)
                          : setopt_httppost (formulário)
                          : execute ()

	return  table.concat (data), c: getinfo_response_code ()

fim

function api.sendStickerId ( chat_id , file_id , reply_to_message_id )
	
	url local = BASE_URL ..  ' / sendSticker? chat_id = '  .. chat_id ..  ' & sticker = '  .. file_id
	
	se reply_to_message_id então
		url = url .. ' & reply_to_message_id = ' .. reply_to_message_id
	fim

	return  sendRequest (url)
	
fim

função api.sendAudio ( chat_id , audio , reply_to_message_id , duração , intérprete , título )

	URL local = BASE_URL ..  ' / sendAudio '
    curl_context: setopt_url (url)

    formulário local = curl. forma ()
    form: add_content ( " chat_id " , chat_id)
    form: add_file ( " audio " , audio)

	se reply_to_message_id então
		form: add_content ( " reply_to_message_id " , reply_to_message_id)
	fim

	se a duração for então
		form: add_content ( " duração " , duração)
	fim

	se performer então
		forma: add_content ( " intérprete " , intérprete)
	fim

	se título então
		form: add_content ( " título " , título)
	fim

    data = {}

    local c = curl_context: setopt_writefunction (tabela. inserção , dados)
                          : setopt_httppost (formulário)
                          : execute ()

	return  table.concat (data), c: getinfo_response_code ()

fim

função api.sendVideo ( chat_id , video , duração , legenda , reply_to_message_id )

	URL local = BASE_URL ..  ' / sendVideo '
    curl_context: setopt_url (url)

    formulário local = curl. forma ()
    form: add_content ( " chat_id " , chat_id)
    form: add_file ( " video " , video)

	se reply_to_message_id então
		form: add_content ( " reply_to_message_id " , reply_to_message_id)
	fim

	se a duração for então
		form: add_content ( " duração " , duração)
	fim

	se legenda então
		form: add_content ( " legenda " , legenda)
	fim

    data = {}

    local c = curl_context: setopt_writefunction (tabela. inserção , dados)
                          : setopt_httppost (formulário)
                          : execute ()

	return  table.concat (data), c: getinfo_response_code ()

fim

função api.sendVoice ( chat_id , voz , reply_to_message_id )

	url local = BASE_URL ..  ' / sendVoice '
    curl_context: setopt_url (url)

    formulário local = curl. forma ()
    form: add_content ( " chat_id " , chat_id)
    form: add_file ( " voz " , voz)

	se reply_to_message_id então
		form: add_content ( " reply_to_message_id " , reply_to_message_id)
	fim

    data = {}

    local c = curl_context: setopt_writefunction (tabela. inserção , dados)
                          : setopt_httppost (formulário)
                          : execute ()

	return  table.concat (data), c: getinfo_response_code ()

fim

função api.sendAdmin ( text , markdown )
	retornar api. sendMessage (config. log . admin , texto, markdown)
fim

função api.sendLog ( text , markdown )
	retornar api. sendMessage (config. log . conversar  ou configuração. log . administração , texto, markdown)
fim

retornar api
