#!/bin/bash

gitlab_version="15.0.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="978d97dc5fefff63a0cbf0aab81866bd8eac731b3a2f68eec768b8ca50c9250b"
gitlab_x86_64_buster_source_sha256="459573c203ebde054eefb31f0d9959585b64737d0cddeec3d7dcacd1560d7fa9"

gitlab_arm64_bullseye_source_sha256="ee5a4affd8a804aefce444e6cb06eecab0f73be64ad898b4cf3c6ab091685cce"
gitlab_arm64_buster_source_sha256="c65b4b9a2e9c964cb36fb9532992c493bf16ea62e1515d5b50ac89e5f27129f9"

gitlab_arm_buster_source_sha256="4c9ed80c3c1d0aa067cec9470c09d2eb4410e605a5029a7353d74e17197a8e0d"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="15.0.0"
		gitlab_arm_buster_source_sha256="4c9ed80c3c1d0aa067cec9470c09d2eb4410e605a5029a7353d74e17197a8e0d"
	fi
	gitlab_source_sha256=$gitlab_arm_buster_source_sha256
fi

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	ynh_backup_if_checksum_is_different --file="$config_path/gitlab.rb"
	cat <<EOF >> "$config_path/gitlab.rb"
# Last chance to fix Gitlab
package['modify_kernel_parameters'] = false
EOF
	ynh_store_file_checksum --file="$config_path/gitlab.rb"
}
