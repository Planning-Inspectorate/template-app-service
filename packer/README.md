# Agent Upgrades

## Pipeline Order

1. `infra-ci` will automatically run basic tests. (Packer CI in ADO)
2. Run `packer-build-image` to build the image for the agents.
3. Run `infra-cd` to deliver the image to ACR and set it as the one to use. (Packer Agent CD in ADO)
4. Run `purge-agent-images` to delete older images in ACR.

## Info

- All pipelines use the iamge `pool: ubuntu-latest`
