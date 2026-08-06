# Homelab Infrastructure Planning

Read this entire document carefully before making any changes.

Do **not** start implementing anything immediately. Your first task is to fully understand the desired architecture. If any requirement is unclear, ask questions instead of making assumptions.

Once you understand everything:

1. Ask any clarification questions.
    
2. After all questions are answered, create a clean specification in `~/nixos/inputs` for GLM 5.2.
    
3. I will review that specification.
    
4. After any requested changes, GLM 5.2 will generate an implementation plan.
    
5. I will review that plan.
    
6. After any requested changes, DeepSeek V4 Pro will implement it.
    
7. If anything breaks afterwards, we'll troubleshoot it together.
    

Never invent requirements that are not explicitly stated.

---

# General Notes

## Profile Page

Currently:

- `https://profile.nanulab.de` redirects to `https://profile.nanulab.de/wg`
    
- The certificate is now provided by Let's Encrypt.
    

Desired behavior:

Instead of redirecting everyone to `/wg`, users should access their own page:

- `/dumitru`
    
- `/iza`
    
- `/adela`
    
- etc.
    

---

# AdGuard

## Current behavior

`https://adguard.nanulab.de/` is accessible both with and without the VPN.

## Desired behavior

The AdGuard **Web UI** should only be accessible through the **Admin VPN**.

Users on the LAN should still be able to use AdGuard as their DNS server, but they must **not** be able to access the administration interface.

The same rule applies to every administrative Web UI used for maintaining the homelab.

---

# Client Naming

Do **not** use device names as client identifiers.

Instead use:

- `dumitru-phone`
    
- `dumitru-pc`
    
- `adela-tv`
    

etc.

The IP address is sufficient for DHCP/static lease purposes.

MAC addresses for Iza, Kerem and Hannah are currently missing and will be added later.

---

# DHCP / Addressing

The DHCP static lease list is currently empty.

Whether static leases should be generated is left to your judgement.

Current IP layout:

## Infrastructure

- 10.0.0.1 → Router
    
- 127.0.0.1
    
- fe80::1
    
- 10.0.0.2 → Homelab / Dell
    
- 127.0.0.2
    
- ::1 (unsure, treat this only as information)
    
- 10.0.0.3–10.0.0.7 reserved for future servers or macvlan Docker containers if they are ever used.
    

## Users

### Dumitru (Admin)

- 10.0.0.8 → iPhone17Pro
    
- 10.0.1.8 → iPhone17Pro VPN
    
- 10.0.0.9 → Arch PC
    
- 10.0.1.9 → Arch PC VPN
    

### Adela

- 10.0.0.10 → iPhoneXS
    
- 10.0.1.10 → VPN
    
- 10.0.0.11 → Samsung TV
    
- 10.0.1.11 → VPN
    
- 10.0.0.12 → Philips Air Purifier
    
- 10.0.1.12 → VPN
    

### Tiberiu

- 10.0.0.13
    
- 10.0.1.13
    

### David

- 10.0.0.14
    
- 10.0.1.14
    
- 10.0.0.15 → Xbox
    
- 10.0.1.15 → VPN
    

### Ramona

- 10.0.0.16
    
- 10.0.1.16
    

### Tibisor

- 10.0.0.17
    
- 10.0.1.17
    

### Iza

- 10.0.0.18
    
- 10.0.1.18
    

### Kerem

- 10.0.0.19
    
- 10.0.1.19
    

### Hannah

- 10.0.0.20
    
- 10.0.1.20
    

### Guests

Addresses `10.0.0.21` through `10.0.0.250` are reserved for guests.

Guests:

- receive no VPN configuration
    
- are not persistent WireGuard clients
    
- can access the LAN
    
- can use the same services that regular users can access while connected to the LAN
    

---

# VPN Design

There is **one WireGuard server**.

It provides **two access levels**, not two separate servers.

## Admin VPN

Used only by me.

This VPN can access **every internal service** hosted under `*.nanulab.de`.

This includes all administration interfaces.

## User VPN

Used by normal users.

This VPN only provides access to the services intended for end users.

Users must **not** have access to administration interfaces or backend services.

---

# Service Accessibility

General rule:

Every service hosted under:

`https://*.nanulab.de`

is private.

A service may be accessible by:

- LAN
    
- Admin VPN
    
- User VPN
    

depending on its purpose.

Everything under:

`dnanu.de`

is public.

The only public service currently planned is:

