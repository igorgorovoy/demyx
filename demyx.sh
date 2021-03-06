#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

die() {
	echo -e "\e[31m" 
	printf '[CRITICAL] %s\n' "$1" >&2
	echo -e "\e[39m"
	exit 1
}

source /srv/demyx/etc/.env

if [ "$1" = "stack" ]; then
	while :; do
		case $2 in
			-h|-\?|--help)
				echo
				echo "  --action        Actions: up, down, restart, logs, and other available docker-compose commands"
				echo "                  Example: demyx stack --up, demyx stack --service=traefik --action=restart"
				echo
				echo "  --down          Shorthand for docker-compose down"
				echo "                  Example: demyx stack --service=traefik --down, demyx stack --down"
				echo
				echo "  --restart       Shorthand for docker-compose restart"
				echo "                  Example: demyx stack --service=traefik --restart, demyx stack --restart"
				echo
				echo "  --up            Shorthand for docker-compose up -d"
				echo "                  Example: demyx stack --service=traefik --up, demyx stack --up"
				echo
				echo "  --service       Services: traefik, watchtower, logrotate"
				echo
				exit 1
				;;
			--action=?*)
				ACTION=${2#*=} 
				;;
			--action=)       
				die '"--action" cannot be empty.'
				;;
			-d|--down)
				DOWN=1
				ACTION=down
				;;
			-r|--restart)
				RESTART=1
				ACTION=restart
				;;
			--service=?*)
				SERVICE=${2#*=}
				;;
			--service=)         
				die '"--service" cannot be empty.'
				;;
			-u|--up)
				UP=1
				ACTION=up
				;;
			--)      
				shift
				break
				;;
			-?*)
				echo
				printf 'Unknown option: %s\n' "$2" >&2
				echo
				exit 1
				;;
			*) 
				break
		esac
		shift
	done

	cd "$ETC" || exit
	
	if [ "$ACTION" = up ] && [ -n "$SERVICE" ]; then
		docker-compose up -d "$SERVICE"
	elif [ "$ACTION" = up ] && [ -z "$SERVICE" ]; then
		docker-compose up -d
	elif [ "$ACTION" = down ] && [ -n "$SERVICE" ]; then
		docker-compose stop "$SERVICE" && docker-compose rm -f "$SERVICE"
	elif [ "$ACTION" = down ] && [ -z "$SERVICE" ]; then
		docker-compose stop && docker-compose rm -f
	elif [ -n "$ACTION" ] && [ -z "$SERVICE" ]; then
		docker-compose $ACTION
	elif [ -n "$ACTION" ] && [ -n "$SERVICE" ]; then
		docker-compose $ACTION "$SERVICE"
	fi

