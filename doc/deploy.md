# Déploiement de StudioPaon

Ce document récapitule les prérequis et étapes nécessaires au déploiement 
de l'application StudioPaon serveur sous la forme d'un exemple de déploiement
de l'application sous Debian 11, et accessible sous le nom de domaine 
`test.studio-paon.fr`

Attention : les données suivantes sont définis à la compilation de l'application 
dans ScBuilder et doivent être connus pour le déploiement

- `webapp.work.dir` : répertoire des fichiers de travail de l'application
- `webapp.logs.dir` : répertoire des journaux de l'application
- `webapp.code` : code de l'application (utilisé pour nommer le war)
- `app.ext.es.host` : adresse du serveur ElasticSearch


## Openjdk Java 11 JRE

- `apt install -y openjdk-11-jre-headless`

## Polices

- `apt install --no-install-recommends -y fonts-noto fonts-noto-cjk fonts-noto-unhinted fonts-noto-color-emoji fonts-noto-ui-core fonts-noto-mono fonts-liberation fontconfig`

## Jetty9

- `apt install -y jetty9`
  
### Configurations

Création des dossiers selon propriétés définis à la compilation de l’application Scenari/StudioPaon
(Définissez les variables correspondantes ou remplacer les par les valeurs définit dans ScBuilder)
- Pour le chemin définit dans la propriété `webapp.work.dir` (transférée dans une variable `webapp_work_dir`) :
  - `sudo mkdir ${webapp_work_dir}/ `
  - `sudo chown jetty:jetty ${webapp_work_dir}/`
- Pour le chemin définit dans la propriété `webapp.logs.dir` (transférée dans une variable `webapp_logs_dir`):
  - `sudo mkdir ${webapp_logs_dir}/ `
  - `sudo chown jetty:jetty ${webapp_logs_dir}/`
- Création d’un fichier `/etc/systemd/system/jetty9.service.d/override.conf` :
  - `sudo touch /etc/systemd/system/jetty9.service.d/override.conf`
  - `sudo echo "ReadWritePaths=/var/lib/jetty9 ${webapp_work_dir} ${webapp_logs_dir}" >> /etc/systemd/system/jetty9.service.d/override.conf`
  - `sudo echo "LimitNOFILE=8192" >> /etc/systemd/system/jetty9.service.d/override.conf`
  
  
- Modification du fichier /etc/default/jetty9 :
  - `sudo echo "JAVA_OPTIONS=\"-Djava.awt.headless=true -Xmx3072M -Xms3072M\"" >> /etc/default/jetty9`

- `sudo systemctl restart jetty9`
  
## ImageMagick

- `apt install -y libpng-dev libjpeg-dev libtiff-dev`
- `apt install -y imagemagick`

## ElasticSearch 7.10.2 OSS (licence Apache2)

- `wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.10.2-amd64.deb`
- `sudo apt install ./elasticsearch-oss-7.10.2-amd64.deb`

Le service est accessible par défaut à l’adresse http://127.0.0.1:9200.

Attention : Vérifiez bien que le paramètre `app.ext.es.host` dans les propriétés du modèle scenari soient a cette 
valeur.
Si ce n’est pas le cas, il faudra modifier aux choix le modèle scenari, le fichier host ou la configuration nginx, pour 
que scenari puisse communiquer avec elasticsearch.

### Configurations spécifiques

Pour simplifier la gestion des dépots ES, nous utilisons ci-après la valeur de 
la propriété `webapp.code` transférée dans une variable `webapp_code`.

- Création d’un dossier de dépot pour l'application
  - `mkdir -p /usr/share/elasticsearch/repos/${webapp_code}`
- Modification des configurations dans `/etc/elasticsearch/elasticsearch.yml`
  - `sudo echo "path.repo: [\"/usr/share/elasticsearch/repos/${webapp_code}\"]" >> /etc/elasticsearch/elasticsearch.yml`

## LibreOffice
- `apt install --no-install-recommends -y libreoffice libreoffice-java-common ure`
  
## Latex
- `apt install --no-install-recommends -y texlive-latex-base texlive-latex-extra texlive-science texlive-fonts-recommended dvipng`

## FFmpeg
- `apt install -y ffmpeg`
  
## Postscriptum

- `wget https://deb.scenari.software/pool/main/p/postscriptum-0.12-app/postscriptum-0.12-app_0.12.6-beta_amd64.deb`
- `apt install -y ./ postscriptum-0.12-app_0.12.6-beta_amd64.deb`
- `rm -f /opt/postscriptum`
- `ln -s /opt/postscriptum-0.12 /opt/postscriptum`

## Scenari StudioPaon

Exemple d'installation après compilation via scBuilder d'un fichier `*_svMake.zip` et transfert sur le serveur.