- `mail.dnanu.de`
    

`mail.nanulab.de` is **not** public.

It is only the administration interface for the mail system.

---

# User Accessible Services

Regular users (LAN or User VPN) may access:

- `photos.nanulab.de` → Immich
    
- `vault.nanulab.de` → Vaultwarden
    
- `home.nanulab.de` → Home Assistant
    
- `music.nanulab.de` → Navidrome
    
- `requests1.nanulab.de`
    
- `media.nanulab.de` → Jellyfin
    
- `requests2.nanulab.de`
    
- `audio.nanulab.de` → Audiobookshelf
    
- `requests3.nanulab.de`
    
- `books.nanulab.de` → Booklore
    
- `requests4.nanulab.de`
    

The `requests*` domains are placeholders.

Do **not** rename them yourself. Another AI agent will decide on better names later.

---

# Admin Accessible Services

The Admin VPN additionally has access to:

- cloud.nanulab.de
    
- status.nanulab.de
    
- adguard.nanulab.de
    
- nginx.nanulab.de
    
- mail.nanulab.de
    
- wg.nanulab.de
    
- ddns.nanulab.de
    
- cloudflare.nanulab.de
    
- restic.nanulab.de
    
- hugo.nanulab.de
    

Media backend services:

Music:

- Lidarr
    

Movies:

- Radarr
    
- Sonarr
    

Books:

- Readarr
    

Indexer / Download stack:

- Prowlarr
    
- qBittorrent
    
- slskd
    
- SABnzbd
    

Future audiobook ARR application:

- TODO
    

Users should only consume media.

Only the administrator should manage and configure the backend.

---

# Additional Notes

- Nextcloud Office replaces Collabora.
    
- Beets has been removed.
    
- Bazarr has been removed.
    
- All services are implemented as native NixOS modules except Booklore.
    
- Some listed services may not expose a Web UI (for example ddclient). Those entries simply describe intended ownership and access rules.
    

---

# Important

If any requirement conflicts with another requirement, ask before deciding.

If anything is ambiguous, ask.

Do not silently choose an implementation.

Your first goal is to understand the desired architecture, not to write code.

`https://profile.nanulab.de` redirects to `https://profile.nanulab.de/wg`, and is now encrypted by let's encrypt (nice), shoul we maybe do /[user] ?
# AdGuard
- Current behaviour: `https://adguard.nanulab.de/` is accessible with VPN and without
- Expected behaviour: `https://adguard.nanulab.de/` should only be accesible with the VPN for the admin
- DHCP static lease is empty.
- don't put client names in identifiers of clients, the IP adress is enough!
- Guests don't need a VPN and don't need to be set in persistent client
	- 10.0.0.1, 127.0.0.1, fe80::1 -> Router
	- 10.0.0.2, 127.0.0.2, ::1 -> Homelab, Dell
	- 10.0.0.3 - 10.0.0.7 -> Resevered for other servers or macvlan docker containers if I decide to run those
		- Note, unsure if ::1 belongs to Homelab
	- Dumitru (Admin)
		- 10.0.0.8 (iPhone17Pro), 10.0.1.8 (iPhone17ProVPN)
		- 10.0.0.9 (arch), 10.0.1.9 (archVPN) 
	- Adela (Regular User)
		- 10.0.0.10 (iPhoneXS), 10.0.1.10 (iPhoneXSVPN)
		- 10.0.0.11 (SamsungTV), 10.0.1.11 (SamsungTVVPN) 
		- 10.0.0.12 (PhillipsAir), 10.0.1.12 (PhillipsAirVPN)
	- Tiberiu (Regular User)
		- 10.0.0.13 (GalaxyS22U), 10.0.1.13 (GalaxyS22UVPN)
	- David (Regular User)
		- 10.0.0.14 (iPhone17ProMax), 10.0.1.14 (iPhone17ProMaxVPN)
		- 10.0.0.15 (XboxOne), 10.0.1.15 (XboxOneVPN)
	- Ramona (Regular User)
		- 10.0.0.16 (iPhone11), 10.0.1.16 (iPhone11VPN)
	- Tibisor (Regular User)
		- 10.0.0.17 (iPhone14), 10.0.1.17 (iPhone14VPN)
	- Iza (Regular User)
		- 10.0.0.18 (iPhone15), 10.0.1.18 (iPhone15VPN)
	- Kerem (Regular User)
		- 10.0.0.19 (iPhone16Pro), 10.0.1.19 (iPhone16ProVPN)
	- Hannah (Regular User)
		- 10.0.0.20 (iPhone15Pro), 10.0.1.20 (iPhone15ProVPN)
	- And everything else from 21-250 are guests.
		- Note: Maybe using the phone names as the identifiers is a bad idea... maybe just names and then the device something like [user]-[device], for example dumitru-pc or dumitru-phone, Yeah I like this a lot better, you don't have MAC Adresses for Iza, Kerem and Hannah but I'll provide you those later.
