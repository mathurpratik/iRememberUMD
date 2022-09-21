/**
 * SearchByTagsAndBoundingBoxServlet.java
 * 
 * Description: Receives a request from user to search for data with 
 * 				specific tags and bounding box map region
 * 
 * File added: 12/24/2011	Pratik Mathur - Initial Import
 * 
 */

package edu.umd.cmsc798a.iremumcp.server.servlets;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.TreeSet;
import java.util.logging.Logger;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.BoundingBox;

import edu.umd.cmsc798a.iremumcp.server.dao.LocationDao;
import edu.umd.cmsc798a.iremumcp.server.dao.PMF;

public class SearchByTagsAndBoundingBoxServlet extends HttpServlet {

	private static final long serialVersionUID = -8476246399648322397L;
	
	/**
	 * doGet - override function from HttpServlet
	 * @param req - accepts incoming request
	 * @param res - XML response includes (lat,lon) and associated blob key
	 */
	public void doGet(HttpServletRequest req, HttpServletResponse res)
	throws IOException {
		Logger log = Logger.getLogger(GetNewBlobKeyServlet.class.getName());
		log.info("SearchByTagsAndBoundingBox.doGet()");
		
		// Incoming data: latitude and longitude of south-west and north-east points
        double latS = Double.parseDouble(req.getParameter("south"));
        double latN = Double.parseDouble(req.getParameter("north"));
        double lonW = Double.parseDouble(req.getParameter("west"));
        double lonE = Double.parseDouble(req.getParameter("east"));
        
        // Incoming data: tags
        String tags = req.getParameter("tags");
        

        // Transform this to a bounding box
        BoundingBox bb = new BoundingBox(latN, lonE, latS, lonW);

        // Calculate the geocells list to be used in the queries (optimize list of cells that complete the given bounding box)
        List<String> cells = GeocellManager.bestBboxSearchCells(bb, null);
        
        String queryString = "select from edu.umd.cmsc798a.iremumcp.server.dao.LocationDao where geocellsParameter.contains(geocells)";
        PersistenceManager pm = PMF.get().getPersistenceManager();
        Query query = pm.newQuery(queryString);
        query.declareParameters("String geocellsParameter");
        List<LocationDao> objects = (List<LocationDao>) query.execute(cells);
        
        List<LocationDao> matchedLocations = filterByTags(tags, objects);
        
        printToXML(matchedLocations, res);
	}
	
	
	/**
	 * Returns a response that looks like
	 * 
	 * <Locations>
	 * 	  <lat>-77.5</lat>
	 * 	  <lat>40<lat>
	 *    <blobkey>9djtjl34jkl3kljgkjl45kjl4lkhjdl90349034-fsfjkljasfdljg9834hdfgk34893hgidfgqreiio34f</blobkey>
	 * </Locations>
	 * @param matchedLocations - locations that contained searched tags
	 * @param res - response to be written to
	 */
	public void printToXML(List<LocationDao>matchedLocations, HttpServletResponse res){
		Iterator<LocationDao> matchedLocationIt = matchedLocations.iterator();
		
		StringBuilder output = new StringBuilder();
		output.append("<Locations>\n");
		while (matchedLocationIt.hasNext()){
			output.append("<Location>\n");
			LocationDao currLocation = matchedLocationIt.next();
			output.append("<lat>" + currLocation.getLatitude() + "</lat>");
			output.append("<lng>" + currLocation.getLongitude() + "</lng>");
			output.append("<blobkey>" + currLocation.getData().getKeyString() + "</blobkey>");
			output.append("</Location>\n");
		}
		output.append("</Locations>");
		
		try {
			res.getWriter().write(output.toString());
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public List<LocationDao> filterByTags(String targetTags, List<LocationDao> locations){
		// if there are no tags to be searched for
		if (isNullOrEmptyString(targetTags)){
			
			// return all locations
			return locations;
		}
		
		// prepare value to be returned
		ArrayList <LocationDao> returnVal = new ArrayList<LocationDao>();	

    	// get tags to be searched
    	String [] searchTags = targetTags.toLowerCase().trim().split(",");

    	// go through locations and weed out the ones with matching tags
    	Iterator <LocationDao> locationsIt = locations.iterator();

    	
    	while (locationsIt.hasNext()){
    		// get current location 
        	LocationDao currLocation = locationsIt.next();
        	
        	// get tags associated with this location
        	TreeSet <String>currTags = currLocation.getTags();
        	
        	// check of any of target tags are in "currTags".
        	for (int x = 0; x < searchTags.length; x++){
        		if (currTags.contains(searchTags[x])){
        			// at this point no need to continue search 
        			// since we found a hit
        			
        			// add this location to return value
        			returnVal.add(currLocation);
        			
        			break; // break out of for loop and goto next location object to be searched.
        		}
        	} // end for: search tags
        } // end while : locations
        
		return returnVal;
	}
	
	public boolean isNullOrEmptyString(String str){
		if (str == null){
			return true;
		}
		
		if (str.trim().equals("")){
			return true;
		}
		
		return false;
	}
}
