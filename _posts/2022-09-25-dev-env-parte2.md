---
layout: post
title: Ambiente di sviluppo - parte 2
tags: setup dev-env vscode github
---

Eccoci qua con la seconda parte del mio ambiente di sviluppo. Stavolta
affronteremo l'argomento del versionamento del codice.

### Account GitHub &#x1F7E1;

Visual Studio Code è nativamente in grado di interagire con un repository Git
quindi potrebbe essere sufficiente così... ma se volete andare un po' oltre,
allora potreste essere tentati di installare e utilizzare un client Git
standalone.

Personalmente, anche per ragioni di lavoro, utilizzo l'accoppiata Git + Fork.

Il primo è il [client standalone](https://git-scm.com/downloads)
mentre il secondo è un'[interfaccia GUI](https://git-fork.com/) che interagisce
con Git ma fornisce molte facilitazioni rispetto all'utilizzo da riga di comando.
Consente inoltre un maggiore controllo rispetto a quanto fatto con VsCode.

Git è il software che consente di registrare tutte le modifiche che vengono
apportate al codice sorgente, con la possibilità di tornare indietro, mantenere
un riferimento ad una versione che funziona mentre si lavora a qualcosa di nuovo
ecc...

Le modifiche vengono archiviate sul pc locale e sono facilmente gestibili con Fork
che fornisce una visione su tutto il repository.

Da tenere in considerazione che il nostro repository è sul pc e questo porta due
svantaggi:
* se si dovesse rompere la memoria di massa su cui è memorizzato, tutto il lavoro verrebbe irrimediabilmente perso (a meno che non ci si prenda l'onere di effettuare copie altrove)
* non si può condividere i dati con altre persone che potrebbero intervenire sul codice

E' buona norma avere un repository remoto che verrà utilizzato da tutti i
contributors come base comune su cui lavorare, avendo intrinsecamente anche un
backup.

![GitHub](/resources/github.png)
Ci sono tanti servizi online, spesso gratuiti seppur con limitazioni, che
consentono di avere repository remote, uno di questi è
[Github](https://github.com/).

Anche qui, come in altre parti del tutorial, non mi dilungo su come configurare
il repository locale con Git, configurare Fork e interfacciare tutto con GitHub,
c'è la documentazione a disposizione, vi invito caldamente a seguirla.

Mi sento di cosigliare l'uso di GitHub, principalmente per la funzionalità di
backup, perciò anche se il progetto è solo vostro e non ci sono altri
collaboratori. Il repository può essere impostato come privato e sarete solo voi
a poter accedere.

### GitHub Pull Requests and Issues Extension &#x1F7E1;
![GitHub](/resources/github-extension.png)

GitHub principalmente offre il servizio di repository remota, ma ultimamente si è
arricchito di molte funzioni utili per la gestione di un progetto (di cui la
repository fa parte) e per la collaboration.

Le funzioni a cui mi riferisco sono la creazione di pull request (cioè la
possibilità di lavorare autonomamente sul codice, di caricarlo sul repository
remoto e di richiedere ad un collaboratore di eseguire una review prima di unirlo
alla codebase) e delle issue.
Le issue sono i problemi ma possono essere visti più in generale come delle
segnalazioni, delle feature oltre che dei bug.

Si possono creare delle issue per tenere traccia delle funzionalità da realizzare
nel progetto, ognuna di esse può essere aperta, sviluppata, associata ad una pull
request e chiusa. Ci sono tantissimi altri dettagli a riguardo, ma non
approfondirò.

Le PR e le issue possono essere gestite interamente su Visual Studio Code tramite
[un'estesione](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-pull-request-github)
che permetterà di controllare tutto senza agire sul sito di GitHub.

## Conclusione

Come già detto, volutamente NON ho inserito tutorial su come utilizzare questi
software. Non si offenda nessuno, ma **NON FORNISCO SUPPORTO SU QUESTE ATTIVITA'**,
la documentazione esiste, è tanta ed è specializzata per ogni software o servizio
che vi propongo, fate riferimento sempre a quella.

Alla prossima lezione!

Se volete chiarimenti su qualche punto di questo post, scrivetemi su
[Gitter](https://gitter.im/intoinside/community)!

Le discussioni più interessanti verranno aggiunte qui.
