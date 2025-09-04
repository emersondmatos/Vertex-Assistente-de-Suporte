@ECHO OFF
:: por Emerson Toneti
TITLE Assistente de Suporte
CHCP 65001 > NUL
setlocal enabledelayedexpansion

:MENU
COLOR 0B
CLS
ECHO.
ECHO  █████   █████ ██████████ ███████████   ███████████ ██████████ █████ █████
ECHO ░░███   ░░███ ░░███░░░░░█░░███░░░░░███ ░█░░░███░░░█░░███░░░░░█░░███ ░░███ 
ECHO  ░███    ░███  ░███  █ ░  ░███    ░███ ░   ░███  ░  ░███  █ ░  ░░███ ███  
ECHO  ░███    ░███  ░██████    ░██████████      ░███     ░██████     ░░█████   
ECHO  ░░███   ███   ░███░░█    ░███░░░░░███     ░███     ░███░░█      ███░███  
ECHO   ░░░█████░    ░███ ░   █ ░███    ░███     ░███     ░███ ░   █  ███ ░░███ 
ECHO     ░░███      ██████████ █████   █████    █████    ██████████ █████ █████
ECHO      ░░░      ░░░░░░░░░░ ░░░░░   ░░░░░    ░░░░░    ░░░░░░░░░░ ░░░░░ ░░░░░                                                                                                                                                                                                                                                                                      
ECHO ===========================================================================
ECHO  Recomenda-se executar como Administrador.
ECHO.
ECHO  Selecione uma opcao para continuar:
ECHO.
ECHO    [1] SubMenu de Otimizacao
ECHO    [2] SubMenu de Rede
ECHO    [3] SubMenu Prefetch/Superfetch
ECHO    [4] SubMenu de Impressao
ECHO    [5] Exclusao de Perfis de Usuarios
ECHO    [6] GPupdate
ECHO.
ECHO    [7] Sair
ECHO ============================================================================
ECHO.

CHOICE /C 1234567 /N 

IF ERRORLEVEL 7 GOTO Op7
IF ERRORLEVEL 6 GOTO Op6
IF ERRORLEVEL 5 GOTO Op5
IF ERRORLEVEL 4 GOTO Op4
IF ERRORLEVEL 3 GOTO Op3
IF ERRORLEVEL 2 GOTO Op2
IF ERRORLEVEL 1 GOTO Op1

:Op1
CALL :SubmenuOti
GOTO MENU

:Op2
CALL :SubmenuRede
GOTO MENU

:Op3
CALL :SubMenuPS
GOTO MENU

:Op4
CALL :SubMenuImp
GOTO MENU

:Op5
CALL:LimpaPerfil
GOTO MENU

:Op6
CALL :GPUPDATE
GOTO MENU

:Op7
GOTO SAIR

:LimpaPerfil
COLOR 0C
CLS
net session >nul 2>&1
if %errorlevel% neq 0 (
    CLS
    echo.
    echo Este script precisa ser executado com privilegios de Administrador.
    echo.
    echo Pressione qualquer tecla para sair.
    pause >nul
    exit
)

echo.
echo ==========================================================
echo        FERRAMENTA DE EXCLUSAO DE PERFIS DE USUARIO
echo ==========================================================
echo.
echo Para sair, simplesmente pressione Enter sem digitar nada.
echo.

set "userlist="
set /p userlist="Digite os nomes dos usuarios a serem removidos (separados por espaco): "

if not defined userlist (
    echo Saindo.
    goto :EOF
)

CLS
echo.
echo ----------------------------------------------------------
echo Iniciando processo para os usuarios: %userlist%
echo ----------------------------------------------------------
echo.

