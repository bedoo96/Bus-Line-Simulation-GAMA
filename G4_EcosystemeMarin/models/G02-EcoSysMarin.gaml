/**
* Name: G02SimEcoMar
* Based on the internal empty template. 
* Author: Obed
* Tags: 
*/


model EcoSysMarin

global {
    int environment_size <- 100;
    int nb_coraux_init <- 10;
    int nb_poissons_init <- 5;
    int nb_poissons_max <- 50;
    int nb_predateurs_init <- 5;
    float poissons_max_energy <- 1.0;
	float poissons_max_transfer <- 0.1;
	float poissons_energy_consum <- 0.5;
	float predateur_max_energy <- 1.0;
	float predateur_energy_transfer <- 0.5;
	float predateur_energy_consum <- 0.5;
    geometry shape <- cube(environment_size);  
    file predateur_img <- file('../includes/pred.png');
    file poisson_img <- file('../includes/poisson_img.png');
    file coraux_img <- file('../includes/coraux_img.png');
    
    init {
    	create eau number: 1;
        create coraux number: nb_coraux_init {
            set location <- {rnd(environment_size), 100, rnd(environment_size)};
            energy_corail <- rnd(1.0,10.0,0.5);
           // write energy_corail;
        }
       create poissons number: nb_poissons_init {
            set location <- {rnd(environment_size), 50, rnd(environment_size)};
            position_initiale <- location;
         
 	}
 	
        create predateurs number: nb_predateurs_init {
           set location <- {rnd(environment_size), 20, rnd(environment_size)};
            position_initiale_predateur <- location;
            set zonevisited <- circle(rayon_observation);
        }
    }


species eau{
	float temperature <- 25.0;
	int compteur <- 50;
	string etat_seuil <- "premier";
	bool is_check <- false;
	
	
	
	reflex changement_temperature{
		compteur <- compteur - 1;
		if(compteur = 0){
			temperature <- rnd_choice([25.0::0.80, 30.0::0.10, 35.0::0.80]);//on a rajouter les probabilites de changement de temperature
			compteur <- 50;
		}
		
	}
}

species coraux {
    float food_value <- 0.1; // Valeur nutritionnelle du corail
    bool isEaten <- false; // Pour déterminer si le corail a été mangé
    bool isAlive <- true;
    rgb couleur <- #blue;
    float energy_corail;
     float energy; // Énergie actuelle du corail
    int last_reproduction_cycle <- 0; 
    int capacite_max_coraux <- 20;// Dernier cycle de reproduction
    int cycle_die <-0;
    //float co_en <- 0.0; test
    
    
     aspect basic {
     	if(isAlive = true){
//     		 draw sphere( environment_size * 0.02) color: couleur; 
     		 draw coraux_img size:( environment_size * 0.06) color: couleur; 
     	}      
        
    }
    
    
reflex reproduction {
    list<eau> temperature_eau <- list(eau);
    if (temperature_eau != []) {
        float temp <- temperature_eau[0].temperature;
        if ((cycle - last_reproduction_cycle > 10) and (temp = 30) and (length(coraux) < capacite_max_coraux)) {
            create coraux number: 1 {
                location <- {rnd(environment_size), 100, rnd(environment_size)};
                energy_corail <- rnd(0.5 * self.energy_corail);
            }
            energy_corail <- energy_corail - 0.2 * energy_corail;
            last_reproduction_cycle <- cycle;
        }
    }
}
reflex blanchiment{
	 list<eau> temperature_eau <- list(eau);
    if (temperature_eau != []) {
        float temp <- temperature_eau[0].temperature;
        if (temp =35){
        	couleur <- #white;
        	if (cycle - cycle_die = 2){
        		do die;
        	}
        }
        }
}
reflex mourrir{
	if (energy_corail <= 0 or isEaten){
//				do die;
		isAlive <- false;
			}  	
}

}

species poissons skills: [moving3D] {
    float energy <- rnd(100.0, 200.0, 10.0); //energy est variable en fonction de chaque poisson
    float max_energy <- rnd(100.0, 250.0, 10.0);//energie maximale est variable en fonction de chaque poisson
    float energy_consum <- rnd(10.0, 50.0, 5.0);//energie consommee est variable en fonction de chaque poisson
    rgb couleur <- #yellow;
    point sa_destination;
    bool peut_marcher <- true;
    bool deja_mange <- false;
    string mission <- "rassasie";
    coraux coraux_proche;
    bool poissonisEaten <- false;
    bool poissonsisEaten <-false;
    point position_initiale ;
    int last_reproduction_cycle <- 0; // Ajouter cet attribut à l'espèce
    int capacite_max_poissons <- 30;
    bool poisson_is_alive <- true;
    
     aspect basic {
    	if(poisson_is_alive = true){
//     		 draw sphere( environment_size * 0.02) color: couleur;
     		 draw poisson_img size:( environment_size * 0.04) color: couleur; 
     	} 
	}
	
reflex poisson_mourrir{
	if (energy <= 0 or poissonisEaten){
				
		poisson_is_alive <- false;
		//do die;
			}  	
}

   reflex move{
   	if(mission = "rassasie"){
   		sa_destination <- nil;
   		do wander;
    		energy <- energy - 5.0;
   		if(energy <= rnd(10.0,20.0,5.0)){
  			mission<- "faim";
   			deja_mange <- false;
    		
  		}
   	}
   	
   	
    	if (mission = "faim" ){
  		list<coraux> liste_coraux <- list(coraux) where(each distance_to self <= 200 and each.isAlive);
    		if(liste_coraux != [] ){
    			coraux_proche <- first(liste_coraux sort_by (self distance_to each));
   			sa_destination <- coraux_proche.location;
    			coraux_proche.couleur <- #purple;    			
    			deja_mange <- true;
    			mission <- "chercher la nourriture";
    		}else{
    			do wander;
    		}
    		
    	}
   	
    	if(mission = "chercher la nourriture" and self distance_to sa_destination <=4.0 ){
  			peut_marcher <- false; 
  			mission <- "manger";
     	}
     	

if (mission = "manger" and coraux_proche != nil) {
	if (coraux_proche.isAlive = false){
		sa_destination <- position_initiale;
		//mission <- "retour_debut";
		write "retour";
//		couleur <-# white;
		
	}
    energy <- energy + 5.0; 
    coraux_proche.energy_corail <- coraux_proche.energy_corail - 0.5;
    if (coraux_proche.energy_corail <= 0) {
        coraux_proche.isEaten <- true;
    }  
    write energy;
    if (energy >= max_energy) {
        mission <- "rassasie";
    }
} 
    	
    	if(mission = "rassasie" and deja_mange= true){
    		sa_destination <- position_initiale;
   		peut_marcher <- true;
    		do wander;
   		energy <- energy - 5.0;
    		mission <- "retour_debut";
    
    	}
    	
    	

    	
   	if(mission = "retour_debut" ){
   		if sa_destination != nil and distance_to(self, sa_destination) <= 5.0{
    			sa_destination <- nil;
    			do wander;
    			mission <- "rassasie";
    		}
    		
   	}
   	
   	if(mission = "rassasie" and deja_mange = true and sa_destination != []){
   		couleur <- #white;
   	}

   	if(peut_marcher = true){
    		do action: goto target: sa_destination speed: 3.0;
    	}
    	
    	if(peut_marcher = true and sa_destination != nil){
        do action: goto target: sa_destination speed: 3.0;
    }
    }
    
    
    
    
  
    
    


reflex se_reproduire {
    if (cycle - last_reproduction_cycle > 100 and energy > 0.9 * max_energy and (length(poissons) < capacite_max_poissons)) { // 100 cycles entre reproductions
        int nombre_descendants <- rnd(1, 2);
        loop i from: 1 to: nombre_descendants {
            create poissons number: 1 {
                location <- {rnd(environment_size), 50, rnd(environment_size)};
                energy <- 0.5 * max_energy;
            }
        }
        energy <- energy - 0.1 * max_energy;
        last_reproduction_cycle <- cycle; // Mettre à jour le dernier cycle de reproduction
    }
}
}



// 2024/05/09 7h55

species predateurs skills: [moving3D] {
    float energy_pre <- rnd(100.0, 200.0, 10.0);
    float max_energy_pre <- rnd(100.0, 250.0, 10.0);
    float energy_consum_pre <- rnd(10.0, 50.0, 5.0);
    rgb color <- #red;
    point destination_predateur;
    point position_initiale_predateur;
    bool peut_marcher <- true;
    bool deja_mange <- false;
    string mission <- "rassasie";
    int rayon_observation <-20;
    poissons proie_proche;
    geometry zonevisited <- nil;
    list closest_unvisited_point;
    int last_reproduction_cycle_preda <- 0;
    int capacite_max_predateurs <- 15;
   
    

    
	reflex move when:(zonevisited.area < world.shape.area){
		
		if(mission = "rassasie"){
			//write 'rassasier pre';
			destination_predateur <- nil;
    		do wander;
    		energy_pre <- energy_pre-1.0;
    		color <-#red;
    		if(energy_pre <= rnd(50.0,60.0,5.0)){
    			mission<- "faim";
    			deja_mange <- false;
    		
    		}
		}
    	
    	
    	if (mission = "faim"  ){
    		write 'faim pre';
    		 do action: wander amplitude: 256.5;
		// mettre a jour le zonevisited <- lui + circle(rayon_observation)
		set zonevisited <- position_initiale_predateur union circle(rayon_observation);
		//Choisir le point le plus proche
		closest_unvisited_point <- list(world.shape - zonevisited);
		do goto target: one_of(closest_unvisited_point);
    		list<poissons> liste_poissons <- list(poissons) where(each distance_to self <= rayon_observation);
    		if(liste_poissons != []){
    			proie_proche <- first(liste_poissons sort_by (self distance_to each));
    			self.location <- point(position_initiale_predateur union circle(rayon_observation));
    			color <- #orange;
    			destination_predateur <- proie_proche.location;
    			proie_proche.couleur <- #green;
    			mission <- "chercher la nourriture";
    		}
    		
    	}
    	
    	
    	if(mission = "chercher la nourriture" and self distance_to destination_predateur <=8.0){
    		
    		write 'cherch nour pre';
   			peut_marcher <- false; 
   			mission <- "manger";
      	}
      	
      	if(mission = "manger" and proie_proche != nil){
      		write 'mag pre';
      		energy_pre <- energy_pre + 5.0;
      		write energy_pre;
      		proie_proche.energy <- proie_proche.energy - 0.5;
    if (proie_proche.energy<= 0) {
        proie_proche.poissonisEaten <- true;
    } 
      		if(energy_pre >= max_energy_pre){
      			mission <- "rassasie";
      			write 'rassasie1';      			
      		}
      		deja_mange <-true;
      	}
    	
		if(mission = "rassasie" and deja_mange= true){
			write 'rassasier preda';
    		destination_predateur <- position_initiale_predateur;
    		peut_marcher <- true;
    		do wander;
    		mission <- "retour_debut";
    	}
////    	
//    	
		if(mission = "retour_debut" ){
			write 'retour deb pred';
			if destination_predateur != nil and distance_to(self, destination_predateur) <= 5.0{
				destination_predateur <- nil;
    			do wander;
    			mission <- "rassasie";
    		}
    	}
    	

    	
		if(peut_marcher = true){
    		do action: goto target: destination_predateur speed: 3.0;
    	}
    }
    
   
  
    


reflex predateur_mourrir{
	if (energy_pre <= 0){
		do die;
			}  	
}

    aspect basic {
//        draw sphere( environment_size * 0.02) color: color;
        draw predateur_img size:( environment_size * 0.2) color: color;
        if(zonevisited != nil){
			//draw zonevisited color: #gray;
		} 
    }
}



}
experiment EcoSysMarin type: gui {
//    parameter "Size of environment: " var: environment_size min: 50 max: 200 category: "Environment";
//    parameter "Initial number of poissons: " var: nb_poissons_init min: 0 max: 1000 category: "poissons";
//	parameter "Poissons max energy: " var: poissons_max_energy category: "poissons";
//	parameter "Poissons max transfer: " var: poissons_max_transfer category: "poissons";
//	parameter "Poissons energy consumption: " var: poissons_energy_consum category: "poissons";
  
    output {
        display View3D type: 3d background: rgb(10, 40, 55) {
            graphics "env" {
                draw cube(environment_size) color: #black wireframe: true;    
            }
            species coraux aspect: basic ;
            //transparency:0.9;
            species poissons aspect: basic;
            species predateurs aspect: basic;
        }
//        monitor "Number of poissons" value: nb_poissons_init;
//		monitor "Number of predateurs" value: nb_predateurs_init;
    }
}

