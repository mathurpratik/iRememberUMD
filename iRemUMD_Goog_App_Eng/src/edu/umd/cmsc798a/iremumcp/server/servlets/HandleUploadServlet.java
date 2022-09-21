/**
 * HandleUploadServlet.java
 * 
 * Description: GAE invokes this class AFTER upload has completed.
 * 			    By the time you get to this class the following 
 * 				information should be available to you: 
 * 					1) (lat,lon)
 * 					2) tags = [tag1,tag2,tag3,...etc]
 * 					3) blob key
 * 
 * File added: 12/19/2011	Pratik Mathur - Initial Import
 * 
 */
package edu.umd.cmsc798a.iremumcp.server.servlets;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;
import java.util.logging.Logger;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.Point;
import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;

import edu.umd.cmsc798a.iremumcp.server.dao.LocationDao;
import edu.umd.cmsc798a.iremumcp.server.dao.PMF;

public class HandleUploadServlet extends HttpServlet {

	private static final long serialVersionUID = -439536516636297870L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();
	private Logger log = Logger.getLogger(HandleUploadServlet.class.getName());

	public void doPost(HttpServletRequest req, HttpServletResponse res)
			throws ServletException, IOException {
		
		log.info("Upload.doPost()");
		Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
		double lat = new Double(req.getParameter("myLat"));
		double lng = new Double(req.getParameter("myLng"));
		String tags = req.getParameter("myTags");
		String key = blobs.get("myFile").getKeyString();
		BlobKey bk = new BlobKey(key);

		PersistenceManager pm = PMF.get().getPersistenceManager();
		String tagsArr[] = tags.split(",");
		
		// LOGGING STUFF
		res.getWriter().write("lat is " + req.getParameter("myLat"));
		res.getWriter().write("lng is " + req.getParameter("myLng"));
		res.getWriter().write("tags are: " + tagsArr.toString());
		
		
		log.info("tags are:" + Arrays.toString(tagsArr));
		res.getWriter().write("blob key is " + key);
		// LOGGEND END
		
		Point p = new Point(Double.valueOf(lat), Double.valueOf(lng));
		List<String> cells = GeocellManager.generateGeoCell(p);
		LocationDao obj = new LocationDao();
		obj.setLatitude(lat);    // set latitutde
		obj.setLongitude(lng);   // set longitude
		obj.setGeocells(cells);  // set geo cell
		obj.setBlobKey(bk);      // set blob key
		obj.setTags(this.convertArrayToTreeSet(tagsArr));  // set sorted tags
		try {
			pm.makePersistent(obj);
		} finally {
			pm.close();
		}
		res.getWriter().write(
				"<a href=\"handledownload?blob-key=" + bk.getKeyString()
						+ "\"> Click Here To Get the Just Uploaded file </a>");
	}
	
	public TreeSet <String> convertArrayToTreeSet(String [] arr){
		TreeSet <String> returnVal = new TreeSet<String>();
		
		int x = 0;
		for (String s : arr) {
			returnVal.add(s);
			x++;
		}
		return returnVal;
	}
}
