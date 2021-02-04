# ironic-inspector-image

This repo contains the files needed to build the Ironic Inspector images used by Metal3.

When updated, builds are automatically triggered on https://quay.io/repository/metal3-io/ironic-inspector/

Applying Patches to the image
-----------------------------

When building the image, it is possible to specify a patch of one or more
upstream projects to apply to the image, passing a file with the patch list
using the PATCH_LIST build argument.

At the moment, only projects hosted in opendev.org are supported.

Each line of the file is in the form "project_dir refspec" where:
- project is the last part of the project url including the org, for example openstack/ironic-inspector
- refspec is the gerrit refspec of the patch we want to test, for example refs/changes/96/766996/2

