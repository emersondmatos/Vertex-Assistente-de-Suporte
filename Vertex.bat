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
ECHO    [1] SubMenu de otimizacao
ECHO    [2] SubMenu Prefetch/Superfetch
ECHO    [3] SubMenu de Impressao
ECHO    [4] Exclusao de Perfis de Usuarios
ECHO    [5] GPupdate
ECHO.
ECHO    [6] Sair
ECHO ============================================================================
ECHO.

CHOICE /C 123456 /N 

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
CALL :SubMenuPS
GOTO MENU

:Op3
CALL :SubMenuImp
GOTO MENU

:Op4
CALL:LimpaPerfil
GOTO MENU

:Op5
CALL :GPUPDATE
GOTO MENU

:Op6
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
echo        Ferramenta de Exclusao de Perfis de Usuario
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
ECHO                            MENU DE OTIMIZACAO
ECHO ===========================================================================
ECHO.
ECHO    [1] Limpeza de Arquivos Temporarios e Cache
ECHO    [2] Verificacao e Reparo de Arquivos do Sistema
ECHO    [3] Otimizacao de Rede
ECHO    [4] Limpeza de disco
ECHO    [5] Plano de energia "Desempenho Maximo"
ECHO    [6] Selecionar plano de Desempenho
ECHO.
ECHO    [7] Executar TODAS as otimizacoes em sequencia (Com reparo de sistema)
ECHO    [8] Executar TODAS as otimizacoes em sequencia (Sem reparo de sistema)
ECHO.
ECHO    [9] Voltar ao menu principal
ECHO.
ECHO ===========================================================================
ECHO.
CHOICE /C 123456789 /N 

IF ERRORLEVEL 9 GOTO :MENU
IF ERRORLEVEL 8 GOTO :TODAS
IF ERRORLEVEL 7 GOTO :TODASR
IF ERRORLEVEL 6 GOTO :DESEMPENHO
IF ERRORLEVEL 5 GOTO :ENERGIA
IF ERRORLEVEL 4 GOTO :LIMPDISCO
IF ERRORLEVEL 3 GOTO :REDE
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
ECHO.
ECHO   [2] Voltar ao menu principal
ECHO.
ECHO ===========================================================================
ECHO.

CHOICE /C 12 /N 
IF ERRORLEVEL 2 GOTO MENU
IF ERRORLEVEL 1 GOTO SPOOLER

:SPOOLER
CLS
net stop spooler
timeout /t 5 >nul
net start spooler
ECHO Spooler reiniciado.
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
ECHO Iniciando limpeza de arquivos.
ECHO.
ECHO Feche o maximo de programas possivel para uma limpeza mais eficaz.
PAUSE
ECHO.
ECHO Limpando arquivos e pastas temporarias do Usuario (%TEMP%).
PUSHD %TEMP% 2>NUL
IF ERRORLEVEL 1 (
    ECHO   [AVISO] Nao foi possivel acessar a pasta %TEMP%.
) ELSE (
    DEL /F /S /Q *.* >NUL 2>&1
    FOR /D %%i IN (*.*) DO RMDIR /S /Q "%%i" >NUL 2>&1
    POPD
    ECHO   Concluido!
)

ECHO.
ECHO Limpando arquivos e pastas temporarias do Sistema (C:\Windows\Temp).
PUSHD C:\Windows\Temp 2>NUL
IF ERRORLEVEL 1 (
    ECHO   [AVISO] Nao foi possivel acessar C:\Windows\Temp.
) ELSE (
    DEL /F /S /Q *.* >NUL 2>&1
    FOR /D %%i IN (*.*) DO RMDIR /S /Q "%%i" >NUL 2>&1
    POPD
    ECHO   Concluido!
)

ECHO.
ECHO Limpando cache de DNS...
ipconfig /flushdns
ECHO.
ECHO Concluido!
ECHO Alguns arquivos podem estar sendo utilizados e portanto nao foram excluidos.
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
ECHO Iniciando a otimizacao completa.
ECHO Este processo pode demorar. 
PAUSE
CALL :LIMPEZA
CALL :DESABILITARFAST
CALL :REDE
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