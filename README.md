Die Datei *[Dockerfile](https://fizban02.rz.tu-harburg.de/Docker/moodle/blob/master/Dockerfile)*
==

- Basis ist Ubuntu 14.04
- Jeder Build des Images aktualisiert das Basis-System auf den neuesten Stand
- Jeder Build des Images aktualisiert Moodle Minor-Branch
  - Für eine neue Major-Version ist die entsprechende `git clone …`-Zeile anzupassen
- Voraussetzungen für SSL werden erfüllt
  - Die notwendigen Dateien liegen im Unterverzeichnis `conf/certs`
- Cron-Jobs werden eingetragen

- Erstellung eines neuen Images mit

        docker build -t local/moodle:latest .

    Der Name des Images `local/moodle:latest` wird in der Datei `docker-compose.yml` verwendet


Die Datei *[docker-compose.yml](https://fizban02.rz.tu-harburg.de/Docker/moodle/blob/master/docker-compose.yml)*
==============================

- Es wird ein laufender Container mit einer *MariaDB*-Installation erwartet
- Der Name dieses Containers lautet im Beispiel `local/moodle:latest`
- Der Host, unter dem dieser Datenbank-Server zu erreichen ist, lautet im Beispiel `db`.
  - Dieser Name wird automatisch im Docker-Container in die Datei `/etc/hosts` eingetragen

Die Datei *[start.sh](https://fizban02.rz.tu-harburg.de/Docker/moodle/blob/master/start.sh)*
==

- Bei jedem Start wird eine Aktualisierung von Moodle durchgeführt


TODOs
==

- Das Root-Verzeichnis könnte angepasst werden, so dass kein Pfad in der URL verwendet werden muss, dazu muss aber auch eine bestehende `config.php` angepasst werden

# Shibboleth
