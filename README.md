sdkman-fish
---
A fish plugin for [sdkman](https://sdkman.io/).

# Requirements

- [sdkman](https://sdkman.io/)
- [fzf](https://github.com/junegunn/fzf)

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

