# Ambulo web deployment

`deploy.sh` builds the Flutter web client and synchronizes `build/web` to a
remote host with Ansible and rsync. It serves only the Ambulo client; users
configure their Ambulo API server address inside the app.

1. Copy `ansible/deploy_config.yaml.example` to `ansible/deploy_config.yaml`.
2. Set the SSH target and deployment directory in the copied file.
3. Set the nginx `server_name`, certificate paths, and `root` in
   `sample_nginx.conf`. The root must match `deploy_target_dir`.
4. Run `./deploy.sh` from the repository root.

The installed Ansible collections are ignored because `deploy.sh` installs
them from the pinned requirements file. Keep your deployment configuration
according to your repository's preferred release process.
