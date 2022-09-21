/**
 * HandleDownloadServlet.java
 * 
 * Description: looks up blob associated with passed in blob key and 
 * 				returns it in the response as binary data.
 * 
 * File added: 12/19/2011	Pratik Mathur - Initial Import
 * 
 */

package edu.umd.cmsc798a.iremumcp.server.servlets;

import java.io.IOException;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobInfo;
import com.google.appengine.api.blobstore.BlobInfoFactory;
import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreServiceFactory;

public class HandleDownloadServlet extends HttpServlet {

	private static final long serialVersionUID = 794602418850207539L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		Logger log = Logger.getLogger(HandleDownloadServlet.class.getName());
		log.info("HandleDownloadServlet.doGet()");
		resp.getWriter().write("downloading file" + req.getParameter("blob-key"));
		
		BlobKey blobKey = new BlobKey(req.getParameter("blob-key"));
		BlobInfoFactory blobInfoFactory = new BlobInfoFactory(DatastoreServiceFactory.getDatastoreService());
		BlobInfo b = blobInfoFactory.loadBlobInfo(blobKey);
		resp.setHeader("content-type", b.getContentType());
		resp.setHeader("content-disposition",
				"attachment; filename=" + b.getFilename());
		blobstoreService.serve(blobKey, resp);
	}
}
