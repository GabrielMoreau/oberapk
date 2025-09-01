# Oberapk - Automated Debian packages download, modification and upload to a local Reprepro repository

Oberapk is a tool to automate the uploading of Debian packages
to a local [Reprepro](https://wiki.debian.org/DebianRepository/SetupWithReprepro) repository.
The goal is to simplify the provision of software on a local park
without having them fetch the packages on remote sites.
For each package, there is a specific recipe to get the latest version,
if any, and then push it to the right Debian distribution(s)
that your [Reprepro](https://wiki.debian.org/DebianRepository/SetupWithReprepro)
instance manages locally.

It is however possible to slightly modify the package during the recipe,
or to build very simple packages in which the programs are written
in scripting languages that do not need to be compiled
or complex build steps.
Oberapk is therefore not a copy or reimplementation of the mirroring protocol
built into [Reprepro](https://wiki.debian.org/DebianRepository/SetupWithReprepro).

A short [manual](https://legi.gricad-pages.univ-grenoble-alpes.fr/soft/trokata/oberapk/)
is available online, which is a copy of the command line manual.
However, most of the information is also listed below.

The master Git repository in on the [GRICAD Gitlab](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/oberapk).
Other Git repository are mirror or fork.

## Download / Ready-made package

Up-to-date Debian packages can be found at
https://legi.gricad-pages.univ-grenoble-alpes.fr/soft/trokata/oberapk/download/

Please note that the Debian packages are very simple
and certainly do not check all the Debian Policy rules and quality.
They are however functional and in production at LEGI.

## Description

For 36 reasons, you need to retrieve already working binary packages,
and you also need a local cache for all the computers in your fleet.
Oberapk is made to help you manage this task, here are some reasons.

* You have configured the computers in your fleet to fetch packages
  from your local apt repository.

* It is easier with your asset management tool to push software
  to a workstation if it is available in your repository.

* You need teams or zoom or any other software of this type,
  but you don't want the computers in your park to go
  and get them directly from the manufacturers.

* You develop user tools and system tools and you want
  to deploy them via your apt repository.

Oberapk allows you via a programmed task (cron) to update the packages
in `.deb` format locally on a computer,
then to push them into your apt repository via the reprepro tool.
Indeed, for the moment, Oberapk only works with the reprepro service.

Please note that Oberapk is not a tool for making packages
(unless they are really simple without compiling or downloading
any additional files).
It simply allows you to retrieve packages automatically
and push them to your local repository.

In order to distinguish a package from its recipe, in Oberapk,
the recipes are called `packaging`.
A set of recipes to apply will be called `kit`.

 | Breton | Français  | English   |
 |--------|-----------|-----------|
 | ober   | contruire | make      |
 | pakaj  | emballage | packaging |
 | stroll | ensemble  | kit       |

Some programs may be difficult to automate: impossible to download from
the Internet, complex compilation, etc. This is outside oberapk's weekly
scope. However, recipes are given in the [annex.d](./annex.d) files for
scripts to help build this type of package. Perhaps one day automation
will be possible and carried out if it proves useful and necessary.

## Packaging list

This list is updated manually from time to time.
An always up to date list is to look at the files available
in the folder [pakaj.d](pakaj.d/):

* [apptainer](https://github.com/apptainer/apptainer) [apptainer apptainer-suid],
  [atom](https://github.com/atom/atom);
* [backuppc-silzigan](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/backuppc-silizan),
  [bidiez](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/bidiez);
* [certcheck](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/certcheck),
  [chrome](https://www.google.com/chrome/);
* [ddt](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ddt),
  [discord](https://discord.com/),
  [drawio](https://app.diagrams.net/);
* [eduvpn](https://www.eduvpn.org) [eduvpn-client eduvpn-client-data libeduvpn-common libeduvpn-common-dbgsym python3-eduvpn-client python3-eduvpn-common],
  [espanso](https://espanso.org);
* [ferdium](https://ferdium.org/),
  [firefox-latest](https://www.mozilla.org/),
  [firefox](https://www.mozilla.org/) [firefox firefox-l10n-fr],
  [freskein](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/freskein),
  [f-secure](https://www.withsecure.com/en/support/product-support/business-suite/policy-manager) [f-secure-policy-manager-console f-secure-policy-manager-proxy f-secure-policy-manager-server];
* [ganttproject](https://github.com/bardsoftware/ganttproject),
  [gestex-ng](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/gestex),
  [gestex](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/gestex),
  [grv](https://github.com/rgburke/grv);
* [ht3ctl](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ht3ctl);
* [icaclient](https://www.citrix.com/) [icaclient ctxusb];
* [jitsi](https://desktop.jitsi.org/) [jitsi],
  [julia](https://julialang.org) [julia-lts];
* [kannad](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/kannad),
  [klask](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/klask),
  [kopia](https://github.com/kopia/kopia) [kopia kopia-ui];
* [libpng12](http://libpng.org/pub/png/libpng.html) [libpng12-1];
* [masterpdf](https://code-industry.net/free-pdf-editor/),
  [modular](https://www.modular.com/);
* [nagios-velvice](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/nagios-velvice),
  [netdata](https://github.com/netdata/netdata),
  [nodejs](https://stackoverflow.com/questions/48943416/bash-npm-command-not-found-in-debian-9-3);
* [oberapk](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/oberapk),
  [onlyoffice](https://www.onlyoffice.com/desktop.aspx) [onlyoffice-desktopeditors],
  [openfoam](https://openfoam.com) [openfoam openfoam-common openfoam-default openfoam-dev openfoam-source openfoam-tools openfoam-tutorials],
  [opensnitch](https://github.com/evilsocket/opensnitch/) [opensnitch python3-opensnitch-ui];
* [powershell](https://microsoft.com/powershell),
  [project-meta](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/project-meta),
  [protonmail](https://proton.me) [protonmail-bridge];
* [qgis](http://qgis.org/) [libqgis python-qgis python3-qgis qgis],
  [quarto](https://github.com/quarto-dev/quarto-cli);
* [reaction](https://framagit.org/ppom),
  [rstudio](https://www.rstudio.com/);
* [signal](https://signal.org/) [signal-desktop],
  [skype](https://www.skype.com/) [skypeforlinux] (obsolete since 2025/05),
  [slack](https://slack.com/intl/fr-fr/downloads/linux) [slack-desktop],
  [spideroak](https://spideroak.com/) [spideroakone];
* [tabby](https://tabby.sh/) [tabby-terminal],
  [teams](https://teams.com/),
  [teamviewer](https://www.teamviewer.com/),
  [tixeoclient](https://www.tixeo.com/),
  [tssh](https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/tssh);
* [udsclient3](http://www.udsenterprise.com);
* [veracrypt](https://www.veracrypt.fr/) [veracrypt veracrypt-console],
  [virtualbox](https://www.virtualbox.org/wiki/Linux_Downloads),
  [vscode](https://github.com/microsoft/vscode) [code code-insiders],
  [codium](https://github.com/VSCodium/vscodium);
* [webex](https://www.webex.com/downloads.html);
* [xnview](https://www.xnview.com),
  [xpipe](https://xpipe.io);
* [yadedaily](https://yade-dem.org/) [yadedaily python3-yadedaily libyadedaily],
  [yed](https://www.yworks.com/products/yed) [yed-latest],
  [yq](https://github.com/mikefarah/yq);
* [zoom](https://zoom.us/),
  [zotero](https://www.zotero.org/).

## Schematic diagram of how it works

```mermaid
graph LR;
  subgraph Internet software repository
    idsx[Soft-XYZ]
    idsl[Soft-LMN]
    idsi[...]
    idso[Soft-Oberapk]
  end

  subgraph Oberapk service
    ids>Server]
    idc[Conf - pkg/dists]

    ido((Oberapk))
    
    idmx(Pakaj Soft-XYZ)
    idml(Pakaj Soft-LMN)
    idmi(Pakaj ...)
    idmo(Pakaj Soft-Oberapk)
  end

  subgraph APT web service
    idr[(Local Reprepro)]
  end

  idclient1>Computer 1]
  idclient2>Computer 2]

  idsx -. wget .-> idmx
  idsl -. wget .-> idml
  idsi -. wget .-> idmi
  idso -. wget .-> idmo

  ids -- daily cron --> ido
  ids -- apt-get / auto update --> idr

  idc -- choice pkg --> ido

  ido --> idmx
  ido --> idml
  ido --> idmi
  ido --> idmo

  idmx -- rebuild deb --> idmx
  idml -- rebuild deb --> idml
  idmi -- rebuild deb --> idmi
  idmo -- rebuild deb --> idmo

  idmx -. push .-> idr
  idml -. push .-> idr
  idmi -. push .-> idr
  idmo -. push .-> idr

  idclient1 -- apt-get --> idr
  idclient2 -- apt-get --> idr
```

## Commands

```bash
oberapk help
oberapk avail
oberapk list
oberapk kit
oberapk update pkg
oberapk upgrade kit
oberapk pushed pkg
oberapk remove pkg | bash
oberapk source pkg
oberapk binaries
oberapk version
```

* The `avail` command allows you to know all the available packaging
  in the Oberapk distribution.

* The `list` command allows you to know all the configure packaging
  defined  in your configuration file..

* The `kit` command lets you know the packaging set
  defined in your configuration file.

* The `update` command is used to start a recipe, and thus ultimately
  to update the packages that this packaging manages.
  The `pkg` packaging must be defined in your configuration file.

* The `upgrade` command allows to apply all the packaging defined
  by a `kit`.
  If a kit with the name `all` exists on your installation, then you can
  update with a single command the software of your local repository
  which are managed by Oberapk.
  The `kit` must be defined in your configuration file.

* The `pushed` command lists all versions of the packages in this
  packaging that are already in the Reprepro package manager.
  These are the packages that are in practice available to end users
  The `pkg` packaging must be defined in your configuration file.

* The `remove` command remove the last version of the package in the
  Reprepro package manager.
  It is then possible to push it again via the `update` command.
  In a normal life, you do not need to use this command.
  The `pkg` packaging must be defined in your configuration file.

  For security reasons, the command does not take any direct action.
  You have to pipe to bash the output of the command to really remove the
  package from the Reprepro package manager.

* The `source` command is for developers.
  It allows to test a new recipe.
  It allows to set the global variables useful for the bash function. 
  The `pkg` here is a packaging defined in the oberpak distribution
  (see the `avail` command).
  It is not only a packaging declared in your configuration file.

* The `binaries` command is for developers.
  It allows to list all the commands that have been used
  in the other recipes.
  It is preferable if possible to restrict yourself to these commands
  in order not to add any additional dependency to Oberapk. 

### Configuration files

There are two configuration files.
They can be under `/etc/oberapk` folder or under `$HOME/.local/oberapk`.

* The `oberapk.conf` file describes the local configuration of your site.
  It indicates which kits are available and which packages can be
  applied to which versions of the distribution (based on the
  distribution name).
  In this way, each site has the choice of pushing the packages it
  wants onto its local Reprepro repository and only onto the
  distribution version(s) it needs.
  Please note that the recipes will certainly not work on all
  distributions.
  Oberapk is intended to be a simple tool for managing a reasonable
  number of machines.
  Not all cases are taken into account.

  ```
  @all: @free @non-free
  @free: grv codium nodejs
  @non-free: discord teams teamviewer
  
  @daily: @free teams
  @weekly: teamviewer
  
  grv:4:        bullseye buster stretch
  codium:3:     bullseye buster
  nodejs:3:              buster stretch
  discord:2:             buster
  teams:2:      bullseye buster
  teamviewer:2: bullseye buster stretch
  ```

  For packaging, the second parameter is the number of old package
  to kept each time a new one is uploaded.
  If the new package is not functional,
  it is always possible to manually push one of the old versions
  to your local reprepo repository.

* `oberapk.sh` is a file in Bash format which defines
  the global variables.

  ```
  #CONF_FILE=/etc/oberapk/oberapk.conf
  #PAKAJ_FOLDER=/usr/share/oberapk/pakaj.d
  REPREPRO=/var/www/debian
  RUN_USER=lambda
  ```

### Usage

A simple usage is to upgrade all the packaging.
```bash
oberapk upgrade all
```

It's possible to just run just a packaging, for example `grv`.
```bash
oberapk update grv
```

If there is a problem in a kit, you can more easily tell which package
it is in by filtering the output a bit.
```bash
oberapk upgrade all 2>&1 | egrep -i '(error|info:)'
```

Upgrade quickly your own Oberapk version on your server
```bash
oberapk update oberapk; sudo apt update; sudo apt upgrade
```

### Cron job

One cron job is placed in the daily folder
and another in the weekly cron folder.
These tasks do not run as root, but switch to the `RUN_USER` account,
if and only if you have defined it.
These tasks run the daily and weekly kits,
so consider if you need to define `@daily` and `@weekly`
in your configuration file,
along with the associated software you want to update.

You can also define your own `/etc/cron.d/oberapk` file in the cron
folder which will update a set of packages (`kit`) you want,
at a time you want...
It is then up to you to define it because the predefined cron files
(daily and weekly...) are launched at a time fixed
by your system configuration.
Beware, Oberapk should never and refuses to be launched
by the user `root` (here `lambda`).
```
9:33 23 * * *  lambda  test -x $(which oberapk) && oberapk upgrade all 2>&1 | logger -t oberapk
```
It may not be a good idea to run it under the `www-data` account.
However, Apache (or Nginx) must have access to the folders
where Reprepro stores the packages that Oberapk pushes.

In case your repository is signed, which is better,
either you manually push the updates by doing an `oberapk upgrade all`
regularly in order to put the passphrase of the key,
or you have a key without passphrase as it is sometimes done
for SSH keys (which is dangerous),
or you have a GPG agent which keeps in RAM the passphrase
that you manually enter shortly after each reboot.

## Repository / Contribute

### Source

The whole code is under **free license**.
The script in ```bash``` is under GPL version 2 or more recent (http://www.gnu.org/licenses/gpl.html).
All the source code is available on the forge of the Grenoble campus:
https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/oberapk
The sources are managed via Git (GitLab).
It is very easy to stay synchronized with these sources.

* The initial recovery
  ```bash
  git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/oberapk
  ```
* The updates afterwards
  ```bash
  git pull
  ```
* Contribute.
  It is possible to contribute by proposing pull requests,
  merge requests or simply old fashioned patches.

### Patch

It is possible to have a writing access to the project on the forge
on motivated request to [Gabriel Moreau](mailto:Gabriel.Moreau@univ-grenoble-alpes.fr).
For questions of administration time and security,
the project is not directly accessible in writing without authorization.
For questions of decentralization of the web, of autonomy
and non-allegiance to the ambient (and North American) centralism,
we use the forge of the university campus of Grenoble...

You can propose a patch by email of a particular file via the ```diff``` command:
```bash
diff -u oberapk.org oberapk.new > oberapk.patch
```
The patch is applied (after reading and rereading it) via the command:
```bash
patch -p0 < oberapk.patch
```

## COPYRIGHT

Copyright (C) 2017-2025, LEGI UMR 5519 / CNRS UGA G-INP, Grenoble, France

This project was originally written by
[Gabriel Moreau](mailto:Gabriel.Moreau@univ-grenoble-alpes.fr).

Licence: [GNU GPL version 2 or later](https://spdx.org/licenses/GPL-2.0-or-later.html)
