# StudioPaon - Modèle documentaire et compléments serveur scenari

Studio PAON est une chaîne de production semi-automatisée pour la production
de livres adaptés aux formats Full DAISY et BRF aux normes du Pôle d'adaptation
des Ouvrages Numériques (PAON) de
[l'Association Valentin Haüy (AVH)](https://www.avh.asso.fr).
Financé par l'AVH et subventionné par
[le ministère de la Culture](https://www.culture.gouv.fr/),
le projet est coordonné par
[Gautier Chomel - Éditadapt](https://www.editadapt.net/)
et réalisé en partenariat avec Luc Audrain,
[Kelis](https://scenari.kelis.fr/),
[Scopyleft](http://scopyleft.fr/) et Thomas Parisot.

Studio PAON est réalisé avec les logiciels
[SCENARI](https://scenari.org/),
une suite de solutions logicielles libres et gratuites éditées par Kelis.

Ce dépot contient le modèle documentaire utilisé par l'application
pour structurer les processus de transcription, ainsi que les processus
d'imports dans studio-paon de fichiers éditeurs au format XML/LG, XML/DTBook
ou EPUB3, et d'exports des documents de travail vers les formats :
- DAISY2.02 texte et audio,
- ODT avec codes Duxburry pour le braille
- DTBook XML
- DAISY3 (En développement)
- EPUB3 (En développement)

# Environnement de développement

(Cette section en cours de rédaction)

## Prérequis

Les logiciels suivants doivent être installés préalablement :
- IntelliJ IDEA
- Temurin JDK 11
    - Peut être installer via IntelliJ
- NodeJS 18 ou plus
- ImageMagick
    -  Sous Windows, l'installateur de ImageMagick
       peut aussi installer FFMPEG
- FFMPEG
- ElasticSearch 8.17.1 ou plus

En plus de ce dépot, vous aurez besoin de cloner le dépot de code scenari :
https://source.scenari.software/git/dev-core/
Pour simplifier la mise en place, il est conseiller de cloner le dépot dev-core
de scenari à coter du dépot studio-paon.

## Configuration
### Elastic search

Dans le fichier de configuration d'elasticsearch (`elasticsearch.yml`),
ajouter ou modifier les lignes suivantes :
```yml
# Indiquez le répertoire où ES stockera ses données
# et insérez son chemin ci apres à la place de /path/to/data
path.data: C:/path/to/data
# Associez le port 9811 a ES - cette information est stocké 
http.port: 9811
# Creer un répertoire auquel ES pourra accéder en lecture/écriture/execution 
# et où ES stockera les dépots de documents et indiquez-le
# ci-aprés entre crochet et double-quote, 
# à la place de C:/path/to/es-repo :
path.repo: ["C:/path/to/es-repo"]
```

Il est recommandé d'ajouter le chemin du dossier `bin` d'ElasticSearch dans la
variable d'environnement `PATH` pour faciliter son lancement.

# Intellij

Une documentation sur la mise en place de l'environnement dans intellij est
fournis par les équipes de Scenari dans le dépot de code de scenari dans le
fichier
[Doc_Core/dev/desk.md](https://source.scenari.software/projects/dev-core/repository/git/revisions/6.1/entry/Doc_Core/dev/desk.md)

# Grandes étapes de préparation

Dans Intellij IDEA :
- Ouvrer le projet Mod.studio-paon-sc61.iml
- Ouvrez
- Définissez les variables d'environnement
- Allez dans le menu `Project structure > Project`
    - Pour le champ `SDK`, sélectionnez un JDK version 11
    - Vous pouvez installer `temurin 11` via intellij si aucun jdk n'est disponible
- Importer les projets gradle
    - `dev-core/Main_core/build.gradle.kts`
    - `dev-core/Main_libs/build.gradle.kts`
- Dans l'onglet gradle désactiver les projets :
    - `buildSrc`
    - `Tst_*`
    - `Web_*`
    - `Wui_*`
    - `WuiR_*`
- Lancer le rechargement de gradle
- Creer un module `Bui` a coter des dépots `dev-core` et `studio-paon`
    - Supprimer la `content-root` par défaut
    - Ajouter en `content-root` tous les répertoires `dev-core/Bui_*`
- Creer un module `Ide` a coter des dépots `dev-core` et `studio-paon`
    - Supprimer la `content-root` par défaut
    - Ajouter en `content-root` le répertoire `dev-core/Ide_Intellij`
- Creer un jar de déploiement :
    - Allez dans le menu `Project structure > Artifacts > Add > Jar > From Module With Dependencies`
    - Sélectionner le module Mod.studio-paon-sc61
    - Définissez les valeurs suivantes dans les champs listés :
        - `Name` : `Mod.studio-paon-sc61`
        - `Output directory` : chemin absolu du répertoire `sources/portal/servers/libjar.doss` du
          dépot studio-paon
        - `Output layout` : ne garder que la sortie de compilation du module
          Mod.studio-paon-sc61
- Ouvrez le fichier `studio-paon/SCENARIbuilder-paon.run.xml` et cliquez sur
  `Open run/debug configuration`
    - Modifier le jdk de la configuration pour utiliser celui de votre projet
- Pour Windows, dans chaque dossier `dev-core/Web_*`, creer un dossier `~bin`
- Ouvrez un terminal et rendez-vous dans le dossier
  `dev-core/Wui_Bootstrap`
- Lancez les commandes suivantes :
```bash
npm run install:all
npm run dist
```
- Dans intellij, Ouvrez le fichier `studio-paon/SCENARIbuilder-paon.run.xml`
- Cliquez sur `Open Run/Debug configurations` pour la charger dans la liste des
  configurations de lancement
- Si nécessaire, remplacer le JDK cible
- Dans les paramètres de intelliJ, rendez-vous dans `Build, Execution, Deployment > Build Tools > Gradle`
  - Sélectionner le projet gradle `Main_Core`
  - Pour les options `Build and run using` et `Run tests using` : sélectionnez `IntelliJ`
    (Sans ça, vous pourriez ne pas avoir de liaison entre le serveur de dev de l'interface et le serveur scenari) 

# Lancement de l'application via intellij
(En cours de rédaction)
- Lancer elasticsearch dans un terminal
- Dans un autre terminal, placez-vous dans le dossier `dev-core/Wui_Bootstrap`
  et lancez la commande `npm run launch:devServer`


## Possible blocage au lancement de scenari

### Probleme d'exception lancer sur une fonction `getSsOfSs`

Il est possible que le build ne copie pas certains dossier de resource lors de la phase de build.
Pour corriger le probleme, exécuter les commandes suivantes:

```bash
cp -r ./dev-core/Jav_Wsp/src/main/java/com/scenari/m/bdp/item/fs/ssofss ./dev-core/Jav_Wsp/~bin/main/java/com/scenari/m/bdp/item/fs/ssofss
cp -r ./dev-core/Jav_Wsp/src/main/java/com/scenari/m/bdp/item/fs/ss4unknownwsp  ./dev-core/Jav_Wsp/~bin/main/java/com/scenari/m/bdp/item/fs/ss4unknownwsp
```

### L'interface reste bloqué sur un écran "Chargement"

- Vérifiez que le projet `Main_Core` est bien configurer pour être lancer avec `IntelliJ` dans `Build, Execution, Deployment > Build Tools > Gradle`
- Vérifiez que le serveur de développement de l'interface est bien lancé (`npm run launch:devServer` dans `dev-core\Wui_Bootstrap`)

## Notes pour les développeurs travaillant sous Windows

Il est possible qu'une ou plusieurs exceptions soit lever au démarrage
spécifiant que les ports requis sont déjà utilisés, alors qu'aucun autre
application n'est lancé sur ces ports.

Il apparait que dans certaines configuration (notamment si des fonctionnalités 
de virtualisation type Hyper-V sont activés), Windows réserve des plages de 
ports et en exclu l'utilisation par d'autres services.

Pour les débloquer et en permettre l'utilisation, il faut lancer les commandes
suivantes (en mode Administrateur) :
```batch
net stop winnat
net start winnat
```


