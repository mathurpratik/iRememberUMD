package edu.umd.cmsc798a.iremumcp.server.servlets;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.BoundingBox;

import edu.umd.cmsc798a.iremumcp.server.dao.PMF;
import edu.umd.cmsc798a.iremumcp.server.dao.TestObjectToSave;

public class TestSearchObjectToSaveServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse res)
	throws ServletException, IOException {
		double latS = Double.parseDouble(req.getParameter("south"));
		double latN = Double.parseDouble(req.getParameter("north"));
		double lonW = Double.parseDouble(req.getParameter("west"));
		double lonE = Double.parseDouble(req.getParameter("east"));
		
		List<String> cells = new ArrayList<String>();
		List<TestObjectToSave> objects = new ArrayList<TestObjectToSave>(1);
		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		// Transform this to a bounding box
		BoundingBox bb = new BoundingBox(latN, lonE, latS, lonW);
		cells = GeocellManager.bestBboxSearchCells(bb, null);
		
		String queryString = "select from edu.umd.cmsc798a.iremumcp.server.dao.TestObjectToSave where geocellsParameter.contains(geocells)";
		javax.jdo.Query query = pm.newQuery(queryString);
		query.declareParameters("String geocellsParameter");
		objects = (List<TestObjectToSave>) query.execute(cells);
		
		Iterator<TestObjectToSave> objIt = objects.iterator();
		while (objIt.hasNext()){
			TestObjectToSave currObj = objIt.next();
			res.getWriter().print("lat = " + currObj.getLatitude() + ", lon = " + currObj.getLongitude() + "\n");
			
		}
	}
}


