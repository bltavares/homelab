## TODOs

- [ ] Remove hardcoded files from nomad templates and replace with consul variables
- [x] Migrate all images to use the internal registry
- [x] Create an upgrade script for the internal registry
  - [ ] Make services restart after job is finished
- [ ] Fork Trow into Balsa and remove the GRPC copy overhead
- [ ] Readjust all resources usage
- [ ] Introduce restart policies and checks to all services
- [x] Remove unsed files from the repo
- [x] Update the cluster to ProxMox v8 and Debian 12
- [x] Update node access to use single-node-writer
