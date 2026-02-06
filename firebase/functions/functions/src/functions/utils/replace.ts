export function replaceAll(
  str: string,
  search: string,
  replace: string
): string {
  while (str.includes(search)) {
    str = str.replace(search, replace);
  }
  return str;
}

export function replaceRegExpAll(
  str: string,
  search: RegExp,
  replace: string
): string {
  while (str.match(search)) {
    str = str.replace(search, replace);
  }
  return str;
}
