# Host Image

Fedora Atomic / bootc host image definitions live here. MVP 0 starts with a
minimal developer preview image, rollback validation, SBOM generation, and
signature/promotion gates.

## Local Build

Build the developer preview image from the repository root:

```sh
make image-build
```

The default base is `quay.io/fedora/fedora-bootc:latest`. Override it when
testing a pinned Fedora release or architecture-specific tag:

```sh
make image-build BASE_IMAGE=quay.io/fedora/fedora-bootc:43
```
