/*
	CRUD - Harbour + MiniGUI + MySQL
	Agosto 2023
*/
#include 'hmg.ch'
#include 'xhb.ch'
#include 'hmg_hpdf.ch'
#include 'tsbrowse.ch'

function main()

     configurar_sistema()

     conectar_bd()

     define window form_main;
          at 0,0;
          width 800;
          height 600;
          title 'CRUD - Harbour + MiniGUI + MySQL';
          icon 'icone';
          windowtype main
          /*
               menu
          */
        	define main menu of form_main
         		define popup '&Tabelas'
               	menuitem 'Grupos' action grupos()
               end popup
		end menu
          /*
               toolbar
          */
          define splitbox
               define toolbar tb_main of form_main buttonsize 80,70 font 'verdana' size 9 bold flat
                    button btn_1;
                         caption 'Grupos';
                         picture 'grupos';
                         action grupos();
                         separator
                    button btn_6;
                         caption 'Sair';
                         picture 'exit';
                         action form_main.release
               end toolbar
          end splitbox

		@ getdesktopheight()-380,getdesktopwidth()-500 image logo_mysql ;
			picture 'logo_mysql' ;
			width 480 ;
			height 270

     end window

     form_main.maximize
     form_main.activate

     return( nil )
*-------------------------------------------------------------------------------
static function configurar_sistema()

     local a_cores

 	set interactiveclose query
	set date british
	set century on
	set epoch to 1950
	set browsesync on
	set deleted on
	set talk off
	set score off
	set multiple off warning
	set tooltipballoon on
	set navigation extended
     set autoadjust on
	set codepage to portuguese
	set language to portuguese

 	request HB_LANG_PT
 	request HB_CODEPAGE_PT850
 	hb_langselect('PT')
 	hb_setcodepage('PT850')
     /*
          setar estilo do menu
     */
     set menustyle extended
     set menucursor full
     set menuseparator single rightalign
     /*
          reconfigurar cores do menu
     */
     a_cores := getmenucolors()
     a_cores[ MNUCLR_MENUBARSELECTEDITEM1 ]       := rgb(201,222,245) //ítem horizontal - opção mestre
     a_cores[ MNUCLR_MENUBARSELECTEDITEM2 ]       := rgb(201,222,245) //ítem horizontal - opção mestre
     a_cores[ MNUCLR_MENUBARBACKGROUND1 ]         := getsyscolor(15)  //fundo opção horizontal
     a_cores[ MNUCLR_MENUBARBACKGROUND2 ]         := getsyscolor(15)  //fundo opção horizontal
     a_cores[ MNUCLR_MENUBARTEXT ]                := rgb(000,000,000) //letra menu horizontal
     a_cores[ MNUCLR_MENUBARSELECTEDTEXT ]        := rgb(000,000,000) //letra selecionada menu horizontal
     a_cores[ MNUCLR_SEPARATOR1 ]                 := rgb(218,218,218) //linha separadora
     a_cores[ MNUCLR_IMAGEBACKGROUND1 ]           := rgb(246,246,246) //fundo bmp do ítem
     a_cores[ MNUCLR_IMAGEBACKGROUND2 ]           := rgb(246,246,246) //fundo bmp do ítem
     a_cores[ MNUCLR_MENUITEMSELECTEDTEXT ]       := rgb(000,000,000) //texto do ítem selecionado
     a_cores[ MNUCLR_SELECTEDITEMBORDER1 ]        := rgb(201,222,245) //bordas do ítem (vert.)
     a_cores[ MNUCLR_SELECTEDITEMBORDER2 ]        := rgb(201,222,245) //bordas do ítem (vert.)
     a_cores[ MNUCLR_SELECTEDITEMBORDER3 ]        := rgb(201,222,245) //bordas do ítem (vert.)
     a_cores[ MNUCLR_SELECTEDITEMBORDER4 ]        := rgb(201,222,245) //bordas do ítem (vert.)
     a_cores[ MNUCLR_MENUITEMTEXT ]               := rgb(000,000,000) //texto geral menu (vert.)
     a_cores[ MNUCLR_MENUITEMSELECTEDTEXT ]       := rgb(000,000,000) //texto menu opção selecionada (vert.)
     a_cores[ MNUCLR_MENUITEMBACKGROUND1 ]        := rgb(246,246,246) //fundo geral menu (vert.)
     a_cores[ MNUCLR_MENUITEMBACKGROUND2 ]        := rgb(246,246,246) //fundo geral menu (vert.)
     a_cores[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ]:= rgb(201,222,245) //fundo ítem menu selec. (vert.)
     a_cores[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ]:= rgb(201,222,245) //fundo ítem menu selec. (vert.)
     setmenucolors( a_cores )

	return( nil )
