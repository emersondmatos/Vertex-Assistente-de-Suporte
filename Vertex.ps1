#Requires -RunAsAdministrator
# Script por Emerson Toneti
$Host.UI.RawUI.WindowTitle = "Assistente de Suporte"
$Host.UI.RawUI.ForegroundColor = "Cyan"
$Host.UI.RawUI.BackgroundColor = "Black"
$OutputEncoding = [System.Text.Encoding]::UTF8 


function Show-MainMenu {
    Clear-Host
    Write-Host @"
     ##:  :##  ########  ######:   ########  ########  ##    ## 
     ##    ##  ########  #######   ########  ########  :##  ##: 
     :##  ##:  ##        ##   :##     ##     ##         ##  ##  
     :##  ##:  ##        ##    ##     ##     ##         :####:  
      ## .##   ##        ##   :##     ##     ##          ####   
      ##::##   #######   #######:     ##     #######     :##:   
      ##::##   #######   ######       ##     #######     :##:   
      :####:   ##        ##   ##.     ##     ##          ####   
      .####.   ##        ##   ##      ##     ##         :####:  
       ####    ##        ##   :##     ##     ##         ##::##  
       ####    ########  ##    ##:    ##     ########  :##  ##: 
        ##     ########  ##    ###    ##     ########  ##    ##                                                                           
===========================================================================
 Recomenda-se executar como Administrador.
===========================================================================
 Selecione uma opcao para continuar:

    [1] SubMenu de otimizacao
    [2] SubMenu Prefetch/Superfetch
    [3] SubMenu de Impressao
    [4] Exclusao de Perfis de Usuarios
    [5] GPupdate

    [6] Sair
============================================================================

"@
}

function Show-OptimizationMenu {
    while ($true) {
        Clear-Host
        Write-Host @"
===========================================================================
                           MENU DE OTIMIZACAO
===========================================================================

    [1] Limpeza de Arquivos Temporarios e Cache
    [2] Verificacao e Reparo de Arquivos do Sistema
    [3] Otimizacao de Rede
    [4] Limpeza de disco
    [5] Plano de energia "Desempenho Maximo"
    [6] Selecionar plano de Desempenho
    [7] Executar TODAS as otimizacoes em sequencia (Com reparo de sistema)
    [8] Executar TODAS as otimizacoes em sequencia (Sem reparo de sistema)

    [9] Voltar ao menu principal
===========================================================================

"@
        $choice = Read-Host "Escolha uma opcao"
        switch ($choice) {
            '1' { Invoke-TempFileCleanup; Pause-Script }
            '2' { Invoke-SystemRepair; Pause-Script }
            '3' { Invoke-NetworkOptimization; Pause-Script }
            '4' { Start-Process cleanmgr -ArgumentList "/d C:" -Wait }
            '5' { Set-MaxPerformancePlan; Pause-Script }
            '6' { Start-Process sysdm.cpl }
            '7' { Invoke-AllOptimizations -WithSystemRepair; Pause-Script }
            '8' { Invoke-AllOptimizations; Pause-Script }
            '9' { return } 
            default { Write-Warning "Opcao invalida." ; Start-Sleep -Seconds 2 }
        }
    }
}

function Show-PrefetchMenu {
    while ($true) {
        Clear-Host
        Write-Host @"
===========================================================================
                 GERENCIADOR DO PREFETCH/SUPERFETCH
===========================================================================

   [1] Desabilitar
   [2] Habilitar

   [3] Voltar ao menu principal
===========================================================================

"@
        $choice = Read-Host "Escolha uma opcao"
        switch ($choice) {
            '1' { Set-PrefetchStatus -Enable:$false; Pause-Script }
            '2' { Set-PrefetchStatus -Enable:$true; Pause-Script }
            '3' { return } 
            default { Write-Warning "Opcao invalida." ; Start-Sleep -Seconds 2 }
        }
    }
}

