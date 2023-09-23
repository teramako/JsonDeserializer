# JsonDeserializer

For PowerShell v5.1 (Desktop Edition).

Like `ConvertFrom-Json -AsHashtable` on PowerShell Core, deserialize JSON string to Hashtable.

```powershell
Import-Module JsonDeserializer

'{ "n": 10, "s": "str", "o": {"name":"obj"}, "arr": [0,1,2], "null": null }' | ConvertFrom-JsonAsHashtable
```

```
Name                           Value
----                           -----
n                              10
s                              str
o                              {name}
arr                            {0, 1, 2}
null
invalid                        invalid

```
