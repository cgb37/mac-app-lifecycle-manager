# Changelog

All notable changes to this project will be documented in this file. See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.


# 2.0.0 (2026-02-02)


### Bug Fixes

* **release:** add --ci flag for non-interactive GitHub authentication ([701ec5e](https://github.com/cgb37/mac-app-lifecycle-manager/commit/701ec5eff037afa821e54f797d194a641ed968a0))
* **release:** explicitly pass GITHUB_TOKEN through npm scripts ([a955eb1](https://github.com/cgb37/mac-app-lifecycle-manager/commit/a955eb11da5ff393e9c0bdae36f5551452b66724))
* **release:** explicitly pass GITHUB_TOKEN to npx commands ([c700b7c](https://github.com/cgb37/mac-app-lifecycle-manager/commit/c700b7c82229c0e85384fd7a5878dcd04fc92723))
* **release:** improve GitHub token handling and debug output ([42352b6](https://github.com/cgb37/mac-app-lifecycle-manager/commit/42352b6440884b6f6cb5c0695e89ce4fd7927d47))
* **release:** remove tokenRef from GitHub configuration ([83ede75](https://github.com/cgb37/mac-app-lifecycle-manager/commit/83ede752066f6e8fdd0abbdc3da67cecff0ce2f6))


### Documentation

* update GitHub authentication section in release process ([9b4070b](https://github.com/cgb37/mac-app-lifecycle-manager/commit/9b4070b94d6b8b60a306f4a7f3067ebe3dbee6bb))


### Features

* **changelog:** add initial changelog documentation ([853b752](https://github.com/cgb37/mac-app-lifecycle-manager/commit/853b7522223e95ac6932a22fa8d89deff084593c)), closes [#8](https://github.com/cgb37/mac-app-lifecycle-manager/issues/8)
* **close-apps:** improve app closing logic for better performance ([15ab32b](https://github.com/cgb37/mac-app-lifecycle-manager/commit/15ab32b2edf5543aea06b1c807b3d306af259f79))
* **common:** add shared utility functions for scripts ([aba34ed](https://github.com/cgb37/mac-app-lifecycle-manager/commit/aba34ed6eb2cdabf8a4bdd256fc1f80be8c24f77)), closes [#1](https://github.com/cgb37/mac-app-lifecycle-manager/issues/1)
* **config:** add configuration templates for automation ([f90814e](https://github.com/cgb37/mac-app-lifecycle-manager/commit/f90814e220b21f56dcd67b6d56d2c118d9f8c028)), closes [#1](https://github.com/cgb37/mac-app-lifecycle-manager/issues/1)
* **config:** add example configuration for auto-closing apps ([3a9325f](https://github.com/cgb37/mac-app-lifecycle-manager/commit/3a9325fd55e97c345168154a40c1eb1f6879db1e)), closes [#1](https://github.com/cgb37/mac-app-lifecycle-manager/issues/1)
* **config:** add example configuration for auto-launch apps ([cfcf1ff](https://github.com/cgb37/mac-app-lifecycle-manager/commit/cfcf1ff1966564c05390ba122ad17e182070a386)), closes [#1](https://github.com/cgb37/mac-app-lifecycle-manager/issues/1)
* **config:** add example configuration for close apps feature ([266c422](https://github.com/cgb37/mac-app-lifecycle-manager/commit/266c422626913491497bf8ed441bb698d4d5b6e2)), closes [#1](https://github.com/cgb37/mac-app-lifecycle-manager/issues/1)
* **config:** add example configuration for open apps manager ([58393b5](https://github.com/cgb37/mac-app-lifecycle-manager/commit/58393b5ec3e3fecdab0384263feb49fb4ce5212e)), closes [#1](https://github.com/cgb37/mac-app-lifecycle-manager/issues/1)
* **config:** add log rotation settings in config example ([b09ec7c](https://github.com/cgb37/mac-app-lifecycle-manager/commit/b09ec7cce85ab94837692cd2bb984892638f5497))
* **config:** add logging configuration options ([65cbe9b](https://github.com/cgb37/mac-app-lifecycle-manager/commit/65cbe9bfb749fae588f0ce2b20c8effec5e87a68))
* **docs:** add comprehensive configuration reference ([81acc03](https://github.com/cgb37/mac-app-lifecycle-manager/commit/81acc035b509d41ab405727b9caa8f191bf4d68d)), closes [#1](https://github.com/cgb37/mac-app-lifecycle-manager/issues/1)
* **docs:** add comprehensive instructions for macOS app lifecycle manager ([61e8cf7](https://github.com/cgb37/mac-app-lifecycle-manager/commit/61e8cf76a2b2c4e72464a2bbf80f56dd3af35c6c))
* **docs:** add logging system documentation ([ec770b7](https://github.com/cgb37/mac-app-lifecycle-manager/commit/ec770b72a2e12a24490c24c9f9b5a0add452fedc))
* **docs:** add release process documentation ([667d2a7](https://github.com/cgb37/mac-app-lifecycle-manager/commit/667d2a7aa8247c9ba46d82aa579c3d219ee309ee)), closes [#8](https://github.com/cgb37/mac-app-lifecycle-manager/issues/8)
* **env:** add example environment variable configuration ([e425447](https://github.com/cgb37/mac-app-lifecycle-manager/commit/e425447a20f3358742043f5a96bfc336ed882376))
* **gitignore:** add macOS and Windows ignore patterns ([ef43e0f](https://github.com/cgb37/mac-app-lifecycle-manager/commit/ef43e0f982f1cb46f5d700d52321fb4f22907df7))
* **launchd:** add versioning to plist templates ([8e2aa2c](https://github.com/cgb37/mac-app-lifecycle-manager/commit/8e2aa2ce5362049d14f44326b61161758c1919a7))
* **logging:** add log rotation and cleanup functions ([a186665](https://github.com/cgb37/mac-app-lifecycle-manager/commit/a1866651ad18a61635c6b193f0a5999b16c77989))
* **mac-app-lifecycle:** add CLI tool for managing macOS apps ([4c96959](https://github.com/cgb37/mac-app-lifecycle-manager/commit/4c96959daa10a80db2c9740088cdbc2366a55be7)), closes [#1](https://github.com/cgb37/mac-app-lifecycle-manager/issues/1)
* **migration-plan:** establish framework for macOS app lifecycle management ([723157e](https://github.com/cgb37/mac-app-lifecycle-manager/commit/723157ecc029fce82e8929228edb5584bf8051e8))
* **open-apps:** add automation script for launching apps ([cb18011](https://github.com/cgb37/mac-app-lifecycle-manager/commit/cb18011cd353a6a90168f6bc602ce3b97a376eed)), closes [#5](https://github.com/cgb37/mac-app-lifecycle-manager/issues/5)
* **package:** add initial package.json for macOS lifecycle manager ([c823727](https://github.com/cgb37/mac-app-lifecycle-manager/commit/c8237273262c440c2b0dd66f49723bb53f1885fb))
* **readme:** add initial project documentation ([69b3da6](https://github.com/cgb37/mac-app-lifecycle-manager/commit/69b3da6571ba93ab2490e3717f503547bb5c904d))
* **README:** document completion of phases 2 and 3 ([fc98195](https://github.com/cgb37/mac-app-lifecycle-manager/commit/fc981957feee099bb8d69e8f05a3c82a07cb5bf8)), closes [#5](https://github.com/cgb37/mac-app-lifecycle-manager/issues/5)
* **release:** add GITHUB_TOKEN loading and verification ([12ec9d0](https://github.com/cgb37/mac-app-lifecycle-manager/commit/12ec9d02dbbc3a918949c1ba1d7545669c97dd7f))
* **release:** allow additional parameters for release-it ([83c5456](https://github.com/cgb37/mac-app-lifecycle-manager/commit/83c5456605c7ac5ac6e31dd9e2a84879370c380d))
* **scripts:** add release wrapper for version management ([7706e0f](https://github.com/cgb37/mac-app-lifecycle-manager/commit/7706e0f4687af234ff474d5975eb36571276c733)), closes [#8](https://github.com/cgb37/mac-app-lifecycle-manager/issues/8)
* **scripts:** add version update script ([e1e598c](https://github.com/cgb37/mac-app-lifecycle-manager/commit/e1e598cd00c73e209cba7d9238b0ef138a312e9e))
* **scripts:** add versioning to close and open apps scripts ([4bbbb19](https://github.com/cgb37/mac-app-lifecycle-manager/commit/4bbbb19af318c39ca60ee50515d2714d071a33f3)), closes [#8](https://github.com/cgb37/mac-app-lifecycle-manager/issues/8)
* **tests:** add log rotation test suite ([d4aa202](https://github.com/cgb37/mac-app-lifecycle-manager/commit/d4aa20291d9beb5afc279a9258640266c4e15c57))
* **tests:** add release-it configuration validation script ([1cf0166](https://github.com/cgb37/mac-app-lifecycle-manager/commit/1cf01663c46e9d9af39d2b3ae92247929666371f)), closes [#8](https://github.com/cgb37/mac-app-lifecycle-manager/issues/8)


### BREAKING CHANGES

* Shell environment variables now override `.env` file configurations.
* **logging:** The setup_logging function has been enhanced to include log rotation capabilities.

## [0.1.0] - TBD

### Features

- Initial project setup
- AppleScript-based app lifecycle management
- Conventional changelog and release-it integration

### Documentation

- Project documentation structure
- Release process documentation