for %%u in (%userlist%) do (
    set "username=%%u"
    echo Processando usuario: !username!

    wmic useraccount where name="!username!" get sid >nul 2>&1
    if !errorlevel! neq 0 (
        echo   [AVISO] Usuario "!username!" nao encontrado no sistema. Pulando.
    ) else (
        set "USERID="
        for /f "tokens=*" %%s in ('wmic useraccount where name="!username!" get sid ^| find "S-1-"') do (
            set "USERID=%%s"
        )
        for /l %%a in (1,1,10) do if "!USERID:~-1!"==" " set USERID=!USERID:~0,-1!

        echo   - SID encontrado: !USERID!
        
        echo   - Removendo diretorio do perfil C:\Users\!username!.
        wmic path win32_userprofile where "LocalPath like 'C:\\Users\\!username!'" delete >nul 2>&1
        
        if defined USERID (
            echo   - Removendo chaves do Registro.
            REG DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\!USERID!" /f >nul 2>&1
            REG DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\!USERID!.bak" /f >nul 2>&1
        )
        
        echo   - Removendo a conta de usuario local "!username!".
        net user !username! /delete >nul 2>&1
        
        echo   [SUCESSO] Perfil do usuario "!username!" foi removido.
    )
    echo.
)

echo ----------------------------------------------------------
echo Processo finalizado.
echo.
echo Pressione qualquer tecla para voltar ao menu principal.
pause >nul
goto :EOF

:SubmenuOti
COLOR 0B
CLS
ECHO.
ECHO ===========================================================================
ECHO                         SUBMENU DE OTIMIZACAO
ECHO ===========================================================================
ECHO.
ECHO    [1] Limpeza de Arquivos Temporarios e Cache
ECHO    [2] Verificacao e Reparo de Arquivos do Sistema
ECHO    [3] Limpeza de disco
ECHO    [4] Plano de energia "Desempenho Maximo"
ECHO    [5] Selecionar plano de Desempenho
ECHO.
ECHO    [6] Executar TODAS as otimizacoes em sequencia (Com reparo de sistema)
ECHO    [7] Executar TODAS as otimizacoes em sequencia (Sem reparo de sistema)
ECHO.
ECHO    [8] Voltar ao menu principal
ECHO.
ECHO ===========================================================================
ECHO.
CHOICE /C 12345678 /N 

IF ERRORLEVEL 8 GOTO :MENU
IF ERRORLEVEL 7 GOTO :TODAS
IF ERRORLEVEL 6 GOTO :TODASR
IF ERRORLEVEL 5 GOTO :DESEMPENHO
IF ERRORLEVEL 4 GOTO :ENERGIA
IF ERRORLEVEL 3 GOTO :LIMPDISCO
IF ERRORLEVEL 2 GOTO :SISTEMA
IF ERRORLEVEL 1 GOTO :LIMPEZA

:DESEMPENHO
CLS
sysdm.cpl
PAUSE
GOTO :SubmenuOti

:ENERGIA
CLS
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
ECHO Concluido!
PAUSE
GOTO :SubmenuOti

:LIMPDISCO
CLS
cleanmgr /d C:
PAUSE
GOTO :SubmenuOti

:SubmenuRede
COLOR 0B
CLS
ECHO.
ECHO ===========================================================================
ECHO                           SUBMENU DE REDE
ECHO ===========================================================================
ECHO.
ECHO    [1] Redefinicao do TCP/IP
ECHO    [2] Redefinicao do Winsock
ECHO    [3] Limpar Cache de DNS
ECHO    [4] Liberar e renovar o IP
ECHO    [5] Testar Conectividade (Ping 8.8.8.8)
ECHO    [6] Exibir rotas de rede
ECHO    [7] IPconfig
ECHO.
ECHO    [8] Voltar ao menu principal
ECHO.
ECHO ===========================================================================
ECHO.
CHOICE /C 12345678 /N 

IF ERRORLEVEL 8 GOTO :MENU
IF ERRORLEVEL 7 GOTO :IPCONFIG
IF ERRORLEVEL 6 GOTO :ROTA
IF ERRORLEVEL 5 GOTO :PING
IF ERRORLEVEL 4 GOTO :IPRENEW
IF ERRORLEVEL 3 GOTO :DNS
IF ERRORLEVEL 2 GOTO :WINSOCK
IF ERRORLEVEL 1 GOTO :TCPIP

:IPRENEW
CLS
ECHO Liberando e renovando o IP.
ipconfig /release
ipconfig /renew
ECHO  Concluido!
PAUSE
GOTO :SubmenuRede

:TCPIP
CLS
ECHO Redefinindo o TCP/IP.
netsh int ip reset
ECHO  Concluido!
PAUSE
GOTO :SubmenuRede

:WINSOCK
CLS
ECHO Redefinindo o Winsock.
netsh winsock reset
ECHO  Concluido!
PAUSE
GOTO :SubmenuRede

