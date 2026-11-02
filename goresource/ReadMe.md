# Background
syso utility embeds resouce in bwanclient.exe.
syso.exe is built using https://github.com/hallazzang/syso.

# Functionality
syso.exe reads syso.json and coverts into out.syso.
go build/install embeds out.syso in final go exe.

Please check syso README.md for more details.

# JSON format

```
{
  "VersionInfos": [
    {
      "ID": 1,
      "Fixed": {
        "FileVersion": "<<Version>>",
        "ProductVersion": "<<Version>>"
      },
      "StringTables": [
        {
          "Language": "0409",
          "Charset": "04b0",
          "Strings": {
            "CompanyName": "Netskope Inc",
            "FileDescription": "BWAN Client manager",
            "FileVersion": "<<Version>>",
            "InternalName": "bwanclient",
            "LegalCopyright": "\u00a9 Netskope Inc. All rights reserved.",
            "OriginalFilename": "bwanclient.Exe",
            "ProductName": "Netskope\u00ae Client",
            "ProductVersion": "<<Version>>"
          }
        }
      ],
      "Translations": [
        {
          "Language": "0409",
          "Charset": "04b0"
        }
      ]
    }
  ]
}
```


# AMD64 patch

Upstream syso generates x86 (I386) COFF objects. bwanclient.exe is built for AMD64, so the
generated out.syso must be AMD64 too. The change is in `syso-amd64.patch` (this folder).

## What changed

`pkg/coff/file.go` is the only file changed:

| Field | Before (x86) | After (AMD64) |
|-------|--------------|---------------|
| COFF header `Machine` | `0x14c` (IMAGE_FILE_MACHINE_I386) | `0x8664` (IMAGE_FILE_MACHINE_AMD64) |
| COFF header `Characteristics` | `0x0100` (IMAGE_FILE_32BIT_MACHINE) | `0` |
| Relocation `Type` | `0x0007` (IMAGE_REL_I386_DIR32NB) | `0x0003` (IMAGE_REL_AMD64_ADDR32NB) |

There is no option or flag. The tool always generates AMD64.

## Apply the patch

Run from the root of the original syso source (the folder containing `syso.go`):

```
patch -p1 < syso-amd64.patch
```

or

```
git apply syso-amd64.patch
```

## Verify

Run syso.exe on a syso.json, then check the first bytes of out.syso. A correct AMD64 file
starts with `64 86` (Machine 0x8664, little-endian). An x86 file starts with `4c 01`.

Rebuild syso.exe after applying the patch. A syso.exe built before the patch still emits x86 objects.
