class exchange {
  file { 'C:/scripts':
    ensure => 'directory',
    owner => 'Administradores',
    group => 'Administrador',
  }
  file { 'C:\scripts\exchange.ps1':
    ensure => 'file',
    source => 'puppet:///modules/so_puppet_windows/exchange.ps1',
    recurse => 'remote',
    owner => 'Administrador',
    group => 'Administradores',
  }
}
