var documenterSearchIndex = {"docs":
[{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"% Relazione LAR TGW 3D - Gruppo 8b % Luca Maria Lauricella; Valerio Marini; % \\today","category":"page"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"Progetto relativo al Corso di Calcolo Parallelo e Distribuito del  Prof. Paoluzzi presso l'Università Roma Tre.","category":"page"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"Repository del progetto: https://github.com/lauriluca99/TGW-3D.jl","category":"page"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"Documentazione del progetto: https://lauriluca99.github.io/TGW-3D.jl","category":"page"},{"location":"intro/#Introduzione-Linear-Algebraic-Rappresentation:","page":"Introduzione a LAR","title":"Introduzione Linear Algebraic Rappresentation:","text":"","category":"section"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"LAR è uno schema rappresentativo per modelli geometrici e topologici. Il dominio di questo schema consiste in complessi di cellule formati a loro volta da matrici sparse (matrici con grande affluenza di zeri). L’analisi di questi complessi cellulari è fatta attraverso semplici operazioni algebriche lineari, la più comune è la moltiplicazione sparsa matrice/vettore.","category":"page"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"Dato che LAR permette una computazione efficiente di qualsiasi modello topologico, viene utilizzato con un linguaggio di programmazione, anch’esso efficiente e veloce, come Julia, il quale permette di sfruttare tutte le sue potenzialità.","category":"page"},{"location":"intro/#*Perché-LAR?*","page":"Introduzione a LAR","title":"Perché LAR?","text":"","category":"section"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"Scegliamo LAR in quanto l’aumento della complessità dei dati geometrici e dei modelli topologici richiedono una migliore rappresentazione e un modello matematico appropriato per tutte le strutture topologiche. Quindi si ha un complesso co-chain formato da collezioni di matrici sparse.","category":"page"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"Un complesso chain consiste in una sequenza di moduli dove la singola immagine di ognuno è contenuta nel nucleo della successiva (successivo conosce precedente).","category":"page"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"(Image: Complesso chain)","category":"page"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"Un complesso co-chain è la stessa cosa ma con direzioni opposte.","category":"page"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"(Image: Complesso co-chain)","category":"page"},{"location":"intro/#Obiettivo-del-progetto","page":"Introduzione a LAR","title":"Obiettivo del progetto","text":"","category":"section"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"In questo progetto si vuole ottimizzare e parallelizzare il codice dell'algoritmo TGW 3D presente nella libreria LinearAlgebraicRappresentation.jl ","category":"page"},{"location":"intro/#**TGW-3D**","page":"Introduzione a LAR","title":"TGW 3D","text":"","category":"section"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"L’algoritmo Topological Gift Wrapping calcola le d-celle di una partizione di spazio generate da loro partendo da un oggetto geometrico d-1 dimensionale.","category":"page"},{"location":"intro/","page":"Introduzione a LAR","title":"Introduzione a LAR","text":"TGW prende una matrice sparsa di dimensione d-1 in input e produce in output la matrice sparsa di dimensione d sconosciuta aumentata dalle celle esterne.","category":"page"},{"location":"README/","page":"LAR TGW 3D","title":"LAR TGW 3D","text":"(Image: Build) (Image: Documentation) (Image: Github Pages)","category":"page"},{"location":"README/#LAR-TGW-3D","page":"LAR TGW 3D","title":"LAR TGW 3D","text":"","category":"section"},{"location":"README/","page":"LAR TGW 3D","title":"LAR TGW 3D","text":"Progetto 8b del corso di Calcolo Parallelo e Distribuito erogato durante l'anno accademico 2021/2022 presso il Dipartimento di Ingegneria Informatica dell'Università Roma Tre.","category":"page"},{"location":"README/#Membri-del-team:","page":"LAR TGW 3D","title":"Membri del team:","text":"","category":"section"},{"location":"README/","page":"LAR TGW 3D","title":"LAR TGW 3D","text":"Luca Maria Lauricella","category":"page"},{"location":"README/","page":"LAR TGW 3D","title":"LAR TGW 3D","text":"Valerio Marini","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"% Relazione LAR TGW 3D - Gruppo 8b % Luca Maria Lauricella; Valerio Marini; % \\today","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Progetto relativo al Corso di Calcolo Parallelo e Distribuito del  Prof. Paoluzzi presso l'Università Roma Tre.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Repository del progetto: https://github.com/lauriluca99/TGW-3D.jl","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Documentazione del progetto: https://lauriluca99.github.io/TGW-3D.jl","category":"page"},{"location":"studioEsecutivo/#Studio-esecutivo","page":"Studio Esecutivo","title":"Studio esecutivo","text":"","category":"section"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Nello studio esecutivo abbiamo analizzato il codice nei notebooks cercando delle possibili  ottimizzazioni. Non è stato possibile ottimizzare tutte le funzioni, infatti le principali modifiche sono state effettuate nelle funzioni:  frag_face e merge_vertices.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Per migliorare il codice, sono stati presi in considerazione i libri: Julia High Performance e  Hands-On Julia Programming, nei quali vengono menzionate le seguenti macro  per migliorare le performance e la stabilità del codice:","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"@async: racchiude l'espressione in un Task ed ","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"inizierà con l'esecuzione di questa attività procedendo con qualsiasi altra cosa venga dopo nello script, senza aspettare  che il Task termini.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"@sync: contrariamente al precedente, questa macro aspetta che ","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"tutti i Task creati dalla parallelizzazione siano completati prima di proseguire.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Thread.@spawn: Crea un Task e schedula l'esecuzione su un qualsiasi thread disponibile. ","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Il Task viene assegnato ad un Thread quando diventa disponibile.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"@simd: si utilizza solo nei for per permettere al compilatore di avere","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"più libertà nella gestione del ciclo consentendo di riordinarlo.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"@inbounds: elimina il controllo dei limiti degli array all'interno dell'espressione\n@views: converte le operazioni di taglio sull'array in una data espressione per ritornare ","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"una variabile di tipo View.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"@code_warntype: viene utilizzato per individuare i problemi causati dai tipi delle variabili, ","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"operando conseguentemente con un'assegnazione specifica che riduce la complessità del codice.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"@benchmark: questa macro può essere usata solo davanti alle chiamate di funzione.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Valuta i parametri della funzione separatamente e chiama la funzione più volte per costruire   un campione di tempi di esecuzione.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"@btime: simile a @benchmark ma restituisce meno informazioni, quali il tempo minimo ","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"ed il numero di allocazioni.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"@profile: questa macro esegue l'espressione collezionando dei campionamenti periodici.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Nei campioni si può vedere la gerarchia delle funzioni ed il tempo di esecuzione di ogni riga.","category":"page"},{"location":"studioEsecutivo/#frag_face","page":"Studio Esecutivo","title":"frag_face","text":"","category":"section"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Utilizzando la macro @code_warntype si individuano molte variabili assegnate al tipo Any.  Questo significa essenzialmente che ci sarà un'allocazione per la posizione della memoria e  l'indirezione al valore effettivo durante l'esecuzione della funzione.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"(Image: Benchmark della funzione originale)","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Tramite ProfileView otteniamo un grafico in cui si ottiene la misurazione temporale di ogni singola riga di codice.  La larghezza delle barre mostra il tempo trascorso in ogni locazione di chiamata,  mentre la gerarchia di chiamata è rappresentata dalle varie altezze del grafico.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"(Image: Grafico di ProfileView della funzione originale)","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Per ottimizzare la funzione abbiamo assegnato alle variabili locali un tipo deterministico per rimuovere il tipo Any ed avere la funzione type-stable. Inoltre si possono creare delle viste degli array quando c'è un'operazione di slicing,  con la macro @views, le quali permettono di accedere ai valori dell'array  senza dover effettuare una copia.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Dopo aver eseguito vari test, si è optato per utilizzare la macro @async per parallelizzare il ciclo for che calcola l'intersezione della faccia sigma con le facce in sp_idx[sigma].","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Quindi, applicando le suddette modifiche, si è raggiunto un tempo minimo di esecuzione inferiore di circa 20% dalla versione originale.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"(Image: Benchmark della funzione modificata)","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"(Image: Grafico di ProfileView della funzione modificata)","category":"page"},{"location":"studioEsecutivo/#merge_vertices","page":"Studio Esecutivo","title":"merge_vertices","text":"","category":"section"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Anche per quanto riguarda questa funzione abbiamo effettuato un controllo su i vari tipi di variabili assegnati utilizzando  la macro @code_warntype, questa volta però non erano presenti variabili di tipo Any che ci avrebbero dunque destabilizzato i tipi della funzione. Per ottimizzare quest’ ultima abbiamo, un’altra volta, introdotto opportunamente davanti ai cicli for  la macro @async che, parallelizzando le operazioni di calcolo, ci ha permesso di avere un'ottimizzazione del 30% sul tempo di esecuzione.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"(Image: Benchmark della funzione originale)","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Notiamo in seguito come vengono modificati i tempi dopo l'ottimizzazione.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"(Image: Benchmark della funzione modificata)","category":"page"},{"location":"studioEsecutivo/#spatial_arrangement","page":"Studio Esecutivo","title":"spatial_arrangement","text":"","category":"section"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Di nuovo, anche per questa funzione è stato effettuato un controllo su i vari tipi di variabili utilizzando  la macro @code_warntype, quindi abbiamo stabilizzato i tipi delle variabili e parallelizzando le funzioni mergevertices  e fragface, che vengono richiamate all'interno della funzione corrente, abbiamo ottenuto un codice che si comporta come una  versione più veloce del codice precedente risparmiando circa un 40% del tempo di esecuzione.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"(Image: Benchmark della funzione originale)","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Notiamo in seguito come vengono modificati i tempi dopo l'ottimizzazione.","category":"page"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"(Image: Benchmark della funzione modificata)","category":"page"},{"location":"studioEsecutivo/#Azioni-Github","page":"Studio Esecutivo","title":"Azioni Github","text":"","category":"section"},{"location":"studioEsecutivo/","page":"Studio Esecutivo","title":"Studio Esecutivo","text":"Grazie all'utilizzo del libro Hands-On Julia Programming, in particolare il capitolo 13, si sono costruite diverse Actions di Github, le quali eseguono delle istruzioni specifiche quando Github rileva gli eventi di attivazione corrispondenti.  Ogni volta che c'è un nuovo push sul branch master, viene effettuata una simulazione per verificare che il modulo  TGW3D.jl venga correttamente aggiunto sui sistemi operativi Ubuntu (x86 e x64), Windows (x86 e x64) e macOS (x64).  Inoltre, tramite la libreria Documenter.jl, viene presa la documentazione del nostro progetto ed inserita sulla pagina di Github corrispondente.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"% Relazione LAR TGW 3D - Gruppo 8b % Luca Maria Lauricella; Valerio Marini; % \\today","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Progetto relativo al Corso di Calcolo Parallelo e Distribuito del  Prof. Paoluzzi presso l'Università Roma Tre.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Repository del progetto: https://github.com/lauriluca99/TGW-3D.jl","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Documentazione del progetto: https://lauriluca99.github.io/TGW-3D.jl","category":"page"},{"location":"studioPreliminare/#Obiettivo-del-progetto","page":"Studio Preliminare","title":"Obiettivo del progetto","text":"","category":"section"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"In questo progetto si vuole ottimizzare e parallelizzare il codice dell'algoritmo TGW 3D presente nella libreria LinearAlgebraicRappresentation.jl ","category":"page"},{"location":"studioPreliminare/#**TGW-3D**","page":"Studio Preliminare","title":"TGW 3D","text":"","category":"section"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"L’algoritmo Topological Gift Wrapping calcola le d-celle di una partizione di spazio generate da loro partendo da un oggetto geometrico d-1 dimensionale.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"TGW prende una matrice sparsa di dimensione d-1 in input e produce in output la matrice sparsa di dimensione d sconosciuta aumentata dalle celle esterne.","category":"page"},{"location":"studioPreliminare/#Studio-Preliminare","page":"Studio Preliminare","title":"Studio Preliminare","text":"","category":"section"},{"location":"studioPreliminare/#spatial_arrangement.jl","page":"Studio Preliminare","title":"spatial_arrangement.jl","text":"","category":"section"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"L'algoritmo TGW 3D è implementato all'interno del file spatial_arrangement.jl","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"(Image: Grafo delle Dipendenze di spatial_arrangement.jl)","category":"page"},{"location":"studioPreliminare/#Funzioni-presenti","page":"Studio Preliminare","title":"Funzioni presenti","text":"","category":"section"},{"location":"studioPreliminare/#**spatial_arrangement:**","page":"Studio Preliminare","title":"spatial_arrangement:","text":"","category":"section"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Calcola la partizione dei complessi cellulari dati, con scheletro di dimensione 2, in 3D.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Un complesso cellulare è partizionato quando l’intersezione di ogni possibile paio di celle del complesso è vuota e l’unione di tutte le celle è l’insieme dello spazio Euclideo. La funzione ritorna la partizione complessa come una lista di vertici V e una catena di bordi EV, FE, CF.","category":"page"},{"location":"studioPreliminare/#*spatial_arrangement_1:*","page":"Studio Preliminare","title":"spatial_arrangement_1:","text":"","category":"section"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Si occupa del processo di frammentazione delle facce per l’utilizzo del planar arrangement.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>compute_FV:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Ritorna l’array FV di tipo Lar.Cells dal prodotto di due array sparsi in input di tipo Lar.ChainOp.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>spaceindex:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Dato un modello geometrico, calcola le intersezioni tra i bounding box. Nello specifico, la funzione calcola le 1-celle e il loro bounding box attraverso la funzione boundingBox. Si suddividono le coordinate x e y in due dizionari chiamando la funzione coordintervals. Per entrambe le coordinate x e y, si calcola un intervalTree cioè una struttura dati che contiene intervalli. La funzione boxCovering viene chiamata per calcolare le sovrapposizioni sulle singole dimensioni dei bounding Box. Intersecando quest’ultime, si ottengono le intersezioni effettive tra bounding box. La funzione esegue lo stesso procedimento sulla coordinata z se presente. Infine, si eliminano le intersezioni di ogni bounding box con loro stessi.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>frag_face:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Effettua la trasformazione in 2D delle facce fornite come parametro sigma, dopo di che ogni faccia sigma si interseca con le facce Presenti in sp_index sempre fornito come parametro della funzione.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>skel_merge:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Effettua l’unione di due scheletri che possono avere 1 o 2 dimensioni.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>merge_vertices:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Effettua l’unione dei vertici, dei lati e delle facce vicine.","category":"page"},{"location":"studioPreliminare/#*biconnected_components:*","page":"Studio Preliminare","title":"biconnected_components:","text":"","category":"section"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Calcola le componenti biconnesse del grafo EV rappresenato da bordi, ovvero coppie di vertici.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>an_edge:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Funzione che, dato in input un punto, prende un lato connesso ad esso.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>get_head:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Funzione che, dato in input un lato e la coda, fornisce la testa","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>v_to_vi:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Funzione che, dato un vertice in input, ritorna falso se la prima occerrenza della matrice è pari a 0 oppure ritorna il valore trovato.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>push!:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Inserisce uno o più oggetti nella matrice.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>pop!:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Rimuove l’ultimo oggetto nella matrice e lo ritorna.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>sort:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Ordina la matrice e ne ritorna una copia.","category":"page"},{"location":"studioPreliminare/#*spatial_arrangement_2:*","page":"Studio Preliminare","title":"spatial_arrangement_2:","text":"","category":"section"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Effettua la ricostruzione delle facce permettendo il wrapping spaziale 3D.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>minimal_3cycles:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Funzione che riporta i parametri dati in input in 3 dimensioni e calcola le nuove celle adiacenti per estendere i bordi della figura geometrica. Infine ritorna la matrice sparsa tridimensionale.","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"<u>build_copFC:</u>","category":"page"},{"location":"studioPreliminare/","page":"Studio Preliminare","title":"Studio Preliminare","text":"Funzione alternativa alla precedente.","category":"page"},{"location":"","page":"Riferimenti API","title":"Riferimenti API","text":"Modules = [TGW3D]\nOrder = [:module]","category":"page"},{"location":"#TGW3D.TGW3D","page":"Riferimenti API","title":"TGW3D.TGW3D","text":"L’algoritmo Topological Gift Wrapping calcola le d-celle di una partizione di spazio generate da loro partendo da un oggetto geometrico d-1 dimensionale.\n\nTGW prende una matrice sparsa di dimensione d-1 in input e produce in output la matrice sparsa di dimensione d sconosciuta aumentata dalle celle esterne.\n\n\n\n\n\n","category":"module"},{"location":"#Riferimenti","page":"Riferimenti API","title":"Riferimenti","text":"","category":"section"},{"location":"","page":"Riferimenti API","title":"Riferimenti API","text":"Questa pagina ha i riferimenti a tutti i tipi, metodi e funzioni utilizzati.","category":"page"},{"location":"#Tipi","page":"Riferimenti API","title":"Tipi","text":"","category":"section"},{"location":"","page":"Riferimenti API","title":"Riferimenti API","text":"Modules = [TGW3D]\nOrder = [:type]","category":"page"},{"location":"#TGW3D.ChainOp","page":"Riferimenti API","title":"TGW3D.ChainOp","text":"ChainOp = SparseArrays.SparseMatrixCSC{Int8,Int}\n\nDichiarazione Alias di specifiche strutture dati di LAR.\n\nLa SparseMatrix nel formato Colonne sparse compresse, contiene la rappresentazione in coordinate di un operatore tra lo spazio lineare delle P-chains.\n\nOperatori P-Boundary  P-Chain - (P-1)-Chain e P-Coboundary  P-Chain - (P+1)-Chain sono tipicamente immagazinati come ChainOpcon elementi in -101 oppure in 01, per operatori assegnati e non-assegnati rispettivamente.\n\n\n\n\n\n","category":"type"},{"location":"#TGW3D.Points","page":"Riferimenti API","title":"TGW3D.Points","text":"Points = Array{Number,2}\n\nDichiarazione Alias di specifiche strutture dati di LAR.\n\nArray{Number,2,1} M x N compatto per immagazzinare la posizione dei vertici (0-cells) di un complesso cellulare. Il numero delle righe M è la dimensione  dello spazio di inclusione. Il numero delle colonne N è il numero dei vertici.\n\n\n\n\n\n","category":"type"},{"location":"#Funzioni","page":"Riferimenti API","title":"Funzioni","text":"","category":"section"},{"location":"","page":"Riferimenti API","title":"Riferimenti API","text":"Modules = [TGW3D]\nOrder = [:function]","category":"page"},{"location":"#TGW3D.face_angle-Tuple{Int64, Int64}","page":"Riferimenti API","title":"TGW3D.face_angle","text":"function face_angle(e::Int, f::Int)\n\nFunzione che calcola l'angolo di una faccia f rispetto allo spigolo e.\n\nInput\n\ne::Int \nf::Int\n\nOutput\n\nangle::Matrix\n\n\n\n\n\n","category":"method"},{"location":"#TGW3D.filter_fn-Tuple{Any}","page":"Riferimenti API","title":"TGW3D.filter_fn","text":"function filter_fn(face)\n\nFunzione di filtro per la funzione `merge_vertices`. La funzione `filter_fn` prende in input una faccia\ne restituisce `true` se i vertici della faccia non sono stati visitati, `false` altrimenti.\n\nInput\n\nface::Vector{Tuple{Int64, Int64}} \n\nOutput\n\ntrue/false::Bool\n\n\n\n\n\n","category":"method"},{"location":"#TGW3D.frag_face-Tuple{Matrix, SparseArrays.SparseMatrixCSC{Int8, Int64}, SparseArrays.SparseMatrixCSC{Int8, Int64}, Vector{Vector{Int64}}, Int64}","page":"Riferimenti API","title":"TGW3D.frag_face","text":"function frag_face(\n        V::Points, \n        EV::ChainOp, \n        FE::ChainOp, \n        sp_idx::Vector{Int64}, \n        sigma::Int64)\n\nPrende la faccia sigma e la trasforma in 2D per poter calcolare le intersezioni con le facce in sp_idx[sigma] ed ottenere la disposizione 2D della faccia sigma.\n\nInput\n\nV::Points\nEV::ChainOp \nFE::ChainOp\nsp_idx::Vector{Int64}\nsigma::Int64\n\nOutput\n\nnV::Points\nnEV::ChainOp\nnFE::ChainOp\n\n\n\n\n\n","category":"method"},{"location":"#TGW3D.frag_face_channel-Tuple{Any, Any, Matrix, SparseArrays.SparseMatrixCSC{Int8, Int64}, SparseArrays.SparseMatrixCSC{Int8, Int64}, Vector{Int64}}","page":"Riferimenti API","title":"TGW3D.frag_face_channel","text":"function frag_face_channel(\n        in_chan, \n        out_chan, \n        V::Points, \n        EV::ChainOp, \n        FE::ChainOp, \n        sp_idx::Vector{Int64})\n\nFunziona che parallelizza, con l'utilizzo dei canali, la frammentazione delle facce in FE rispetto le facce in sp_idx.\n\nInput\n\nin_chan \nout_chan \nV::Points \nEV::ChainOp \nFE::ChainOp\nsp_idx::Vector{Int64}\n\nOutput\n\nV::Points\nEV::ChainOp\n\n\n\n\n\n","category":"method"},{"location":"#TGW3D.merge_vertices","page":"Riferimenti API","title":"TGW3D.merge_vertices","text":"function merge_vertices(\n        V::Points, \n        EV::ChainOp, \n        FE::ChainOp, \n        [err=1e-4])\n\nRimuove i vertici congruenti ad un singolo rappresentatante, traduce i lati per tener  conto della congruenza ed otteniene nuove facce congruenti.\n\nArgomenti addizionali:\n\nerr: Limite di errore massimo che si vuole utilizzare. Di Defaults a 1e-4.\n\nInput\n\nV::Points \nEV::ChainOp \nFE::ChainOp\nerr=1e-4\n\nOutput\n\nnV::Points\nnEV::ChainOp\nnFE::ChainOp\n\n\n\n\n\n","category":"function"},{"location":"#TGW3D.minimal_3cycles-Tuple{Matrix, SparseArrays.SparseMatrixCSC{Int8, Int64}, SparseArrays.SparseMatrixCSC{Int8, Int64}}","page":"Riferimenti API","title":"TGW3D.minimal_3cycles","text":"Input\n\nV::Points\nEV::ChainOp \nFE::ChainOp\n\nOutput\n\nFC::ChainOp\n\n\n\n\n\n","category":"method"},{"location":"#TGW3D.removeinnerloops-Tuple{Any, Any}","page":"Riferimenti API","title":"TGW3D.removeinnerloops","text":"function removeinnerloops(\n        g::Int64, \n        nFE::ChainOp)\n\nRimuove le facce all'interno dei cicli interni dalla matrice sparsa nFE. Il valore restituito ha g righe in meno rispetto all'input nFE.\n\nInput\n\ng::Int \nnFE::ChainOp\n\nOutput\n\nnFE::ChainOp\n\n\n\n\n\n","category":"method"},{"location":"#TGW3D.spatial_arrangement","page":"Riferimenti API","title":"TGW3D.spatial_arrangement","text":"function spatial_arrangement(\n        V::Points, \n        copEV::ChainOp, \n        copFE::ChainOp; \n        [multiproc::Bool])\n\nCalcola la disposizione sulle cellule complesse 2-skeleton date\tin 3D.\n\nUn complesso cellulare è disposto quando l'intersezione di ogni coppia di celle del complesso è vuota e l'unione di tutte le celle rappresenta l'intero spazio Euclideo. La funzione ritorna la piena disposizione complessa come una lista di vertici V e una catena di lati EV, FE, CF.\n\nArgomenti addizionali:\n\nmultiproc::Bool: Esegue la computazione in modalità parallela. Di Defaults a false.\n\nInput\n\nV::Points \ncopEV::ChainOp \ncopFE::ChainOp\nmultiproc::Bool=false\n\nOutput\n\nrV::Points\nrEV::ChainOp\nrFE::ChainOp\nrCF::ChainOp \n\n\n\n\n\n","category":"function"},{"location":"#TGW3D.spatial_arrangement_1","page":"Riferimenti API","title":"TGW3D.spatial_arrangement_1","text":"function spatial_arrangement_1(\n        V::Points,\n        copEV::ChainOp,\n        copFE::ChainOp, \n        [multiproc::Bool=false])\n\nSi occupa del processo di frammentazione delle facce per l'utilizzo del planar arrangement.\t Richiama le funzioni frag_face e `merge_vertices' per ritornare i nuovi vertici, lati e facce.\n\nArgomenti addizionali:\n\nmultiproc::Bool: Esegue la computazione in modalità parallela. Di Defaults a false.\n\nInput\n\nV::Points \ncopEV::ChainOp \ncopFE::ChainOp\nmultiproc::Bool=false\n\nOutput\n\nrV::Points\nrEV::ChainOp\nrFE::ChainOp\n\n\n\n\n\n","category":"function"},{"location":"#TGW3D.spatial_arrangement_2","page":"Riferimenti API","title":"TGW3D.spatial_arrangement_2","text":"function spatial_arrangement_2(\n        rV::Points, \n        rcopEV::ChainOp, \n        rcopFE::ChainOp, \n        [multiproc::Bool=false])\n\nEffettua la ricostruzione delle facce permettendo il wrapping spaziale 3D.\n\nArgomenti addizionali:\n\nmultiproc::Bool: Esegue la computazione in modalità parallela. Di Defaults a false.\n\nInput\n\nrV::Points \nrcopEV::ChainOp \nrcopFE::ChainOp\nmultiproc::Bool=false\n\nOutput\n\nrV::Points \nrcopEV::ChainOp \nrcopFE::ChainOp\nmultiproc::Bool=false\n\n\n\n\n\n","category":"function"}]
}
