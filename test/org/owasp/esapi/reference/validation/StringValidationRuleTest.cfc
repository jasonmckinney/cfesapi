<!--- /**
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
<cfcomponent displayname="StringValidationRuleTest" extends="cfesapi.test.org.owasp.esapi.lang.TestCase" output="false">

	<cfscript>
		instance.ESAPI = newComponent("cfesapi.org.owasp.esapi.ESAPI").init();
	</cfscript>

	<cffunction access="public" returntype="void" name="testWhitelistPattern" output="false">
		<cfset var local = {}/>

		<cfscript>

			local.validationRule = newComponent("cfesapi.org.owasp.esapi.reference.validation.StringValidationRule").init(instance.ESAPI, "Alphabetic");

			assertEquals("Magnum44", local.validationRule.getValid("", "Magnum44"));
			local.validationRule.addWhitelistPattern("^[a-zA-Z]*");
			try {
				local.validationRule.getValid("", "Magnum44");
				fail("Expected Exception not thrown");
			}
			catch(cfesapi.org.owasp.esapi.errors.ValidationException ve) {
				assertTrue(len(ve.message));
			}
			assertEquals("MagnumPI", local.validationRule.getValid("", "MagnumPI"));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testWhitelistPattern_Invalid" output="false">
		<cfset var local = {}/>

		<cfscript>

			local.validationRule = newComponent("cfesapi.org.owasp.esapi.reference.validation.StringValidationRule").init(instance.ESAPI, "");

			//null white list patterns throw IllegalArgumentException
			/* NULL test
			try {
			    local.pattern = null;
			    local.validationRule.addWhitelistPattern(local.pattern);
			    fail("Expected Exception not thrown");
			}
			catch (java.lang.IllegalArgumentException ie) {
			    assertTrue(len(ie.message));
			} */
			/* NULL test
			try {
			    local.pattern = null;
			    validationRule.addWhitelistPattern(local.pattern);
			    fail("Expected Exception not thrown");
			}
			catch (java.lang.IllegalArgumentException ie) {
			    assertTrue(len(ie.message));
			}*/
			//invalid white list patterns throw PatternSyntaxException
			try {
				local.pattern = "_][0}[";
				local.validationRule.addWhitelistPattern(local.pattern);
				fail("Expected Exception not thrown");
			}
			catch(java.lang.IllegalArgumentException ie) {
				assertTrue(len(ie.message));
			}
		</cfscript>

	</cffunction>

	<!--- this test locks up ACF8
	    <cffunction access="public" returntype="void" name="testWhitelist" output="false">

	    <cfscript>
	        local.validationRule = newComponent("cfesapi.org.owasp.esapi.reference.validation.StringValidationRule").init(instance.ESAPI, "");

	        local.whitelistArray = ['a', 'b', 'c'];
	        assertEquals("abc", local.validationRule.whitelist("12345abcdef", local.whitelistArray));
	    </cfscript>

	</cffunction>--->

	<cffunction access="public" returntype="void" name="testBlacklistPattern" output="false">
		<cfset var local = {}/>

		<cfscript>

			local.validationRule = newComponent("cfesapi.org.owasp.esapi.reference.validation.StringValidationRule").init(instance.ESAPI, "NoAngleBrackets");

			assertEquals("beg <script> end", local.validationRule.getValid("", "beg <script> end"));
			local.validationRule.addBlacklistPattern("^.*(<|>).*");
			try {
				local.validationRule.getValid("", "beg <script> end");
				fail("Expected Exception not thrown");
			}
			catch(cfesapi.org.owasp.esapi.errors.ValidationException ve) {
				assertTrue(len(ve.message));
			}
			assertEquals("beg script end", local.validationRule.getValid("", "beg script end"));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testBlacklistPattern_Invalid" output="false">
		<cfset var local = {}/>

		<cfscript>

			local.validationRule = newComponent("cfesapi.org.owasp.esapi.reference.validation.StringValidationRule").init(instance.ESAPI, "");

			//null black list patterns throw IllegalArgumentException
			/* NULL test
			try {
			    local.pattern = null;
			    local.validationRule.addBlacklistPattern(local.pattern);
			    fail("Expected Exception not thrown");
			}
			catch (java.lang.IllegalArgumentException ie) {
			    assertTrue(len(ie.message));
			}*/
			/* NULL test
			try {
			    local.pattern = null;
			    local.validationRule.addBlacklistPattern(local.pattern);
			    fail("Expected Exception not thrown");
			}
			catch (java.lang.IllegalArgumentException ie) {
			    assertTrue(len(ie.message));
			}*/
			//invalid black list patterns throw PatternSyntaxException
			try {
				local.pattern = "_][0}[";
				local.validationRule.addBlacklistPattern(local.pattern);
				fail("Expected Exception not thrown");
			}
			catch(java.lang.IllegalArgumentException ie) {
				assertTrue(len(ie.message));
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testCheckLengths" output="false">
		<cfset var local = {}/>

		<cfscript>

			local.validationRule = newComponent("cfesapi.org.owasp.esapi.reference.validation.StringValidationRule").init(instance.ESAPI, "Max12_Min2");
			local.validationRule.setMinimumLength(2);
			local.validationRule.setMaximumLength(12);

			assertTrue(local.validationRule.isValidESAPI("", "12"));
			assertTrue(local.validationRule.isValidESAPI("", "123456"));
			assertTrue(local.validationRule.isValidESAPI("", "ABCDEFGHIJKL"));

			assertFalse(local.validationRule.isValidESAPI("", "1"));
			assertFalse(local.validationRule.isValidESAPI("", "ABCDEFGHIJKLM"));

			local.errorList = newComponent("cfesapi.org.owasp.esapi.ValidationErrorList").init();
			assertEquals("1234567890", local.validationRule.getValid("", "1234567890", local.errorList));
			assertEquals(0, local.errorList.size());
			assertEquals("", local.validationRule.getValid("", "123456789012345", local.errorList));
			assertEquals(1, local.errorList.size());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testAllowNull" output="false">
		<cfset var local = {}/>

		<cfscript>

			local.validationRule = newComponent("cfesapi.org.owasp.esapi.reference.validation.StringValidationRule").init(instance.ESAPI, "");

			assertFalse(local.validationRule.isAllowNull());
			assertFalse(local.validationRule.isValidESAPI("", ""));

			local.validationRule.setAllowNull(true);
			assertTrue(local.validationRule.isAllowNull());
			assertTrue(local.validationRule.isValidESAPI("", ""));
		</cfscript>

	</cffunction>

</cfcomponent>