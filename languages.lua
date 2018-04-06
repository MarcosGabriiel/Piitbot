configuração local =  require  ' config '

strings locais = {} - array interno com strings traduzidas

- Avalia a expressão da Lua
função local eval ( str )
	 carga de retorno ( ' return '  .. str) ()
fim

- Analisa o arquivo com tradução e retorna uma tabela com strings em inglês como
- chaves e cadeias traduzidas como valores. As chaves são armazenadas sem uma guia
- linebreak para rastrear bugs do xgettext. Adiciona linebreak desnecessário para
- literais de string com colchetes longos. Traduções difusas são ignoradas se o sinalizador
- config.allow_fuzzy_translations não está definido.
função local parse ( filename )
	estado local =  ' ign_msgstr '  - estados da máquina de estados finitos
	local msgid, msgstr
	resultado local = {}

	para linha em  io.lines (filename) fazer
		linha = linha: trim ()
		entrada local , argumento = linha: match ( ' ^ (% w *)% s * (". *") $ ' )
		if line: match ( ' ^ #,. * fuzzy ' ), então
			input =  ' fuzzy '
		fim

		assert (state ==  ' msgid '  ou state ==  ' msgstr '  ou state ==  ' ign_msgid '  ou state ==  ' ign_msgstr ' )
		assert (input ==  nil  ou input ==  ' '  ou input ==  ' msgid '  ou input ==  ' msgstr '  ou input ==  ' fuzzy ' )

		if state ==  ' msgid '  e input ==  ' '  então
			msgid = msgid ..  eval (argumento)
		elseif state ==  ' msgid '  e input ==  ' msgstr '  então
			msgstr =  eval (argumento)
			state =  ' msgstr '
		elseif state ==  ' msgstr '  e input ==  ' '  então
			msgstr = msgstr ..  eval (argumento)
		elseif state ==  ' msgstr '  e input ==  ' msgid '  então
			if msgstr ~ =  ' '  então resulta [msgid: gsub ( ' ^ \ n ' , ' ' )] = msgstr end
			msgid =  eval (argumento)
			estado =  ' msgid '
		elseif state ==  ' msgstr '  e input ==  ' fuzzy '  então
			if msgstr ~ =  ' '  então resulta [msgid: gsub ( ' ^ \ n ' , ' ' )] = msgstr end
			se  não config. allow_fuzzy_translations  então
				estado =  ' ign_msgid '
			fim
		elseif state ==  ' ign_msgid '  e input ==  ' msgstr '  então
			estado =  ' ign_msgstr '
		elseif state ==  ' ign_msgstr '  e input ==  ' msgid '  então
			msgid =  eval (argumento)
			estado =  ' msgid '
		estado elseif ==  ' ign_msgstr '  e input ==  ' fuzzy '  então
			estado =  ' ign_msgid '
		fim
	fim
	if state ==  ' msgstr '  e msgstr ~ =  ' '  então
		resultado [msgid: gsub ( ' ^ \ n ' , ' ' )] = msgstr
	fim

	resultado de retorno
fim

local, locale = {} - mesa com funções exportadas

localidade. language  =  ' en '  - idioma padrão

function locale.init ( diretório )
	diretório = diretório ou  " locales "

	para lang_code em  pares (config. available_languages ) do
		strings [lang_code] =  parse ( string.format ( ' % s /% s.po ' , diretório, lang_code))
	fim
fim

function locale.translate ( msgid )
	return strings [locale. idioma ] [msgid: gsub ( ' ^ \ n ' , ' ' )] ou msgid
fim

_ = localidade. traduzir

localidade. init ()

retornar local
