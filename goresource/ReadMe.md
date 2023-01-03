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

