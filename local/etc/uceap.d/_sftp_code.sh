function _sftp_code() {
	SFTP_PORT=`terminus connection:info --field=sftp_port`
	SFTP_USER=`terminus connection:info --field=sftp_username`
	SFTP_HOST=`terminus connection:info --field=sftp_host`

	terminus connection:set sftp -y
	rsync -e "ssh -p $SFTP_PORT -o StrictHostKeyChecking=no" -rv --checksum --delete --exclude=.git --exclude=web/sites/default/files ./ $SFTP_USER@$SFTP_HOST:code/
}
