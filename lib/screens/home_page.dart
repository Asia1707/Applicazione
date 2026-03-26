//PROVA

Scaffold(

      drawer: Drawer(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                children:[ Card(elevation: 10, child:Text('da decidere'),),]
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 107, 83, 138), // altrimetni light green 
        actions:[Icon(Icons.account_circle_sharp),],
        title: Text('Astemix & Drugbelix'),
        centerTitle: true,
      ),
      body: Container(
        
        color: const Color.fromARGB(255, 255, 240, 207),
        // Figlio del container 
        child:
        // Organizzo una colonna portante dentro il container
        Column( mainAxisAlignment: MainAxisAlignment.center,
          // All'interno della colonna posso gestire più figli 
          children: [
              
              // Organizziamo per righe 
              // Prima riga - Testo benvenuto
              Row(mainAxisAlignment: MainAxisAlignment.center, // mi pongo al centro della riga 
                 crossAxisAlignment: CrossAxisAlignment.start, // Dovrebbe mettemrinin alto nella colonna portante

                children: [ // Elementi dentro la righa 
                  Container(
                    alignment: Alignment(1, 1), // per centrare oggetti all'interno del container 
                    constraints: BoxConstraints(maxWidth: 300,maxHeight: 300), // fissa dimensioni del container 
                    color : Colors.black , 
                    padding: EdgeInsets.all(10.0),
                    child: Text('WELECOME!',style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold ,color:Colors.amber),),
                            ) 
                          ] // Children prima row
                  ),

              // Seconda riga- card user Name 
              Row( mainAxisAlignment: MainAxisAlignment.center,
                children:[
                    SizedBox( height:50, width:300,
                       child: Card(elevation: 3, shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Column( mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text('Inserire username') ] ),
                                    ),),
                  ], ),
              // Terza riga- card user ID
              Row( mainAxisAlignment: MainAxisAlignment.center,
                children:[
                    SizedBox( height:50, width:300,
                       child: Card(elevation: 3, shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Column( mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text('Inserire codice ID ') ] ),
                                    ),),
                  ], ),


                ],// Children della colonna protante 

              )
        ),

        
  
    );

