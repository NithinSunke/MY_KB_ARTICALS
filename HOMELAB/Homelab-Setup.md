install windows 10 using vintoy bootable usb
update os to latest version apply all the patches
set the static ip
install vmware workstation
install proxmox vm
configure pangolin tunnel
access resources using domain names publically








pangolin access run in powershell

curl -o newt.exe -L "https://github.com/fosrl/newt/releases/download/1.2.1/newt_windows_amd64.exe"
newt.exe --id v4jmg7ovvzba3tp --secret sccih6hh0jeasii7ziwelt34n1eojyh6x16ixg2mbdjh1knb --endpoint https://pangolin.scslabs.xyz


Start-Job -ScriptBlock {
    & "C:\newt\newt.exe" --id v4jmg7ovvzba3tp --secret sccih6hh0jeasii7ziwelt34n1eojyh6x16ixg2mbdjh1knb --endpoint https://pangolin.scslabs.xyz
}