*-------------------------------------------------------------------------------
function conectar_bd()
	
     local v_hostname := 'localhost'
     local v_usuario  := 'root'
     local v_senha    := '102030'
     local v_database := 'crud'	  	  	

     public oMySQL

     oMySQL := tmysqlserver():new(v_hostname,v_usuario,v_senha)

     if oMySQL:neterr()
		msginfo('Erro conexão com o servidor MySQL :: '+oMySQL:error())
     else
          criar_bd(v_database)
          criar_tabelas()
     endif

     return(nil)
*-------------------------------------------------------------------------------
function criar_bd( pNomeBanco )

	local i := 0
     local aBaseDeDadosExistentes := {}

     pNomeBanco := lower(pNomeBanco)

     aBaseDeDadosExistentes := oMySQL:ListDBs()

     IF oMySQL:NetErr()
		msginfo('Erro verificando base de dados'+oMySQL:Error())
     ENDIF

     IF Ascan( aBaseDeDadosExistentes, Lower( pNomeBanco )) != 0
		oMySQL:SelectDB( pNomeBanco )
          IF oMySQL:NetErr()
			msginfo('Erro conectar à base de dados '+oMySQL:Error())
          ENDIF
     ELSE
          oMySQL:CreateDatabase( pNomeBanco )
          IF oMySQL:NetErr()
               msginfo('Erro criação base de dados '+p_basededados+', '+oMySQL:Error())
          ELSE
               oMySQL:SelectDB( pNomeBanco )
               IF oMySQL:NetErr()
				msginfo('Erro tentando conectar à '+p_basededados+' , '+oMySQL:Error())
               ENDIF
          ENDIF
     ENDIF

	RETURN( nil )
*-------------------------------------------------------------------------------
function criar_tabelas()

	local i := 0
     local x_i := 0
     local aTabelasExistentes := {}
     local aStruc := {}
     local cQuery
     local oQuery
     /*
          array : tabelas do sistema
     */
     aTabelasExistentes := oMySQL:ListTables()
     /*
          grupos
     */
     IF Ascan(aTabelasExistentes,Lower('grupos')) != 0
     ELSE
          cQuery := 'create table grupos (' + ;
               'id int unsigned not null auto_increment,' + ;
               'descricao varchar(30),' + ;
               'max_desc float(6,2),' + ;
               'classif_fiscal varchar(7),' + ;
               'logotipo longblob,' + ;
               'primary key (id)) ' + ;
               'collate=latin1_swedish_ci engine=InnoDB default charset=latin1'
               oQuery := oMySQL:Query( cQuery )
               IF oMySQL:Neterr()
                    msginfo('Tabela grupos : '+oMySQL:Error())
               ENDIF
               oQuery:Destroy()
     ENDIF

     RETURN( nil )