# Services accessiblity
- Basic rule of thumb: services hosted at `https://*.nanulab.de` should only be accessible on the VPN, there should be two types of VPN's, one for me (the admin) that can access everything at `https://*.nanulab.de` 
	- And one VPN for regular users that can access the media stack.
		- Services accessible for regular users:
			- `https://photos.nanulab.de` -> Immich
			- `https://vault.nanulab.de` -> Vaultwarden
			- `https://home.nanulab.de` -> HomeAssistant
			- `https://music.nanulab.de` -> Navidrome
			- `https://requests1.nanulab.de` -> navidrome requests
			- `https://media.nanulab.de` -> Jellyfin
			- `https://requests2.nanulab.de` -> jellyfin requests
			- `https://audio.nanulab.de` -> AudioBookShelf
			- `https://requests3.nanulab.de` -> ABS requests
			- `https://books.nanulab.de` -> Booklore
			- `https://requests4.nanulab.de` -> Booklore requests
			- Normal users -> Booklore requests
				- If you have better names for the request pages please change. `https://requests[number].nanulab.de` is a placeholder for now
		- Services accessible for admin user (me):
			- `https://photos.nanulab.de` -> Immich
			- `https://vault.nanulab.de` -> Vaultwarden
			- `https://home.nanulab.de` -> HomeAssistant
			- `https://cloud.nanulab.de` -> Nextcloud
				- dropped collabora since Nextcloud provides us with Nextcloud office
			- `https://status.nanulab.de` -> Beszl
				- Is this needed? we don't run any docker containers.
			- `https://adguard.nanulab.de` -> Adguard Home
			- `https://nginx.nanulab.de` -> Nginx
			- `https://mail.nanulab.de` -> SNM
			- `https://wg.nanulab.de` -> Wireguard
			- `https://ddns.nanulab.de` -> ddclient
			- `https://cloudflare.nanulab.de` -> Cloudflared
			- `https://restic.nanulab.de` -> Restic
			- `https://hugo.nanulab.de` -> Hugo
			- Media Server
				- Music Server
					- `https://music.nanulab.de` -> Navidrome
					- `https://requests1.nanulab.de` -> requests
					- `https://lidarr.nanulab.de` -> Lidarr
						- we are dropping beets
				- Movies & Shows Server
					- `https://media.nanulab.de` -> Jellyfin
					- `https://requests2.nanulab.de` -> requests
					- `https://radarr.nanulab.de` -> Radarr
					- `https://sonarr.nanulab.de` -> Sonarr
						- dropping bazarr
				- AudioBooks and Podcasts Server
					- `https://audio.nanulab.de` -> ABS
					- `https://requests3.nanulab.de` -> requests
					- `https://[arr].nanulab.de` -> arr for AudioBooks and Podcasts (need to find, add to TODO.md)
				- Books Server
					- `https://books.nanulab.de` -> Booklore
					- `https://requests4.nanulab.de` -> requests
					- `https://readarr.nanulab.de` -> Readarr
				- Media Server backend
					- `vpn.nanulab.de` -> VPN confinment
						- `https://prowlarr.nanulab.de` -> Indexer
							- `https://torrent.nanulab.de` -> qBittorrent
							- `https://soulseek.nanulab.de` -> slskd
							- `https://usenet.nanulab.de` -> SABnzbd
		- Note: of course only if these services provie a webUI, i don't think nginx or ddclient has one, this is just a example so you get what I mean.
		- Note: Basic rule, normal users access and use the services, admin can configure them.
		- Note: mail.dnanu.de is public (must be)

Read this whole banana of things and then ask me some questions, afterwards we will cook something in ~/nixos/inputs for GLM5.2 to read, after that I review it and you make changes to it if needed, we feed it into GLM5.2, it creates a plan, I review it and you make changes to it if needed and then we feed it into DeepSeek V4 Pro and from there we trouble shoot it if something happens, understood?