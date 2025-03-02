#!/bin/bash

gitlab_version="16.1.5"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="da5a3eac413c2c1646bdec1fceed170fb0c77f4ebb61beae16fb2d84e3d14d63"
gitlab_x86_64_buster_source_sha256="f74e92fe2ebfc31d2b04aff606876cf3881912ef10ccf440ca74c486059f41dd"

gitlab_arm64_bullseye_source_sha256="d6a660b057cf7621d6edd01458790b49582abe54d0e8b69024d37380d3d8a6ab"
gitlab_arm64_buster_source_sha256="370f54e6a14732397ecd050b3e582ee766cb43475c08da56516e77de20af1d1f"

gitlab_arm_buster_source_sha256="0ce903f3bd83ee7aa5e12649422ce42f75700167564c008fa2a57f831c42f55e"
gitlab_arm_bullseye_source_sha256="ead7cec3a747d30ca20fb251f07c42636a86a3f35eae4d5ebebc8a20f8843832"

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
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	fi
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