L'application StudioPaon se compose d'un composant java au format war 
(l'application serveur) et d'un composant web (l'application cliente).
Le nom du fichier war dépend de la propriété `webapp.code` définit à la compilation de l’application scenariBuilder.

En utilisant les commandes suivantes, l'application java `${webapp_code}.war` sera déployer dans jetty, et l'application web
sera déployer dans `/var/www/studio-paon`:

 - `rm -rf ~/studio-paon; mkdir ~/studio-paon; unzip *_svMake.zip -d ~/studio-paon`
 - `mkdir -p ~/studio-paon/deploy && tar xvf ~/studio-paon/*.tgz -C ~/studio-paon/deploy`
 - `sudo find ~/studio-paon/deploy -type f -name "${webapp_code}.war" -exec sudo chown jetty:jetty {} \; -exec sudo mv {} /usr/share/jetty9/webapps/${webapp_code}.war \;`
 - `sudo rm -rf /var/www/studio-paon; sudo find ~/studio-paon/deploy -type d -name "static" -exec sudo cp -r "{}" /var/www/studio-paon \;`
 - `sudo systemctl restart jetty9`

Une fois l’application installée, il faut aussi déployer le modèle documentaire manuellement dans l’application avant de commencer à l’utiliser.

## NGINX

- `sudo apt install -y nginx`

## Configurations spécifiques

Pour cet exemple, nous considèrerons 
- le domaine `test.studio-paon.fr` pour lequel
un fichier de configuration `/etc/nginx/sites-available/test.studio-paon.fr` 
est utilisé.
- le code de l'application `webapp.code` comme étant `scenari`
  - l'application est alors accessible par les urls commençant par `http://127.0.0.1:8080/scenari`
  - Si vous changez le champ `webapp.code`, vérifiez quel url racine lui est 
    associée au chargement dans jetty et remplacez-la dans le fichier ci-après


Attention : si vous utilisez le bot `Lets encrypt` pour la certification ssl,
il pourra modifier le fichier pour le passage en SSL.

```nginx
map $http_upgrade $connection_upgrade {
  default upgrade;
  ''      '';
}

server {
	listen 80 test.studio-paon.fr;
	listen [::]:80 test.studio-paon.fr;

	# Suivant le repertoire de déploiement du site
	root /var/www/studio-paon;

	client_max_body_size 0;

	proxy_request_buffering off;
	proxy_buffering off;
	proxy_read_timeout 600;

	error_log /var/log/nginx/error_test.studio-paon.fr.log error;
	access_log /var/log/nginx/access_test.studio-paon.fr.log combined;

	# Add index.php to the list if you are using PHP
	index fr-FR/home.xhtml;

	server_name test.studio-paon.fr;
	
	# Redirections pour scenari / StudioPaon
	location /~~static/ {
		alias /var/www/studio-paon/;
	}
	location /~~static/#portletCode#/fr-FR	{
		alias /var/www/studio-paon/chain/fr-FR;
	}
	location /~~static/import/fr-FR	{
		alias /var/www/studio-paon/import/fr-FR;
	}
	location /~~static/depot/fr-FR	{
		alias /var/www/studio-paon/depot/fr-FR;
	}
	location /~~import/~~search	{
		proxy_pass http://127.0.0.1:8080/scenari/import/search;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_set_header Host $host;
	}
	location /~~import/~~write	{
		proxy_pass http://127.0.0.1:8080/scenari/import;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_set_header Host $host;
	}
	location /~~import/~~repos	{
		internal;
		alias /var/lib/scenari/data/prl-import;
	}
	
	location /~~import/~~edit
	{
		return 301 https://test.studio-paon.fr/~~static/import/fr-FR/depot.xhtml;
	}
	
	location /~~import {
		proxy_pass http://127.0.0.1:8080/scenari/import/tree;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_set_header Host $host;
	}
	location /~~search {
		proxy_pass http://127.0.0.1:8080/scenari/depot/search;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_set_header Host $host;
	}
	location /~~chain {
		proxy_pass http://127.0.0.1:8080/scenari/chain;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_set_header Host $host;
	}
	location /~~write {
		proxy_pass http://127.0.0.1:8080/scenari/depot;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_set_header Host $host;
	}
	location /~~depot/~~repos {
		internal;
		alias /var/lib/scenari/data/prl-depot;
	}
	location /~~edit
	{
		return 301 http://test.studio-paon.fr/~~static/depot/fr-FR/depot.xhtml;
	}

	location / {
		proxy_pass http://127.0.0.1:8080/scenari/depot/tree;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_set_header Host $host;
	}
}
# Si vous utilisez letsencrypt 
# Ce fichier sera modifié automatiquement par certbot pour le passage en SSL
```

## Installation du modèle documentaire
