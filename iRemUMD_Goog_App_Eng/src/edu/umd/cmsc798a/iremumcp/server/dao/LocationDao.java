/**
 * ObjectToSave.java
 * 
 * Description: Persists the following to database:
 * 				1) (lat,lon)
 * 				2) tags
 * 				3) geocells - see description below
 * 
 * File added: 12/19/2011	Pratik Mathur - Initial Import
 * 
 */


/*
 * """Defines the notion of 'geocells' and exposes methods to operate on them.

A geocell is a hexadecimal string that defines a two dimensional rectangular
region inside the [-90,90] x [-180,180] latitude/longitude space. A geocell's
'resolution' is its length. For most practical purposes, at high resolutions,
geocells can be treated as single points.

Much like geohashes (see http://en.wikipedia.org/wiki/Geohash), geocells are
hierarchical, in that any prefix of a geocell is considered its ancestor, with
geocell[:-1] being geocell's immediate parent cell.

To calculate the rectangle of a given geocell string, first divide the
[-90,90] x [-180,180] latitude/longitude space evenly into a 4x4 grid like so:

             +---+---+---+---+ (90, 180)
             | a | b | e | f |
             +---+---+---+---+
             | 8 | 9 | c | d |
             +---+---+---+---+
             | 2 | 3 | 6 | 7 |
             +---+---+---+---+
             | 0 | 1 | 4 | 5 |
  (-90,-180) +---+---+---+---+

NOTE: The point (0, 0) is at the intersection of grid cells 3, 6, 9 and c. And,
      for example, cell 7 should be the sub-rectangle from
      (-45, 90) to (0, 180).

Calculate the sub-rectangle for the first character of the geocell string and
re-divide this sub-rectangle into another 4x4 grid. For example, if the geocell
string is '78a', we will re-divide the sub-rectangle like so:

               .                   .
               .                   .
           . . +----+----+----+----+ (0, 180)
               | 7a | 7b | 7e | 7f |
               +----+----+----+----+
               | 78 | 79 | 7c | 7d |
               +----+----+----+----+
               | 72 | 73 | 76 | 77 |
               +----+----+----+----+
               | 70 | 71 | 74 | 75 |
  . . (-45,90) +----+----+----+----+
               .                   .
               .                   .

Continue to re-divide into sub-rectangles and 4x4 grids until the entire
geocell string has been exhausted. The final sub-rectangle is the rectangular
region for the geocell.
"""

 */

package edu.umd.cmsc798a.iremumcp.server.dao;

/*
 Copyright 2010 Alexandre Gellibert

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at http://www.apache.org/licenses/
 LICENSE-2.0 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an "AS IS"
 BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 implied. See the License for the specific language governing permissions
 and limitations under the License.
 */

import java.util.List;
import java.util.TreeSet;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.beoui.geocell.annotations.Geocells;
import com.beoui.geocell.annotations.Latitude;
import com.beoui.geocell.annotations.Longitude;
import com.google.appengine.api.blobstore.BlobKey;

@PersistenceCapable
public class LocationDao {

	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Long id;

	@Persistent
	@Latitude
	private double latitude;

	@Persistent
	@Longitude
	private double longitude;

	@Persistent
	@Geocells
	private List<String> geocells;

	@Persistent
	private TreeSet<String> tags;
	
	@Persistent
	@Blobkeydata
	private BlobKey blobKeydata;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public double getLatitude() {
		return latitude;
	}

	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	public double getLongitude() {
		return longitude;
	}

	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}

	public List<String> getGeocells() {
		return geocells;
	}

	public void setGeocells(List<String> geocells) {
		this.geocells = geocells;
	}

	public TreeSet<String> getTags() {
		return tags;
	}

	public void setTags(TreeSet<String> tags) {
		this.tags = tags;
	}
	
	public BlobKey getData() {
		return blobKeydata;
	}

	public void setBlobKey(BlobKey data) {
		this.blobKeydata = data;
	}
}