*-------------------------------------------------------------------------------
function grupos()

	local v_largura := 1000
	local v_altura := 600
     private a_dados_grupos := {}

     pesquisar(0)

     define window form_grupos;
          at 0,0;
          width v_largura;
          height v_altura;
          title 'Grupos';
          icon 'icone';
          modal;
          nosize
          /*
               tbrowse
          */
      	define tbrowse otb_grupos;
         		at 0,0;
         		of form_grupos;
         		width v_largura -5;
         		height v_altura -80;
         		font 'verdana';
         		size 10;
         		fontcolor {30,30,30};
         		on dblclick dados_grupos( 2 );
	    		selector .T.
               /*
               	fonte de dados
              	*/
         		otb_grupos:setarray(a_dados_grupos)
               /*
               	configurar tbrowse
              	*/
	   	    	otb_grupos:nLineStyle  := 2
	         	otb_grupos:hFontHead   := getfonthandle('verdana')
	         	otb_grupos:lNoHScroll  := .F.
	         	otb_grupos:nWheelLines := 1
	         	otb_grupos:nHeightCell := 20
	         	otb_grupos:nHeightHead := otb_grupos:nHeightCell + 10
               otb_grupos:SetColor({CLR_FOCUSB},{{|a,b,c| If(c:nCell==b,{RGB(128,255,255),;
                         RGB(128,255,255)},{RGB(230,230,230),RGB(230,230,230)})}})
			otb_grupos:ResetVScroll()
			otb_grupos:Refresh(.T.)
			/*
				adicionar colunas
			*/
         		add column to otb_grupos ;
            		data array element 1;
            		header 'Cód.' ;
            		align DT_CENTER, DT_CENTER ;
            		width 40 ;
  		  		colors CLR_BLACK, CLR_HGRAY
         		add column to otb_grupos ;
            		data array element 2;
            		header 'Descrição' ;
            		align DT_LEFT, DT_CENTER ;
            		width 250 ;
            		colors CLR_BLACK, RGB(206,224,239)
         		add column to otb_grupos ;
            		data array element 3;
            		header 'Máximo Desconto' ;
            		align DT_LEFT, DT_CENTER ;
            		width 150
         		add column to otb_grupos ;
            		data array element 4;
            		header 'Classificação Fiscal' ;
            		align DT_LEFT, DT_CENTER ;
            		width 150
		end tbrowse
          /*
               botões : opções
          */
          @ form_grupos.height -77,form_grupos.width -428 buttonex btn_relatorio ;
          	caption 'Relatório' ;
               width 90 ;
               height 45 ;
               font 'verdana' size 10 ;
               action relatorio()
          @ form_grupos.height -77,form_grupos.width -328 buttonex btn_novo ;
          	caption 'Novo' ;
               width 80 ;
               height 45 ;
               font 'verdana' size 10 ;
               action dados_grupos(1)
          @ form_grupos.height -77,form_grupos.width -243 buttonex btn_edt_exc ;
          	caption 'Alterar / Excluir' ;
               width 130 ;
               height 45 ;
               font 'verdana' size 10 ;
               action dados_grupos(2)
          @ form_grupos.height -77,form_grupos.width -108 buttonex btn_voltar ;
          	caption 'Voltar - ESC' ;
               width 100 ;
               height 45 ;
               font 'verdana' size 10 ;
               action thiswindow.release
          /*
               pesquisa ( filtro )
          */
          @ form_grupos.height -72,5 textbox tbox_pesquisa width v_largura -440 height 35 value '';
               font 'calibri' size 11 uppercase on change pesquisar(1)
		/*
			fechar : janela
		*/
          on key escape action form_grupos.release

     end window

	form_grupos.center
     form_grupos.activate

     return(nil)
*-------------------------------------------------------------------------------
static function pesquisar(p_tipo)

	local oQuery
   	local oRow := {}
  	local i := 0   	
 	local v_pesquisa := ''
	local v_find := ''
	/*
		zerar : array
	*/
	a_dados_grupos := {}
	/*
		definir texto da pesquisa
	*/	
	if p_tipo == 1
		v_find := form_grupos.tbox_pesquisa.value
		v_pesquisa := '"'+upper(alltrim(v_find))+'%"'
	endif

	if p_tipo == 0
		oQuery := oMySQL:query('select id,descricao,max_desc,classif_fiscal from grupos order by descricao')
	elseif p_tipo == 1
		oQuery := oMySQL:query('select id,descricao,max_desc,classif_fiscal from grupos where descricao like '+v_pesquisa+' order by descricao')
	endif

	if oQuery:neterr()
 		msginfo('ERRO:'+oQuery:error())
	  	return(nil)
    	endif
	if oQuery:eof()
          aadd(a_dados_grupos,{'0','-','-','-'})
 		return(nil)
   	endif

	for i := 1 TO oQuery:lastrec()
 		oRow := oQuery:getrow(i)  		
		aadd(a_dados_grupos,{alltrim(str(oRow:fieldget(1))),;
			Alltrim(oRow:FieldGet(2)),;
               Trans(oRow:FieldGet(3),'@R 999.99'),;
               Alltrim(oRow:FieldGet(4))})		
     	oQuery:skip(1)
	next i

	oQuery:destroy()

	if p_tipo == 1
		otb_grupos:setarray(a_dados_grupos)	
		otb_grupos:refresh()
	endif

	return(nil)
