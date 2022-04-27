# Autoenv

#### Autoenv automatically sources (known/whitelisted) `.envrc` and `.envrc.leave` files.

This plugin adds support for enter and leave events. By default `.envrc` files are used when entering a directory, and `.envrc.leave` files when leaving a directory. And you can set variable `CLICOLOR=1` for enabling colored output.

The environment variables `$AUTOENV_ENTER_FILE` & `$AUTOENV_LEAVE_FILE` can be used
to override the default values for the file names of `.envrc` & `.envrc.leave` respectively.

![](term.png)

## Example of use

- If you are in the directory `/home/user/dir1` and execute `cd /var/www/myproject` this plugin will source the following files if they exist

```
/home/user/dir1/.envrc.leave
/home/user/.envrc.leave
/home/.envrc.leave
/var/.envrc
/var/www/.envrc
/var/www/myproject/.envrc
```

- If you are in the directory `/` and execute `cd /home/user/dir1` this plugin will source the following files if they exist

```
/home/.envrc
/home/user/.envrc
/home/user/dir1/.envrc
```

- If you are in the directory `/home/user/dir1` and execute `cd /` this plugin will source the following files if they exist

```
/home/user/dir1/.envrc.leave
/home/user/.envrc.leave
/home/.envrc.leave
```

## Examples of `.envrc` and `.envrc.leave` files

