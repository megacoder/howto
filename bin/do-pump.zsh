if [[ /bin/pump ]]; then
	eval $(/bin/pump --startup)
	ZSHEXT()	{
		/bin/pump --shutdown
	}
fi
