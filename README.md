sdkman-fish
---
A fish plugin for [sdkman](https://sdkman.io/).

When you execute install, uninstall, default, or use commands you can select a version with fzf.  
![Screenshot from 2021-09-22 21-09-01](https://user-images.githubusercontent.com/7029819/134340916-4a00f3d9-4844-4d84-b60c-d85dd6746605.png)

In addition, this plugin supports auto env function. If .sdkmanrc exists on current or parent directory, your java
version in current shell process is changed automatically.

# Requirements

- [sdkman](https://sdkman.io/)
- [fzf](https://github.com/junegunn/fzf)
- [gnu sed](https://www.gnu.org/software/sed/manual/sed.html)
  - If you use macos, execute `brew install gnu-sed` command to install it.

# Installation

```bash
fisher install miya10kei/sdkman-fish
```

# Configuration

write this on your config.fish

```bash
set -x JAVA_HOME $HOME/.sdkman/candidates/java/current

for candidate in $HOME/.sdkman/candidates/* ;
  addPath $candidate/current/bin
end
```

If you want to use auto env function.  
Please write this on your config.fish.

```bash
function sdk_auto_env --on-variable PWD
  __sdk_auto_env
end
```

and write this on your sdkman config.

```
sdkman_auto_env=false
sdkman_auto_env_fish=true
```

# License

[MIT](LICENSE)

