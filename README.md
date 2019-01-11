# CustomPush
Custom Push Notifications for Sonarr and Radarr

## What is this?
I have been looking for a way to customise the push notifications I receive from Sonarr and Radarr to make things easier at a glance. I didn't like "Radarr - Movie Downloaded" or "Sonarr - Episode Downloaded" and other services would tell me which episode/movie was actually completed.

When I found multiple requests for the ability to customise this and no simple solution I decided to make my own.

I didn't want to use any add-ins if possible and wanted something I could run on Windows or Linux as I occasionally move my installs around. I found a great script on the Sonarr.TV forum by bobbintb and used that to create everything in Powershell for Sonarr. Once I had it working I modified the script to work for Radarr and posted it online for everyone to share.

## Requirements
Unfortunately I wasn't able to parse JSON in bash alone so if you run Linux or Mac OS you will need to install jq from here: [https://stedolan.github.io/jq/](https://stedolan.github.io/jq/)

I realise I could have used Python as most Mac/Linux users should have this installed but I don't really know Python that well and the PowerShell scripts translated to Bash quite easily.

## Usage
### Windows
Follow the below steps replacing the relevant folder/file names

1. In Sonarr/Radarr go to **Settings > Connect > +**
2. Choose **Custom Script**
3. Check **On Download** and **On Upgrade**
4. Path: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
5. Arguments: `-ExecutionPolicy ByPass -File C:\Users\User\Sonarr\PushBullet.ps1` *Use the location where you saved the relevant .ps1 script*
6. Test/Save

### Linux
Follow the below steps replacing the relevant folder/file names

0. Run chmod +x on the PushBullet.sh scripts (or set them to be Executable in the properties)
1. In Sonarr/Radarr go to **Settings > Connect > +**
2. Choose **Custom Script**
3. Check **On Download** and **On Upgrade**
4. Path: `\home\user\Sonarr\PushBullet.sh` *Use the location where you saved the relevant .sh script*
5. Arguments: *Leave blank*
6. Test/Save

### Mac OS
I have not been able to test this on a Mac but I understand it should work the same as the Linux shell script above. If anyone is able to test this and provide feedback that would be greatly appreciated.

## Credits
[bobbintb](https://forums.sonarr.tv/u/bobbintb) - His original email and SMS notification script is what inspired this and was used/modified for my scripts. [https://forums.sonarr.tv/t/custom-email-and-sms-notifications/14401](https://forums.sonarr.tv/t/custom-email-and-sms-notifications/14401)

Also a big thanks to the Sonarr and Radarr teams for their great products, well documented API's and sample scripts.

## What's Next? Something Broke! I did a thing!
- I'm going to try and make a BoxCar script as well as I found a couple of requests for this as well.
- If you found an issue and can't fix it yourself, please log an issue in GitHub and I will try to fix it for you.
- If you found an issue and fixed it yourself or want to contribute some code, please send a pull request and I will try to include it.