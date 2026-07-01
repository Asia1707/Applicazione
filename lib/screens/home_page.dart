import 'package:flutter/material.dart';
// devi trovare modo di passare la variabile del nome dell admin per il login a pagina home 


class Home extends StatefulWidget {
  static const route = '/home/';
  static const routeDisplayName = 'HomePage';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  int startnumber = 5 ;  // variabile che tiene traccia della streak, inizializzata con 5 
  bool azzera = false ;  // serve per azzerrare il contatore della streak 
  int navigationindex = 0 ;
   // indice della navigation bar 
    void incrementa() {
    setState(() {
      startnumber++; // incrementiamo il numero della streak 

      if (azzera == true ) {startnumber = 0;} // if che serve per azzeramento della streaak
      azzera = false ; // dopo aver azzerato riporto su false il valore 

    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(

      body: Container(
                //  const Color.fromARGB(255, 119, 152, 113) VERDOLINO
                color: const Color.fromARGB(255, 255, 255, 255), 
                // Figlio del container 
                child:
                // Organizzo una colonna portante dentro il container
                Column( mainAxisAlignment: MainAxisAlignment.start,
                
                      // All'interno della colonna posso gestire più figli 
                      children: [

              // riga bianca per separazione
              Row( children: [Container(height:25)] ), 

              // riga con bottone per i settings 
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                IconButton(onPressed: (){} , icon: Icon(Icons.settings))],),         
              
              // Riga bianca per creare spazio 
              Row(  children: [ // Elementi dentro la righa 
                    Container(
                    // alignment: Alignment(0.0, -1.0), // per centrare oggetti all'interno del container 
                    constraints: BoxConstraints(maxHeight: 30), // fissa dimensioni del container  ),
                               ),],),

              // Organizziamo per righe: 

              // Prima riga - Testo benvenuto
              Row( mainAxisAlignment: MainAxisAlignment.start, // mi pongo al centro della riga 
                   // crossAxisAlignment: CrossAxisAlignment.start, // Dovrebbe mettemrinin alto nella colonna portante
                
                  children: [ // Elementi dentro la righa 

                  SizedBox(width: 25,),
                  Text('Benvenuto! userController',
                        style: TextStyle(fontSize: 34, 
                                          fontWeight: FontWeight.bold ,
                                          color:Color.fromARGB(255, 0, 0, 0)),),
                          ] // Children prima row
                  ),

              // Row bianca per creare spazio 
              Row(  children: [ // Elementi dentro la righa 
                    Container(
                    // alignment: Alignment(0.0, -1.0), // per centrare oggetti all'interno del container 
                    constraints: BoxConstraints(maxHeight: 70), // fissa dimensioni del container  ),
                              ),
                              ],
                              ),

              Row(mainAxisAlignment: MainAxisAlignment.center,
                    children:[ Text(' LA TUA STREAK: ',
                                          style: TextStyle(fontSize: 25 * 0.5,
                                           color: const Color.fromARGB(255, 0, 0, 0),
                                           fontWeight: FontWeight.bold,)),]),
                    
               
                                                              
              // Row dove stampo il contatore della streak 
              Row(mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    
             
                                                              

                    Container(
                                   width: 110,
                                   height: 110,
                                   alignment: Alignment.center,
                                   decoration: BoxDecoration(
                                   shape: BoxShape.circle,
                                   color: const Color.fromARGB(255, 136, 65, 171),),
                                   child: Text( '$startnumber',   //${widget.streak} è il numero che dobbiamo mettergli in input 
                                           style: TextStyle( 
                                                  fontSize: 100 * 0.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,)
                                           )
                                           )
                                           ],
            ),

            SizedBox(height: 80,), // crea spazio tra le due righe 

            // Riga con domanda e bottoni  
            Row(mainAxisAlignment: MainAxisAlignment.start,

            children:[
              SizedBox(width: 30,),
              Text('Hai assunto qualche sostanza oggi?', style: TextStyle(fontWeight: FontWeight.bold)  ),
              SizedBox(width: 20,), // serve solo a creare separazione tra il testo e il bottone 
              ElevatedButton(onPressed: (){azzera = true;incrementa(); }, child: Text('Sì'),), // il bottonr si che azzera il contatore 
              SizedBox(width: 10,), // serve solo a creare separazione i bottoni 
              ElevatedButton(onPressed: (){incrementa();}, child: Text('No'),) // bottone no che incrementa il contaotre 
            ],)
                  
          ], // Children della colonna protante
       
              ),

        ),

    bottomNavigationBar: BottomNavigationBar(
      selectedItemColor: Color.fromARGB(255, 125, 26, 223),
      onTap: (index){
        setState((){
              navigationindex = index ;
               });
    },
    currentIndex: navigationindex,
                        items: [
      BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profilo'),
      BottomNavigationBarItem(icon: Icon(Icons.settings),label: 'Impostazioni'),
      
    ]),
    );
  }
}
