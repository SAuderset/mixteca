install rename via homebrew
navigate to the folder with cd

the basic schema is
```
rename -n -v 'pattern.to.delete/pattern.to.stay/' *.file.extension
```

Example: delete all the non-digits characters from wav files:
```
rename -n -v 's/\D+\.wav/.wav/' *
```

remove -n to actually rename the files