function Show-PrinterMenu {
     while ($true) {
        Clear-Host
        Write-Host @"
===========================================================================
                         SUBMENU DE IMPRESSAO
===========================================================================

   [1] Reiniciar o spooler de impressao

   [2] Voltar ao menu principal
===========================================================================

"@
        $choice = Read-Host "Escolha uma opcao"
        switch ($choice) {
            '1' { Restart-SpoolerService; Pause-Script }
            '2' { return } 
            default { Write-Warning "Opcao invalida." ; Start-Sleep -Seconds 2 }
        }
    }
}

function Invoke-GPUpdate {
    Clear-Host
    Write-Host "Atualizando as politicas de grupo..." -ForegroundColor Green
    gpupdate /force
    Write-Host "`nConcluido!" -ForegroundColor Green
}

function Invoke-TempFileCleanup {
    Clear-Host
    Write-Host "Iniciando limpeza de arquivos." -ForegroundColor Green
    Write-Host "Feche o maximo de programas possivel para uma limpeza mais eficaz."
    Pause-Script

    Write-Host "`Limpando arquivos e pastas temporarias do Usuario (%TEMP%)..."
    Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Concluido!" -ForegroundColor Green

    Write-Host "`Limpando arquivos e pastas temporarias do Sistema (C:\Windows\Temp)..."
    Get-ChildItem -Path "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Concluido!" -ForegroundColor Green

    Write-Host "`Limpando cache de DNS..."
    Clear-DnsClientCache
    Write-Host "   Concluido!" -ForegroundColor Green

    Write-Host "`nAlguns arquivos podem estar sendo utilizados e portanto nao foram excluidos." -ForegroundColor Yellow
}

function Invoke-SystemRepair {
    Clear-Host
    Write-Host "Iniciando a verificacao do sistema. Este processo pode demorar." -ForegroundColor Green
    Pause-Script
    Write-Host "`nVerificando e reparando com SFC..."
    sfc /scannow
    Write-Host "`nVerificando e reparando com DISM..."
    Dism /Online /Cleanup-Image /RestoreHealth
    Write-Host "`nConcluido!" -ForegroundColor Green
}

function Invoke-NetworkOptimization {
    Clear-Host
    Write-Host "Otimizando a rede. Este processo ira redefinir as configuracoes de rede." -ForegroundColor Green
    Write-Host "Recomenda-se reiniciar o computador depois deste processo." -ForegroundColor Yellow
    Pause-Script
    Write-Host "`nRedefinindo o catalogo Winsock..."
    netsh winsock reset
    Write-Host "Redefinindo o stack IP..."
    netsh int ip reset
    Write-Host "Limpando cache de DNS..."
    Clear-DnsClientCache
    Write-Host "`nConcluido!" -ForegroundColor Green
}

function Set-MaxPerformancePlan {
    Clear-Host
    Write-Host "Ativando o plano de energia 'Desempenho Maximo'..." -ForegroundColor Green
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    Write-Host "Concluido!" -ForegroundColor Green
}

function Remove-UserProfiles {
    Clear-Host
    Write-Host @"
==========================================================
       Ferramenta de Exclusao de Perfis de Usuario
==========================================================

Para sair, simplesmente pressione Enter sem digitar nada.
"@
    $userListInput = Read-Host "Digite os nomes dos usuarios a serem removidos (separados por espaco)"

    if ([string]::IsNullOrWhiteSpace($userListInput)) {
        Write-Host "Saindo."
        Start-Sleep -Seconds 1
        return
    }
    
    $users = $userListInput.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)

    Clear-Host
    Write-Host "----------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "Iniciando processo para os usuarios: $users" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------" -ForegroundColor Yellow

    foreach ($user in $users) {
        Write-Host "`nProcessando usuario: $user" -ForegroundColor Cyan
        try {
            $userAccount = Get-CimInstance -ClassName Win32_UserAccount -Filter "Name = '$user'" -ErrorAction Stop
            $sid = $userAccount.SID
            Write-Host "  - SID encontrado: $sid"

            $profile = Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.SID -eq $sid }
            if ($profile) {
                Write-Host "  - Removendo o perfil WMI e o diretorio do usuario..."
                $profile | Remove-CimInstance
            } else {
                 Write-Warning "  - Perfil WMI não encontrado. Tentando remover a pasta manualmente..."
                 $userFolderPath = "C:\Users\$user"
                 if (Test-Path $userFolderPath) {
                    Remove-Item -Path $userFolderPath -Recurse -Force -ErrorAction SilentlyContinue
                 }
            }
            
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid"
            $regPathBak = $regPath + ".bak"
            if (Test-Path $regPath) {
                Write-Host "  - Removendo chave do Registro: $regPath"
                Remove-Item -Path $regPath -Recurse -Force
            }
            if (Test-Path $regPathBak) {
                 Write-Host "  - Removendo chave do Registro: $regPathBak"
                 Remove-Item -Path $regPathBak -Recurse -Force
            }

            Write-Host "  - Removendo a conta de usuario local '$user'..."
            net user $user /delete
            
            Write-Host "  [SUCESSO] Perfil do usuario '$user' foi removido." -ForegroundColor Green

        } catch {
            Write-Warning "  [AVISO] Nao foi possivel processar o usuario '$user'. Ele pode nao existir ou ocorreu um erro: $($_.Exception.Message)"
        }
    }
    Write-Host "`n----------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "Processo finalizado." -ForegroundColor Yellow
}