elif [ "$1" = "wp" ]; then
	while :; do
		case $2 in
			-h|-\?|--help)
				echo
				echo "  --action        Actions: up, down, restart, logs, and other available docker-compose commands"
				echo "                  Example: demyx wp --dom=domain.tld --service=wp --action=up"
				echo
				echo "  --all           Selects all sites with some flags"
				echo "                  Example: demyx wp --backup --all"
				echo
				echo "  --backup        Backs up a site to /srv/demyx/backup"
				echo "                  Example: demyx wp --backup=domain.tld, demyx wp --dom=domain.tld --backup"
				echo
				echo "  --cli           Run commands to containers: wp, db"
				echo "                  Example: demyx wp --dom=domain.tld --cli'ls -al'"
				echo
				echo "  --clone         Clones a site"
				echo "                  Example: demyx wp --dom=new-domain.tld --clone=old-domain.tld --ssl"
				echo
				echo "  --dom, --domain Primary flag to target your sites"
				echo "                  Example: demyx wp --dom=domain.tld --flag"
				echo
				echo "  --dev           Editing files from host to container will reflect on page reload"
				echo "                  Example: demyx wp --dom=domain.tld --dev, demyx wp --dom=domain.tld --dev=off"
				echo
				echo "  --down          Shorthand for docker-compose down"
				echo "                  Example: demyx wp --down=domain.tld, demyx wp --dom=domain.tld --down"
				echo
				echo "  --du            Get a site's directory total size"
				echo "                  Example: demyx wp --down=domain.tld --du, demyx wp --down=domain.tld --du=wp, demyx wp --down=domain.tld --du=db"
				echo
				echo "  --env           Shows all environment variables for a given site"
				echo "                  Example: demyx wp --env=domain.tld, demyx wp --dom=domain.tld --env"
				echo
				echo "  --force         Force an override, only applies to --refresh for now"
				echo "                  Example: demyx wp --refresh --all --force, demyx wp --dom=domain.tld --refresh --force"
				echo
				echo "  --import        Import a non demyx stack WordPress site, must be in a specific format"
				echo "                  - Directory must be named domain.tld"
				echo "                  - Archive must be in /srv/demyx/backup named domain.tld.tgz"
				echo "                  - Database that will be imported must be named import.sql"
				echo "                  Example: demyx wp --dom=domain.tld --import"
				echo
				echo "  --list          List all WordPress sites"
				echo "                  Example: demyx wp --list"
				echo
				echo "  --monitor       Cron flag for auto scaling containers"
				echo
				echo "  --no-restart    Prevents a container from restarting when used with some flags"
				echo "                  Example: demyx wp --dom=domain.tld --run --dev --no-restart"
				echo 
				echo "  --pma           Enable phpmyadmin: pma.primary-domain.tld"
				echo "                  Example: demyx wp --dom=domain.tld --pma, demyx wp --dom=domain.tld --pma=off"
				echo
				echo "  --refresh       Regenerate all config files for a site; use with caution"
				echo "                  Example: demyx wp --refresh=domain.tld --ssl, demyx wp --dom=domain.tld --refresh --ssl"
				echo
				echo "  --remove        Removes a site"
				echo "                  Example: demyx wp --rm=domain.tld, demyx wp --dom=domain.tld --rm, demyx wp --rm --all"
				echo
				echo "  --restart       Shorthand for docker-compose restart"
				echo "                  Example: demyx wp --restart=domain.tld, demyx wp --dom=domain.tld --restart"
				echo
				echo "  --restore       Restore a site's backup"
				echo "                  Example: demyx wp --restore=domain.tld, demyx wp --dom=domain.tld --restore"
				echo
				echo "  --run           Create a new site"
				echo "                  Example: demyx wp --run=domain.tld --ssl, demyx wp --dom=domain.tld --run --ssl"
				echo
				echo "  --scale         Scale a site's container"
				echo "                  Example: demyx wp --dom=domain.tld --scale=3, demyx wp --dom=domain.tld --service=wp --scale=3"
				echo
				echo "  --shell         Shell into a site's wp/db container"
				echo "                  Example: demyx wp --dom=domain.tld --shell, demyx wp --dom=domain.tld --shell=db"
				echo
				echo "  --ssl           Enables SSL for your domain, provided by Lets Encrypt"
				echo "                  Example: demyx wp --dom=domain.tld --ssl, demyx wp --dom=domain.tld --ssl=off"
				echo
				echo "  --up            Shorthand for docker-compose up -d"
				echo "                  Example: demyx wp --up=domain.tld, demyx wp --dom=domain.tld --up"
				echo 
				echo "  --wpcli         Send wp-cli commands to a site"
				echo "                  Example: demyx wp --dom=domain.tld --wpcli='user list' --all"
				echo 
				exit 1
				;;
			--action=?*)
				ACTION=${2#*=}
				;;
			--action=)       
				die '"--action" cannot be empty.'
				;;
			--all)
				ALL=1
				;;
			--backup)
				BACKUP=1
				;;
			--backup=?*)
				DOMAIN=${2#*=}
				BACKUP=1
				;;
			--backup=)         
				die '"--backup" cannot be empty.'
				;;
			--cli=?*)
				CLI=${2#*=}
				;;
			--cli=)
				die '"--cli" cannot be empty.'
				;;
			--clone=?*)
				CLONE=${2#*=}
				;;
			--clone=)
				die '"--clone" cannot be empty.'
				;;
			--dev)
				DEV=on
				;;
			--dev=?*)
				DEV=${2#*=}
				;;
			--dev=)         
				die '"--dev" cannot be empty.'
				;;
			--dom=?*|--domain=?*)
				DOMAIN=${2#*=}
				;;
			--dom=|--domain=)         
				die '"--domain" cannot be empty.'
				;;
			--down)
				ACTION=down
				;;
			--down=?*)
				DOMAIN=${2#*=}
				ACTION=down
				;;
			--du)
				DU=1
				;;
			--du=?*)
				DU=${2#*=}
				;;
			--du=)         
				die '"--du" cannot be empty.'
				;;
			--env)
				ENV=1
				;;
			--env=?*)
				DOMAIN=${2#*=}
				ENV=1
				;;
			-f|--force)
				FORCE=1
				;;
			--import)
				IMPORT=1
				;;
			--list)
				LIST=1
				;;
			--monitor)
				MONITOR=1
				;;
			--no-restart)
				NO_RESTART=1
				;;
			--pma|--pma=on)
				PMA=on
				;;
			--pma=off)
				PMA=off
				;;
			--pma=)         
				die '"--pma" cannot be empty.'
				;;
			--refresh)
				REFRESH=1
				;;
			--refresh=?*)
				DOMAIN=${2#*=}
				REFRESH=${2#*=}
				;;
			--refresh=)         
				die '"--refresh" cannot be empty.'
				;;
			--rm|--remove)
				REMOVE=1
				;;
			--rm=?*|--remove=?*)
				REMOVE=1
				DOMAIN=${2#*=}
				;;
			--rm=|--remove=)         
				die '"--rm" cannot be empty.'
				;;
			--restart)
				RESTART=1
				;;
			--restart=?*)
				DOMAIN=${2#*=}
				RESTART=${2#*=}
				;;
			--restart=)         
				die '"--restart" cannot be empty.'
				;;
			--restore)
				RESTORE=1
				;;
			--restore=?*)
				DOMAIN=${2#*=}
				RESTORE=1
				;;
			--run)
				RUN=1
				;;
			--run=?*)
				RUN=1
				DOMAIN=${2#*=}
				;;
			--run=)         
				die '"--run" cannot be empty.'
				;;
			--scale=?*)
				SCALE=${2#*=}
				;;
			--scale=)         
				die '"--scale" cannot be empty.'
				;;
			--service=?*)
				SERVICE=${2#*=}
				;;
			--service=)         
				die '"--service" cannot be empty.'
				;;
			--shell=?*)
				DEMYX_SHELL=${2#*=}
				;;
			--shell|--shell=)
				if [ -z "$DEMYX_SHELL" ]; then
					DEMYX_SHELL="wp"
				fi
				;;
			--ssl|--ssl=on)
				SSL=on
				;;
			--ssl=off)
				SSL=off
				;;
			--ssl=)       
				die '"--ssl" cannot be empty.'
				;;
			--up)
				ACTION=up
				;;
			--up=?*)
				DOMAIN=${2#*=}
				ACTION=up
				;;
			--wpcli=?*)
				WPCLI=${2#*=}
				;;
			--wpcli=)       
				die '"--wpcli" cannot be empty.'
				;;
			--)      
				shift
				break
				;;
			-?*)
				echo -e "\e[31m"
				printf 'Unknown option: %s\n' "$2" >&2
				echo -e "\e[39m"
				exit 1
				;;
			*) 
				break
		esac
		shift
	done
	
	WP_ID=$(uuidgen | awk -F '[-]' '{print $1}')
	CONTAINER_PATH=$APPS/$DOMAIN
	CONTAINER_NAME=${DOMAIN//./_}
	WP=${DOMAIN//./}_wp_${WP_ID}_1
	DB=${DOMAIN//./}_db_${WP_ID}_1

	if [ -n "$ACTION" ]; then
		[[ ! -d $CONTAINER_PATH ]] && die "Domain doesn't exist"

		if [ -z "$ALL" ] && [ -n "$DOMAIN" ]; then
			cd "$CONTAINER_PATH" && source .env
		fi

		if [ "$ACTION" = up ] && [ -n "$SERVICE" ] && [ -n "$DOMAIN" ]; then
			docker-compose up -d "${CONTAINER_NAME}"_"$SERVICE"
		elif [ "$ACTION" = up ] && [ -z "$ALL" ] && [ -n "$DOMAIN" ]; then
			docker-compose up -d
		elif [ "$ACTION" = up ] && [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				[[ -f $APPS/$i/data/wp-config.php ]] && cd "$APPS"/"$i" && docker-compose up -d
			done
		elif [ "$ACTION" = down ] && [ -z "$ALL" ] && [ -n "$DOMAIN" ]; then
			docker-compose stop && docker-compose rm -f
		elif [ "$ACTION" = down ] && [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				[[ -f $APPS/$i/data/wp-config.php ]] && cd "$APPS"/"$i" && docker-compose stop && docker-compose rm -f || echo -e "\e[33m[WARNING] Skipping $i\e[39m"
			done
		elif [ -n "$ACTION" ] && [ -z "$SERVICE" ] && [ -n "$DOMAIN" ]; then
			docker-compose $ACTION
		elif [ -n "$ACTION" ] && [ -n "$SERVICE" ] && [ -n "$DOMAIN" ]; then
			if [ "$SERVICE" = "wp" ]; then
				docker-compose $ACTION wp_"${WP_ID}"
			else
				docker-compose $ACTION db_"${WP_ID}"
			fi
		else
			echo
			echo -e "\e[31m[CRITICAL] No --domain or --action\e[39m"
			echo
			echo -e "\e[34m[INFO] Try passing --all or demyx wp -h for a list of commands\e[39m"
			echo
		fi
	elif [ -n "$BACKUP" ]; then
		cd "$APPS" || exit
		if [ -n "$ALL" ]; then
			for i in *
			do
				if [ -f "$i"/data/wp-config.php ]; then
					echo -e "\e[34m[INFO] Backing up $i\e[39m"
					sudo tar -czf "$i".tgz "$i"
					mv "$i".tgz "$APPS_BACKUP"
				else
					echo -e "\e[33m[WARNING] Skipping $i\e[39m"
				fi
			done
			sudo chown -R "${USER}":"${USER}" "$APPS_BACKUP"
		else
			echo -e "\e[34m[INFO] Backing up $DOMAIN\e[39m"
			sudo tar -czvf "$DOMAIN".tgz "$DOMAIN"
			mv "$DOMAIN".tgz "$APPS_BACKUP"
			sudo chown -R "${USER}":"${USER}" "$APPS_BACKUP"
		fi
	elif [ -n "$CLI" ]; then
		cd "$CONTAINER_PATH" || exit
		source .env
		if [ "$SERVICE" = db ]; then
			docker-compose exec db_"${WP_ID}" $CLI
		else
			docker-compose exec wp_"${WP_ID}" $CLI
		fi
	elif [ -n "$CLONE" ]; then
		[[ -d $CONTAINER_PATH ]] && demyx wp --rm="$DOMAIN"

		echo -e "\e[34m[INFO] Cloning $CLONE to $DOMAIN\e[39m"

		mkdir -p "$CONTAINER_PATH"/conf
		bash "$ETC"/functions/env.sh "$WP_ID" "$DOMAIN" "$CONTAINER_PATH" "$CONTAINER_NAME" "$WP" "$DB"
		bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$SSL"
		bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN"
		bash "$ETC"/functions/php.sh "$CONTAINER_PATH"
		bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN"
		bash "$ETC"/functions/logs.sh "$DOMAIN"

		source "$CONTAINER_PATH"/.env

		demyx wp --dom="$CLONE" --wpcli="db export clone.sql --exclude_tables=wp_users,wp_usermeta"
		sudo cp -R "$APPS"/"$CLONE"/data "$CONTAINER_PATH"
		sudo rm "$CONTAINER_PATH"/data/wp-config.php
		sudo chown -R "${USER}":"${USER}" "$CONTAINER_PATH"
		rm -rf "$CONTAINER_PATH"/db
		sudo rm "$APPS"/"$CLONE"/data/clone.sql

		demyx wp --up="$DOMAIN"
		
		sleep 10

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli config create \
		--dbhost="$WORDPRESS_DB_HOST" \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$WORDPRESS_DB_PASSWORD"

		sleep 10

		sudo sed -i "s/$table_prefix = 'wp_';/$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g" "$CONTAINER_PATH"/data/wp-config.php

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli core install \
		--url="$DOMAIN" --title="$DOMAIN" \
		--admin_user="$WORDPRESS_USER" \
		--admin_password="$WORDPRESS_USER_PASSWORD" \
		--admin_email=info@"$DOMAIN" \
		--skip-email

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli db import clone.sql

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli search-replace "$CLONE" "$DOMAIN"

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli config shuffle-salts

		sudo rm "$CONTAINER_PATH"/data/clone.sql

		[[ -n "$DEV" ]] && demyx wp --dom="$DOMAIN" --dev

		echo
		echo "$DOMAIN/wp-admin"
		echo "Username: $WORDPRESS_USER"
		echo "Password: $WORDPRESS_USER_PASSWORD"
		echo
	elif [ -n "$DEV" ] && [ -z "$RUN" ] && [ -z "$CLONE" ]; then
		if [ "$DEV" = on ]; then
			DEV_MODE_CHECK=$(grep -r "sendfile off" /srv/demyx/apps/$DOMAIN/conf/nginx.conf)
			[[ -n "$DEV_MODE_CHECK" ]] && die "Development mode is already turned on for $DOMAIN"

			echo -e "\e[34m[INFO] Turning on development mode for $DOMAIN\e[39m"
			sed -i 's/sendfile on;/sendfile off;/g' "$CONTAINER_PATH"/conf/nginx.conf
			demyx wp --dom="$DOMAIN" --cli='mv /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini /'
			[[ -z "$NO_RESTART" ]] && demyx wp --dom="$DOMAIN" --service=wp --action=restart
		elif [ "$DEV" = off ]; then
			DEV_MODE_CHECK=$(grep -r "sendfile on" /srv/demyx/apps/$DOMAIN/conf/nginx.conf)
			[[ -n "$DEV_MODE_CHECK" ]] && die "Development mode is already turned off for $DOMAIN"

			echo -e "\e[34m[INFO] Turning off development mode for $DOMAIN\e[39m"
			sed -i 's/sendfile off;/sendfile on;/g' "$CONTAINER_PATH"/conf/nginx.conf
			demyx wp --dom="$DOMAIN" --cli='mv /docker-php-ext-opcache.ini /usr/local/etc/php/conf.d'
			[[ -z "$NO_RESTART" ]] && demyx wp --dom="$DOMAIN" --service=wp --action=restart
		elif [ "$DEV" = check ] && [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				[[ -f "$i"/data/wp-config.php ]] && bash "$ETC"/functions/warnings.sh "$i"
			done
		elif [ "$DEV" = check ] && [ -n "$DOMAIN" ]; then
			[[ -f "$CONTAINER_PATH"/data/wp-config.php ]] && bash "$ETC"/functions/warnings.sh "$DOMAIN"
		else
			die "--dev=$DEV not found"
		fi
	elif [ -n "$DU" ]; then
		if [ "$DU" = wp ]; then
			du -sh "$CONTAINER_PATH"/data
		elif [ "$DU" = db ]; then
			du -sh "$CONTAINER_PATH"/db
		else
			du -sh "$CONTAINER_PATH"
		fi
	elif [ -n "$ENV" ]; then
		echo
		cat "$CONTAINER_PATH"/.env
		echo
	elif [ -n "$LIST" ]; then
		cd "$APPS" || exit
		for i in *
		do
			[[ ! -f "$APPS"/"$i"/data/wp-config.php ]] && continue
			echo "$i"
		done
	elif [ -n "$IMPORT" ]; then
		[[ ! -f $APPS_BACKUP/$DOMAIN.tgz ]] && die "$APPS_BACKUP/$DOMAIN.tgz doesn't exist"
		cd "$APPS_BACKUP" || exit
		tar -xzf "$DOMAIN".tgz
		[[ ! -d $APPS_BACKUP/$DOMAIN ]] && die "$APPS_BACKUP/$DOMAIN doesn't exist"
		[[ ! -f $APPS_BACKUP/$DOMAIN/import.sql ]] && die "$APPS_BACKUP/$DOMAIN/import.sql doesn't exist"
		[[ -d $CONTAINER_PATH ]] && demyx wp --rm="$DOMAIN"

		echo -e "\e[34m[INFO] Importing $DOMAIN\e[39m"

		mkdir -p "$CONTAINER_PATH"/conf
		bash "$ETC"/functions/env.sh "$WP_ID" "$DOMAIN" "$CONTAINER_PATH" "$CONTAINER_NAME" "$WP" "$DB"
		bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$SSL"
		bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN"
		bash "$ETC"/functions/php.sh "$CONTAINER_PATH"
		bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN"
		bash "$ETC"/functions/logs.sh "$DOMAIN"

		source "$CONTAINER_PATH"/.env

		mv "$DOMAIN" "$CONTAINER_PATH"/data
		rm "$CONTAINER_PATH"/data/wp-config.php
		sudo chown -R "$USER":"$USER" "$CONTAINER_PATH"

		demyx wp --up="$DOMAIN"
		
		sleep 10

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli config create \
		--dbhost="$WORDPRESS_DB_HOST" \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$WORDPRESS_DB_PASSWORD"

		sleep 5

		sudo sed -i "s/$table_prefix = 'wp_';/$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g" "$CONTAINER_PATH"/data/wp-config.php

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli core install \
		--url="$DOMAIN" --title="$DOMAIN" \
		--admin_user="$WORDPRESS_USER" \
		--admin_password="$WORDPRESS_USER_PASSWORD" \
		--admin_email=info@"$DOMAIN" \
		--skip-email

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli db reset --yes

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli db import import.sql

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli config shuffle-salts

		sudo rm "$CONTAINER_PATH"/data/import.sql

		echo
		echo "$DOMAIN/wp-admin"
		echo
	elif [ -n "$MONITOR" ]; then
		MONITOR_STATS=$(docker stats --no-stream)
		cd "$APPS" || exit
		for i in *
		do
			[[ ! -f "$APPS"/"$i"/data/wp-config.php ]] && continue
			source "$APPS"/"$i"/.env
			if [ ! -f "$APPS"/"$i"/.monitor ]; then
				echo "MONITOR_COUNT=0" > "$APPS"/"$i"/.monitor 
			else
				source "$APPS"/"$i"/.monitor
			fi

			MONITOR_CHECK=$(echo "$MONITOR_STATS" | grep "$WP" | awk '{print $3}' | awk -F '[.]' '{print $1}')

			if (( "$MONITOR_CHECK" >= "$MONITOR_CPU" )); then
				if [[ "$MONITOR_COUNT" != "$MONITOR_THRESHOLD" ]]; then
					MONITOR_COUNT_UP=$((MONITOR_COUNT+1))
					echo "MONITOR_COUNT=${MONITOR_COUNT_UP}" > "$APPS"/"$i"/.monitor
				else
					if [[ "$MONITOR_COUNT" = 3 ]]; then
						cd "$APPS"/"$i" || exit
						/usr/local/bin/docker-compose up -d --scale wp_"${WP_ID}"="${MONITOR_SCALE}" wp_"${WP_ID}"
						/usr/local/bin/docker-compose up -d --scale db_"${WP_ID}"="${MONITOR_SCALE}" db_"${WP_ID}"
						[[ -f "$DEMYX"/custom/callback.sh ]] && bash "$DEMYX"/custom/callback.sh "monitor" "$i" "$MONITOR_CHECK"
					fi
				fi
			elif (( "$MONITOR_CHECK" <= "$MONITOR_CPU" )); then
				if (( "$MONITOR_COUNT" > 0 )); then
					MONITOR_COUNT_DOWN=$((MONITOR_COUNT-1))
					echo "MONITOR_COUNT=${MONITOR_COUNT_DOWN}" > "$APPS"/"$i"/.monitor
				else
					if [[ "$MONITOR_COUNT" = 0 ]]; then
						cd "$APPS"/"$i" || exit
						/usr/local/bin/docker-compose up -d --scale wp_"${WP_ID}"=1 wp_"${WP_ID}"
						/usr/local/bin/docker-compose up -d --scale db_"${WP_ID}"=1 db_"${WP_ID}"
					fi
				fi
			fi
		done
	elif [ -n "$PMA" ]; then
		PMA_EXIST=$(docker ps -aq -f name=phpmyadmin)
		if [ "$PMA" = "on" ]; then
			[[ -n "$PMA_EXIST" ]] && docker stop phpmyadmin && docker rm phpmyadmin
			
			source "$CONTAINER_PATH"/.env

			docker run -d \
			--name phpmyadmin \
			--network traefik \
			--restart unless-stopped \
			-e PMA_HOST="${DB}" \
			-e MYSQL_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD}" \
			-l "traefik.enable=1" \
			-l "traefik.frontend.rule=Host:pma.${PRIMARY_DOMAIN}" \
			-l "traefik.port=80" \
			-l "traefik.frontend.redirect.entryPoint=https" \
			-l "traefik.frontend.headers.forceSTSHeader=${FORCE_STS_HEADER}" \
			-l "traefik.frontend.headers.STSSeconds=${STS_SECONDS}" \
			-l "traefik.frontend.headers.STSIncludeSubdomains=${STS_INCLUDE_SUBDOMAINS}" \
			-l "traefik.frontend.headers.STSPreload=${STS_PRELOAD}" \
			phpmyadmin/phpmyadmin

			echo
			echo "phpMyAdmin: pma.$PRIMARY_DOMAIN"
			echo "Username: $WORDPRESS_DB_USER"
			echo "Password: $WORDPRESS_DB_PASSWORD"
			echo 
		else
			docker stop phpmyadmin && docker rm phpmyadmin
		fi
	elif [ -n "$REFRESH" ]; then
		if [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				if [ -f "$i"/data/wp-config.php ]; then 
					echo -e "\e[34m[INFO] Refreshing $i\e[39m"
					DOMAIN=$i
					CONTAINER_PATH=$APPS/$DOMAIN
					CONTAINER_NAME=${DOMAIN//./_}
					bash "$ETC"/functions/env.sh "$WP_ID" "$DOMAIN" "$CONTAINER_PATH" "$CONTAINER_NAME" "$WP" "$DB" "$FORCE"
					bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
					bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
					bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
					bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
					bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"
					[[ -z "$NO_RESTART" ]] && demyx wp --dom="$i" --up
				fi
			done
		else
			[[ -z "$DOMAIN" ]] && die 'Domain is missing or add --all'
			echo -e "\e[34m[INFO] Refreshing $DOMAIN\e[39m"
			bash "$ETC"/functions/env.sh "$WP_ID" "$DOMAIN" "$CONTAINER_PATH" "$CONTAINER_NAME" "$WP" "$DB" "$FORCE"
			bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
			bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
			bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
			bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
			bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"
			[[ -z "$NO_RESTART" ]] && demyx wp --dom="$DOMAIN" --up
		fi
	elif [ -n "$RESTART" ]; then
		cd "$APPS" || exit
		if [ -n "$ALL" ]; then
			for i in *
			do
				[[ -f $APPS/$i/data/wp-config.php ]] && cd "$APPS"/"$i" && docker-compose restart || echo -e "\e[33m[WARNING] Skipping $i\e[39m"
			done
		else
			[[ -z "$DOMAIN" ]] && die 'Domain is missing, use --dom or --restart=domain.tld'
			cd "$APPS"/"$DOMAIN" && docker-compose restart
		fi
	elif [ -n "$RESTORE" ]; then
		[[ ! -f $APPS_BACKUP/$DOMAIN.tgz ]] && die "No backups found for $DOMAIN"
		echo -e "\e[34m[INFO] Restoring $DOMAIN\e[39m"
		cd "$APPS_BACKUP" || exit
		sudo tar -xzf "$DOMAIN".tgz
		[ -d "$CONTAINER_PATH" ] && sudo rm -rf "$CONTAINER_PATH"
		mv "$DOMAIN" "$APPS"
		sudo chown -R "${USER}":"${USER}" "$CONTAINER_PATH"
		bash "$ETC"/functions/logs.sh "$DOMAIN"
		demyx wp --dom="$DOMAIN" --up
	elif [ -n "$REMOVE" ]; then
		echo -e "\e[33m"
		if [ -z "$DOMAIN" ]; then
			read -rep "[WARNING] Delete all sites? [yY]: " DELETE_SITE
		else
			read -rep "[WARNING] Delete/overwrite $DOMAIN? [yY]: " DELETE_SITE
		fi
		echo -e "\e[39m"
		[[ "$DELETE_SITE" != [yY] ]] && die 'Cancel removal of site(s)'
		if [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				echo -e "\e[31m[CRITICAL] Removing $i\e[39m"
				[[ -f $APPS/$i/docker-compose.yml ]] && cd "$APPS"/"$i" && docker-compose stop && docker-compose rm -f
				cd .. && rm -rf "$i"
				rm "$LOGS"/"$i"*.log
			done
		else
			[[ ! -d $CONTAINER_PATH ]] && die "Domain doesn't exist"
			echo -e "\e[31m[CRITICAL] Removing $DOMAIN\e[39m"
			[[ -f $CONTAINER_PATH/docker-compose.yml ]] && cd "$CONTAINER_PATH" && docker-compose stop && docker-compose rm -f
			[[ -f $LOGS/$DOMAIN.access.log ]] && rm "$LOGS"/"$DOMAIN".access.log && rm "$LOGS"/"$DOMAIN".error.log
			cd .. && sudo rm -rf "$CONTAINER_PATH"
		fi
	elif [ -n "$RUN" ]; then
		set -e
		[[ -d $CONTAINER_PATH ]] && demyx wp --rm="$DOMAIN"
		echo -e "\e[34m[INFO] Creating $DOMAIN\e[39m"

		mkdir -p "$CONTAINER_PATH"/conf

		# Future plans for subnets
		#bash $ETC/functions/subnet.sh $DOMAIN $CONTAINER_NAME create
		bash "$ETC"/functions/env.sh "$WP_ID" "$DOMAIN" "$CONTAINER_PATH" "$CONTAINER_NAME" "$WP" "$DB" "$FORCE"
		bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
		bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
		bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
		bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
		bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"

		cd "$CONTAINER_PATH" || exit
		docker-compose up -d

		sleep 10
		source "$CONTAINER_PATH"/.env

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli core install \
		--url="$DOMAIN" --title="$DOMAIN" \
		--admin_user="$WORDPRESS_USER" \
		--admin_password="$WORDPRESS_USER_PASSWORD" \
		--admin_email=info@"$DOMAIN" \
		--skip-email

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli rewrite structure '/%category%/%postname%/'

		[[ -n "$DEV" ]] && demyx wp --dom="$DOMAIN" --dev

		echo
		echo "$DOMAIN/wp-admin"
		echo "Username: $WORDPRESS_USER"
		echo "Password: $WORDPRESS_USER_PASSWORD"
		echo
	elif [ -n "$DEMYX_SHELL" ]; then
		source "$CONTAINER_PATH"/.env
		if [ "$DEMYX_SHELL" = "wp" ]; then
			docker exec -it "$WP" bash
		else
			docker exec -it "$DB" sh
		fi
	elif [ -n "$SCALE" ]; then
		cd "$CONTAINER_PATH" || exit
		source .env
		[[ -z "$SERVICE" ]] && echo -e "\e[33m[WARNING] --service is missing, targeting all services...\e[39m"
		if [ "$SERVICE" = wp ]; then
			docker-compose up -d --scale wp_"${WP_ID}"="$SCALE" wp_"${WP_ID}"
		elif [ "$SERVICE" = db ]; then
			docker-compose up -d --scale db_"${WP_ID}"="$SCALE" db_"${WP_ID}"
		else
			docker-compose up -d --scale wp_"${WP_ID}"="$SCALE" wp_"${WP_ID}"
			docker-compose up -d --scale db_"${WP_ID}"="$SCALE" db_"${WP_ID}"
		fi
	elif [ -n "$SSL" ]; then
		bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
		demyx wp --dom="$DOMAIN" --up
	elif [ -n "$UPDATE" ]; then
		echo "COMING SOON"
	elif [ -n "$WPCLI" ]; then
		if [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				if [ -f "$i"/data/wp-config.php ]; then
					source "$APPS"/"$i"/.env
					docker run -it --rm \
					--volumes-from "$WP" \
					--network container:"$WP" \
					wordpress:cli $WPCLI
				else
					echo -e "\e[33m[WARNING] Skipping $i\e[39m"
				fi
			done
		else
			source "$CONTAINER_PATH"/.env
			docker run -it --rm \
			--volumes-from "$WP" \
			--network container:"$WP" \
			wordpress:cli $WPCLI
		fi
	fi
else
	[[ -z "$1" ]] && echo && echo -e "\e[34m[INFO] See commands for help: demyx -h, demyx stack -h, demyx wp -h\e[39m" && echo
	while :; do
		case $1 in
			-h|-\?|--help)
				echo 
				echo "  If you modified any of the files (.conf/.ini/.yml/etc) then delete the first comment at the top of the file(s)"
				echo
				echo "  -df              Wrapper for docker system df"
				echo "                   Example: demyx -df"
				echo
				echo "  --dom            Flag needed to run other Docker images"
				echo "                   Example: demyx --dom=domain.tld --install=gitea"
				echo 
				echo "  --email          Flag needed for Rocket.Chat"
				echo "                   Example: demyx --dom=domain.tld --email=info@domain.tld --install=rocketchat"
				echo 
				echo "  -f, --force      Forces an update"
				echo "                   Example: demyx --force --update, demyx -f -u"
				echo
				echo "  --install        Install Rocket.Chat and Gitea"
				echo
				echo "  -p, --prune      Wrapper for docker system prune && docker volume prune"
				echo "                   Example: demyx -p, demyx --prune"
				echo
				echo "  -t, --top        Runs ctop (htop for containers)"
				echo "                   Example: demyx -t, demyx --top"
				echo
				exit 1
				;;
			--dom=?*)
				DOMAIN=${1#*=}
				;;
			--dom=)         
				die '"--domain" cannot be empty.'
				;;
			--email=?*)
				EMAIL=${1#*=}
				;;
			--email=)         
				die '"--email" cannot be empty.'
				;;
			-f|--force)
				FORCE=1
				;;
			--install=?*)
				INSTALL=${1#*=}
				;;
			--install=)         
				die '"--install" cannot be empty.'
				;;
			-p|--prune)       
				docker system prune -f
				docker volume prune -f
				;;
			-df)       
				docker system df
				;;
			-t|--top)
				CTOP_CHECK=$(docker ps | grep ctop | awk '{print $1}')
				[[ -n "$CTOP_CHECK" ]] && docker stop "$CTOP_CHECK"
				docker run --rm -ti -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop
				;;
			-u|--update)
				# Cron check
				CRON_WP_CHECK=$(crontab -l | grep "cron event run --due-now")
				CRON_MONITOR_CHECK=$(crontab -l | grep "demyx wp --monitor")

				if [ -z "$CRON_WP_CHECK" ]; then
					# WP Cron every 2 hours
					echo -e "\e[34m[INFO] Demyx cron not found, installing now to crontabs \e[39m"
					crontab -l > "$ETC"/CRON_WP_CHECK
					echo "0 */2 * * * /usr/local/bin/demyx wp --all --wpcli='cron event run --due-now'" >> "$ETC"/CRON_WP_CHECK
					crontab "$ETC"/CRON_WP_CHECK
					rm "$ETC"/CRON_WP_CHECK
				fi

				if [ -z "$CRON_MONITOR_CHECK" ]; then
					# WP Cron every minute
					echo -e "\e[34m[INFO] Auto scaling cron not found, installing now to crontabs \e[39m"
					crontab -l > "$ETC"/CRON_MONITOR_CHECK
					echo "* * * * * /usr/local/bin/demyx wp --monitor" >> "$ETC"/CRON_MONITOR_CHECK
					crontab "$ETC"/CRON_MONITOR_CHECK
					rm "$ETC"/CRON_MONITOR_CHECK
					demyx wp --refresh --all
				fi

				# Check for custom folder where users can place custom shell scripts
				if [ ! -d "$DEMYX"/custom ]; then
					mkdir "$DEMYX"/custom
					echo "#!/bin/bash
					# Demyx
					# https://github.com/demyxco/demyx
					# Feel free to edit/modify this file since it will not be updated.

					TYPE=\$1

					#if [ \"\$TYPE\" = monitor ]; then
					#DOMAIN=\$2
					#CPU=\$3
					#do code
					#fi" | tr -d '\011' > "$DEMYX"/custom/callback.sh
				fi

				if [ -f /etc/cron.daily/demyx-daily ]; then
					# Will remove this May 1st
					sudo rm /etc/cron.daily/demyx-daily
				fi

				cd "$GIT" || exit

				if [ -n "$FORCE" ]; then
					echo -e "\e[33m[WARNING] Forcing an update for Demyx...\e[39m"
				else
					echo -e "\e[34m[INFO] Checking for updates\e[39m"
				fi

				CHECK_FOR_UPDATES=$(git pull | grep "Already up to date." )

				if [ -n "$FORCE" ] || [ "$CHECK_FOR_UPDATES" != "Already up to date." ]; then
					[[ -z "$FORCE" ]] && echo -e "\e[34m[INFO] Updating Demyx...\e[39m"
					bash "$ETC"/functions/etc-env.sh
					bash "$ETC"/functions/etc-yml.sh
					rm -rf "$ETC"/functions
					cp -R "$GIT"/etc/functions "$ETC"
				else
					echo -e "\e[32m[SUCCESS] Already up to date.\e[39m"
				fi
				
				demyx wp --dev=check --all
				;;
			--)      
				shift
				break
				;;
			-?*)
				echo
				printf 'Unknown option: %s\n' "$1" >&2
				echo
				exit 1
				;;
			*) 
				break
		esac
		shift
	done

	if [ -n "$DOMAIN" ] && [ -n "$EMAIL" ] && [ "$INSTALL" = rocketchat ]; then
		mkdir -p "$APPS"/"$DOMAIN"
		bash "$ETC"/functions/rocketchat.sh "$DOMAIN" "$EMAIL" "$APPS"/"$DOMAIN"
		cd "$APPS"/"$DOMAIN" && docker-compose up -d
	elif [ -n "$DOMAIN" ] && [ "$INSTALL" = gitea ]; then
		mkdir -p "$APPS"/"$DOMAIN"
		sudo mkdir -p /app/gitea
		sudo chown -R "$USER":"$USER" /app/gitea
		printf '#!/bin/sh\nssh -p 2222 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\\"$SSH_ORIGINAL_COMMAND\\" $0 $@"' > /app/gitea/gitea
		chmod +x /app/gitea/gitea
		sudo chown -R root:root /app/gitea
		sudo adduser git --gecos GECOS
		sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key"
		sudo chown -R "$USER":"$USER" /home/git
		echo "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(cat /home/git/.ssh/id_rsa.pub)" >> /home/git/.ssh/authorized_keys
		sudo chown -R git:git /home/git
		bash "$ETC"/functions/gitea.sh "$DOMAIN" "$APPS"/"$DOMAIN"
		cd "$APPS"/"$DOMAIN" && docker-compose up -d
	fi

fi