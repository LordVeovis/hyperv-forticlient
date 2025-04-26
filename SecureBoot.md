# SecureBoot documentation

* PK (Platform Key): usually as a public certificate, managed by the OEM or the Platform Owner (aka the final user for a standard PC). Having the private key associated to PK allows updating the KEK.
    * In other words, the Platform Owner, authenticated by it's Platform Key, control the entity that decide what binary is allowed to boot on the system, it does not control what can be booted or not (at least not directly).
* KEK (Key Exchange Keys): usually as a public certificate. Having the private key associated to KEK allows updating db and dbx.
    * In other words, the entity that control the KEK decide what binary is allowed to boot on the system
* db: databases of certificates, keys or hashed that can be booted. The EFI binaries (bootloader) are signed with one of theses certificates
* dbx: database of EFI hashes or certificates of EFI binaries that are FORBIDDEN to be booted.

You can read the content of theses variables with efi-readvar from the efitools package:

```sh
efi-readvar -v PK
efi-readvar -v KEK
efi-readvar -v db
efi-readvar -v dbx
```

# Certificates

A couple of common certificates

## KEK

* Microsoft Corporation KEK CA 2011: old KEK certificate expiring in 2026
* Microsoft Corporation KEK 2K CA 2023: new KEK certificate

# db

* Microsoft Windows Production PCA 2011: old, this certificate signs the Windows bootloader
* Windows UEFI CA 2023: new, this certificate signs the Windows bootloader
* Microsoft Corporation UEFI CA 2011: old, this certificate signs the Linux shim
* Microsoft UEFI CA 2023: new, this certificate signs the Linux shim
* Microsoft Windows Production PCA 2011: old, maybe this is used to sign hardware driver components???
* Microsoft Option ROM UEFI CA 2023: new, maybe this is used to sign hardware driver components???

# See also

* [https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-secure-boot-key-creation-and-management-guidance?view=windows-11]
* [https://techcommunity.microsoft.com/blog/windows-itpro-blog/updating-microsoft-secure-boot-keys/4055324]