function Set-PrefetchStatus {
    param(
        [bool]$Enable
    )
    Clear-Host
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
    
    if ($Enable) {
        Write-Host "Habilitando o Prefetch e Superfetch (SysMain)..." -ForegroundColor Green
        Set-ItemProperty -Path $regPath -Name "EnablePrefetcher" -Value 3 -Type DWord -Force
        Set-Service -Name "SysMain" -StartupType Automatic
        Start-Service -Name "SysMain"
        Write-Host "Habilitados!" -ForegroundColor Green
    } else {
        Write-Host "Desabilitando o Prefetch e Superfetch (SysMain)..." -ForegroundColor Green
        Set-ItemProperty -Path $regPath -Name "EnablePrefetcher" -Value 0 -Type DWord -Force
        Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "SysMain" -StartupType Disabled
        Write-Host "Desabilitados!" -ForegroundColor Green
    }
}

function Restart-SpoolerService {
    Clear-Host
    Write-Host "Reiniciando o servico de Spooler de Impressao." -ForegroundColor Green
    Stop-Service -Name Spooler -Force
    Write-Host "Aguardando 5 segundos..."
    Start-Sleep -Seconds 5
    Start-Service -Name Spooler
    Write-Host "Spooler reiniciado." -ForegroundColor Green
}

function Invoke-AllOptimizations {
    param (
        [switch]$WithSystemRepair
    )
    Clear-Host
    Write-Host "Iniciando a otimizacao completa. Este processo pode demorar." -ForegroundColor Green
    Pause-Script
    
    Invoke-TempFileCleanup
    Set-PrefetchStatus -Enable:$false
    Invoke-NetworkOptimization
    Start-Process cleanmgr -ArgumentList "/d C:" -Wait
    Start-Process sysdm.cpl
    Set-MaxPerformancePlan
    
    if ($WithSystemRepair) {
        Invoke-SystemRepair
    }

    Write-Host "`nOtimizacao concluida!" -ForegroundColor Green
    Write-Host "Reinicie seu computador para finalizar todas as alteracoes." -ForegroundColor Yellow
}

function Pause-Script {
    Write-Host "`nPressione qualquer tecla para continuar..." -NoNewline
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    Write-Host
}

while ($true) {
    Show-MainMenu
    $choice = Read-Host "Escolha uma opcao"
    switch ($choice) {
        '1' { Show-OptimizationMenu }
        '2' { Show-PrefetchMenu }
        '3' { Show-PrinterMenu }
        '4' { Remove-UserProfiles; Pause-Script }
        '5' { Invoke-GPUpdate; Pause-Script }
        '6' {
            Clear-Host
            Write-Host "Saindo..."
            Start-Sleep -Seconds 1
            return 
        }
        default {
            Write-Warning "Opcao invalida. Tente novamente."
            Start-Sleep -Seconds 2
        }
    }
}