*-------------------------------------------------------------------------------
function dados_grupos( parametro )

     local v_logotipo
     local img_grupos
	local nH	
     local img_tmp := curdrive()+':\'+curdir()+'\img_tmp.jpg'

	LOCAL oQuery
 	LOCAL oRow := {}
   	LOCAL v_titulo := 'Novo'
  	LOCAL v_id := ''

     LOCAL v_descricao      := ''
     LOCAL v_maximo_desc    := 0
     LOCAL v_classif_fiscal := ''

     private path_img_grupos

	IF parametro == 2
		v_id := a_dados_grupos[otb_grupos:nAt][1]
          if Val(v_id) == 0
               return( nil )
          endif
  		v_titulo := 'Alterar'
          oQuery := oMySQL:Query('select * from grupos where id = '+v_id)
          IF oQuery:NetErr()
               msginfo('Informação não encontrada')
               return( nil )
          ELSE
               oRow := oQuery:GetRow( 1 )
               v_descricao      := alltrim(oRow:FieldGet(2))
               v_maximo_desc    := oRow:FieldGet(3)
               v_classif_fiscal := alltrim(oRow:FieldGet(4))
               v_logotipo       := oRow:FieldGet(5)
 		ENDIF
          oQuery:Destroy()
          /*
               recuperar imagem gravada na tabela
          */
          img_grupos := HexToStr( AllTrim( v_logotipo ) )
          nH := FCreate( img_tmp )
          FWrite( nH, img_grupos )
          FClose( nH )
          path_img_grupos := img_tmp
	ENDIF

	DEFINE WINDOW form_dados_grupos ;
 		AT 0, 0 ;
   		WIDTH 700 ;
     	HEIGHT 500 ;
      	TITLE (v_titulo) ;
       	ICON 'icone' ;
      	MODAL ;
      	NOSIZE
          /*
               say
          */
          @ 010,010 LABEL Label_1 VALUE 'Descrição' AUTOSIZE TRANSPARENT BOLD
          @ 070,010 LABEL Label_2 VALUE 'Máximo Desconto (%)' AUTOSIZE TRANSPARENT BOLD
          @ 130,010 LABEL Label_3 VALUE 'Classificação Fiscal' AUTOSIZE TRANSPARENT BOLD
          /*
               get
          */
          @ 030,010 TEXTBOX Tbox_descricao HEIGHT 30 WIDTH 350 VALUE v_descricao UPPERCASE
          @ 090,010 GETBOX Tbox_max_desc HEIGHT 30 WIDTH 150 VALUE v_maximo_desc picture '@R 999.99'
          @ 150,010 TEXTBOX Tbox_cla_fis HEIGHT 30 WIDTH 200 VALUE v_classif_fiscal UPPERCASE
          /*
               logotipo
          */
		@ 010,380 FRAME Frame_logotipo caption '' WIDTH 1 HEIGHT 270
  		@ 020,400 IMAGE Img_logotipo PICTURE path_img_grupos WIDTH 260 HEIGHT 260 WHITEBACKGROUND
          @ 300,400 buttonex btn_busca_logotipo ;
          	caption 'Buscar imagem (foto)' ;
               width 260 ;
               height 50 ;
               font 'verdana' size 10 ;
               fontcolor BLACK ;
               backcolor WHITE ;
               action carregar_imagem()
          /*
               botões
          */
          @ thiswindow.height -85,thiswindow.width -215 buttonex btn_gravar ;
          	caption 'Gravar' ;
               width 100 ;
               height 50 ;
               font 'verdana' size 10 ;
               fontcolor BLUE ;
               backcolor WHITE ;
               action gravar( parametro, v_id )
          @ thiswindow.height -85,thiswindow.width -110 buttonex btn_voltar ;
          	caption 'Voltar - ESC' ;
               width 100 ;
               height 50 ;
               font 'verdana' size 10 ;
               action thiswindow.release
		if parametro == 2
	          /*
	          	mostra botão para excluir
	         	*/
	          @ thiswindow.height -85,thiswindow.width -320 buttonex btn_excluir ;
	               caption 'Excluir' ;
	               width 100 ;
	               height 50 ;
	               font 'verdana' size 10 ;
	               fontcolor RED ;
	               action excluir( v_id )
          endif

		on key escape action thiswindow.release
		
	END WINDOW

	form_dados_grupos.center
 	form_dados_grupos.activate

	RETURN( nil )	
*-------------------------------------------------------------------------------
static function excluir( p_id )

	local cQuery
 	local oQuery

	if MsgYesNo('Excluir ?')
 		cQuery := 'delete from grupos where id = '+p_id
   		oQuery := oMySQL:query( cQuery )
     	if oQuery:neterr()
      		msginfo(oQuery:error(),'ERRO',3)
        		return( nil )
          endif
          oQuery:destroy()
          form_dados_grupos.release
          pesquisar(1)
	endif

	return( nil )
