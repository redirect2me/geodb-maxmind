# MaxMind for Resolve.rs [<img alt="Resolve.rs Logo" src="https://resolve.rs/favicon.svg" height="96" align="right"/>](https://resolve.rs/)

The MaxMind "Lite" databases are free to use, but you cannot redistribute them, and cannot (reliably) download them every time a server starts.  To get a server to start without hitting MaxMind directly, I use an encrypted version that automatically updates once a week.

## Using

This is just for [resolve.rs](https://resolve.rs), but you can do the same thing with your own fork. You need to set the following Github secrets:

* `MAXMIND_LICENSE_KEY` - from MaxMind
* `MAXMIND_ACCOUNT_ID` - also from MaxMind
* `MMDB_ENCRYPTION_KEY` - generate a 32-byte (64 hex digits) encryption key

You will use the `MMDB_ENCRYPTION_KEY` when decrypting the database files on your server.

## License

The script is licensed under the [GNU Affero General Public License v3.0](LICENSE.txt).

This product includes GeoLite2 data created by MaxMind, available from [www.maxmind.com](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data/)

## Release Files

- GeoLite2-ASN.mmdb.enc: encrypted ASN lookup database
- GeoLite2-City.mmdb.enc: encrypted city lookup database
- mmdb.iv: initialization vector used for encryption
- mmdb.md5: md5 hashes of the unencrypted files (to detect updates)

## Credits

[![Bash](https://www.vectorlogo.zone/logos/gnu_bash/gnu_bash-ar21.svg)](https://www.gnu.org/software/bash/ "Scripting")
[![Git](https://www.vectorlogo.zone/logos/git-scm/git-scm-ar21.svg)](https://git-scm.com/ "Version control")
[![Github](https://www.vectorlogo.zone/logos/github/github-ar21.svg)](https://github.com/ "Code hosting")
[![MaxMind](https://www.vectorlogo.zone/logos/maxmind/maxmind-ar21.svg)](https://www.maxmind.com/ "IP geolocation and ASN databases")
[![OpenSSL](https://www.vectorlogo.zone/logos/openssl/openssl-ar21.svg)](https://www.openssl.org/ "Encryption")
