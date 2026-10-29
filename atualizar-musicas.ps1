$pasta = Split-Path -Parent $MyInvocation.MyCommand.Path
$audios = Get-ChildItem -Path (Join-Path $pasta 'musicas') -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '^\.(mp3|m4a|wav|ogg)$' } | Sort-Object Name
$lista = @()
foreach ($a in $audios) {
  $base = [IO.Path]::GetFileNameWithoutExtension($a.Name)
  $titulo = ($base -replace '[-_]+',' ').Trim()
  $capa = ''
  foreach ($ext in 'jpg','jpeg','png','webp') {
    foreach ($dir in 'capas','musicas') {
      $c = Join-Path (Join-Path $pasta $dir) ($base + '.' + $ext)
      if (Test-Path -LiteralPath $c) { $capa = $dir + '/' + [uri]::EscapeDataString($base + '.' + $ext); break }
    }
    if ($capa) { break }
  }
  $lista += [pscustomobject]@{ titulo = $titulo; audio = 'musicas/' + [uri]::EscapeDataString($a.Name); capa = $capa }
}
if ($lista.Count -eq 0) { $json = '[]' } else { $json = ConvertTo-Json -InputObject @($lista) -Compress }
Set-Content -Path (Join-Path $pasta 'musicas.js') -Value ('window.MUSICAS=' + $json + ';') -Encoding UTF8
Write-Host ('Pronto! ' + $lista.Count + ' musica(s) na lista.')