*-------------------------------------------------------------------------------
STATIC FUNCTION Gravar( parametro, p_id )

	LOCAL cQuery
 	LOCAL oQuery

     LOCAL v_logotipo   := StrToHex(MemoRead(path_img_grupos))
     LOCAL v_descricao  := AllTrim(Form_dados_grupos.Tbox_descricao.value)
     LOCAL v_max_desc   := str(form_dados_grupos.Tbox_max_desc.value,6,2)
     LOCAL v_cla_fiscal := AllTrim(Form_dados_grupos.Tbox_cla_fis.value)
     /*
          validações
     */
	IF Empty( v_descricao )
		msginfo('Digite : Descrição')
 		RETURN( nil )
	ENDIF
     /*
          inclusão
     */
	IF parametro == 1
		cQuery := "insert into grupos (descricao,max_desc,classif_fiscal,logotipo) values ('"
          cQuery += v_descricao  + "','" 		
          cQuery += v_max_desc   + "','" 		
          cQuery += v_cla_fiscal + "','" 		
 		cQuery += v_logotipo   + "')"
	ENDIF
     /*
          alteração
     */
	IF parametro == 2	
		cQuery := "update grupos set "
	 	cQuery += "descricao='"       + v_descricao  + "',"	 	
	 	cQuery += "max_desc='"        + v_max_desc   + "',"	 	
	 	cQuery += "classif_fiscal='"  + v_cla_fiscal	+ "',"	 	
	 	cQuery += "logotipo='"		+ v_logotipo	+ "' "
  	 	cQuery += "where id='"        + p_id	     + "'"		
	ENDIF
	
	oQuery := oMySQL:Query( cQuery )
	IF oQuery:NetErr()
		msginfo(oQuery:Error())
 	ENDIF
  	oQuery:Destroy()
   	form_dados_grupos.release

    	pesquisar(1)

	RETURN( Nil )
*-------------------------------------------------------------------------------
static function carregar_imagem()

     cFile := GetFile({{'Selecione a imagem','*.JPG;*.PNG'},{'Formato JPG','*.JPG'},{'Formato PNG','*.PNG'}},'Pesquisa', GetCurrentFolder(), .F., .T. )

     IF Empty ( cFile )
          RETURN( nil )
     ENDIF

     path_img_grupos := cFile

     SetProperty('form_dados_grupos','img_logotipo','picture',cFile)

     RETURN( nil )
*-------------------------------------------------------------------------------
static function relatorio()

	local oQuery
     local cQuery
     local oRow         := {}
	local lSuccess     := .F.
     local linha        := 0
     local linha_inicio := 50
     local u_linha      := 260
     local i            := 0
     /*
          selecionar dados
     */
     oQuery := oMySQL:Query('select * from grupos order by descricao')
     /*
          checar se tabela está vazia
     */
     if oQuery:Eof()
		msginfo('Tabela vazia, tecle ENTER')
		return(nil)
	endif
	/*
		iniciar o relatório
	*/
   	SELECT HPDFDOC 'relatorio.pdf' TO lSuccess PAPERSIZE HPDF_PAPER_A4
	SET HPDFDOC ENCODING TO "WinAnsiEncoding"   	

   	SET HPDFDOC FONT NAME TO 'courier new'
   	SET HPDFDOC FONT SIZE TO 10
   	
   	if lSuccess   	
    		START HPDFDOC   	    		
         		START HPDFPAGE

               Cabecalho()

               linha := linha_inicio

               FOR i := 1 TO oQuery:LastRec()

                    oRow := oQuery:GetRow( i )

                    @ linha,010 HPDFPRINT Alltrim( oRow:FieldGet(2) ) FONT 'courier new' SIZE 10
                    @ linha,080 HPDFPRINT Alltrim( oRow:FieldGet(4) ) FONT 'courier new' SIZE 10  		

                    linha += 5
					
                    IF linha >= u_linha
                         pagina ++
                         END HPDFPAGE
                         START HPDFPAGE
                         Cabecalho()
                         linha := linha_inicio
                    ENDIF

                    oQuery:Skip( 1 )

               NEXT i

               END HPDFPAGE
          END HPDFDOC

          oQuery:Destroy()
     endif

   	EXECUTE FILE 'relatorio.pdf'

	return(nil)
*-------------------------------------------------------------------------------
static function cabecalho()

     @ 005,010 HPDFPRINT IMAGE 'logo_empresa.png' WIDTH 35 HEIGHT 25

	@ 010,060 HPDFPRINT 'RELATORIO DE GRUPOS' FONT 'courier new' SIZE 10 BOLD
	@ 010,130 HPDFPRINT dtoc(Date()) FONT 'courier new' SIZE 10 BOLD
	@ 015,060 HPDFPRINT 'ORDEM : DESCRIÇÃO' FONT 'courier new' SIZE 10

	@ 030,010 HPDFPRINT LINE TO 030,200 PENWIDTH 0.2

	@ 035,010 HPDFPRINT 'Descrição' FONT 'courier new' SIZE 10 BOLD
	@ 035,080 HPDFPRINT 'Classif.Fiscal' FONT 'courier new' SIZE 10 BOLD

	@ 040,010 HPDFPRINT LINE TO 040,200 PENWIDTH 0.2
			
     RETURN( Nil )