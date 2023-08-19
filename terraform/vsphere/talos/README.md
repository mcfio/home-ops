# terraform/vsphere/talos

This repository provisions the necessary objects to operate talos, declaratively, in my vSphere lab environment.

The direnv `.envrc` populates the environment variables at `terraform` execution time to provide authentication
to the vSphere APIs using credentials stored in `1Password`.

Using the `op run` cli command with terraform, like so:

```sh
op run -- terraform <action>
```
