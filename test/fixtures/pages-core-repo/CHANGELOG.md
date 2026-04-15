## 0.21.0 (2026-04-01)

### Added

- create workshop site build flow 4856
- feat: create workshop oauth flow 4855
- Update app to Node v22 and update the dependencies
- Add site delete webhook for publisher site

### Fixed

- branch with an invalid name should create an invalid build #2375
- remove deprecated component
- force patched version of fast-xml-parser
- set node value in Docker
- include screen reader text and update 404 test to expect updated login string
- adjust slightly navigation text style
- Audit and fix dependencies #4845
- Publisher endpoint host environment variable
- Use the correct bound route service domain by env

### Maintenance

- Remove deprecated security-considerations automation files
- update to use new branding logos
- update color palette
- update styling to revise color palette
- update admin-client node engine
- update favicons with new pages logo
- update styles and menus

## 0.20.1 (2025-12-01)

### Fixed

- CI clamav resources for prod deploy

## 0.20.0 (2025-12-01)

### Added

- Enable public file storage service in production
- Add site engine select when creating a site from an existing reposity #4801
- remove organization manager Github username #4800
- add admin UI to manage a sites Public File Storage #4819
- add site file storage service admin api end points
- Add route service cookie check for clamav file endpoints
- Add route-service app
- Add ClamAV REST scan route service

### Fixed

- Automated platform build message for new domains
- **ci**: Properly configure route service resources for non-prod envs

### Maintenance

- update documentation links
- Update axios and delete deprecated frontend tests
- Add CODEOWNERS
- new test for OrganizationCard component
- Clean up File Details UI with fixed links and button types
- Set security considerations action to read only
- Update csurf and app build dependencies
