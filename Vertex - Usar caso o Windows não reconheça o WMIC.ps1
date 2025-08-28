#Requires -RunAsAdministrator
# por Emerson Toneti
# 1.3 21/08/2025

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
 Selecione uma opcao para continuar:

    [1] Menu de otimizacao
    [2] GPupdate
    [3] Menu Prefetch/Superfetch
    [4] Problemas de impressao
    [5] Limpa Perfil

    [6] Sair
============================================================================

"@
}

function Show-OptimizationMenu {
    while ($true) {
        Clear-Host
        Write-Host "===========================================================================" -ForegroundColor Yellow
        Write-Host "                         MENU DE OTIMIZACAO" -ForegroundColor Yellow
        Write-Host "===========================================================================" -ForegroundColor Yellow
        Write-Host @"

    [1] Limpeza de Arquivos Temporarios e Cache
    [2] Verificacao e Reparo de Arquivos do Sistema
    [3] Otimizacao de Rede
    [4] Limpeza de disco
    [5] Plano de energia 'Desempenho Maximo'
    [6] Selecionar plano de Desempenho
    [7] Executar TODAS as otimizacoes em sequencia

    [8] Voltar ao menu principal
===========================================================================

"@
        $choice = Read-Host "Escolha uma opcao"
        switch ($choice) {
            '1' { Invoke-TempFileCleanup; Pause-Script }
            '2' { Invoke-SystemRepair; Pause-Script }
            '3' { Invoke-NetworkOptimization; Pause-Script }
            '4' { Start-Process cleanmgr -ArgumentList "/d C:" -Wait; }
            '5' { Set-MaxPerformancePlan; Pause-Script }
            '6' { Start-Process sysdm.cpl; }
            '7' { Invoke-AllOptimizations; Pause-Script }
            '8' { return }
            default { Write-Warning "Opcao invalida." ; Start-Sleep -Seconds 2 }
        }
    }
}

function Show-PrefetchMenu {
    while ($true) {
        Clear-Host
        Write-Host "===========================================================================" -ForegroundColor Yellow
        Write-Host "                    GERENCIADOR DO PREFETCH/SUPERFETCH" -ForegroundColor Yellow
        Write-Host "===========================================================================" -ForegroundColor Yellow
        Write-Host @"

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
        Write-Host "===========================================================================" -ForegroundColor Yellow
        Write-Host "                    PROBLEMAS COMUNS DE IMPRESSAO" -ForegroundColor Yellow
        Write-Host "===========================================================================" -ForegroundColor Yellow
        Write-Host @"

   [1] Reiniciar o spooler de impressao
   [2] Corrigir erro 0x00000709
   [3] Corrigir erro 0x00000bcb
   [4] Corrigir erro 0x0000011b

   [5] Voltar ao menu principal
===========================================================================

"@
        $choice = Read-Host "Escolha uma opcao"
        switch ($choice) {
            '1' { Restart-SpoolerService; Pause-Script }
            '2' { Resolve-PrinterError -Error '709'; Pause-Script }
            '3' { Resolve-PrinterError -Error '0bcb'; Pause-Script }
            '4' { Resolve-PrinterError -Error '11b'; Pause-Script }
            '5' { return }
            default { Write-Warning "Opcao invalida." ; Start-Sleep -Seconds 2 }
        }
    }
}

function Invoke-GPUpdate {
    Clear-Host
    Write-Host "Atualizando as politicas de grupo..." -ForegroundColor Green
    gpupdate /force
    Write-Host "`Concluido!" -ForegroundColor Green
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

    Write-Host "`Alguns arquivos podem estar sendo utilizados e portanto nao foram excluidos." -ForegroundColor Yellow
}

function Invoke-SystemRepair {
    Clear-Host
    Write-Host "Iniciando a verificacao do sistema. Este processo pode demorar." -ForegroundColor Green
    Pause-Script
    Write-Host "`Verificando e reparando com SFC..."
    sfc /scannow
    Write-Host "`Verificando e reparando com DISM..."
    Dism /Online /Cleanup-Image /RestoreHealth
    Write-Host "`Concluido!" -ForegroundColor Green
}