:DNS
CLS
ECHO Limpando o cache de DNS.
ipconfig /flushdns
ECHO  Concluido!
PAUSE
GOTO :SubmenuRede

:PING
CLS
ECHO Testando conectividade com o Google DNS (8.8.8.8).
ping 8.8.8.8 -n 4
ECHO  Concluido!
PAUSE
GOTO :SubmenuRede

:ROTA
CLS
ECHO Exibindo rotas de rede.
route print
ECHO  Concluido!
PAUSE
GOTO :SubmenuRede

:IPCONFIG
CLS
ECHO Exibindo informacoes de rede.
ipconfig /all
ECHO  Concluido!
PAUSE
GOTO :SubmenuRede

:SubMenuPS
COLOR 0B
CLS
ECHO.
ECHO ===========================================================================
ECHO                  GERENCIADOR DO PREFETCH/SUPERFETCH
ECHO ===========================================================================
ECHO.
ECHO   [1] Desabilitar
ECHO   [2] Habilitar
ECHO.
ECHO   [3] Voltar ao menu principal
ECHO.
ECHO ===========================================================================
ECHO.

CHOICE /C 123 /N 

IF ERRORLEVEL 3 GOTO MENU
IF ERRORLEVEL 2 GOTO HABILITAR
IF ERRORLEVEL 1 GOTO DESABILITAR

:SubMenuImp
COLOR 0B
CLS
ECHO.
ECHO ===========================================================================
ECHO                          SUBMENU DE IMPRESSAO
ECHO ===========================================================================
ECHO.
ECHO   [1] Reiniciar o spooler de impressao
ECHO   [2] Exibir status do spooler
ECHO   [3] Listar impressoras instaladas
ECHO   [4] Limpar fila de impressao
ECHO   [5] Testar impressao (pagina de teste)
ECHO   [6] Reinstalar drivers de impressora
ECHO.
ECHO   [7] Voltar ao menu principal
ECHO ===========================================================================
ECHO.

CHOICE /C 1234567 /N 
IF ERRORLEVEL 7 GOTO MENU
IF ERRORLEVEL 6 GOTO REINSTALARDRV
IF ERRORLEVEL 5 GOTO TESTEIMP
IF ERRORLEVEL 4 GOTO LIMPAFILA
IF ERRORLEVEL 3 GOTO LISTAIMP
IF ERRORLEVEL 2 GOTO STATUSPOOL
IF ERRORLEVEL 1 GOTO SPOOLER

:SPOOLER
CLS
net stop spooler
timeout /t 5 >nul
net start spooler
ECHO Spooler reiniciado.
PAUSE
GOTO SubMenuImp

:STATUSPOOL
CLS
ECHO Status do spooler de impressao:
sc query spooler
PAUSE
GOTO SubMenuImp

:LISTAIMP
CLS
ECHO Impressoras instaladas:
wmic printer get name,default,status
PAUSE
GOTO SubMenuImp

:LIMPAFILA
CLS
ECHO Limpando fila de impressao...
net stop spooler
timeout /t 2 >nul
del /F /Q "%systemroot%\System32\spool\PRINTERS\*.*" >nul 2>&1
net start spooler
ECHO Fila de impressao limpa!
PAUSE
GOTO SubMenuImp

:TESTEIMP
CLS
ECHO Impressoras instaladas:
wmic printer get name
ECHO.
SET /P PRINTER="Digite o nome exato da impressora para teste: "
IF NOT DEFINED PRINTER (
    ECHO Nenhuma impressora informada.
    PAUSE
    GOTO SubMenuImp
)
ECHO Enviando pagina de teste para "%PRINTER%".
rundll32 printui.dll,PrintUIEntry /k /n "%PRINTER%"
ECHO Comando enviado.
PAUSE
GOTO SubMenuImp

:REINSTALARDRV
CLS
ECHO Reinstalando drivers de impressora...
ECHO.
ECHO Este comando abre o assistente do Windows para reinstalacao manual.
rundll32 printui.dll,PrintUIEntry /il
ECHO.
ECHO Quando terminar, feche a janela para retornar ao menu.
PAUSE
GOTO SubMenuImp

