@ECHO OFF
:: por Emerson Toneti
:: 1.2 21/08/2025
TITLE Assistente de Suporte
COLOR 0B
CHCP 65001 > NUL

:MENU
CLS
ECHO.⠀⠀
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
ECHO    [1] Menu de otimizacao
ECHO    [2] GPupdate
ECHO    [3] Menu Prefetch/Superfetch
ECHO    [4] Problemas de impressao
ECHO    [5] Limpa Perfil
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
CALL :GPUPDATE
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
GOTO SAIR

@echo off
CLS

:SubmenuOti
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
ECHO    [7] Executar TODAS as otimizacoes em sequencia
ECHO.
ECHO    [8] Voltar ao menu principal
ECHO.
ECHO ===========================================================================
ECHO.
CHOICE /C 12345678 /N 

IF ERRORLEVEL 8 GOTO :MENU
IF ERRORLEVEL 7 GOTO :TODAS
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

:LimpaPerfil
:: Script do limpa perfil criado originalmente por Marcelo Esteves
CLS
net session >nul 2>&1
if %errorlevel% neq 0 (
    CLS
    echo.
    echo Voce precisa executar este script como Administrador.
    echo.
    echo Pressione qualquer tecla para voltar ao menu...
    pause >nul
	GOTO :MENU
)

setlocal enabledelayedexpansion

set "username="
set /p username="Digite o nome do usuario: "

if not defined username (
    echo.
    echo Nao encontrado, voltando ao menu.
    echo.
    pause
    GOTO :EOF
)

CD C:\USERS
wmic path win32_userprofile where LocalPath="c:\\Users\\%username%" delete
wmic useraccount where name="%username%" get sid | find "S-1-" >0 && set /p USERID=<0
IF ERRORLEVEL 1 GOTO FOLDER
ECHO %USERID%
for /l %%a in (1,1,10) do if "!userid:~-1!"==" " set userid=!userid:~0,-1!
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\!userid!" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\!userid!.bak" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\!userid!" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\!userid!" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Status\!userid!" /f
REG DELETE "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Group Policy\State\!userid!" /f
REG DELETE "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Group Policy\Status\!userid!" /f
PAUSE
GOTO :MENU

:FOLDER
rmdir /s /q %username%
PAUSE
GOTO :MENU

:SubMenuPS
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
CLS
ECHO.
ECHO ===========================================================================
ECHO                      PROBLEMAS COMUNS DE IMPRESSAO
ECHO ===========================================================================
ECHO.
ECHO   [1] Reiniciar o spooler de impressao
ECHO   [2] Corrigir erro 0x00000709
ECHO   [3] Corrigir erro 0x00000bcb
ECHO   [4] Corrigir erro 0x0000011b
ECHO.
ECHO   [5] Voltar ao menu principal
ECHO.
ECHO ===========================================================================
ECHO.

CHOICE /C 12345 /N 
IF ERRORLEVEL 5 GOTO MENU
IF ERRORLEVEL 4 GOTO erro11gb
IF ERRORLEVEL 3 GOTO erro0bcb
IF ERRORLEVEL 2 GOTO erro709
IF ERRORLEVEL 1 GOTO spooler

:ERRO11b
CLS
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f
echo Erro 0x0000011b corrigido.
pause
GOTO SubMenuImp

:ERRO0bcb
CLS
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f
echo Erro 0x00000bcb corrigido.
pause
GOTO SubMenuImp

:ERRO709
CLS
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f
echo Erro 0x00000709 corrigido.
pause
GOTO SubMenuImp

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
ECHO Atualizando as politicas de grupo
ECHO.
gpupdate /force
ECHO.
ECHO Concluido!
ECHO.
PAUSE
GOTO :EOF

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
CALL :SISTEMA
ECHO.
ECHO Otimizacao concluida!
ECHO Reinicie seu computador para finalizar todas as alteracoes.
ECHO.
PAUSE
GOTO :SubmenuOti

:SAIR
CLS
ECHO.
TIMEOUT /T 3 /NOBREAK >NUL
EXIT