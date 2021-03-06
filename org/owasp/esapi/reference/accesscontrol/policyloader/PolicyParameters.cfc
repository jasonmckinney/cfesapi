<!---
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
    --->
<cfinterface>

	<cffunction access="public" returntype="any" name="get" output="false"
	            hint="Follows the contract for java.util.Map;">
		<cfargument type="String" name="key" required="true"/>

	</cffunction>

	<cffunction access="public" returntype="void" name="set" output="false"
	            hint="This works just like a Map, except it will throw an exception if lock() has been called.">
		<cfargument type="String" name="key" required="true"/>
		<cfargument type="any" name="value" required="true"/>

	</cffunction>

	<cffunction access="public" returntype="void" name="put" output="false"
	            hint="This is a convenience method for developers that prefer to think of this as a map instead of being bean-like. ">
		<cfargument type="String" name="key" required="true"/>
		<cfargument type="any" name="value" required="true"/>

	</cffunction>

	<cffunction access="public" returntype="void" name="lock" output="false"
	            hint="This makes the map itself read only, but the mutability of objects that this map contains is not affected. Specifically, properties cannot be added or removed and the reference cannot be changed to a different object, but this does not change whether the values that the object contains can be changed.">
	</cffunction>

</cfinterface>