:DESABILITARFAST
CLS
ECHO Desabilitando o Prefetch e Superfetch
ECHO.
ECHO Alterando registro do Prefetch.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f
ECHO.
ECHO Desabilitando o SysMain.
sc stop "SysMain"
sc config "SysMain" start=disabled
ECHO.
ECHO Desabilitados!
ECHO.
PAUSE
GOTO :SubmenuOti

:DESABILITAR
CLS
ECHO Desabilitando o Prefetch e Superfetch
ECHO.
ECHO Alterando registro do Prefetch.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f
ECHO.
ECHO Desabilitando o SysMain.
sc stop "SysMain"
sc config "SysMain" start=disabled
ECHO.
ECHO Desabilitados!
ECHO.
PAUSE
GOTO SubMenuPS


:HABILITAR
CLS
ECHO Habilitando o Prefetch e Superfetch.
ECHO.
ECHO Alterando o registro para habilitar Prefetch.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 3 /f
ECHO.
ECHO Configurando o servico SysMain (Superfetch) para automatico.
sc config "SysMain" start=auto
sc start "SysMain"
ECHO.
ECHO Habilitados!
ECHO.
PAUSE
GOTO SubMenuPS


:LIMPEZA
CLS
ECHO Iniciando limpeza da pasta TEMP do AppData do usuario.
ECHO.
ECHO Feche o maximo de programas possivel para uma limpeza mais eficaz.
PAUSE
ECHO.
ECHO Limpando arquivos e pastas temporarias do AppData do Usuario (%USERPROFILE%\AppData\Local\Temp).
PUSHD "%USERPROFILE%\AppData\Local\Temp" 2>NUL
IF ERRORLEVEL 1 (
    ECHO   Nao foi possivel acessar %USERPROFILE%\AppData\Local\Temp.
) ELSE (
    DEL /F /S /Q *.* >NUL 2>&1
    FOR /D %%i IN (*.*) DO RMDIR /S /Q "%%i" >NUL 2>&1
    POPD
    ECHO   Concluido!
)
ECHO.
PAUSE
GOTO :SubmenuOti

:SISTEMA
CLS
ECHO Iniciando a verificao do sistema.
ECHO.
ECHO Este processo pode demorar.
PAUSE
ECHO.
ECHO Verificando e reparando.
sfc /scannow
ECHO.
ECHO
Dism /Online /Cleanup-Image /RestoreHealth
ECHO.
ECHO Concluido! 
ECHO.
PAUSE
GOTO :SubmenuOti

:REDE
CLS
ECHO Otimizando a rede.
ECHO.
ECHO Este processo ira redefinir as configuracoes de rede.
ECHO Recomenda-se reiniciar o computador depois deste processo.
PAUSE
ECHO.
ECHO Redefinindo o catalogo Winsock.
netsh winsock reset
ECHO Redefinindo o stack IP.
netsh int ip reset
ECHO Limpando cache de DNS.
ipconfig /flushdns
ECHO.
ECHO Concluido!
ECHO.
PAUSE
GOTO :SubmenuOti

:GPUPDATE
CLS
ECHO Atualizando as politicas de grupo.
ECHO.
gpupdate /force
ECHO.
ECHO Concluido!
ECHO.
PAUSE
GOTO :EOF

:TODASR
CLS
ECHO Iniciando a otimizacao completa com reparo de sistema.
ECHO Este processo pode demorar. 
PAUSE
CALL :LIMPEZA
CALL :DESABILITARFAST
CALL :LIMPDISCO
CALL :DESEMPENHO
CALL :ENERGIA
CALL :SISTEMA
ECHO.
ECHO Otimizacao concluida!
ECHO Reinicie seu computador para finalizar todas as alteracoes.
ECHO.
PAUSE
GOTO :SubmenuOti

:TODAS
CLS
ECHO Iniciando a otimizacao completa.
ECHO Este processo pode demorar. 
PAUSE
CALL :LIMPEZA
CALL :DESABILITARFAST
CALL :REDE
CALL :LIMPDISCO
CALL :DESEMPENHO
CALL :ENERGIA
ECHO.
ECHO Otimizacao concluida!
ECHO Reinicie seu computador para finalizar todas as alteracoes.
ECHO.
PAUSE
GOTO :SubmenuOti

:SAIR
CLS
ECHO.
TIMEOUT /T 1 /NOBREAK >NUL
EXIT