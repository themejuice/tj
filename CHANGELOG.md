# Releases

## `v0.28.1`

- Update `update` command to perform a `git pull`, properly updating the repo
- Ensure that paths passed to Net-SSH are strings, fixing an issue where the `uploads:pull` and `uploads:push` tasks would fail

## `v0.28.0`

- Update `delete` command to provision virtual machine by default
- Add `update` command to keep virtual machine up to date
- Add `--template-revision` flag (with alias `--template-branch`)
- Add `--vm-revision` flag

## `v0.27.0`

- Change default VM box to [Graft](https://github.com/ezekg/graft)
- Change default VM IP address from `192.168.50.4` to `192.168.13.37`
- Change default VM path from `~/tj-vagrant` to `~/graft`
- Update Vagrant plugin dependencies to mirror Graft's dependencies
- Add support for ERB within a starter template's `Juicefile`
- Add `project` key to `Juicefile`
- Deprecate `deployment.application.name` in favor of `project.name`
- Infer values for project name and location on `tj setup` if project contains
  `project` information within the `Juicefile` config
- Update Landrush to `1.0`, now with experimental Windows support
- Update task for `wp-cli.local.yml` file creation to generate configuration for
  the official WP-CLI SSH feature, as opposed to the plugin we were using
- Fix issue where a tilde (`~`) was not properly expanded for project locations
- Update and clarify constraints for a project's name
- Update documentation to mention how to specify a port for deployment
- Update and clarify documentation on the `Juicefile` configuration file
