/**
* Name: kmeans
* Based on the internal empty template. 
* Author: Obed
* Tags: 
*/


model kmeans

global {
    // ... (your existing code)

    // New agent for central agent C1
    agent C1 {
        string nom <- "CentralAgent";
        point location <- entre_ferme;
        list<points> liste_points;
        
        reflex init {
            // Create 10 points and assign them to the central agent
            create points number: 10 {
                liste_points <- agentset(points);
            }
        }

        // K-means clustering method
        reflex k_means {
            list<points> cluster1;
            list<points> cluster2;
            
            // Assuming points have a 'centre' attribute, you may need to adapt this based on your actual agent structure
            point center1 <- liste_points[1].centre;
            point center2 <- liste_points[2].centre;
            
            do cluster1 <- liste_points in_range: center1 max: 50.0;
            do cluster2 <- liste_points in_range: center2 max: 50.0;
            
            // Update the centroids based on the mean of each cluster
            center1 <- mean_of(cluster1.location);
            center2 <- mean_of(cluster2.location);
            
            // Repeat the process until convergence (you may need to define convergence criteria)
        }
    }
}

species points {
    string nom <- "Point";
    point location;
    point centre; // Center assigned by k-means

    aspect default {
        draw circle: 2 color: #blue;
    }
    
    // Other attributes and reflexes as needed
}

