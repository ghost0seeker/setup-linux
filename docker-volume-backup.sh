#!/bin/bash
LOG_FILE="docker_volume_backup.log"

if [ -z "$(docker compose ps -q)" ]; then
    echo "No Docker compose services found. Exiting."
    echo "ERROR: docker backup failed on $(date +%Y-%m-%d): No services running" >> "$LOG_FILE"
    exit 0
fi

volumes=($(docker compose volumes --format "{{.Name}}" 2>/dev/null))

docker compose down

for volume in "${volumes[@]}"; do    
    docker run --rm -v "$volume":/source -v "$(pwd)":/target alpine tar -cvzf /target/"$volume"_"$(date +%Y-%m-%d)".tar.gz /source
    if [ $? -eq 0 ]; then
        echo "INFO: Docker volume $volume backup done on $(date +%Y-%m-%d)" >> "$LOG_FILE"
    else
        echo "ERROR: Docker volume $volume backup failed on $(date +%Y-%m-%d): docker run alpine failed" >> "$LOG_FILE"
    fi
done

docker compose up -d