function Invoke-NetworkOptimization {
    Clear-Host
    Write-Host "Otimizando a rede. Este processo ira redefinir as configuracoes de rede." -ForegroundColor Green
    Write-Host "Recomenda-se reiniciar o computador depois deste processo." -ForegroundColor Yellow
    Pause-Script
    Write-Host "`Redefinindo o catalogo Winsock..."
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

#Script do limpa perfil criado originalnamente por Marcelo Esteves
function Remove-CorruptUserProfile {
    Clear-Host
    $username = Read-Host "Digite o nome de usuario do perfil a ser removido"
    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Warning "Nome de usuario nao pode ser vazio. Voltando ao menu."
        Start-Sleep -Seconds 3
        return
    }

    try {
        Write-Host "Procurando perfil para o usuario '$username'..."
        $profile = Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.LocalPath -eq "C:\Users\$username" }

        if ($profile) {
            Write-Host "Perfil encontrado. Removendo..." -ForegroundColor Yellow
            $profile | Remove-CimInstance
            Write-Host "Perfil WMI removido com sucesso." -ForegroundColor Green
        } else {
            Write-Warning "Nenhum perfil WMI encontrado para C:\\Users\\$username. Tentando remover a pasta e chaves de registro manualmente."
        }

        $userAccount = Get-CimInstance -ClassName Win32_UserAccount -Filter "Name = '$username'"
        if ($userAccount) {
            $sid = $userAccount.SID
            Write-Host "SID do usuario encontrado: $sid"
            $regPaths = @(
                "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid",
                "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($sid).bak",
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\$sid",
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\$sid",
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Status\$sid",
                "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Group Policy\State\$sid",
                "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Group Policy\Status\$sid"
            )

            foreach ($path in $regPaths) {
                if (Test-Path $path) {
                    Write-Host "Removendo chave de registro: $path"
                    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "Limpeza de registro concluida." -ForegroundColor Green
        }

        $userFolderPath = "C:\Users\$username"
        if (Test-Path $userFolderPath) {
            Write-Host "Removendo a pasta do perfil: $userFolderPath" -ForegroundColor Yellow
            Remove-Item -Path $userFolderPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Pasta do perfil removida." -ForegroundColor Green
        }
        
        Write-Host "`Processo de limpeza para o usuario '$username' finalizado." -ForegroundColor Green
    }
    catch {
        Write-Error "Ocorreu um erro durante a remocao do perfil: $($_.Exception.Message)"
    }
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
    Start-Sleep -Seconds 5
    Start-Service -Name Spooler
    Write-Host "Spooler reiniciado." -ForegroundColor Green
}

function Resolve-PrinterError {
    param(
        [string]$Error
    )
    Clear-Host
    try {
        switch ($Error) {
            '11b' {
                $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Print"
                $name = "RpcAuthnLevelPrivacyEnabled"
                $value = 0
                Write-Host "Corrigindo erro 0x0000011b..."
            }
            '0bcb' {
                $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"
                $name = "RestrictDriverInstallationToAdministrators"
                $value = 0
                Write-Host "Corrigindo erro 0x00000bcb..."
            }
            '709' {
                $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC"
                $name = "RpcUseNamedPipeProtocol"
                $value = 1
                Write-Host "Corrigindo erro 0x00000709..."
            }
        }
        
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        Set-ItemProperty -Path $path -Name $name -Value $value -Type DWord -Force
        Write-Host "Correcao aplicada com sucesso!" -ForegroundColor Green
    }
    catch {
        Write-Error "Falha ao aplicar correcao: $($_.Exception.Message)"
    }
}

function Invoke-AllOptimizations {
    Clear-Host
    Write-Host "Iniciando a otimizacao completa. Este processo pode demorar." -ForegroundColor Green
    Pause-Script
    
    Invoke-TempFileCleanup
    Set-PrefetchStatus -Enable:$false
    Invoke-NetworkOptimization
    Start-Process cleanmgr -ArgumentList "/d C:" -Wait
    Start-Process sysdm.cpl -Wait
    Set-MaxPerformancePlan
    Invoke-SystemRepair

    Write-Host "`Otimizacao concluida!" -ForegroundColor Green
    Write-Host "Reinicie seu computador para finalizar todas as alteracoes." -ForegroundColor Yellow
}

function Pause-Script {
    Write-Host "`Pressione qualquer tecla para continuar..." -NoNewline
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    Write-Host
}

while ($true) {
    Show-MainMenu
    $choice = Read-Host "Escolha uma opcao"
    switch ($choice) {
        '1' { Show-OptimizationMenu }
        '2' { Invoke-GPUpdate; Pause-Script }
        '3' { Show-PrefetchMenu }
        '4' { Show-PrinterMenu }
        '5' { Remove-CorruptUserProfile; Pause-Script }
        '6' {
            Clear-Host
            Start-Sleep -Seconds 3
            return
        }
        default {
            Write-Warning "Opcao invalida. Tente novamente."
            Start-Sleep -Seconds 2
        }
    }
}