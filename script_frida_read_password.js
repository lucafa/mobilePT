Java.perform(function () {
    var Crypto = Java.use("sg.vantagepoint.a.a");

    // Hook del metodo statico: a(byte[] key, byte[] data)
    Crypto.a.overload("[B", "[B").implementation = function (key, data) {
        var result = this.a(key, data);

        var decrypted = Java.use("java.lang.String").$new(result);
        console.log("[*] AES decrypt called");
        console.log("    ↪ Decrypted string: " + decrypted);

        return result;
    };
});

