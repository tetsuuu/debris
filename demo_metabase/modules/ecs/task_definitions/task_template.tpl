[
  {
    "name": "${container_name}",
    "image": "${image_name}:${label}",
    "cpu": 512,
    "memory": 2048,
    "essential": true,
    "network_mode": "awsvpc",
    "portMappings": [
      {
      "hostPort": 3000,
      "containerPort": 3000,
      "protocol": "tcp"
      }
    ],
    "environment": [
      { "name": "MB_DB_TYPE", "value": "${db_type}" },
      { "name": "MB_DB_DBNAME", "value": "${db_dbname}" },
      { "name": "MB_DB_PORT", "value": "${db_port}" },
      { "name": "MB_DB_USER", "value": "${db_user}" },
      { "name": "MB_DB_HOST", "value": "${db_host}" }
    ],
    "secrets": [{
      "name": "MB_DB_PASS",
      "valueFrom": "${secret_params}"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "container"
      }
    }
  }
]