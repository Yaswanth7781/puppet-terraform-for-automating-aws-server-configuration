
node 'uniguard-app' {

  # 1. Install required packages
  package { ['git', 'docker.io', 'nginx']:
    ensure => installed,
  }

  # 2. Create application directory
  file { '/opt/documind':
    ensure  => directory,
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0755',
    require => Package['git'],
  }

  # 3. Clone GitHub repository
  exec { 'clone-documind':
    command => '/usr/bin/git clone https://github.com/Yaswanth7781/documind-RAG-Platform.git /opt/documind',
    creates => '/opt/documind/.git',
    user    => 'ubuntu',
    require => File['/opt/documind'],
  }

  # 4. Ensure Docker is running
  service { 'docker':
    ensure  => running,
    enable  => true,
    require => Package['docker.io'],
  }

  # 5. Deploy application using Docker Compose
  exec { 'deploy-documind':
    command   => '/usr/bin/docker compose up -d --build',
    cwd       => '/opt/documind',
    path      => ['/usr/bin', '/usr/local/bin'],
    require   => [
      Exec['clone-documind'],
      Service['docker'],
    ],
    logoutput => true,
  }

  # 7. Configure Nginx reverse proxy
  file { '/etc/nginx/sites-available/default':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "server {\n    listen 80 default_server;\n    listen [::]:80 default_server;\n    server_name _;\n\n    location / {\n        proxy_pass http://127.0.0.1:5173;\n        proxy_http_version 1.1;\n        proxy_set_header Host \$host;\n        proxy_set_header Upgrade \$http_upgrade;\n        proxy_set_header Connection \"upgrade\";\n        proxy_set_header X-Real-IP \$remote_addr;\n        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n    }\n}\n",
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # 8. Ensure Nginx is running
  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }

}

