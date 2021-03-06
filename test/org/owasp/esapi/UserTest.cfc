﻿<!--- /**
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
 */ --->
<cfcomponent displayname="UserTest" extends="cfesapi.test.org.owasp.esapi.lang.TestCase" output="false">

	<cfscript>
		instance.ESAPI = newComponent("cfesapi.org.owasp.esapi.ESAPI").init();
	</cfscript>

	<cffunction access="public" returntype="void" name="setUp" output="false">

		<cfscript>
			cleanUpUsers();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="tearDown" output="false">

		<cfscript>
			// none
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testAllMethods" output="false">
		<cfset var local = {}/>

		<cfscript>
			// create a user to test Anonymous
			local.accountName = instance.ESAPI.randomizer().getRandomString(8, createObject("java", "org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.authenticator = instance.ESAPI.authenticator();
			local.password = local.authenticator.generateStrongPassword();
			local.user = local.authenticator.createUser(local.accountName, local.password, local.password);

			// test the rest of the Anonymous user
			User.ANONYMOUS = newComponent("cfesapi.org.owasp.esapi.User$ANONYMOUS").init(instance.ESAPI);
			local.empty = [];
			try {
				User.ANONYMOUS.addRole("");
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.addRoles(local.empty);
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.changePassword("", "", "");
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.disable();
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.enable();
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.getAccountId();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getAccountName();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getName();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getCSRFToken();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getExpirationTime();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getFailedLoginCount();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getLastFailedLoginTime();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getLastLoginTime();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getLastPasswordChangeTime();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getRoles();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.getScreenName();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.addSession("");
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.removeSession("");
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.incrementFailedLoginCount();
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.isAnonymous();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.isEnabled();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.isExpired();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.isInRole("");
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.isLocked();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.isLoggedIn();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.isSessionAbsoluteTimeout();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.isSessionTimeout();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.lock();
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.loginWithPassword(password="");
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.logout();
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.removeRole("");
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.resetCSRFToken();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.setAccountName("");
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.setExpirationTime(newJava("java.util.Date").init());
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.setRoles(local.empty);
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.setScreenName("");
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.unlock();
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.verifyPassword("");
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.setLastFailedLoginTime(newJava("java.util.Date").init());
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.setLastLoginTime(newJava("java.util.Date").init());
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.setLastHostAddress("");
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.setLastPasswordChangeTime(newJava("java.util.Date").init());
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.getEventMap();
				fail("");
			}
			catch(java.lang.RuntimeException e) {
			}
			try {
				User.ANONYMOUS.getLocaleESAPI();
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
			try {
				User.ANONYMOUS.setLocaleESAPI("");
			}
			catch(java.lang.RuntimeException e) {
				fail("");
			}
		</cfscript>

	</cffunction>

</cfcomponent>