/**
 * OWASP Enterprise Security API (ESAPI)
 * 
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2011 - The OWASP Foundation
 * 
 * The ESAPI is published by OWASP under the BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 * 
 * @author Damon Miller
 * @created 2011
 */
component extends="mxunit.framework.TestCase" {

	/*
	 * All CFESAPI test cases extend this component. If your MXUnit path is different, you can change it here to affect all tests.
	 * 
	 * If you need anything applied to all test cases, put them here
	 */
	Assert = {};
	Assert["assertTrue"] = assertTrue;
	Assert["assertFalse"] = assertFalse;
	Assert["assertEquals"] = assertEquals;

	instance.javaCache = {};

	/**
	 * Returns a reference to the specified Java class.
	 * Internally, this stores the reference for reuse to save on the number of classes created per request.
	 */
	
	private function newJava(required classpath) {
		if(!structKeyExists(instance.javaCache, arguments.classpath)) {
			instance.javaCache[arguments.classpath] = createObject("java", arguments.classpath);
		}
		return instance.javaCache[arguments.classpath];
	}
	
	/**
	 * Return an empty byte array with specified length
	 */
	
	private binary function newByte(required numeric len) {
		StringBuilder = newJava("java.lang.StringBuilder").init();
		StringBuilder.setLength(arguments.len);
		return StringBuilder.toString().getBytes();
	}
	
	/**
	 * Deletes the users.txt file from the User's Home directory.
	 * This prevents the file from getting too large and causing the test cases to take an extremely long time to run.
	 */
	
	private void function cleanUpUsers() {
		local.filePath = newJava("java.lang.System").getProperty("user.home") & "/esapi/users.txt";
		if(fileExists(local.filePath)) {
			try {
				fileDelete(local.filePath);
			}
			catch(Any e) {
			}
		}
	}
	
}