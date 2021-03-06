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
<cfcomponent extends="cfesapi.org.owasp.esapi.lang.Object" output="false">

	<cfscript>
		instance.cipherTextVersion = 20110203;// Format: YYYYMMDD, max is 99991231.
		instance.serialVersionUID = instance.cipherTextVersion;// Format: YYYYMMDD
		instance.ESAPI = "";
		instance.logger = "";

		this.cipherSpec_ = [];
		this.raw_ciphertext_ = [];
		this.separate_mac_ = [];
		this.encryption_timestamp_ = 0;
		instance.kdfVersion_ = "";
		instance.kdfPrfSelection_ = "";

		// All the various pieces that can be set, either directly or indirectly via CipherSpec.
		CipherTextFlags = {ALGNAME=newComponent("cfesapi.org.owasp.esapi.crypto.CipherTextFlags").init("ALGNAME", 1), CIPHERMODE=newComponent("cfesapi.org.owasp.esapi.crypto.CipherTextFlags").init("CIPHERMODE", 2), PADDING=newComponent("cfesapi.org.owasp.esapi.crypto.CipherTextFlags").init("PADDING", 3), KEYSIZE=newComponent("cfesapi.org.owasp.esapi.crypto.CipherTextFlags").init("KEYSIZE", 4), BLOCKSIZE=newComponent("cfesapi.org.owasp.esapi.crypto.CipherTextFlags").init("BLOCKSIZE", 5), CIPHERTEXT=newComponent("cfesapi.org.owasp.esapi.crypto.CipherTextFlags").init("CIPHERTEXT", 6), INITVECTOR=newComponent("cfesapi.org.owasp.esapi.crypto.CipherTextFlags").init("INITVECTOR", 7)};

		// If we have everything set, we compare it to this using '==' which javac specially overloads for this.
		instance.allCtFlags = [CipherTextFlags.ALGNAME, CipherTextFlags.CIPHERMODE, CipherTextFlags.PADDING, CipherTextFlags.KEYSIZE, CipherTextFlags.BLOCKSIZE, CipherTextFlags.CIPHERTEXT, CipherTextFlags.INITVECTOR];

		// These are all the pieces we collect when passed a CipherSpec object.
		instance.fromCipherSpec = [CipherTextFlags.ALGNAME, CipherTextFlags.CIPHERMODE, CipherTextFlags.PADDING, CipherTextFlags.KEYSIZE, CipherTextFlags.BLOCKSIZE];

		// How much we've collected so far. We start out with having collected nothing.
		this.progress = [];
	</cfscript>

	<cffunction access="public" returntype="CipherText" name="init" output="false">
		<cfargument type="cfesapi.org.owasp.esapi.ESAPI" name="ESAPI" required="true"/>
		<cfargument type="cfesapi.org.owasp.esapi.crypto.CipherSpec" name="cipherSpec" required="false" hint="The cipher specification to use."/>
		<cfargument type="binary" name="cipherText" required="false" hint="The raw ciphertext bytes to use."/>

		<cfset var local = {}/>

		<cfscript>
			instance.ESAPI = arguments.ESAPI;
			instance.logger = instance.ESAPI.getLogger("CipherText");

			KeyDerivationFunction = newComponent("cfesapi.org.owasp.esapi.crypto.KeyDerivationFunction").init(instance.ESAPI);
			instance.kdfVersion_ = KeyDerivationFunction.kdfVersion;
			instance.kdfPrfSelection_ = KeyDerivationFunction.getDefaultPRFSelection();

			CryptoHelper = newComponent("cfesapi.org.owasp.esapi.crypto.CryptoHelper").init(instance.ESAPI);

			if(structKeyExists(arguments, "cipherSpec")) {
				this.cipherSpec_ = arguments.cipherSpec;
				if(structKeyExists(arguments, "cipherText")) {
					setCiphertext(arguments.cipherText);
				}
				receivedMany(instance.fromCipherSpec);
				local.iv = arguments.cipherSpec.getIV();
				if(structKeyExists(local, "iv")) {
					received(CipherTextFlags.INITVECTOR);
				}
			}
			else {
				this.cipherSpec_ = newComponent("cfesapi.org.owasp.esapi.crypto.CipherSpec").init(instance.ESAPI);// Uses default for everything but IV.
				receivedMany(instance.fromCipherSpec);
			}

			return this;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="CipherText" name="fromPortableSerializedBytes" output="false"
	            hint="Create a CipherText object from what is supposed to be a portable serialized byte array, given in network byte order, that represents a valid, previously serialized CipherText object using asPortableSerializedByteArray().">
		<cfargument type="binary" name="bytes" required="true" hint="A byte array created via CipherText.asPortableSerializedByteArray()"/>

		<cfset var local = {}/>

		<cfscript>
			local.cts = newComponent("cfesapi.org.owasp.esapi.crypto.CipherTextSerializer").init(ESAPI=instance.ESAPI, cipherTextSerializedBytes=arguments.bytes);
			return local.cts.asCipherText();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getCipherTransformation" output="false"
	            hint="Obtain the String representing the cipher transformation used to encrypt the plaintext. The cipher transformation represents the cipher algorithm, the cipher mode, and the padding scheme used to do the encryption. An example would be 'AES/CBC/PKCS5Padding'.">

		<cfscript>
			return this.cipherSpec_.getCipherTransformation();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getCipherAlgorithm" output="false"
	            hint="Obtain the name of the cipher algorithm used for encrypting the plaintext.">

		<cfscript>
			return this.cipherSpec_.getCipherAlgorithm();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="numeric" name="getKeySize" output="false"
	            hint="Retrieve the key size used with the cipher algorithm that was used to encrypt data to produce this ciphertext.">

		<cfscript>
			return this.cipherSpec_.getKeySize();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="numeric" name="getBlockSize" output="false"
	            hint="Retrieve the block size (in bytes!) of the cipher used for encryption. (Note: If an IV is used, this will also be the IV length.)">

		<cfscript>
			return this.cipherSpec_.getBlockSize();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getCipherMode" output="false"
	            hint="Get the name of the cipher mode used to encrypt some plaintext.">

		<cfscript>
			return this.cipherSpec_.getCipherMode();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getPaddingScheme" output="false"
	            hint="Get the name of the padding scheme used to encrypt some plaintext.">

		<cfscript>
			return this.cipherSpec_.getPaddingScheme();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="binary" name="getIV" required="true"
	            hint="Return the initialization vector (IV) used to encrypt the plaintext if applicable.">

		<cfscript>
			if(isCollected(CipherTextFlags.INITVECTOR)) {
				return this.cipherSpec_.getIV();
			}
			else {
				instance.logger.error(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "IV not set yet; unable to retrieve; returning null");
				return toBinary("");
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="requiresIV" output="false"
	            hint="Return true if the cipher mode used requires an IV. Usually this will be true unless ECB mode (which should be avoided whenever possible) is used.">

		<cfscript>
			return this.cipherSpec_.requiresIV();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="binary" name="getRawCipherText" output="false"
	            hint="Get the raw ciphertext byte array resulting from encrypting some plaintext.">
		<cfset var local = {}/>

		<cfscript>
			if(isCollected(CipherTextFlags.CIPHERTEXT)) {
				local.copy = newByte(arrayLen(this.raw_ciphertext_));
				newJava("java.lang.System").arraycopy(this.raw_ciphertext_, 0, local.copy, 0, arrayLen(this.raw_ciphertext_));
				return local.copy;
			}
			else {
				instance.logger.error(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Raw ciphertext not set yet; unable to retrieve; returning null");
				return toBinary("");
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="numeric" name="getRawCipherTextByteLength" output="false"
	            hint="Get number of bytes in raw ciphertext. Zero is returned if ciphertext has not yet been stored.">

		<cfscript>
			if(arrayLen(this.raw_ciphertext_)) {
				return arrayLen(this.raw_ciphertext_);
			}
			else {
				return 0;
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getBase64EncodedRawCipherText" output="false"
	            hint="Return a base64-encoded representation of the raw ciphertext alone. Even in the case where an IV is used, the IV is not prepended before the base64-encoding is performed. If there is a need to store an encrypted value, say in a database, this is NOT the method you should use unless you are using a 'fixed' IV. If you are NOT using a fixed IV, you should normally use getEncodedIVCipherText() instead.">

		<cfscript>
			return instance.ESAPI.encoder().encodeForBase64(getRawCipherText(), false);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getEncodedIVCipherText" output="false"
	            hint="Return the ciphertext as a base64-encoded String. If an IV was used, the IV if first prepended to the raw ciphertext before base64-encoding. If an IV is not used, then this method returns the same value as getBase64EncodedRawCipherText(). Generally, this is the method that you should use unless you only are using a fixed IV and a storing that IV separately, in which case using getBase64EncodedRawCipherText() can reduce the storage overhead.">
		<cfset var local = {}/>

		<cfscript>
			if(isCollected(CipherTextFlags.INITVECTOR) && isCollected(CipherTextFlags.CIPHERTEXT)) {
				// First concatenate IV + raw ciphertext
				local.iv = getIV();
				local.raw = getRawCipherText();
				local.ivPlusCipherText = newByte(arrayLen(local.iv) + arrayLen(local.raw));
				newJava("java.lang.System").arraycopy(local.iv, 0, local.ivPlusCipherText, 0, arrayLen(local.iv));
				newJava("java.lang.System").arraycopy(local.raw, 0, local.ivPlusCipherText, arrayLen(local.iv), arrayLen(local.raw));
				// Then return the base64 encoded result
				return instance.ESAPI.encoder().encodeForBase64(local.ivPlusCipherText, false);
			}
			else {
				instance.logger.error(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Raw ciphertext and/or IV not set yet; unable to retrieve; returning null");
				return "";
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="computeAndStoreMAC" output="false"
	            hint="Compute and store the Message Authentication Code (MAC) if the ESAPI property Encryptor.CipherText.useMAC is set to true. If it is, the MAC is conceptually calculated as: authKey = DerivedKey(secret_key, 'authenticate'); HMAC-SHA1(authKey, IV + secret_key) where derived key is an HMacSHA1, possibly repeated multiple times.">
		<cfargument type="any" name="authKey" required="true" hint="javax.crypto.SecretKey"/>

		<cfset var local = {}/>

		<cfscript>
			assert(!macComputed(), "Programming error: Can't store message integrity code while encrypting; computeAndStoreMAC() called multiple times.");
			assert(collectedAll(), "Have not collected all required information to compute and store MAC.");
			local.result = computeMAC(arguments.authKey);
			if(structKeyExists(local, "result")) {
				storeSeparateMAC(local.result);
			}
			// If 'result' is null, we already logged this in computeMAC().
		</cfscript>

	</cffunction>

	<cffunction access="package" returntype="void" name="storeSeparateMAC" output="false"
	            hint="Same as computeAndStoreMAC(SecretKey) but this is only used by CipherTextSerializeer. (Has package level access.)">
		<cfargument type="binary" name="macValue" required="true"/>

		<cfscript>
			if(!macComputed()) {
				this.separate_mac_ = newByte(arrayLen(arguments.macValue));
				CryptoHelper.copyByteArray(arguments.macValue, this.separate_mac_);
				assert(macComputed());
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="validateMAC" output="false"
	            hint="Validate the message authentication code (MAC) associated with the ciphertext. This is mostly meant to ensure that an attacker has not replaced the IV or raw ciphertext with something arbitrary. Note however that it will NOT detect the case where an attacker simply substitutes one valid ciphertext with another ciphertext.">
		<cfargument type="any" name="authKey" required="true" hint="javax.crypto.SecretKey: The secret key that is used for proving authenticity of the IV and ciphertext. This key should be derived from the SecretKey passed to the Encryptor##encrypt(javax.crypto.SecretKey, PlainText) and Encryptor##decrypt(javax.crypto.SecretKey, CipherText) methods or the 'master' key when those corresponding encrypt / decrypt methods are used. This authenticity key should be the same length and for the same cipher algorithm as this SecretKey. The method org.owasp.esapi.crypto.CryptoHelper##computeDerivedKey(SecretKey, int, String) is a secure way to produce this derived key."/>

		<cfset var local = {}/>

		<cfscript>
			local.usesMAC = instance.ESAPI.securityConfiguration().useMACforCipherText();

			if(local.usesMAC && macComputed()) {// Uses MAC and it was computed
				// Calculate MAC from HMAC-SHA1(nonce, IV + plaintext) and
				// compare to stored value (separate_mac_). If same, then return true,
				// else return false.
				local.mac = computeMAC(arguments.authKey);
				assert(arrayLen(local.mac) == arrayLen(this.separate_mac_), "MACs are of different lengths. Should both be the same.");
				return CryptoHelper.arrayCompare(local.mac, this.separate_mac_);// Safe compare!!!
			}
			else if(!local.usesMAC) {// Doesn't use MAC
				return true;
			}
			else {// Uses MAC but it has not been computed / stored.
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Cannot validate MAC as it was never computed and stored. Decryption result may be garbage even when decryption succeeds.");
				return true;// Need to return 'true' here because of encrypt() / decrypt() methods don't support this.
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="binary" name="asPortableSerializedByteArray" output="false"
	            hint="Return this CipherText object as a portable (i.e., network byte ordered) serialized byte array. Note this is NOT the same as returning a serialized object using Java serialization. Instead this is a representation that all ESAPI implementations will use to pass ciphertext between different programming language implementations.">
		<cfset var local = {}/>

		<cfscript>
			// Check if this CipherText object is "complete", i.e., all
			// mandatory has been collected.
			if(!collectedAll()) {
				local.msg = "Can't serialize this CipherText object yet as not all mandatory information has been collected";
				throwError(newComponent("cfesapi.org.owasp.esapi.errors.EncryptionException").init(instance.ESAPI, "Can't serialize incomplete ciphertext info", local.msg));
			}

			// If we are supposed to be using a (separate) MAC, also make sure
			// that it has been computed/stored.
			local.usesMAC = instance.ESAPI.securityConfiguration().useMACforCipherText();
			if(local.usesMAC && !macComputed()) {
				local.msg = "Programming error: MAC is required for this cipher mode (" & getCipherMode() & "), but MAC has not yet been computed and stored. Call the method computeAndStoreMAC(SecretKey) first before attempting serialization.";
				throwError(newComponent("cfesapi.org.owasp.esapi.errors.EncryptionException").init(instance.ESAPI, "Can't serialize ciphertext info: Data integrity issue.", local.msg));
			}

			// OK, everything ready, so give it a shot.
			return newComponent("cfesapi.org.owasp.esapi.crypto.CipherTextSerializer").init(ESAPI=instance.ESAPI, cipherTextObj=this).asSerializedByteArray();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setCiphertext" output="false"
	            hint="Set the raw ciphertext.">
		<cfargument type="binary" name="ciphertext" required="true" hint="The raw ciphertext."/>

		<cfset var local = {}/>

		<cfscript>
			if(!macComputed()) {
				if(!structKeyExists(arguments, "ciphertext") || arrayLen(arguments.ciphertext) == 0) {
					throwError(newComponent("cfesapi.org.owasp.esapi.errors.EncryptionException").init(instance.ESAPI, "Encryption faled; no ciphertext", "Ciphertext may not be null or 0 length!"));
				}
				if(isCollected(CipherTextFlags.CIPHERTEXT)) {
					instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Raw ciphertext was already set; resetting.");
				}
				this.raw_ciphertext_ = newByte(arrayLen(arguments.ciphertext));
				CryptoHelper.copyByteArray(arguments.ciphertext, this.raw_ciphertext_);
				received(CipherTextFlags.CIPHERTEXT);
				setEncryptionTimestampCurrent();
			}
			else {
				local.logMsg = "Programming error: Attempt to set ciphertext after MAC already computed.";
				instance.logger.error(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, local.logMsg);
				throwError(newComponent("cfesapi.org.owasp.esapi.errors.EncryptionException").init(instance.ESAPI, "MAC already set; cannot store new raw ciphertext", local.logMsg));
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setIVandCiphertext" output="false"
	            hint="Set the IV and raw ciphertext.">
		<cfargument type="binary" name="iv" required="true" hint="The initialization vector."/>
		<cfargument type="binary" name="ciphertext" required="true" hint="The raw ciphertext."/>

		<cfset var local = {}/>

		<cfscript>
			if(isCollected(CipherTextFlags.INITVECTOR)) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "IV was already set; resetting.");
			}
			if(isCollected(CipherTextFlags.CIPHERTEXT)) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Raw ciphertext was already set; resetting.");
			}
			if(!macComputed()) {
				if(!structKeyExists(arguments, "ciphertext") || arrayLen(arguments.ciphertext) == 0) {
					throwError(newComponent("cfesapi.org.owasp.esapi.errors.EncryptionException").init(instance.ESAPI, "Encryption faled; no ciphertext", "Ciphertext may not be null or 0 length!"));
				}
				if(!structKeyExists(arguments, "iv") || arrayLen(arguments.iv) == 0) {
					if(requiresIV()) {
						throwError(newComponent("cfesapi.org.owasp.esapi.errors.EncryptionException").init(instance.ESAPI, "Encryption failed -- mandatory IV missing", "Cipher mode " & getCipherMode() & " has null or empty IV"));
					}
				}
				else if(arrayLen(arguments.iv) != getBlockSize()) {
					throwError(newComponent("cfesapi.org.owasp.esapi.errors.EncryptionException").init(instance.ESAPI, "Encryption failed -- bad parameters passed to encrypt", "IV length does not match cipher block size of " & getBlockSize()));
				}
				this.cipherSpec_.setIV(arguments.iv);
				received(CipherTextFlags.INITVECTOR);
				setCiphertext(arguments.ciphertext);
			}
			else {
				local.logMsg = "MAC already computed from previously set IV and raw ciphertext; may not be reset -- object is immutable.";
				instance.logger.error(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, local.logMsg);// Discuss: By throwing, this gets logged as warning, but it's really error! Why is an exception only a warning???
				throwError(newComponent("cfesapi.org.owasp.esapi.errors.EncryptionException").init(instance.ESAPI, "Validation of decryption failed.", local.logMsg));
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="numeric" name="getKDFVersion" output="false">

		<cfscript>
			return instance.kdfVersion_;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setKDFVersion" output="false">
		<cfargument type="numeric" name="vers" required="true"/>

		<cfscript>
			assert(arguments.vers > 0 && arguments.vers <= 99991231, "Version must be positive, in format YYYYMMDD and <= 99991231.");
			instance.kdfVersion_ = arguments.vers;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="PRF_ALGORITHMS" name="getKDF_PRF" output="false">

		<cfscript>
			return KeyDerivationFunction.convertIntToPRF(instance.kdfPrfSelection_);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="numeric" name="kdfPRFAsInt" output="false">

		<cfscript>
			return instance.kdfPrfSelection_;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setKDF_PRF" output="false">
		<cfargument type="numeric" name="prfSelection" required="true"/>

		<cfscript>
			assert(arguments.prfSelection >= 0 && arguments.prfSelection <= 15, "kdfPrf == " & arguments.prfSelection & " must be between 0 and 15.");
			instance.kdfPrfSelection_ = arguments.prfSelection;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="numeric" name="getEncryptionTimestamp" output="false"
	            hint="Get stored timestamp representing when data was encrypted.">

		<cfscript>
			return this.encryption_timestamp_;
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="void" name="setEncryptionTimestampCurrent" output="false"
	            hint="Set the encryption timestamp to the current system time as determined by getTickCount(), but only if it has not been previously set. That is, this method ony has an effect the first time that it is called for this object.">

		<cfscript>
			// We want to skip this when it's already been set via the package
			// level call setEncryptionTimestamp(long) done via CipherTextSerializer
			// otherwise it gets reset to the current time. But when it's restored
			// from a serialized CipherText object, we want to keep the original
			// encryption timestamp.
			if(this.encryption_timestamp_ != 0) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").EVENT_FAILURE, "Attempt to reset non-zero CipherText encryption timestamp to current time!");
			}
			this.encryption_timestamp_ = getTickCount();
		</cfscript>

	</cffunction>

	<cffunction access="package" returntype="void" name="setEncryptionTimestamp" output="false"
	            hint="Set the encryption timestamp to the time stamp specified by the parameter. This method is intended for use only by CipherTextSerializer.">
		<cfargument type="numeric" name="timestamp" required="true" hint="The time in milliseconds since epoch time (midnight, January 1, 1970 GMT)."/>

		<cfscript>
			assert(arguments.timestamp > 0, "Timestamp must be greater than zero.");
			if(this.encryption_timestamp_ == 0) {// Only set it if it's not yet been set.
				instance.logger.warning(newJava("org.owasp.esapi.Logger").EVENT_FAILURE, "Attempt to reset non-zero CipherText encryption timestamp to " & newJava("java.util.Date").init(javaCast("long", arguments.timestamp)) + "!");
			}
			this.encryption_timestamp_ = arguments.timestamp;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="numeric" name="getSerialVersionUID" output="false"
	            hint="Used in supporting CipherText serialization.">

		<cfscript>
			return instance.serialVersionUID;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="binary" name="getSeparateMAC" output="false"
	            hint="Return the separately calculated Message Authentication Code (MAC) that is computed via the computeAndStoreMAC(SecretKey authKey) method.">
		<cfset var local = {}/>

		<cfscript>
			if(!arrayLen(this.separate_mac_)) {
				return toBinary("");
			}
			local.copy = newByte(arrayLen(this.separate_mac_));
			newJava("java.lang.System").arraycopy(this.separate_mac_, 0, local.copy, 0, arrayLen(this.separate_mac_));
			return local.copy;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="toStringESAPI" output="false">
		<cfset var local = {}/>

		<cfscript>
			local.sb = newComponent("cfesapi.org.owasp.esapi.lang.StringBuilder").init("CipherText: ");
			local.creationTime = iif(getEncryptionTimestamp() == 0, de("No timestamp available"), de(newJava("java.util.Date").init(javaCast("long", getEncryptionTimestamp())).toString()));
			local.n = getRawCipherTextByteLength();
			local.rawCipherText = iif(local.n > 0, de("present (" & local.n & " bytes)"), de("absent"));
			local.mac = iif(arrayLen(this.separate_mac_), de("present"), de("absent"));
			local.sb.append("Creation time: ").append(local.creationTime);
			local.sb.append(", raw ciphertext is ").append(local.rawCipherText);
			local.sb.append(", MAC is ").append(local.mac).append("; ");
			local.sb.append(this.cipherSpec_.toStringESAPI());
			return local.sb.toStringESAPI();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="equalsESAPI" output="false">
		<cfargument type="any" name="other" required="true"/>

		<cfset var local = {}/>

		<cfscript>
			local.result = false;
			if(!structKeyExists(arguments, "other"))
				return false;
			if(isInstanceOf(arguments.other, "cfesapi.org.owasp.esapi.crypto.CipherText")) {
				local.that = arguments.other;
				if(this.collectedAll() && local.that.collectedAll()) {
					local.result = (local.that.canEqual(this) && this.cipherSpec_.equalsESAPI(local.that.cipherSpec_) && CryptoHelper.arrayCompare(this.raw_ciphertext_, local.that.raw_ciphertext_) && CryptoHelper.arrayCompare(this.separate_mac_, local.that.separate_mac_) && this.encryption_timestamp_ == local.that.encryption_timestamp_);
				}
				else {
					instance.logger.warning(newJava("org.owasp.esapi.Logger").EVENT_FAILURE, "CipherText.equals(): Cannot compare two CipherText objects that are not complete, and therefore immutable!");
					instance.logger.info(newJava("org.owasp.esapi.Logger").EVENT_FAILURE, "This CipherText: " & this.collectedAll() & ";other CipherText: " & local.that.collectedAll());
					instance.logger.info(newJava("org.owasp.esapi.Logger").EVENT_FAILURE, "CipherText.equals(): Progress comparison: " & iif(this.progress == local.that.progress, de("Same"), de("Different")));
					instance.logger.info(newJava("org.owasp.esapi.Logger").EVENT_FAILURE, "CipherText.equals(): Status this: " & this.progress & "; status other CipherText object: " & local.that.progress);
					// CHECKME: Perhaps we should throw a RuntimeException instead???
					return false;
				}
			}
			return local.result;
		</cfscript>

	</cffunction>

	<!--- hashCode --->

	<cffunction access="package" returntype="boolean" name="canEqual" output="false">
		<cfargument type="any" name="other" required="true"/>

		<cfscript>
			return isInstanceOf(arguments.other, "cfesapi.org.owasp.esapi.crypto.CipherText");
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="binary" name="computeMAC" output="false"
	            hint="Compute a MAC, but do not store it. May set the nonce value as a side-effect.  The MAC is calculated as: HMAC-SHA1(nonce, IV + plaintext)">
		<cfargument type="any" name="authKey" required="true" hint="javax.crypto.SecretKey: The ciphertext value for which the MAC is computed."/>

		<cfset var local = {}/>

		<cfscript>
			assert(structKeyExists(this, "raw_ciphertext_") && arrayLen(this.raw_ciphertext_) != 0, "Raw ciphertext may not be null or empty.");
			assert(structKeyExists(arguments, "authKey") && arrayLen(arguments.authKey.getEncoded()) != 0, "Authenticity secret key may not be null or zero length.");
			try {
				local.sk = newJava("javax.crypto.spec.SecretKeySpec").init(arguments.authKey.getEncoded(), "HmacSHA1");
				local.mac = newJava("javax.crypto.Mac").getInstance("HmacSHA1");
				local.mac.init(local.sk);
				if(requiresIV()) {
					local.mac.update(getIV());
				}
				local.result = local.mac.doFinal(getRawCipherText());
				return local.result;
			}
			catch(java.security.NoSuchAlgorithmException e) {
				instance.logger.error(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Cannot compute MAC w/out HmacSHA1.", e);
				return "";
			}
			catch(java.security.InvalidKeyException e) {
				instance.logger.error(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Cannot comput MAC; invalid 'key' for HmacSHA1.", e);
				return "";
			}
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="boolean" name="macComputed" output="false"
	            hint="Return true if the MAC has already been computed (i.e., not null).">

		<cfscript>
			return iif(arrayLen(this.separate_mac_), true, false);
		</cfscript>

	</cffunction>

	<cffunction access="package" returntype="boolean" name="collectedAll" output="false"
	            hint="Return true if we've collected all the required pieces; otherwise false.">
		<cfset var local = {}/>

		<cfscript>
			local.ctFlags = "";
			if(requiresIV()) {
				local.ctFlags = instance.allCtFlags;
			}
			else {
				// NOTE: not understanding this; hopefully just throwing the 1 element in an array is correct ??
				//local.initVector = EnumSet.of(CipherTextFlags.INITVECTOR);
				//local.ctFlags = EnumSet.complementOf(local.initVector);
				local.ctFlags = [CipherTextFlags.INITVECTOR];
			}
			local.result = this.progress.containsAll(local.ctFlags);
			return local.result;
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="boolean" name="isCollected" output="false"
	            hint="Check if we've collected a specific flag type.">
		<cfargument type="cfesapi.org.owasp.esapi.crypto.CipherTextFlags" name="flag" required="true" hint="The flag type; e.g., CipherTextFlags.INITVECTOR, etc."/>

		<cfscript>
			return yesNoFormat(arrayFind(this.progress, arguments.flag));
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="void" name="received" output="false"
	            hint="Add the flag to the set of what we've already collected.">
		<cfargument type="cfesapi.org.owasp.esapi.crypto.CipherTextFlags" name="flag" required="true" hint="The flag type to be added; e.g., CipherTextFlags.INITVECTOR."/>

		<cfscript>
			this.progress.add(arguments.flag);
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="void" name="receivedMany" output="false"
	            hint="Add all the flags from the specified set to that we've collected so far.">
		<cfargument type="Array" name="ctSet" required="true" hint="A EnumSet&lt;CipherTextFlags&gt; containing all the flags we wish to add."/>

		<cfset var local = {}/>

		<cfscript>
			local.it = arguments.ctSet.iterator();
			while(local.it.hasNext()) {
				received(local.it.next());
			}
		</cfscript>

	</cffunction>

</cfcomponent>