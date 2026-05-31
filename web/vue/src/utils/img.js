export function fixImg(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return '/' + url.replace(/^\//, '')
}
